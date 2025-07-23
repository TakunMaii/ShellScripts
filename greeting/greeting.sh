#!/bin/bash

# 添加缓存文件路径，存储上次问候的时间段
CACHE_DIR="$HOME/.greeting_cache"
CACHE_FILE="$CACHE_DIR/last_interval"

# 确保缓存目录存在
mkdir -p "$CACHE_DIR"

# 定义时间段常数
MORNING_INTERVAL=1
NOON_INTERVAL=2
AFTERNOON_INTERVAL=3
EVENING_INTERVAL=4
NIGHT_INTERVAL=5

# 获取当前时间信息
current_hour=$(date +%H)
username=$(whoami)
current_date=$(date +%Y%m%d)

# 根据小时确定当前时间段
get_current_interval() {
    if [ $current_hour -ge 5 ] && [ $current_hour -lt 12 ]; then
        echo $MORNING_INTERVAL
    elif [ $current_hour -ge 12 ] && [ $current_hour -lt 14 ]; then
        echo $NOON_INTERVAL
    elif [ $current_hour -ge 14 ] && [ $current_hour -lt 18 ]; then
        echo $AFTERNOON_INTERVAL
    elif [ $current_hour -ge 18 ] && [ $current_hour -lt 22 ]; then
        echo $EVENING_INTERVAL
    else
        echo $NIGHT_INTERVAL
    fi
}

# 获取时间段对应的问候语
get_interval_greeting() {
    case $1 in
        $MORNING_INTERVAL) echo "Good morning" ;;
        $NOON_INTERVAL)    echo "Hello" ;;
        $AFTERNOON_INTERVAL) echo "Good afternoon" ;;
        $EVENING_INTERVAL) echo "Good evening" ;;
        $NIGHT_INTERVAL)  echo "Good night" ;;
    esac
}

# 检查是否需要显示主要问候语
current_interval=$(get_current_interval)
need_main_greeting=true

if [ -f "$CACHE_FILE" ]; then
    read last_date last_interval < "$CACHE_FILE"
    if [ "$last_date" = "$current_date" ] && [ "$last_interval" -eq "$current_interval" ]; then
        need_main_greeting=false
    fi
fi

# 更新缓存文件
echo "$current_date $current_interval" > "$CACHE_FILE"

# 主要问候语（仅在需要时设置）
if $need_main_greeting; then
    main_greeting=$(get_interval_greeting $current_interval)
else
    main_greeting=""
fi

random_extra() {
    local local_extras=(
        "How's the weather out there?"
        "How are you feeling today?"
        "Ready for a great day?"
        "Hope you're having a wonderful time!"
        "Everything going well?"
        "What's on your mind today?"
        "Sending positive vibes your way!"
        "Did anything interesting happen today?"
        "Wishing you all the best!"
        "You're looking fantastic today!"
        "Take a moment to appreciate today."
        "Remember to stay hydrated!"
        "What are your plans for today?"
        "Sending smiles your way!"
        "The world is better with you in it!"
        "Take a deep breath and relax."
    )
    
    if [ $((RANDOM % 2)) -eq 0 ]; then
        quote=$(curl -fsSL --max-time 3 "https://api.quotable.io/random" 2>/dev/null | jq -r '.content' 2>/dev/null)
        if [ -n "$quote" ]; then
            echo "\"$quote\""
            return
        fi
    fi
    
    echo "${local_extras[$RANDOM % ${#local_extras[@]}]}"
}

if [ -n "$main_greeting" ]; then
    greeting="${main_greeting}, ${username^}! $(random_extra)"
else
    greeting=$(random_extra)
fi

echo "$greeting"
