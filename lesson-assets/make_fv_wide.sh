set -e
# 横長FV（2160×1080）：左＝元バナー上部（ロゴ・見出し・バッジ・人物）、右＝料金と開催日程を縦に大きく積んだ金枠パネル
cd "$(dirname "$0")"
W=2160; H=1080; TW=1446
fe(){ echo "format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255*max(clip(min(min(X,W-1-X),min(Y,H-1-Y))/$1,0,1),clip(((r(X,Y)+g(X,Y)+b(X,Y))/3-45)/50,0,1))'"; }
ffmpeg -loglevel error -y -f lavfi -i "color=c=black:s=${W}x${H},format=rgba" -vf "geq=r='clip(12+12*(1-hypot((X-1810)/760,(Y-540)/640)),8,34)':g='clip(19+16*(1-hypot((X-1810)/760,(Y-540)/640)),12,42)':b='clip(15+11*(1-hypot((X-1810)/760,(Y-540)/640)),10,30)':a='clip((X-1180)/300*255,0,255)'" -frames:v 1 panel.png
# 金枠：上下の余白を詰め、縦ほぼいっぱい（y=70〜1010）
FX=1478; FW=656; FY=70; FH=940; CX=$((FX+FW/2))
PW=606; PH=206          # 料金（元の約1.5倍）
LW=470; LH=65           # 開催日程ラベル
DW1=376; DW2=354; DH=147  # 日付2行（元の約1.57倍）を縦に積む
PY=150; R1=410; LY=452; D1Y=562; R2=740; D2Y=772
ffmpeg -loglevel error -y -i banner-original.png -i panel.png \
 -filter_complex "\
 [0:v]crop=1254:936:0:0,scale=${TW}:${H}:flags=lanczos,pad=${W}:${H}:0:0:color=black,format=rgba[top];\
 [top][1:v]overlay=0:0,\
 drawbox=x=${FX}:y=${FY}:w=${FW}:h=${FH}:color=0x060D08@0.88:t=fill,\
 drawbox=x=${FX}:y=${FY}:w=${FW}:h=${FH}:color=0xD2AE62@0.85:t=2,\
 drawbox=x=$((FX+12)):y=$((FY+12)):w=$((FW-24)):h=$((FH-24)):color=0xD2AE62@0.30:t=1,\
 drawbox=x=$((CX-250)):y=${R1}:w=500:h=1:color=0xD2AE62@0.6:t=fill,\
 drawbox=x=$((CX-150)):y=${R2}:w=300:h=1:color=0xD2AE62@0.45:t=fill[base];\
 [0:v]crop=400:136:90:955,scale=${PW}:${PH}:flags=lanczos,$(fe 40)[price];\
 [0:v]crop=337:47:539:949,scale=${LW}:${LH}:flags=lanczos[label];\
 [0:v]crop=240:94:552:998,scale=${DW1}:${DH}:flags=lanczos,$(fe 26)[d1];\
 [0:v]crop=226:94:907:998,scale=${DW2}:${DH}:flags=lanczos,$(fe 26)[d2];\
 [base][price]overlay=$((CX-PW/2)):${PY}[b1];\
 [b1][label]overlay=$((CX-LW/2)):${LY}[b2];\
 [b2][d1]overlay=$((CX-DW1/2)):${D1Y}[b3];\
 [b3][d2]overlay=$((CX-DW1/2+16)):${D2Y},format=yuv444p" -frames:v 1 -q:v 2 fv-wide.jpg
rm -f panel.png
