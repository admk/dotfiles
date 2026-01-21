#!/bin/bash
input=$(cat)
# echo "$input" > /tmp/statusline_debug.log
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path')

format_number() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        printf "%dM" $((num / 1000000))
    elif [ "$num" -ge 1000 ]; then
        printf "%dk" $((num / 1000))
    else
        echo "$num"
    fi
}

get_home_relative_path() {
    local path="$1"
    local home_dir="$HOME"

    if [[ "$path" == "$home_dir"* ]]; then
        echo "~${path#$home_dir}"
    else
        echo "$path"
    fi
}

shorten_path() {
    local path="$1"
    local IFS='/'
    local -a components=($path)
    local result=""
    local last_idx=$((${#components[@]} - 1))

    for i in "${!components[@]}"; do
        if [ $i -eq $last_idx ]; then
            # Keep last component full
            if [ -n "$result" ]; then
                result="${result}/${components[$i]}"
            else
                result="${components[$i]}"
            fi
        else
            # Shorten to first letter (or dot + first letter for dotfiles)
            local comp="${components[$i]}"
            if [ -n "$comp" ]; then
                local shortened=""
                if [[ "$comp" == .* ]]; then
                    # For dotfiles, keep the dot and first letter after it
                    shortened=".${comp:1:1}"
                else
                    # For regular names, just first letter
                    shortened="${comp:0:1}"
                fi
                if [ -n "$result" ]; then
                    result="${result}/${shortened}"
                else
                    result="${shortened}"
                fi
            fi
        fi
    done

    echo "$result"
}

CURRENT_DIR="󰉋 $(shorten_path "$(get_home_relative_path "$CURRENT_DIR")")"
# PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" [ $BRANCH]"
    fi
fi

CURRENT_MODEL=" │ 󰵰 $(echo "$input" | jq -r '.model.display_name')"

BASE_URL=""
if [ -n "$ANTHROPIC_BASE_URL" ]; then
    BASE_URL_ROOT=$(echo "$ANTHROPIC_BASE_URL" | awk -F/ '{print $3}')
    BASE_URL=" │ 󰖟 $BASE_URL_ROOT"
fi

TOKEN_COUNT=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    input_total=0
    output_total=0
    while IFS= read -r line; do
        line="${line#"${line%%[![:space:]]*}"}"  # Remove leading whitespace
        line="${line%"${line##*[![:space:]]}"}"  # Remove trailing whitespace
        if [ -n "$line" ]; then
            type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
            if [ "$type" = "assistant" ]; then
                has_usage=$(echo "$line" | jq '.message.usage // empty' 2>/dev/null)
                if [ -n "$has_usage" ]; then
                    input_tokens=$(echo "$line" | jq '.message.usage.input_tokens // 0' 2>/dev/null | cut -d. -f1)
                    cache_creation=$(echo "$line" | jq '.message.usage.cache_creation_input_tokens // 0' 2>/dev/null | cut -d. -f1)
                    cache_read=$(echo "$line" | jq '.message.usage.cache_read_input_tokens // 0' 2>/dev/null | cut -d. -f1)
                    output_tokens=$(echo "$line" | jq '.message.usage.output_tokens // 0' 2>/dev/null | cut -d. -f1)

                    input_total=$((input_total + input_tokens + cache_creation + cache_read))
                    output_total=$((output_total + output_tokens))
                fi
            fi
        fi
    done < <(tac "$TRANSCRIPT_PATH")

    if [ "$input_total" -gt 0 ] || [ "$output_total" -gt 0 ]; then
        input_formatted=$(format_number "$input_total")
        output_formatted=$(format_number "$output_total")
        TOKEN_COUNT=" │  $input_formatted  $output_formatted"
    else
        TOKEN_COUNT=""
    fi
fi

# Context usage progress bar
CONTEXT_BAR=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')

    if [ "$size" -gt 0 ]; then
        pct=$((current * 100 / size))

        # Create progress bar
        bar_length=10
        filled=$((pct * bar_length / 100))
        empty=$((bar_length - filled))

        bar=""
        for ((i=0; i<filled; i++)); do
            bar="${bar}█"
        done
        for ((i=0; i<empty; i++)); do
            bar="${bar}░"
        done

        # Color code based on usage: green <50%, yellow 50-80%, red >80%
        if [ "$pct" -lt 50 ]; then
            color=$'\033[32m'  # green
        elif [ "$pct" -lt 80 ]; then
            color=$'\033[33m'  # yellow
        else
            color=$'\033[31m'  # red
        fi
        reset=$'\033[0m'

        CONTEXT_BAR=" │ ${color}${bar}${reset} ${pct}%"
    fi
fi

printf "%s%s%s%s%s%s" "$CURRENT_DIR" "$GIT_BRANCH" "$CURRENT_MODEL" "$BASE_URL" "$TOKEN_COUNT" "$CONTEXT_BAR"
