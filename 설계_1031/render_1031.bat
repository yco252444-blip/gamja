@echo off
chcp 65001 >nul
rem 10/31 재설계 (통 12x12x12, 패드·방열판 Ø90) 출력 파일 다시 만들기. cad 폴더에서 실행.
rem OpenSCAD 경로가 다르면 아래 한 줄만 고칠 것.
set OSC="C:\Program Files\OpenSCAD\openscad.exe"
if not exist dxf mkdir dxf
if not exist previews mkdir previews

rem 레이저 아크릴 DXF 6판
%OSC% -o dxf\앞판_acryl.dxf      -D view=30 oink_exterior.scad
%OSC% -o dxf\뒤판_acryl.dxf      -D view=31 oink_exterior.scad
%OSC% -o dxf\왼쪽판_acryl.dxf    -D view=32 oink_exterior.scad
%OSC% -o dxf\오른쪽판_acryl.dxf  -D view=33 oink_exterior.scad
%OSC% -o dxf\바닥판_acryl.dxf    -D view=34 oink_exterior.scad
%OSC% -o dxf\뚜껑_acryl.dxf      -D view=35 oink_exterior.scad

rem 크기가 바뀐 출력 부품 (나머지 STL은 치수 변화 없음)
%OSC% -o stl\격자받침판_PETG.stl -D view=21 oink_exterior.scad

rem 확인용 미리보기
%OSC% -o previews\v01_전체조립.png   -D view=1  --imgsize=1600,1200 --autocenter --viewall oink_exterior.scad
%OSC% -o previews\v16_평면치수도.png -D view=16 --imgsize=1600,1200 --autocenter --viewall --projection=o --camera=0,0,0,0,0,0,0 oink_exterior.scad
%OSC% -o previews\v17_측면치수도.png -D view=17 --imgsize=1600,1200 --autocenter --viewall --projection=o --camera=0,0,0,0,0,0,0 oink_exterior.scad
%OSC% -o previews\v19_받침조립.png   -D view=19 --imgsize=1600,1200 --autocenter --viewall oink_exterior.scad
echo 완료. ECHO 출력에서 "※" 경고가 없는지 확인할 것.
pause
