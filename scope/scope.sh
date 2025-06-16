#!/usr/bin/env bash

# 选择要预览的文件
if [ $# -eq 0 ]; then
    file=$(fzf --preview 'bat --color=always --line-range=:50 {}')
    [ -z "$file" ] && exit 0
else
    file="$1"
fi

# 获取文件信息
filename=$(basename "$file")
filepath=$(realpath "$file")
filetype=$(file -bL "$file")
mimetype=$(file -bL --mime-type "$file")
filesize=$(du -h "$file" | cut -f1)
perm=$(stat -c "%a %A" "$file")
modtime=$(stat -c "%y" "$file")

# 打印文件头信息
echo -e "\033[1;34m━━━ 文件信息 ━━━\033[0m"
echo "名称: $filename"
echo "路径: $filepath"
echo "大小: $filesize"
echo "类型: $filetype"
echo "MIME: $mimetype"
echo "权限: $perm"
echo "修改: $modtime"

# 根据文件类型预览内容
echo -e "\n\033[1;34m━━━ 内容预览 ━━━\033[0m"
case "$mimetype" in
    text/*|*/xml|*/json)
        bat --color=always "$file" || cat "$file"
        ;;
    image/*)
        chafa -f symbols "$file"
        exiftool -s -s -s -gps:all -createdate -focallength "$file" | head -5
        ;;
    video/*|audio/*)
        mediainfo "$file" | head -15
        ffmpegthumbnailer -i "$file" -o /tmp/vidthumb.jpg -q 10 -s 0 2>/dev/null
        chafa /tmp/vidthumb.jpg
        ;;
    application/pdf)
        pdftotext -l 25 -nopgbrk -q "$file" - | bat -l txt
        ;;
    application/json)
        jq -C '.' "$file" | bat -l json
        ;;
    application/x-bittorrent)
        transmission-show --scrape "$file"
        ;;
    application/zip|application/x-*compressed*)
        unar -l "$file" | head -20
        ;;
    text/markdown)
        glow -s dark "$file" | head -50
        ;;
    text/html)
        w3m -dump -cols 80 "$file" | head -40
        ;;
    application/vnd.openxmlformats-officedocument.*|application/vnd.ms-*)
        unar -p- -t text "$file" 2>/dev/null | head -50 | bat
        ;;
    inode/directory)
        ls -lAh --color=always "$file"
        ;;
    *)
        echo "未知文件类型，显示原始内容..."
        head -n 30 "$file"
        ;;
esac
