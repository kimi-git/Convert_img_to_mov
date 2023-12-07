#!/bin/bash
# Script to make time series images into video

# 対象のRaspberry Pi
rasp="zero_zeta"
# your home dir.
home="replace this with your home dir"

# スクリプトが実行されるディレクトリ
original_dir=$(pwd)

# 対象ディレクトリ
base_dir="/home/${home}/Pictures/rasp_${rasp}"
cd $base_dir

# 先月を取得
last_month=$(date -d "$(date '+%Y-%m-01') 1 months ago" '+%Y-%m')
temp_folder=$(date -d "$last_month-01" '+%Y%m')
year=$(date -d "$last_month-01" '+%Y')

# ディレクトリを作成し、対象ファイルを移動、カレントディレクトリを変更
if [ ! -d "$temp_folder" ]; then
    mkdir -p "${temp_folder}"
fi
mv ${temp_folder}*.jpg  ./${temp_folder} || exit 1
cd ${temp_folder}

# 空のファイルを検索、削除
# ネットワーク状態により、画像が壊れることがある様で、容量ゼロのjpegファイルが存在するとffmpegが失敗するため。
find . -empty -delete

# 番号のファイル名に変更
ls | awk '{printf " mv %s pic%05d.jpg\n", $0, NR}' | bash

# 動画化
ffmpeg -f image2 -r 15 -i pic%05d.jpg -r 15 -an -vcodec libx264 -pix_fmt yuv420p -loglevel quiet ${temp_folder}.mp4

if [ $? -eq 0 ]; then
    # 完成した動画ファイルを年フォルダに移動、フォルダがなければ作成。
    if [ ! -d "../$year" ]; then
        mkdir "../$year"
    fi
    mv "${temp_folder}.mp4" ../${year}/"${temp_folder}_${rasp}.mp4"

    cd $original_dir
    # 作業フォルダを削除
    rm -r $temp_folder    
fi

