#!/bin/bash
# Script to make time series images into video

# 対象のRaspberry Pi
rasp="zero_zeta"
# your home dir.
home="replace this with your home dir"

# ベースディレクトリ
base_dir="/home/${home}/Pictures/rasp_${rasp}"

# カレントディレクトリを指定のディレクトリに変更
cd "$base_dir" || exit 1

# 前日を取得
file_name=`date -d 'yesterday' '+%Y%m%d'`
# 前日の年を取得
year=$(date -d "$file_name" '+%Y')

# テンポラリフォルダを作成しファイルをコピーカレントディレクトリを変更
mkdir -p temp 
mv ${file_name}*.jpg  ./temp/  || exit 1
cd ./temp/

# 空のファイルを検索、削除
# ネットワーク状態により、画像が壊れることがある様で、容量ゼロのjpegファイルが存在するとffmpegが失敗するため。
find . -empty -delete 

# 連番のつけ直し 
ls | awk '{printf " mv %s pic%05d.jpg\n", $0, NR}' | bash

# 動画ファイルへの変換
ffmpeg -f image2 -r 15 -i pic%05d.jpg -r 15 -an -vcodec libx264 -pix_fmt yuv420p -loglevel quiet ${file_name}.mp4

if [ $? -eq 0 ]; then

    # 動画ファイルの移動
    mv "${file_name}.mp4" ../${year}/"${file_name}_${rasp}.mp4"
    # tempフォルダから移動、消去
    cd ..
    rm -r temp
fi
