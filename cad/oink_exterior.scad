// Oink 외형 — 레이저 아크릴 판 케이스(L 브래킷 + M3) + 마인크래프트풍 돼지 머리 센서
// 사용자 결정(10/29) 기준. 아래부터 케이스 바닥판 → 스페이서 3 → 로드셀(5kg 막대형) → 스페이서 3 → 격자 받침판 3
// → 단열판 5 → 육묘 패드 ≈3 → 방수판 0.5 → 3L 락앤락 A (흙, 똑바로) → 3L 뚜껑 10 → 돼지 머리
// → 3L 락앤락 B (거꾸로 덮개) → 여유 top_gap 10 → 케이스 뚜껑. (방수 트레이·15mm 벽 없음)
// 케이스 높이는 위 쌓은 높이 + 여유(top_gap 10)로 자동 계산. 통에는 케이블 구멍 없음.
// → 통·뚜껑·머리 실측 후 lock3_h, lid_t, box_bot, hw/hh/hd 만 고치면 됨 (간섭·틈은 ECHO로 확인).
// 치수 근거: 250x180 = 사용자 스케치, 패드 150x220 = 상품명. 높이들은 추정(미검증). 단위 mm.
//
// view = 1  전체 조립
//        2  분해도 (스페이서·로드셀·격자판·멈춤 기둥·3L A·흙, 돼지 머리 + 거꾸로 덮은 3L B)
//        3  앞판   (TFT 마운트 자리 사각 구멍 + M3 4개)   ┐ 3~8, 14: 레이저 커팅 아크릴 (두께 acryl_t)
//        4  뒤판                                         │ 보기용으로 눕힌 상태. 가공 파일은 30~36 → cad/dxf/
//        5  왼쪽 판 (케이블 구멍 Ø10, 전장 칸 쪽, 로드셀~패드 높이)
//        6  오른쪽 판 (USB-C, 통풍)                       │
//        7  바닥판 (로드셀 접시머리 M4 2 — 접시 가공은 따로, 멈춤 기둥 M3 4)
//        8  뚜껑 (환기 슬롯, 손가락 구멍, 위 브래킷 M3)    ┘
//        9  모서리 L 브래킷 (출력, M3) → STL
//       10  돼지 머리 조립 + 심부온도 탐침
//       11  돼지 머리 몸통 (출력용, 앞면이 바닥 → 서포트 거의 없음)
//       12  돼지 뒤판 = 센서판 (H2S·CO2 구멍, XIAO·보조배터리 고정, M3 4개)
//       13  코 + 귀 2개 (따로 출력 후 본드)
//       14  (칸막이 삭제됨 10/29)
//       15  돼지 뒤판 뗀 모습 (안쪽 확인)
//       16  평면 치수도 (위에서 본 모습)
//       17  측면 치수도 (높이)
//       18  (아크릴은 안 나눔 → 이음판 없음. 판이 cut_max 넘을 때만 생김)
//       19  받침 조립 (스페이서 + 로드셀 + 격자 받침판 + 멈춤 기둥, 단열판·패드·방수판은 얇은 유령)
//       20  스페이서 2개 (출력, 3mm, 로드셀 양끝: 아래=바닥판에 접시머리 M4, 위=격자판 밑)
//       21  격자 받침판 (출력, PETG: 패드 60℃ 근처라 PLA는 물러짐. 중심 = 로드셀 중심 위)
//       22  기울기 멈춤 기둥 4개 (출력, 격자판 모서리 밑 1.5 띄움, 바닥판에 M3)
//       23  TFT 마운트 (출력: 앞판 구멍에 끼우는 턱 + 날개 M3 4 + 뒤쪽 TFT 보스 M3 4, 앞면이 바닥)
//       24  TFT 마운트 조립 모습 (앞판 일부 + 마운트 + TFT)
//       30~35  DXF용 2D 외곽: 30 앞 31 뒤 32 왼 33 오른 34 바닥 35 뚜껑
//  ※ 판이 cut_max를 넘으면 자동으로 조각냄 (아크릴 기본값에선 안 나눔). half/side 는 그때만 의미 있음

half = 0;                 // 위아래 조각: 0 = 둘 다(보기용), 1 = 아래 조각, 2 = 위 조각
side = 0;                 // 좌우 조각: 0 = 둘 다(보기용), 1 = 왼쪽, 2 = 오른쪽
view = 1;                 // [1:10]

/* [챔버 = 3L 락앤락 2개 — 실측 후 수정] */
// 3L A(흙, 똑바로) → 3L 뚜껑 → (돼지 머리) → 3L B(거꾸로 덮개)
chamber_w = 250;          // 통 윗면(테두리) 가로 (사용자 스케치)
chamber_d = 180;          // 통 윗면(테두리) 깊이 (사용자 스케치)
box_bot = [240, 170];     // 통 바닥 바깥 크기 (위가 넓은 통 가정, 추정·미검증)
lock3_h = 99;             // 3L 통 높이 (추정, 미검증)
lid_t = 10;               // 3L 뚜껑 두께 (사용자 확인 약 1cm)
ch_wall = 3;              // 통 벽 두께 (가정)
chamber_h = 2*lock3_h + lid_t;   // 통 A + 뚜껑 + 통 B
soil_h = 50;              // 3L A 흙 높이 (가정). 탐침은 이 흙 가운데까지
top_gap = 10;             // 거꾸로 놓은 3L B 위 ~ 케이스 뚜껑 여유 (10/29: 30 → 10)
// 격자판 위: 단열판 → 육묘 패드 → 방수판 → 3L A 바닥이 눌러 밀착 (셋 다 구입품, 그림에선 얇은 유령)
mat_w = 220;              // 육묘 패드 가로 (상품명 15x22cm)
mat_d = 150;              // 육묘 패드 세로
mat_t = 3;                // 패드 두께 (미검증)
ins_t = 5;                // 단열판 (코르크/폼보드, 미검증)
wp_t = 0.5;               // 방수판 (PET/PP 시트, 미검증)

/* [여유] */
side_gap  = 4;            // 양옆·뒤: 챔버와 벽 사이 빈 틈 (단열재 없음)
elec_gap = 30;            // 앞판 안쪽 ~ 챔버(통) 앞: TFT 마운트 + HX711·배선 공간 (칸막이 없음). 최소값은 ECHO
// 받침 (출력): 스페이서 2개 + 격자 받침판(벽 없음) + 기울기 멈춤 기둥 4개. 지지대 없음 (10/29 삭제, 받침 낮춤)
//   바닥판 → 아래 스페이서(한쪽 끝, 바닥판 밑에서 접시머리 M4) → 로드셀 → 위 스페이서(반대쪽 끝) → 격자판
// 격자판 중심 = 로드셀 중심 바로 위. 격자판은 아래 스페이서·벽·멈춤 기둥 어디에도 안 닿아야 무게가 전부 로드셀로 감 (틈은 ECHO)
// 재질: 격자판은 PETG (패드 60℃ 근처, PLA는 물러짐). 스페이서·기둥은 PLA도 가능하나 PETG 권장
loadcell_kg = 5;          // 로드셀 용량 kg (5kg 막대형. 10kg 교체 검토 중: 총 4.5~5.5kg 추정, 미검증)
lc_l = 80;                // 로드셀 길이 (5kg 막대형 가정, 미검증)
lc_w = 12.7;              // 로드셀 폭·높이 (미검증)
lc_bolt = 4;              // 로드셀 볼트 M 규격 (기본 M4, M5면 5. 미검증)
lc_hole_d = lc_bolt + 0.5;   // 볼트 구멍
lc_pitch = 15;            // 같은 쪽 구멍 2개 간격 (미검증)
lc_end = 7.5;             // 로드셀 끝 → 첫 구멍 중심 (미검증)
lc_sp = 3;                // 스페이서 높이 (로드셀 양끝, 폭 = 로드셀 폭)
lc_fix = 2*lc_end + lc_pitch;   // 스페이서 길이 (구멍 2개 가운데 정렬, 가운데 휨부는 비움)
stop_s = 12;              // 기울기 멈춤 기둥 단면 (네모)
stop_gap = 1.5;           // 멈춤 기둥 윗면 ~ 격자판 아랫면 (평소 안 닿음)
gp = [250, 180];          // 격자 받침판 크기 (통 바닥 250x180에 맞춤)
gp_h = 3;                 // 격자판 높이 (리브·테두리, 받침 낮추기 10/29: 6 → 3)
gp_rib = 3;               // 리브 두께
gp_rim = 5;               // 바깥 테두리 폭
gp_pitch = 40;            // 격자 간격 (약)

/* [표시창] */
display = "tft";          // ["tft", "oled"] 앞판 표시창 종류. 기본 = 3.5" TFT THL-CD08 (ILI9488 480x320, SPI, 터치)
// (선택) 0.96" I2C OLED (SSD1306, 4핀) — 흔한 모듈 값, 미검증 (실측 후 수정). TFT 값은 아래 [판]의 lcd_*
oled_pcb = [27.3, 27.8];  // 기판 가로 x 세로
oled_glass = [26, 15];    // 유리 가로 x 세로
oled_glass_top = 4.5;     // 기판 윗변 → 유리 윗변
oled_view = [22, 11];     // 보이는 영역 (유리 가운데 가정)
oled_hole = [23, 23];     // 고정 구멍 간격 (중심), Ø2
oled_hole_d = 2;
oled_t = 4;               // 두께 (헤더 핀 제외)
oled_glass_t = 1.6;       // 유리+틀 두께 = 보스 높이 (유리가 앞판 안쪽에 닿게, 미검증)
win_margin = 1;           // 앞판 구멍 = 보이는 영역 + 사방 1

/* [판 = 레이저 커팅 아크릴] */
acryl_t = 3;              // 아크릴 두께 (두께 미정, 3 or 5. 미검증) — 벽·바닥·뚜껑 모두
t   = acryl_t;            // 판 두께 (아래 계산은 전부 t 사용)
cut_max = 600;            // 레이저 가공 최대 판 크기 (미검증). 넘으면 자동 분할
// TFT 마운트 (출력, PETG/PLA): 앞판 사각 구멍에 끼우는 턱(plug) + 안쪽 날개(flange, M3 4개로 아크릴에 고정) + 뒤쪽 TFT 보스
tm_rim = 3;               // 턱: 표시창 둘레 테두리 폭
tm_fl_t = 3;              // 날개 두께
tm_fl_m = 12;             // 날개: 턱 바깥으로 더 나오는 폭 (위아래는 TFT 보스까지 덮게 자동 확장)
kerf = 0.2;               // 아크릴 구멍 ~ 턱 틈 (한쪽, 레이저 커프 고려, 미검증)
// TFT THL-CD08 — 판매처 도면 기준. 세로로 세워 장착 (가로 55 x 세로 96)
tft_pcb = [55.1, 96.18];  // 기판 가로 x 세로
tft_pcb_t = 1.6;          // 기판 두께
tft_glass_t = 2.5;        // 앞쪽 유리 두께 (추정, 미검증) = 보스 높이 → 유리가 앞판 안쪽에 닿음
tft_screen = [48.96, 73.44];   // 표시 영역 (active)
tft_win_dy = 0;           // 표시 영역 세로 위치: 기판 중심 기준 (+ = 위). 도면에 없음 → 가운데 가정, 미검증
tft_hole = [49.5, 90];    // 고정 구멍 Ø3.2 중심 간격 (가로 x 세로), 좌우 끝 ≈2.8, 위아래 끝 ≈3
tft_hdr14 = [10.99, 33.02];    // 아래 14핀 헤더: 기판 왼끝 → 시작, 길이 (핀은 뒤로)
tft_hdr4 = [24.48, 7.62];      // 위 4핀 헤더: 기판 왼끝 → 시작, 길이 (뒷면 SD 슬롯은 왼쪽 아래)
boss_d = 7;               // 표시창 고정 보스 지름 (앞판 뒷면)
lcd_from_top = 88;        // 앞판 위에서 표시창 중심까지 (기판 윗변이 좌우 이음판 아래로 오게)

/* [브래킷] */
bl  = 30;                 // 브래킷 길이
leg = 14;                 // 다리 폭
bt  = 3;                  // 브래킷 두께
m3  = 3.4;                // M3 나사 구멍

/* [돼지 머리 — 마인크래프트풍 둥근 네모] */
// 3L 뚜껑 위에 앉고 거꾸로 덮은 3L B 안에 들어가야 함 (ECHO로 확인)
// 보조배터리: 머리 크기 확정 후 머리 안 / 전장 칸 중 결정
hw = 100;                 // 머리 가로
hh = 70;                  // 머리 높이 (10/29 사용자: 90 → 70, 귀 포함 93이 3L B 안 96에 들어감)
hd = 80;                  // 머리 깊이 (앞→뒤)
h_r = 5;                  // 모서리 둥글기
h_wall = 2.4;             // 벽 두께
bp_t = 3;                 // 뒤판(센서판) 두께
// 탐침 길이 = 3L 뚜껑 윗면 → 3L A 흙 가운데 (파생 치수에서 계산). 3L 뚜껑 가운데에 탐침 구멍 (현장 가공). DS18B20 실측 후 확인
probe_hole = 6.4;         // 탐침 구멍 지름 (프로브 약 6mm 가정, 실측 후 수정)
m3_tap = 2.8;             // 기둥 나사 구멍 (M3 셀프탭)
mq_d = 24;                // MQ-136 감지부 구멍
co2_w = 24;               // CO2 센서 창
co2_h = 18;
snout = [40, 26, 10];     // 코 (따로 출력 후 본드)
ear = [26, 6, 24];        // 세모 귀: 밑변, 두께, 높이 (따로 출력 후 본드)

$fn = 48;
KFONT = "Malgun Gothic";   // 치수도 한글 글꼴

// ---------- 파생 치수 ----------
W = chamber_w + 2*side_gap + 2*t;          // 케이스 바깥 가로
D = chamber_d + side_gap + elec_gap + 2*t;  // 케이스 바깥 깊이 (칸막이 없음)
cy0 = t + elec_gap;                        // 챔버(통) 앞끝 y
lc_z0 = lc_sp;                                  // 로드셀 아랫면 (바닥판 윗면 기준)
cell_h = lc_z0 + lc_w + lc_sp;                  // 격자판 아랫면
ins_z = t + cell_h + gp_h;                      // 단열판 아랫면
pad_z = ins_z + ins_t;                          // 패드 아랫면
wp_z = pad_z + mat_t;                           // 방수판 아랫면
boxA_z = wp_z + wp_t;                           // 3L A 바닥 (방수판에 얹힘)
lock3_z = boxA_z + lock3_h + lid_t;             // 거꾸로 놓은 3L B 입구(아래끝) = 3L 뚜껑 윗면
head_z = lock3_z;                               // 돼지 머리 바닥 = 3L 뚜껑 윗면
H = (lock3_z + lock3_h - t) + top_gap;          // 벽판 높이 (바닥판 위)
soil_z = boxA_z + ch_wall;                      // 흙 = 3L A 안쪽 바닥
soil_max = lock3_h - ch_wall;                   // 흙 최대 깊이 (3L 뚜껑 밑까지)
echo(str("받침층 ", boxA_z - t, " (스페이서 ", lc_sp, " + 로드셀 ", loadcell_kg, "kg ", lc_w, " + 스페이서 ", lc_sp, " + 격자 ", gp_h, " + 단열 ", ins_t, " + 패드 ", mat_t, " + 방수 ", wp_t, ")"));
echo(str("흙 깊이: 최대 ", soil_max, " (3L A 안쪽 바닥 ~ 뚜껑) / 지금 가정 ", soil_h));
probe_tip_z = soil_z + soil_h/2;                // 탐침 끝 = 3L A 흙 가운데
probe_l = head_z - probe_tip_z;                 // 머리 밑으로 나오는 탐침 길이 (3L 뚜껑 가운데 구멍으로)
bx0 = t + side_gap + chamber_w/2;               // 받침 중심 (통 중심)
by0 = cy0 + chamber_d/2;
cable_z = t + (lc_z0 + (wp_z - t))/2;           // 왼쪽 판 케이블 구멍 높이 = 로드셀 아랫면 ~ 패드 윗면 가운데
stop_xy = [for (sx = [-1, 1], sy = [-1, 1]) [sx*(gp[0]/2 - stop_s/2), sy*(gp[1]/2 - stop_s/2)]];   // 멈춤 기둥 중심 (격자판 모서리 밑)
stop_h = cell_h - stop_gap;                     // 멈춤 기둥 높이
lc_mid_below = lc_z0;                           // 로드셀 가운데 밑 여유 (바닥판 윗면까지)
lc_mid_above = cell_h - (lc_z0 + lc_w);         // 로드셀 가운데 위 여유 (격자판 아랫면까지)
echo(str("로드셀 ", loadcell_kg, "kg 가운데 여유: 위 ", lc_mid_above, ", 아래 ", lc_mid_below, " / 멈춤 기둥 틈 ", stop_gap, " (기둥 높이 ", stop_h, ")"));
if (min(lc_mid_above, lc_mid_below) < 3) echo("※ 로드셀 가운데 여유 3 미만");
gp_gap_x = (W - 2*t - gp[0])/2;                 // 격자판 ~ 옆판
gp_gap_f = (by0 - gp[1]/2) - t;                 // 격자판 ~ 앞판
gp_gap_b = (D - t) - (by0 + gp[1]/2);           // 격자판 ~ 뒤판
gp_gap_post = cell_h - lc_sp;                   // 격자판 아랫면 ~ 아래 스페이서 윗면 (= 로드셀 높이 + 위 스페이서)
gp_gap_lc = lc_sp;                              // 격자판 아랫면 ~ 로드셀 고정 끝(바닥판 쪽) 윗면
echo(str("격자판 ", gp[0], " x ", gp[1], " x ", gp_h, " / 틈: 옆판 ", gp_gap_x, ", 앞판 ", gp_gap_f, ", 뒤판 ", gp_gap_b, ", 아래 스페이서 ", gp_gap_post, ", 로드셀 고정끝 ", gp_gap_lc));
if (min(gp_gap_x, gp_gap_f, gp_gap_b, gp_gap_post, gp_gap_lc) < 3) echo("※ 격자판 틈 3 미만");
if (max(gp[0], gp[1]) > 250) echo("※ 격자판이 프린터(250) 초과");
in3_h = lock3_h - ch_wall;                   // 거꾸로 놓은 3L 안쪽 높이
in3_w = box_bot[0] - 2*ch_wall; in3_d = box_bot[1] - 2*ch_wall;   // 거꾸로 놓은 3L B 안쪽 (좁은 쪽 기준)
ear_top = hh - 1 + ear[2];                   // 귀 꼭대기 (머리 바닥 기준, 기울기 무시)
bed = 256;   // 3D 프린터 (격자판·마운트 등 출력 부품 확인용)
// 표시창: 창 크기, 창 중심 → 기판 중심 높이 차(+ = 기판이 위), 구멍 간격·지름, 기판 크기
is_oled = display == "oled";
scr = is_oled ? oled_view : tft_screen;
win = [scr[0] + 2*win_margin, scr[1] + 2*win_margin];   // 앞판 구멍 = 표시 영역 + 사방 1
win_to_pcb = is_oled ? -(oled_pcb[1]/2 - oled_glass_top - oled_glass[1]/2) : -tft_win_dy;   // 창 중심 → 기판 중심 (+ = 기판이 위)
d_hole = is_oled ? oled_hole : tft_hole;
d_hole_d = is_oled ? oled_hole_d : 3.2;
d_tap = is_oled ? 1.6 : m3_tap;                 // 보스 셀프탭 구멍 (M2 / M3)
d_pcb = is_oled ? oled_pcb : tft_pcb;
d_pcb_t = is_oled ? oled_t - oled_glass_t : tft_pcb_t;
boss_h = is_oled ? oled_glass_t : tft_glass_t;  // 보스 높이 = 유리 두께 (헤더 납땜면은 유리보다 낮다고 가정)
boss_dd = is_oled ? 4.5 : boss_d;
win_zc = t + H - lcd_from_top;                  // 표시창 중심 높이 (조립 좌표)
pcb_zc = win_zc + win_to_pcb;                   // 기판 중심 높이
tm_plug = [win[0] + 2*tm_rim, win[1] + 2*tm_rim];              // 마운트 턱 (앞판 구멍에 끼움)
tm_cut = [tm_plug[0] + 2*kerf, tm_plug[1] + 2*kerf];           // 앞판 아크릴 사각 구멍
tm_fl = [max(tm_plug[0] + 2*tm_fl_m, d_hole[0] + boss_dd + 8), max(tm_plug[1] + 2*tm_fl_m, d_hole[1] + boss_dd + 8 + 2*abs(win_to_pcb))];   // 날개
tm_depth = tm_fl_t + boss_h + d_pcb_t + (is_oled ? 3 : 8.5);   // 앞판 안쪽에서 마운트+TFT+헤더가 차지하는 깊이 (헤더 8.5 추정)
tm_fl_holes = [for (sx = [-1, 1], sz = [-1, 1]) [sx*(tm_fl[0]/2 - 5), sz*(tm_fl[1]/2 - 5)]];   // 날개 M3 (창 중심 기준)
echo(str("TFT 마운트: 앞판 구멍 ", tm_cut[0], " x ", tm_cut[1], " / 날개 ", tm_fl[0], " x ", tm_fl[1], " x ", tm_fl_t, " / M3 간격 ", tm_fl[0] - 10, " x ", tm_fl[1] - 10));
echo(str("표시창 ", display, ": 마운트 창 ", win[0], " x ", win[1], " / 기판 ", d_pcb[0], " x ", d_pcb[1], " / 구멍 Ø", d_hole_d, " 간격 ", d_hole[0], " x ", d_hole[1], " / 보스 높이 ", boss_h));
// 보스가 TFT 헤더 자리와 겹치는지 (보스 바깥끝 ~ 헤더 시작)
if (!is_oled) echo(str("보스 ~ 헤더 여유: 14핀 ", tft_hdr14[0] - ((tft_pcb[0] - tft_hole[0])/2 + boss_d/2), ", 4핀 ", tft_hdr4[0] - ((tft_pcb[0] - tft_hole[0])/2 + boss_d/2)));
echo(str("케이스 바깥 ", W, " x ", D, " x ", H + 2*t, " mm / 통 쌓은 높이 ", chamber_h, " / 3L B 위 여유 ", top_gap, " / 탐침 ", probe_l));
echo(str("돼지 머리 ", hw, "x", hd, "x", hh, " (귀 포함 높이 ", ear_top, ") / 3L 안쪽 ", in3_w, "x", in3_d, "x", in3_h));
echo(str("머리 여유: 높이 ", in3_h - hh, " (귀 포함 ", in3_h - ear_top, "), 가로 ", in3_w - hw, ", 깊이 ", in3_d - hd));
echo(str("[요약] 바깥 총높이 ", H + 2*t, " / 흙 깊이 최대 ", soil_max, " (가정 ", soil_h, ") / 귀 여유 ", in3_h - ear_top, " / 격자판 틈 최소 ", min(gp_gap_x, gp_gap_f, gp_gap_b, gp_gap_post, gp_gap_lc)));
if (hh > in3_h || ear_top > in3_h) echo(str("※ 머리 간섭 → 거꾸로 덮은 3L이 ", max(0, hh - in3_h), " 뜸 (귀 포함 ", max(0, ear_top - in3_h), ")"));
echo(str("아크릴 ", t, "t: 앞뒤판 ", W, " x ", H, " / 옆판 ", D - 2*t, " x ", H, " / 바닥·뚜껑 ", W, " x ", D));
echo(str("[바깥 크기] ", W, " x ", D, " x ", H + 2*t, " (가로 x 깊이 x 높이) / elec_gap ", elec_gap, " (최소 ", tm_depth + 3, " = TFT 마운트 깊이 ", tm_depth, " + 3)"));
if (elec_gap < tm_depth + 3) echo("※ elec_gap 이 TFT 마운트 깊이보다 작음");
do_split = H > cut_max;                    // 벽판이 가공 한계보다 크면 위아래 2조각 (아크릴 기본값: 안 나눔)
zc_split = t + H/2;                        // 자르는 높이
if (do_split) echo(str("벽판 높이 ", H, " > ", bed, " → 위아래 2조각 (조각 높이 ", H/2, ")"));
split_fx = [W*0.15, W*0.35, W*0.65, W*0.85]; // 앞·뒤 위아래 이음 위치 (좌우 이음 x=W/2 피함)
do_lr = W > cut_max;                       // 가공 한계보다 넓으면 좌우 2조각
lr_z = [t + 40, t + 100, t + H - 26];      // 앞·뒤 좌우 이음 높이 (LCD 창 피함)
lr_y = [60, 95, 210];                      // 바닥·뚜껑 좌우 이음 위치
split_sy = [D*0.35, D*0.7];                // 옆판 이음 위치
n_strap = (do_split ? 3*len(split_fx) + 2*len(split_sy) : 0) + (do_lr ? 3*len(lr_z) + 2*len(lr_y) : 0);
if (do_lr) echo(str("가로 ", W, " > ", bed, " → 앞·뒤·바닥·뚜껑 좌우 2조각 (x = ", W/2, ")"));
echo(str("이음판 ", n_strap, "개"));

// ---------- 브래킷 ----------
// 원점 = 안쪽 모서리. 다리 A는 +x(판 두께 y), 다리 B는 +y(판 두께 x), 길이는 +z
module bracket() {
    difference() {
        union() { cube([leg, bt, bl]); cube([bt, leg, bl]); }
        bracket_holes();
    }
}
module bracket_holes() {
    translate([leg/2 + bt/2, 0, bl/2]) rotate([90, 0, 0]) cylinder(h = 30, d = m3, center = true);
    translate([0, leg/2 + bt/2, bl/2]) rotate([0, 90, 0]) cylinder(h = 30, d = m3, center = true);
}
// 바닥 모서리용: 길이를 x로 눕히고 다리를 +z(벽)와 +y(바닥)로
module edge_tf() { multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]]) children(); }   // 브래킷 (x,y,z) → (z,x,y)

// 브래킷 배치 (조립 좌표). holes=true면 구멍만
module split_holes() {   // 이음판 나사 구멍 (조립 좌표)
    if (do_lr) for (dx = [-10, 10]) {
        for (z = lr_z) for (y = [-1, D - t - 1])
            translate([W/2 + dx, y, z]) rotate([-90, 0, 0]) cylinder(h = t + 2, d = m3);
        for (y = lr_y) translate([W/2 + dx, y, -1]) cylinder(h = t + 2, d = m3);
    }
    if (do_split) for (dz = [-10, 10]) {
        for (x = split_fx) for (y = [-1, D - t - 1])
            translate([x, y, zc_split + dz]) rotate([-90, 0, 0]) cylinder(h = t + 2, d = m3);
        for (y = split_sy) for (x = [-1, W - t - 1])
            translate([x, y, zc_split + dz]) rotate([0, 90, 0]) cylinder(h = t + 2, d = m3);
    }
}
module placed_brackets(holes = false) {
    if (holes) split_holes();
    zs = [t + 40, t + H - 40 - bl];
    // 세로 모서리 4곳 x 2
    for (z = zs) {
        translate([t, t, z])                      if (holes) bracket_holes(); else bracket();
        translate([W - t, t, z]) mirror([1,0,0])  if (holes) bracket_holes(); else bracket();
        translate([t, D - t, z]) mirror([0,1,0])  if (holes) bracket_holes(); else bracket();
        translate([W - t, D - t, z]) mirror([1,0,0]) mirror([0,1,0]) if (holes) bracket_holes(); else bracket();
    }
    // 바닥 모서리: 앞·뒤 판 각 2개, 옆판 각 2개
    for (x = [W*0.25 - bl/2, W*0.75 - bl/2]) {
        translate([x, t, t]) edge_tf() if (holes) bracket_holes(); else bracket();
        translate([x, D - t, t]) mirror([0,1,0]) edge_tf() if (holes) bracket_holes(); else bracket();
    }
    for (y = [D*0.35 - bl/2, D*0.75 - bl/2]) {
        translate([t, y + bl, t]) rotate([0,0,-90]) edge_tf() if (holes) bracket_holes(); else bracket();
        translate([W - t, y, t]) rotate([0,0,90]) edge_tf() if (holes) bracket_holes(); else bracket();
    }
    // 뚜껑 모서리: 바닥과 같은 배치를 위아래 뒤집음 (뚜껑 아랫면 = t + H)
    translate([0, 0, 2*t + H]) mirror([0, 0, 1]) {   // z = t → t + H
        for (x = [W*0.25 - bl/2, W*0.75 - bl/2]) {
            translate([x, t, t]) edge_tf() if (holes) bracket_holes(); else bracket();
            translate([x, D - t, t]) mirror([0,1,0]) edge_tf() if (holes) bracket_holes(); else bracket();
        }
        for (y = [D*0.35 - bl/2, D*0.75 - bl/2]) {
            translate([t, y + bl, t]) rotate([0,0,-90]) edge_tf() if (holes) bracket_holes(); else bracket();
            translate([W - t, y, t]) rotate([0,0,90]) edge_tf() if (holes) bracket_holes(); else bracket();
        }
    }
}
n_br = 8 + 8 + 8;   // 세로 모서리 8 + 바닥 8 + 뚜껑 8

// ---------- 판 (조립 좌표) ----------
module p_bottom() {
    difference() {
        cube([W, D, t]);
        placed_brackets(true);
        translate([bx0, by0, 0]) {
            for (p = stop_xy) translate([p[0], p[1], -1]) cylinder(h = t + 2, d = m3);         // 멈춤 기둥 고정 M3
            for (x = lc_xa) {   // 로드셀 고정 M4 (바닥판 밑에서 아래 스페이서 관통), 접시머리 자리 (밑면)
                translate([x, 0, -1]) cylinder(h = t + 2, d = lc_hole_d, $fn = 24);
                translate([x, 0, -0.01]) cylinder(h = (cb_d - lc_hole_d)/2 + 0.01, d1 = cb_d, d2 = lc_hole_d, $fn = 24);
            }
        }
    }
}
module p_front() {
    difference() {
        translate([0, 0, t]) cube([W, t, H]);
        // TFT 마운트 자리: 사각 구멍 (턱 + kerf) + 날개 고정 M3 4개
        translate([W/2 - tm_cut[0]/2, -1, win_zc - tm_cut[1]/2]) cube([tm_cut[0], t + 2, tm_cut[1]]);
        for (p = tm_fl_holes) translate([W/2 + p[0], -1, win_zc + p[1]]) rotate([-90, 0, 0]) cylinder(h = t + 2, d = m3);
        placed_brackets(true);
    }
}
module p_back() {
    difference() {
        translate([0, D - t, t]) cube([W, t, H]);
        placed_brackets(true);   // 케이블 구멍은 왼쪽 판(전장 칸 쪽)으로 옮김
    }
}
module p_left() {
    difference() {
        translate([0, t, t]) cube([t, D - 2*t, H]);
        // 로드셀·패드 케이블 구멍 Ø10 (그로밋), 전장 칸 쪽, 로드셀 ~ 패드층 가운데 높이
        translate([-1, t + elec_gap/2, cable_z]) rotate([0, 90, 0]) cylinder(h = t + 2, d = 10);
        placed_brackets(true);
    }
}
module p_right() {
    difference() {
        translate([W - t, t, t]) cube([t, D - 2*t, H]);
        // USB-C 전원 입력 (전장부 쪽 아래)
        translate([W - t - 1, t + elec_gap/2 - 6, t + 14]) cube([t + 2, 12, 6]);
        // 전장부 통풍 슬롯
        for (i = [0:3]) translate([W - t - 1, t + 8, t + H - 60 + i*12]) cube([t + 2, elec_gap - 16, 4]);
        placed_brackets(true);
    }
}
module p_lid() {   // 평판 아크릴: 위 L 브래킷 8개에 M3로 고정 (나사 풀어 열기)
    difference() {
        translate([0, 0, t + H]) cube([W, D, t]);
        // 챔버 위 환기 슬롯
        for (i = [0:6]) translate([t + side_gap + 20 + i * (chamber_w - 40)/6 - 2, cy0 + chamber_d*0.3, t + H - 1]) cube([4, chamber_d*0.4, t + 2]);
        // 손가락 구멍 (전장 칸 위, 둥근 긴 구멍)
        translate([W/2, t + elec_gap/2, t + H - 1]) hull() for (dx = [-20, 20]) translate([dx, 0, 0]) cylinder(h = t + 2, d = 16);
        placed_brackets(true);
        if (do_lr) for (dx = [-10, 10], y = lr_y) translate([W/2 + dx, y, t + H - 10]) cylinder(h = 20, d = m3);   // 좌우 이음
    }
}

// ---------- 내부 참고용 (출력 안 함) ----------
module internals(pig_lift = 0, tft = true) {
    cx = t + side_gap; cy = cy0;
    translate([bx0, by0, t]) base_unit();                                        // 스페이서·로드셀·격자판 (+ 단열판·패드·방수판 유령)
    color("#8a6a45", 0.9) translate([bx0 - in3_w/2, by0 - in3_d/2, soil_z]) cube([in3_w, in3_d, soil_h]); // 흙 (3L A, 가정)
    translate([bx0, by0, boxA_z]) color("#cfe3ee", 0.35) box3(false);           // 3L A (똑바로)
    color("#5f9ec0", 0.5) difference() {   // 3L 뚜껑: 탐침 구멍만 표시 (돼지 탐침과 같은 위치, 현장 가공). 환기 구멍은 사용자가 직접 뚫음
        translate([cx - 2, cy - 2, boxA_z + lock3_h]) cube([chamber_w + 4, chamber_d + 4, lid_t]);
        translate([bx0, by0, boxA_z + lock3_h - 1]) cylinder(h = lid_t + 2, d = probe_hole + 1);
    }
    // 돼지 머리 + 거꾸로 덮은 3L B: 한 묶음으로 같이 움직임 (pig_lift)
    translate([0, 0, pig_lift]) {
        translate([bx0, by0, probe_tip_z]) pig();                                // 머리 바닥 = 3L 뚜껑 윗면
        translate([bx0, by0, lock3_z]) color("#cfe3ee", 0.3) box3(true);        // 3L B (거꾸로, 입구가 아래)
    }
    if (tft) { color("#4a5a66") tft_mount_placed(); display_module(); }
}
// ---------- TFT 마운트 (출력, 케이스에서 브래킷 말고 유일한 출력 부품) ----------
// 조립 좌표: 턱(plug)이 앞판 구멍에 끼어 앞면과 평평, 날개는 앞판 안쪽, 보스는 그 뒤. 유리가 날개 뒷면에 닿음
module tft_mount_placed() {
    difference() {
        union() {
            translate([W/2 - tm_plug[0]/2, 0, win_zc - tm_plug[1]/2]) cube([tm_plug[0], t + 0.01, tm_plug[1]]);          // 턱
            translate([W/2 - tm_fl[0]/2, t, win_zc - tm_fl[1]/2]) cube([tm_fl[0], tm_fl_t, tm_fl[1]]);                   // 날개
            for (dx = [-1, 1], dz = [-1, 1]) translate([W/2 + dx*d_hole[0]/2, t + tm_fl_t - 0.01, pcb_zc + dz*d_hole[1]/2])
                rotate([-90, 0, 0]) cylinder(h = boss_h + 0.01, d = boss_dd, $fn = 24);                                   // TFT 보스
        }
        translate([W/2 - win[0]/2, -1, win_zc - win[1]/2]) cube([win[0], t + tm_fl_t + 2, win[1]]);                      // 표시창 = 표시 영역 + 1
        for (dx = [-1, 1], dz = [-1, 1]) translate([W/2 + dx*d_hole[0]/2, t + 1, pcb_zc + dz*d_hole[1]/2])
            rotate([-90, 0, 0]) cylinder(h = tm_fl_t + boss_h, d = d_tap, $fn = 16);                                      // TFT 셀프탭 (앞은 막힘)
        for (p = tm_fl_holes) translate([W/2 + p[0], t - 1, win_zc + p[1]]) rotate([-90, 0, 0]) cylinder(h = tm_fl_t + 2, d = m3_tap, $fn = 16);   // 아크릴 고정 M3 (앞에서 나사 → 날개에 셀프탭)
    }
}
module flat_tft_mount() { rotate([90, 0, 0]) translate([-W/2, 0, -win_zc]) tft_mount_placed(); }   // 앞면(턱)이 바닥
module display_module() {   // 표시창 모듈 (참고용): 유리 → 기판 → (TFT) 헤더
    y0 = t + tm_fl_t;   // 마운트 날개 뒷면 = 유리 앞면
    color("#101a16") translate([W/2 - scr[0]/2 - 1, y0, win_zc - scr[1]/2 - 1]) cube([scr[0] + 2, boss_h, scr[1] + 2]);   // 유리
    color("#1f5a3a") translate([W/2 - d_pcb[0]/2, y0 + boss_h, pcb_zc - d_pcb[1]/2]) cube([d_pcb[0], d_pcb_t, d_pcb[1]]);  // 기판
    if (!is_oled) color("#222") {   // 헤더 (핀은 뒤로)
        x0 = W/2 - d_pcb[0]/2; yb = y0 + boss_h + d_pcb_t;
        translate([x0 + tft_hdr14[0], yb, pcb_zc - d_pcb[1]/2 + 0.5]) cube([tft_hdr14[1], 8.5, 2.5]);
        translate([x0 + tft_hdr4[0], yb, pcb_zc + d_pcb[1]/2 - 3]) cube([tft_hdr4[1], 8.5, 2.5]);
    }
}
// 3L 락앤락 (참고용): 중심 원점, 바닥 box_bot → 윗면 chamber_w x chamber_d. flip = 거꾸로 (입구가 아래)
module box3(flip) {
    module slab(s, z) translate([-s[0]/2, -s[1]/2, z]) cube([s[0], s[1], 0.01]);
    lo = flip ? [chamber_w, chamber_d] : box_bot; hi = flip ? box_bot : [chamber_w, chamber_d];
    difference() {
        hull() { slab(lo, 0); slab(hi, lock3_h - 0.01); }
        hull() {
            slab([lo[0] - 2*ch_wall, lo[1] - 2*ch_wall], flip ? -1 : ch_wall);
            slab([hi[0] - 2*ch_wall, hi[1] - 2*ch_wall], flip ? lock3_h - ch_wall : lock3_h + 1);
        }
    }
}

// ---------- 받침 (3L A 밑): 스페이서 2 + 로드셀 + 격자 받침판 + 멈춤 기둥 4 ----------
// 원점 = 통 중심(= 로드셀 중심 = 격자판 중심), z = 케이스 바닥판 윗면.
// 막대 로드셀을 x 방향: 왼쪽 끝은 아래 스페이서+바닥판, 오른쪽 끝은 위 스페이서+격자판에 고정
lc_xa = [-lc_l/2 + lc_end, -lc_l/2 + lc_end + lc_pitch];   // 바닥판 쪽 구멍
lc_xb = [lc_l/2 - lc_end, lc_l/2 - lc_end - lc_pitch];     // 격자판 쪽 구멍
lc_z1 = lc_z0 + lc_w;                                       // 로드셀 윗면
cb_d = 2*lc_bolt + 0.5;                                     // 볼트 머리 자리
module bu_spacer() {   // 스페이서 (원점 = 로드셀 끝 쪽 아래 모서리 기준이 아니라 가운데): lc_fix x lc_w x lc_sp, 볼트 구멍 2
    color("#6f7f8a") difference() {
        translate([-lc_fix/2, -lc_w/2, 0]) cube([lc_fix, lc_w, lc_sp]);
        for (dx = [-lc_pitch/2, lc_pitch/2]) translate([dx, 0, -1]) cylinder(h = lc_sp + 2, d = lc_hole_d, $fn = 24);
    }
}
module bu_stop() {   // 기울기 멈춤 기둥: 바닥판에 M3 1개(밑에서 셀프탭), 윗면은 격자판 밑 stop_gap
    color("#7d8a82") difference() {
        translate([-stop_s/2, -stop_s/2, 0]) cube([stop_s, stop_s, stop_h]);
        translate([0, 0, -1]) cylinder(h = 10, d = m3_tap, $fn = 16);
    }
}
module bu_grid() {   // 격자 받침판 (PETG): 테두리 + 약 40 격자 리브(두께 3, 높이 6), 로드셀 고정부만 꽉 참. 벽 없음
    nx = max(1, round(gp[0]/gp_pitch)); ny = max(1, round(gp[1]/gp_pitch));
    z0 = cell_h;
    color("#9aa3a0") translate([0, 0, z0]) difference() {
        union() {
            difference() {
                translate([-gp[0]/2, -gp[1]/2, 0]) cube([gp[0], gp[1], gp_h]);
                translate([-gp[0]/2 + gp_rim, -gp[1]/2 + gp_rim, -1]) cube([gp[0] - 2*gp_rim, gp[1] - 2*gp_rim, gp_h + 2]);
            }
            for (i = [1:nx - 1]) translate([-gp[0]/2 + i*gp[0]/nx - gp_rib/2, -gp[1]/2, 0]) cube([gp_rib, gp[1], gp_h]);
            for (j = [1:ny - 1]) translate([-gp[0]/2, -gp[1]/2 + j*gp[1]/ny - gp_rib/2, 0]) cube([gp[0], gp_rib, gp_h]);
            // 로드셀 고정부: 위 스페이서가 걸치는 격자 칸을 통째로 채움 (둘레 리브와 반 리브씩 겹쳐 한 덩어리, 윗면 = 격자 윗면)
            cw = gp[0]/nx; ch = gp[1]/ny;
            ix0 = floor((lc_l/2 - lc_fix + gp[0]/2)/cw); ix1 = floor((lc_l/2 - 0.01 + gp[0]/2)/cw);
            iy0 = floor((-lc_w/2 + gp[1]/2)/ch);        iy1 = floor((lc_w/2 + gp[1]/2)/ch);
            translate([-gp[0]/2 + ix0*cw - gp_rib/2, -gp[1]/2 + iy0*ch - gp_rib/2, 0])
                cube([(ix1 - ix0 + 1)*cw + gp_rib, (iy1 - iy0 + 1)*ch + gp_rib, gp_h]);
        }
        for (x = lc_xb) {   // 로드셀 볼트 (위에서 접시머리 M4, 머리가 윗면과 평평 → 단열판이 평평하게 얹힘)
            translate([x, 0, -1]) cylinder(h = gp_h + 2, d = lc_hole_d, $fn = 24);
            translate([x, 0, gp_h - (cb_d - lc_hole_d)/2]) cylinder(h = (cb_d - lc_hole_d)/2 + 0.01, d1 = lc_hole_d, d2 = cb_d, $fn = 24);   // 접시머리
        }
    }
}
module base_unit() {
    translate([-lc_l/2 + lc_fix/2, 0, 0]) bu_spacer();                                        // 아래 스페이서 (바닥판에 바로)
    color("#c9a87a", 0.9) translate([-lc_l/2, -lc_w/2, lc_z0]) cube([lc_l, lc_w, lc_w]);      // 로드셀 (참고용)
    translate([lc_l/2 - lc_fix/2, 0, lc_z1]) bu_spacer();                                     // 위 스페이서 (반대쪽 끝)
    for (p = stop_xy) translate([p[0], p[1], 0]) bu_stop();                                   // 멈춤 기둥 4
    bu_grid();
    // 구입품 (얇은 유령): 단열판 → 육묘 패드 → 방수판
    color("#e8dcc0", 0.25) translate([-gp[0]/2, -gp[1]/2, ins_z - t]) cube([gp[0], gp[1], ins_t]);
    color("#d0603a", 0.35) translate([-mat_w/2, -mat_d/2, pad_z - t]) cube([mat_w, mat_d, mat_t]);
    color("#a8d0e0", 0.25) translate([-gp[0]/2, -gp[1]/2, wp_z - t]) cube([gp[0], gp[1], wp_t]);
}

// ---------- 출력용 눕히기 ----------
module flat_front() { multmatrix([[-1, 0, 0, W], [0, 0, 1, -t], [0, 1, 0, 0]]) p_front(); }   // 바깥면이 바닥 (안쪽에서 본 모습)
module flat_back()  { multmatrix([[1, 0, 0, 0], [0, 0, 1, -t], [0, -1, 0, D]]) p_back(); }        // 바깥면이 바닥
module flat_left()  { multmatrix([[0, 1, 0, -t], [0, 0, 1, -t], [1, 0, 0, 0]]) p_left(); }
module flat_right() { multmatrix([[0, 1, 0, -t], [0, 0, 1, -t], [1, 0, 0, -(W - t)]]) p_right(); }
// 위아래 나누기: 자식의 높이 방향이 +y(0..h)일 때. w = 조각 가로 (보기용 배치 간격)
module split2(h, w) {
    if (!do_split) children();
    else {
        if (half != 2) intersection() { children(); translate([-1000, -1000, -1000]) cube([2000, 1000 + h/2, 2000]); }
        if (half != 1) translate([half == 2 ? 0 : w + 15, -h/2, 0])
            intersection() { children(); translate([-1000, h/2, -1000]) cube([2000, 1000, 2000]); }
    }
}
// 좌우 나누기: x = W/2에서 자름 (자식 x 범위 0..W)
module split_lr() {
    if (!do_lr) children();
    else {
        if (side != 2) intersection() { children(); translate([-1000, -1000, -1000]) cube([1000 + W/2, 2000, 2000]); }
        if (side != 1) translate([side == 2 ? -W/2 : 15, 0, 0])
            intersection() { children(); translate([W/2, -1000, -1000]) cube([1000, 2000, 2000]); }
    }
}
// 이음판: 자른 선을 안쪽에서 덮는 띠, M3 2개
module strap() { difference() { cube([16, 36, 3]); for (y = [8, 28]) translate([8, y, -1]) cylinder(h = 5, d = m3); } }
module flat_lid()   { rotate([180, 0, 0]) translate([0, -D, -2*t - H]) p_lid(); }

// ---------- 돼지 머리 (마인크래프트풍, 밑에 심부온도 탐침을 꽂음) ----------
// 부품: 몸통(앞면+옆면, 뒤가 열림) · 뒤판(센서·XIAO·보조배터리 고정, M3 4개로 탈착) · 코 · 귀 2개(본드)
// 좌표: 원점 = 탐침 끝, 앞면 = -y, 머리 바닥 z = probe_l
hz0 = probe_l;
module rcube(s, r) {      // 모서리 둥근 직육면체 (중심 기준)
    hull() for (x = [-1, 1], y = [-1, 1], z = [-1, 1])
        translate([x * (s[0]/2 - r), y * (s[1]/2 - r), z * (s[2]/2 - r)]) sphere(r = r, $fn = 24);
}
boss_xy = [hw/2 - h_wall - 4, hh/2 - h_wall - 4];   // 나사 기둥 위치 (x, z)

module head_body() {
    color("#f2b8c0") translate([0, 0, hz0 + hh/2]) difference() {
        union() {
            difference() {
                rcube([hw, hd, hh], h_r);
                translate([0, h_wall/2 + 0.01, 0]) cube([hw - 2*h_wall, hd - h_wall + 0.02, hh - 2*h_wall], center = true);   // 속 비움, 뒤 열림
            }
            // 모서리 나사 기둥 4개 (앞벽 → 뒤 끝까지)
            for (sx = [-1, 1], sz = [-1, 1]) translate([sx * boss_xy[0], h_wall/2, sz * boss_xy[1]])
                cube([8, hd - h_wall, 8], center = true);
            // 탐침 잡아주는 관 (바닥 안쪽)
            translate([0, 0, -hh/2 + h_wall]) cylinder(h = 10, d = probe_hole + 5);
        }
        for (sx = [-1, 1], sz = [-1, 1]) translate([sx * boss_xy[0], hd/2 - 14, sz * boss_xy[1]])
            rotate([-90, 0, 0]) cylinder(h = 15, d = m3_tap, $fn = 16);
        // 탐침 구멍
        translate([0, 0, -hh/2 - 1]) cylinder(h = h_wall + 12, d = probe_hole, $fn = 24);
        // 바닥 통풍 슬롯
        for (x = [-30, -18, 18, 30]) translate([x, 0, -hh/2]) cube([4, hd*0.5, h_wall*3], center = true);
        // 눈 (네모, 1mm 음각 → 칠하기)
        for (sx = [-1, 1]) translate([sx * 24, -hd/2 + 0.6, hh*0.12]) cube([14, 2.4, 14], center = true);
    }
}
module back_plate() {
    color("#e8d3d7") translate([0, hd/2, hz0 + hh/2]) difference() {
        // 몸통 바깥 윤곽과 같은 둥근 판
        hull() for (x = [-1, 1], z = [-1, 1]) translate([x * (hw/2 - h_r), 0, z * (hh/2 - h_r)]) rotate([-90, 0, 0]) cylinder(h = bp_t, r = h_r, $fn = 24);
        for (sx = [-1, 1], sz = [-1, 1]) translate([sx * boss_xy[0], -1, sz * boss_xy[1]]) rotate([-90, 0, 0]) cylinder(h = bp_t + 2, d = 3.4, $fn = 16);
        translate([24, -1, hh*0.12]) rotate([-90, 0, 0]) cylinder(h = bp_t + 2, d = mq_d);          // H2S
        translate([-24 - co2_w/2, -1, hh*0.12 - co2_h/2]) cube([co2_w, bp_t + 2, co2_h]);             // CO2
        for (z = [-30, -22]) translate([-30, -1, z]) cube([60, bp_t + 2, 3]);                          // 통풍
    }
}
module snout_part() {
    color("#e89aa6") difference() {
        rcube(snout, 3);
        for (sx = [-1, 1]) translate([sx * snout[0]*0.22, 0, snout[2]/2]) cube([8, 10, 4], center = true);   // 콧구멍
    }
}
// 세모 귀: 꼭짓점 둥글린 삼각기둥. 원점 = 밑변 가운데, 두께 방향 = y
module ear_part() {
    color("#f2b8c0") rotate([90, 0, 0]) translate([0, 0, -ear[1]/2])
        linear_extrude(height = ear[1]) offset(r = 2, $fn = 16) offset(delta = -2)
            polygon([[-ear[0]/2, 0], [ear[0]/2, 0], [0, ear[2]]]);
}

module pig() {   // 조립 모습
    head_body();
    back_plate();
    translate([0, -hd/2 - snout[2]/2 + 0.5, hz0 + hh/2 - hh*0.12]) rotate([90, 0, 0]) snout_part();
    for (sx = [-1, 1]) translate([sx * (hw/2 - ear[0]/2 - 4), -hd/2 + 14, hz0 + hh - 1]) rotate([0, sx * 15, 0]) ear_part();
    color("#b8bec2") { translate([0, 0, 3]) cylinder(h = probe_l + 8, d = 6); translate([0, 0, 3]) sphere(d = 6); }   // DS18B20 탐침
    // 눈 칠한 모습 (표시용, 출력 안 함): 흰자 + 검은 눈동자
    for (sx = [-1, 1]) translate([sx * 24, -hd/2 + 0.3, hz0 + hh/2 + hh*0.12]) {
        color("#f4f4f0") cube([14, 0.6, 14], center = true);
        color("#1d2420") translate([sx * 3.5, -0.2, 0]) cube([7, 0.6, 14], center = true);
    }
}
// 출력용 배치
module flat_head_body()  { translate([0, 0, hd/2]) rotate([-90, 0, 0]) translate([0, 0, -hz0 - hh/2]) head_body(); }   // 앞면이 바닥
module flat_back_plate() { rotate([90, 0, 0]) translate([0, -hd/2 - bp_t, -hz0 - hh/2]) back_plate(); }
module flat_small_parts() {
    translate([0, 0, snout[2]/2]) snout_part();
    for (i = [0, 1]) translate([-25 + i*50, 22, ear[1]/2]) rotate([-90, 0, 0]) ear_part();   // 눕혀서 출력
}


// ---------- 치수도 (위에서 본 평면, 단위 mm) ----------
module dim_h(x1, x2, y, label) {   // 가로 치수선
    color("#c8463c") { translate([x1, y - 0.3, 0]) cube([x2 - x1, 0.6, 1]); for (x = [x1, x2]) translate([x - 0.3, y - 3, 0]) cube([0.6, 6, 1]); }
    color("#1d2420") translate([(x1 + x2)/2, y + 2.5, 0]) linear_extrude(1) text(label, size = 6, font = KFONT, halign = "center");
}
module dim_v(y1, y2, x, label) {   // 세로 치수선
    color("#c8463c") { translate([x - 0.3, y1, 0]) cube([0.6, y2 - y1, 1]); for (y = [y1, y2]) translate([x - 3, y - 0.3, 0]) cube([6, 0.6, 1]); }
    color("#1d2420") translate([x - 2.5, (y1 + y2)/2, 0]) rotate([0, 0, 90]) linear_extrude(1) text(label, size = 6, font = KFONT, halign = "center");
}
module plan_view() {
    cx = t + side_gap; cy = cy0;
    // 케이스 벽
    color("#7d8a82") difference() { cube([W, D, 1]); translate([t, t, -1]) cube([W - 2*t, D - 2*t, 3]); }
    // 챔버
    color("#9cc3d8") difference() { translate([cx, cy, 0]) cube([chamber_w, chamber_d, 1]); translate([cx + 3, cy + 3, -1]) cube([chamber_w - 6, chamber_d - 6, 3]); }
    // TFT 마운트 + TFT (앞판 안쪽)
    color("#4a5a66") translate([W/2 - tm_fl[0]/2, t, 0]) cube([tm_fl[0], tm_fl_t, 1]);
    color("#16302a") translate([W/2 - d_pcb[0]/2, t + tm_fl_t + boss_h, 0]) cube([d_pcb[0], d_pcb_t, 1]);
    // 글자
    color("#1d2420") {
        translate([cx + chamber_w/2, cy + chamber_d/2, 0]) linear_extrude(1) text(str("락앤락 ", chamber_w, " x ", chamber_d), size = 8, font = KFONT, halign = "center", valign = "center");
        translate([W/2, t + elec_gap/2 + 8, 0]) linear_extrude(1) text("전장 공간 (TFT · HX711 · 배선)", size = 5.5, font = KFONT, halign = "center", valign = "center");
        translate([W/2, -42, 0]) linear_extrude(1) text("앞 (LCD 쪽)", size = 7, font = KFONT, halign = "center");
    }
    // 바깥 치수
    dim_h(0, W, D + 12, str("바깥 가로 ", W));
    dim_v(0, D, -12, str("바깥 깊이 ", D));
    // 안쪽 간격
    dim_h(0, t, -14, str(t));
    dim_h(t, cx, -26, str("틈 ", side_gap));
    dim_h(cx + chamber_w, W - t, -26, str("틈 ", side_gap));
    dim_v(t, cy, W + 14, str("전장 ", elec_gap));
    dim_v(cy + chamber_d, D - t, W + 14, str("틈 ", side_gap));
}


module side_view() {   // 옆에서 본 단면 (y-z 평면을 x-y로 눕혀 그림)
    cy = cy0;
    hb = head_z;   // 머리 바닥 = 3L 뚜껑 위
    module taper(lo, hi, z, flip) {   // 통 단면 (깊이 방향)
        a = flip ? chamber_d : box_bot[1]; b = flip ? box_bot[1] : chamber_d;
        difference() {
            hull() { translate([by0 - a/2, z, 0]) cube([a, 0.01, 1]); translate([by0 - b/2, z + lock3_h, 0]) cube([b, 0.01, 1]); }
            hull() { translate([by0 - a/2 + 3, z + (flip ? -1 : 3), -1]) cube([a - 6, 0.01, 3]); translate([by0 - b/2 + 3, z + lock3_h + (flip ? -3 : 1), -1]) cube([b - 6, 0.01, 3]); }
        }
    }
    color("#7d8a82") { cube([D, t, 1]); translate([0, t + H, 0]) cube([D, t, 1]); cube([t, H + 2*t, 1]); translate([D - t, 0, 0]) cube([t, H + 2*t, 1]); }
    color("#4a5a66") translate([t, win_zc - tm_fl[1]/2, 0]) cube([tm_fl_t, tm_fl[1], 1]);   // TFT 마운트
    color("#6f7f8a") translate([by0 - lc_w/2, t, 0.05]) cube([lc_w, lc_sp, 1]);   // 아래 스페이서 (위 스페이서는 같은 단면에서 로드셀 위)
    color("#6f7f8a") translate([by0 - lc_w/2, t + lc_z0 + lc_w, 0.05]) cube([lc_w, lc_sp, 1]);
    color("#7d8a82") for (sy = [-1, 1]) translate([by0 + sy*(gp[1]/2 - stop_s/2) - stop_s/2, t, 0]) cube([stop_s, stop_h, 1]);   // 멈춤 기둥
    color("#c9a87a") translate([by0 - lc_w/2, t + lc_z0, 0.1]) cube([lc_w, lc_w, 1]);   // 로드셀
    color("#9aa3a0") translate([by0 - gp[1]/2, t + cell_h, 0]) cube([gp[1], gp_h, 1]);  // 격자판
    color("#e8dcc0") translate([by0 - gp[1]/2, ins_z, 0.1]) cube([gp[1], ins_t, 1]);
    color("#d0603a") translate([by0 - mat_d/2, pad_z, 0.1]) cube([mat_d, mat_t, 1]);
    color("#5f9ec0") translate([by0 - gp[1]/2, wp_z, 0.1]) cube([gp[1], max(wp_t, 0.8), 1]);
    color("#c8463c") translate([0, cable_z - 5, 0.3]) cube([t, 10, 1]);   // 케이블 구멍 높이 (왼쪽 판, 전장 칸)
    color("#9cc3d8") taper(0, 0, boxA_z, false);   // 3L A
    color("#9cc3d8") taper(0, 0, lock3_z, true);   // 3L B 거꾸로
    color("#5f9ec0") translate([cy - 2, boxA_z + lock3_h, 0]) cube([chamber_d + 4, lid_t, 1]);
    color("#8a6a45") translate([by0 - in3_d/2, soil_z, 0.2]) cube([in3_d, soil_h, 1]);
    color("#f2b8c0") translate([by0 - hd/2, hb, 0.2]) cube([hd, hh, 1]);
    color("#b8bec2") translate([by0 - 3, probe_tip_z, 0.3]) cube([6, probe_l, 1]);
    color("#1d2420") {
        translate([by0, soil_z + soil_h + 15, 0]) linear_extrude(1.2) text(str("3L A ", lock3_h, " / 흙"), size = 6, font = KFONT, halign = "center", valign = "center");
        translate([by0 + 60, lock3_z + lock3_h - 12, 0]) linear_extrude(1.2) text("3L B 거꾸로", size = 5, font = KFONT, halign = "center", valign = "center");
        translate([by0, hb + hh/2, 0]) linear_extrude(1.2) text("돼지 머리", size = 6, font = KFONT, halign = "center", valign = "center");
        translate([D + 44, t + 18, 0]) linear_extrude(1.2) text("스페이서·로드셀·격자판·단열·패드·방수", size = 4, font = KFONT, valign = "center");
        translate([cy0/2 + 2, H/2, 0]) rotate([0, 0, 90]) linear_extrude(1.2) text("전장", size = 6, font = KFONT, halign = "center", valign = "center");
        translate([-30, -20, 0]) linear_extrude(1.2) text("← 앞", size = 7, font = KFONT);
    }
    dim_v(0, H + 2*t, -14, str("바깥 높이 ", H + 2*t));
    dim_v(t, boxA_z, D + 30, str("받침 ", boxA_z - t));
    dim_v(boxA_z, boxA_z + lock3_h, D + 14, str("3L A ", lock3_h));
    dim_v(boxA_z + lock3_h, lock3_z, D + 30, str("뚜껑 ", lid_t));
    dim_v(lock3_z, lock3_z + lock3_h, D + 14, str("3L B ", lock3_h));
    dim_v(lock3_z + lock3_h, t + H, D + 30, str("여유 ", top_gap));
    dim_v(hb, hb + in3_h, cy - 10, str("3L 안 ", in3_h));
    dim_v(probe_tip_z, hb, cy + 16, str("탐침 ", probe_l));
    dim_h(0, D, H + 2*t + 12, str("바깥 깊이 ", D));
}

// ---------- 로드셀 근접 옆모습 (view 25): Z 마운트 확인 ----------
module loadcell_closeup() {
    intersection() {   // 로드셀 둘레만 잘라서 앞(-y)에서 봄
        union() { color("#cfd6d0") translate([-bx0, -by0, 0]) p_bottom(); translate([0, 0, t]) base_unit(); }
        translate([-lc_l/2 - 25, -lc_w/2 - 12, -1]) cube([lc_l + 50, lc_w + 24, cell_h + gp_h + t + 2]);
    }
    zt = t;   // 바닥판 윗면
    module lab(x, z, s) color("#1d2420") translate([x, -lc_w/2 - 14, z]) rotate([90, 0, 0]) linear_extrude(0.5) text(s, size = 2.6, font = KFONT, halign = "center", valign = "center");
    module hline(x1, x2, z) color("#c8463c") translate([x1, -lc_w/2 - 13, z - 0.15]) cube([x2 - x1, 0.3, 0.3]);
    lab(-lc_l/2 + lc_fix/2, zt - 5, str("아래 스페이서 ", lc_fix, "x", lc_sp, " (끝까지, 바닥판에 M4)"));
    lab(lc_l/2 - lc_fix/2, zt + cell_h + gp_h + 4, str("위 스페이서 ", lc_fix, "x", lc_sp, " → 격자판"));
    lab(0, zt + lc_z0 + lc_w/2, str("로드셀 ", loadcell_kg, "kg ", lc_l, "x", lc_w));
    lab(0, zt - 9, str("가운데(휨부) 위 ", lc_mid_above, " / 아래 ", lc_mid_below, " 비움"));
    hline(-lc_l/2 + lc_fix, lc_l/2 - lc_fix, zt + lc_z0 - lc_mid_below/2);
    hline(-lc_l/2 + lc_fix, lc_l/2 - lc_fix, zt + lc_z0 + lc_w + lc_mid_above/2);
    lab(0, zt + cell_h + gp_h + 9, "격자판 중심 = 로드셀 중심");
    color("#c8463c") translate([-0.15, -lc_w/2 - 13, zt - 2]) cube([0.3, 0.3, cell_h + gp_h + 8]);
}

// ---------- 층 분해도 (view "2b") — 부품 이름표는 PDF에서 따로 붙임 (previews/hires/v02b_parts.txt) ----------
// 케이스 껍데기(바닥판 + 벌린 반투명 벽판)는 아래, 속 부품은 그 위로 층층이 띄움
module exploded_labeled() {
    ex = 110;                  // 벽판 빼는 거리
    Z0 = t + H + 90;           // 속 부품 시작 높이
    zs = [Z0, Z0 + 50, Z0 + 95, Z0 + 135, Z0 + 175, Z0 + 215, Z0 + 350, Z0 + 410, Z0 + 545, Z0 + 700];
    // 0 로드셀층, 1 격자판, 2 단열, 3 패드, 4 방수, 5 3L A, 6 3L 뚜껑, 7 머리 바닥, 8 3L B, 9 뚜껑
    cx = bx0; cy = by0;
    color(case_col) p_bottom();                                                                       // 15
    translate([0, -ex, 0]) { color("#4a5a66") tft_mount_placed(); display_module(); color(case_col, 0.35) p_front(); }   // 12 (벽판 반투명)
    color(case_col, 0.35) translate([0, ex, 0]) p_back();                                             // 13
    color(case_col, 0.35) { translate([-ex, 0, 0]) p_left(); translate([ex, 0, 0]) p_right(); }       // 14
    color("#9aa3a0") translate([W + ex + 40, -40, 0]) for (i = [0:5]) translate([0, i*(leg + 6), 0]) bracket();   // 16 (6개만 표시)
    translate([cx, cy, zs[0]]) {                                                                      // 10, 11
        for (q = stop_xy) translate([q[0], q[1], 0]) bu_stop();
        translate([-lc_l/2 + lc_fix/2, 0, 0]) bu_spacer();
        color("#c9a87a") translate([-lc_l/2, -lc_w/2, lc_z0]) cube([lc_l, lc_w, lc_w]);
        translate([lc_l/2 - lc_fix/2, 0, lc_z0 + lc_w]) bu_spacer();
    }
    translate([cx, cy, zs[1] - cell_h]) bu_grid();                                                    // 9
    color("#e8dcc0") translate([cx - gp[0]/2, cy - gp[1]/2, zs[2]]) cube([gp[0], gp[1], ins_t]);      // 8
    color("#d0603a") translate([cx - mat_w/2, cy - mat_d/2, zs[3]]) cube([mat_w, mat_d, mat_t]);      // 7
    color("#a8d0e0") translate([cx - gp[0]/2, cy - gp[1]/2, zs[4]]) cube([gp[0], gp[1], 1]);          // 6
    translate([cx, cy, zs[5]]) { color("#cfe3ee", 0.5) box3(false); color("#8a6a45") translate([-in3_w/2, -in3_d/2, ch_wall]) cube([in3_w, in3_d, soil_h]); }   // 5
    color("#5f9ec0", 0.8) translate([cx - chamber_w/2 - 2, cy - chamber_d/2 - 2, zs[6]]) cube([chamber_w + 4, chamber_d + 4, lid_t]);   // 4
    translate([cx, cy, zs[7] - probe_l]) pig();                                                      // 3
    translate([cx, cy, zs[8]]) color("#cfe3ee", 0.45) box3(true);                                     // 2
    color("#dfe4de") translate([0, 0, zs[9] - t - H]) p_lid();                                        // 1
}

// ---------- view 선택 ----------
case_col = "#e7ebe6";
if (view == 1) {
    internals();   // 4L 통·뚜껑, 그 위 돼지 머리 + 거꾸로 덮은 3L
    color(case_col, 0.35) { p_bottom(); p_front(); p_back(); p_left(); p_right(); }   // 케이스는 반투명 (안 보이게)
    color("#dfe4de", 0.35) p_lid();
}
else if (view == 2) {
    e = 70;
    color(case_col) p_bottom();
    translate([0, -e, 0]) { color("#4a5a66") tft_mount_placed(); display_module(); }   // TFT 마운트는 앞판과 같이
    color(case_col, 0.35) {   // 벽판 반투명 (미리보기 모드에서만 보임)
        translate([0, -e, 0]) p_front();
        translate([0, e, 0]) p_back();
        translate([-e, 0, 0]) p_left();
        translate([e, 0, 0]) p_right();
    }
    color("#dfe4de") translate([0, 0, e*3.4]) p_lid();
    color("#9aa3a0") placed_brackets();
    internals(pig_lift = 150, tft = false);   // 돼지 머리 + 3L 덮개는 같이 위로 빼서 표시
}
else if (view == "2b") exploded_labeled();
else if (view == 25) loadcell_closeup();
else if (view == 3) color(case_col) split2(H, W + 15) split_lr() flat_front();
else if (view == 4) color(case_col) split2(H, W + 15) split_lr() flat_back();
else if (view == 5) color(case_col) split2(H, D) flat_left();
else if (view == 6) color(case_col) split2(H, D) flat_right();
else if (view == 7) color(case_col) split_lr() p_bottom();
else if (view == 8) color("#dfe4de") split_lr() flat_lid();
else if (view == 9) color("#9aa3a0") for (i = [0:n_br - 1]) translate([(i % 6) * (leg + 8), floor(i / 6) * (leg + 8), 0]) bracket();   // L 브래킷 n_br개
else if (view == 10) pig();
else if (view == 11) flat_head_body();
else if (view == 12) flat_back_plate();
else if (view == 13) flat_small_parts();
else if (view == 16) plan_view();
else if (view == 17) side_view();
else if (view == 18 && n_strap > 0) color("#9aa3a0") for (i = [0:n_strap - 1]) translate([(i % 8) * 22, floor(i / 8) * 42, 0]) strap();   // 이음판
else if (view == 19) base_unit();                               // 받침 조립 (로드셀·와셔·단열판·패드·방수판은 참고용)
else if (view == 20) for (i = [0, 1]) translate([0, i*(lc_w + 8), 0]) bu_spacer();   // 스페이서 2개
else if (view == 21) translate([0, 0, -cell_h]) bu_grid();      // 격자 받침판 (출력, PETG)
else if (view == 22) for (i = [0:3]) translate([i*(stop_s + 8), 0, 0]) bu_stop();    // 멈춤 기둥 4개
else if (view == 23) color("#4a5a66") flat_tft_mount();      // TFT 마운트 (출력, 앞면이 바닥)
else if (view == 24) {                                          // TFT 마운트 조립 모습 (앞판 일부 + 마운트 + TFT)
    intersection() { color(case_col, 0.5) p_front(); translate([W/2 - 70, -5, win_zc - 75]) cube([140, 20, 150]); }
    color("#4a5a66") tft_mount_placed(); display_module();
}
// DXF용 2D (레이저 커팅): openscad -o x.dxf -D view=30 ...
else if (view == 30) projection() flat_front();
else if (view == 31) projection() flat_back();
else if (view == 32) projection() flat_left();
else if (view == 33) projection() flat_right();
else if (view == 34) projection() p_bottom();
else if (view == 35) projection() flat_lid();
else if (view == 15) { head_body(); translate([0, 60, 0]) back_plate(); }   // 뒤판 뗀 모습 (안쪽 확인)
