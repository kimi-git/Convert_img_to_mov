#!/bin/bash                                                                                                                         
# 日毎のムービーをひと月分まとめるスクリプト

# 対象のRaspberry Pi
rasp="zero_zeta"
# your home dir
home="replace this with your home dir"

# ベースディレクトリ
base_dir="/home/${home}/Pictures/rasp_${rasp}"

# カレントディレクトリを指定のディレクトリに変更
cd "$base_dir" || exit 1

# 先月の年と年月を取得
last_month=$(date -d 'last month' '+%Y-%m')
Year=$(date -d "$last_month-01" '+%Y')
YM=$(date -d "$last_month-01" '+%Y%m')

# カレントディレクトリを先月の年に変更
if [ ! -d "${Year}" ]; then
    mkdir "${Year}"
fi
cd "${Year}" || exit 1

# Trashフォルダが存在しない場合は作成
trash_folder="Trash"
if [ ! -d "${trash_folder}" ]; then
    mkdir "${trash_folder}"  || exit 1
fi

# 日毎の動画のリストを作成
video_list="video_list.txt"
ls "${YM}"*.mp4 | awk '{printf "file %s\n", $0}' > "${video_list}"  || exit 1

# 画像を動画に変換
output_file="temp.mp4"
ffmpeg -f concat -i "${video_list}" -c copy -loglevel quiet "${output_file}" 

# 動画の作成が成功したかを確認
if [ $? -eq 0 ]; then
    # 日毎の動画を削除用フォルダに移動
    mv "${YM}"*.mp4 ./"${trash_folder}"
    # 作成した動画をファイル名変更
    mv temp.mp4 "${YM}_${rasp}.mp4"
    # テンポラリファイルを削除
    rm "${video_list}"
else
    # ファイルが存在しない場合は終了
    # cronに登録し、メール出力が不要な場合、
    # cron ジョブの末尾に "">/dev/null 2>&1" を追加して標準出力と標準エラー出力を破棄すること
    echo "Error: No files found for copying."
    exit 1
fi
