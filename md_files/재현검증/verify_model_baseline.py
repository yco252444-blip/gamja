"""학습 데이터·모델 검증 재현 스크립트 (2026-09-21).
사용: python verify_model_baseline.py <ai-training 폴더 경로>
- 원본 build_dataset_and_train.py의 함수를 그대로 import해 데이터셋을 만든 뒤
  (1) 구간별 샘플 수 (2) 검증셋 정답 분포 (3) '2분 뒤=지금값' 기준선 MAE
  (4) 구간 단위 교차검증(한 구간 제외 후 학습) 을 출력한다.
- 모델 파일은 쓰지 않는다(읽기 전용 검증). 시크릿을 읽지 않는다.
"""
import sys, os
import numpy as np, pandas as pd

root = sys.argv[1] if len(sys.argv) > 1 else "."
sys.path.insert(0, root)
import build_dataset_and_train as b
from sklearn.ensemble import RandomForestRegressor

df = b.load_all_csv(os.path.join(root, "raw-csv"))
df = b.clean_and_sort(df)
df = b.segment_by_time_gap(df)
df = b.forward_fill_inputs(df)
df = df.dropna(subset=["air_temperature_c", "humidity_percent", "mq137_raw"])
s, fn = b.build_dataset(df)
tr, va = b.split_train_val(s)
Xt, yt = b.to_xy(tr); Xv, yv = b.to_xy(va)
i = fn.index("core_temperature_c__current")

print("samples per segment:", pd.Series([x["segment"] for x in s]).value_counts().to_dict())
print("val segments:", pd.Series([x["segment"] for x in va]).value_counts().to_dict())
print("unique core temps:", sorted(df.core_temperature_c.round(2).unique()))
for nm, X, y in [("train", Xt, yt), ("val", Xv, yv)]:
    cur = X[:, i]
    print(nm, "n", len(y), "y std %.3f" % y.std(), "y unique", sorted(set(y.round(2))),
          "persistence MAE %.4f" % np.abs(y - cur).mean())
rf = RandomForestRegressor(n_estimators=12, max_depth=4, random_state=0).fit(Xt, yt)
print("RF val MAE %.4f" % np.abs(rf.predict(Xv) - yv).mean())

X, y = b.to_xy(s)
seg = pd.Series([x["segment"] for x in s]).values
for sid in pd.Series(seg).value_counts().index[:6]:
    m = seg == sid
    if m.sum() < 10 or (~m).sum() < 20:
        continue
    r = RandomForestRegressor(n_estimators=12, max_depth=4, random_state=0).fit(X[~m], y[~m])
    print("LOSO seg", sid, "n", m.sum(),
          "RF MAE %.4f" % np.abs(r.predict(X[m]) - y[m]).mean(),
          "persistence MAE %.4f" % np.abs(y[m] - X[m][:, i]).mean())
