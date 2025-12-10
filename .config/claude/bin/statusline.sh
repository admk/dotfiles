#!/bin/bash
input=$(cat)
# echo "$input" > /tmp/statusline_debug.log
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path')

format_number() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        printf "%.1fM" $(echo "scale=1; $num / 1000000" | bc -l)
    elif [ "$num" -ge 1000 ]; then
        printf "%.1fk" $(echo "scale=1; $num / 1000" | bc -l)
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

CURRENT_DIR=$(get_home_relative_path "$CURRENT_DIR")
# PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" │  $BRANCH"
    fi
fi

CURRENT_MODEL=" │ $(echo "$input" | jq -r '.model.display_name')"

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

echo "󰉋 $CURRENT_DIR$GIT_BRANCH$CURRENT_MODEL$BASE_URL$TOKEN_COUNT"
