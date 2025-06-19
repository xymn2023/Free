#!/bin/bash

# 初始化并导出变量
export UUID="55e8ca56-8a0a-4486-b3f9-b9b0d46638a9"
export ARGO_DOMAIN="vm.pwhhh.nyc.mn"
export ARGO_AUTH="eyJhIjoiZjRhZjc4NGFkMDkzYTBlNGY1OWEwMjZlNDExN2IxNzkiLCJ0IjoiNmI1YjliYTktYTYxYS00YWI5LWEwMzctYzUyYWU2YTZkMGJmIiwicyI6Ik1EUTNOREF4TlRFdFlXRmtNaTAwT0dNNUxXRTFNalV0WXpGak0yWmtOVFZpWTJZNSJ9"
export NAME="ibm"
export CFIP="cloudflare.182682.xyz"
export CFPORT="443"
export CHAT_ID=""
export BOT_TOKEN=""
export UPLOAD_URL=""
declare -a PREFERRED_ADD_LIST=()

# 安装jq工具
apt install jq -y

# 颜色定义
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_WHITE_BOLD='\033[1;37m'
COLOR_RESET='\033[0m'

# 辅助函数
print_separator() {
    echo -e "${COLOR_BLUE}======================================================================${COLOR_RESET}"
}

print_header() {
    local header_text="$1"
    local color_code="$2"
    if [ -z "$color_code" ]; then
        color_code="${COLOR_WHITE_BOLD}"
    fi
    print_separator
    echo -e "${color_code}${header_text}${COLOR_RESET}"
    print_separator
}

# 执行部署函数
run_deployment() {
    print_header "开始部署流程" "${COLOR_CYAN}"
    echo -e "${COLOR_CYAN}  当前配置预览:${COLOR_RESET}"
    echo -e "    ${COLOR_WHITE_BOLD}UUID:${COLOR_RESET} $UUID"
    echo -e "    ${COLOR_WHITE_BOLD}节点名称 (NAME):${COLOR_RESET} $NAME"
    echo -e "    ${COLOR_WHITE_BOLD}主优选IP (CFIP):${COLOR_RESET} $CFIP (端口: $CFPORT)"
    echo -e "    ${COLOR_WHITE_BOLD}优选IP列表:${COLOR_RESET} ${PREFERRED_ADD_LIST[*]}"
    print_separator

    echo -e "${COLOR_YELLOW}  正在准备执行核心部署脚本 (sb.sh)...${COLOR_RESET}"

    SB_SCRIPT_PATH="/tmp/sb_downloaded_script_$(date +%s%N).sh"
    TMP_SB_OUTPUT_FILE=$(mktemp)
    if [ -z "$TMP_SB_OUTPUT_FILE" ]; then
        echo -e "${COLOR_RED}  ✗ 错误: 无法创建临时文件。${COLOR_RESET}"
        exit 1
    fi

    echo -e "${COLOR_CYAN}  > 正在下载核心脚本...${COLOR_RESET}"
    if curl -Lso "$SB_SCRIPT_PATH" https://main.ssss.nyc.mn/sb.sh; then
        chmod +x "$SB_SCRIPT_PATH"
        echo -e "${COLOR_GREEN}  ✓ 下载完成。${COLOR_RESET}"
        echo -e "${COLOR_CYAN}  > 正在执行核心脚本 (此过程可能需要几分钟，请耐心等待)...${COLOR_RESET}"

        bash "$SB_SCRIPT_PATH" > "$TMP_SB_OUTPUT_FILE" 2>&1 &
        SB_PID=$!

        TIMEOUT_SECONDS=180
        elapsed_time=0

        local progress_chars="/-\\|"
        local char_idx=0
        while ps -p $SB_PID > /dev/null && [ "$elapsed_time" -lt "$TIMEOUT_SECONDS" ]; do
            printf "\r${COLOR_YELLOW}  [执行中 ${progress_chars:$char_idx:1}] (已用时: ${elapsed_time}s)${COLOR_RESET}"
            char_idx=$(((char_idx + 1) % ${#progress_chars}))
            sleep 1
            elapsed_time=$((elapsed_time + 1))
        done
        printf "\r${COLOR_GREEN}  [核心脚本执行完毕或超时]                                                  ${COLOR_RESET}\n"

        if ps -p $SB_PID > /dev/null; then
            echo -e "${COLOR_RED}  ✗ 核心脚本 (PID: $SB_PID) 执行超时，尝试终止...${COLOR_RESET}"
            kill -SIGTERM $SB_PID; sleep 2
            if ps -p $SB_PID > /dev/null; then kill -SIGKILL $SB_PID; sleep 1; fi
            if ps -p $SB_PID > /dev/null; then echo -e "${COLOR_RED}    ✗ 无法终止核心脚本。${COLOR_RESET}"; else echo -e "${COLOR_GREEN}    ✓ 核心脚本已终止。${COLOR_RESET}"; fi
        else
            echo -e "${COLOR_GREEN}  ✓ 核心脚本 (PID: $SB_PID) 已执行完毕。${COLOR_RESET}"
            wait $SB_PID; SB_EXEC_EXIT_CODE=$?
            if [ "$SB_EXEC_EXIT_CODE" -ne 0 ]; then echo -e "${COLOR_RED}  警告: 核心脚本退出码为 $SB_EXEC_EXIT_CODE。${COLOR_RESET}"; fi
        fi
        rm "$SB_SCRIPT_PATH"
    else
        echo -e "${COLOR_RED}  ✗ 错误: 下载核心脚本失败。${COLOR_RESET}"
        echo "Error: sb.sh download failed." > "$TMP_SB_OUTPUT_FILE"
    fi

    sleep 0.5
    RAW_SB_OUTPUT=$(cat "$TMP_SB_OUTPUT_FILE")
    rm "$TMP_SB_OUTPUT_FILE"
    echo

    print_header "部署结果分析与链接生成" "${COLOR_CYAN}"
    if [ -z "$RAW_SB_OUTPUT" ]; then
        echo -e "${COLOR_RED}  ✗ 错误: 未能捕获到核心脚本的任何输出。${COLOR_RESET}"
    else
        echo -e "${COLOR_MAGENTA}--- 核心脚本执行结果摘要 ---${COLOR_RESET}"

        ARGO_DOMAIN_OUTPUT=$(echo "$RAW_SB_OUTPUT" | grep "ArgoDomain:")
        if [ -n "$ARGO_DOMAIN_OUTPUT" ]; then
            ARGO_ACTUAL_DOMAIN=$(echo "$ARGO_DOMAIN_OUTPUT" | awk -F': ' '{print $2}')
            echo -e "${COLOR_CYAN}  Argo 域名:${COLOR_RESET} ${COLOR_WHITE_BOLD}${ARGO_ACTUAL_DOMAIN}${COLOR_RESET}"
        else
            echo -e "${COLOR_YELLOW}  未检测到 Argo 域名。${COLOR_RESET}"
            ARGO_ACTUAL_DOMAIN=""
        fi

        ORIGINAL_VMESS_LINK=$(echo "$RAW_SB_OUTPUT" | grep "vmess://" | head -n 1)
        declare -a GENERATED_VMESS_LINKS_ARRAY=()

        if [ -z "$ORIGINAL_VMESS_LINK" ]; then
            echo -e "${COLOR_YELLOW}  未检测到 VMess 链接。${COLOR_RESET}"
        else
            echo -e "${COLOR_GREEN}  正在处理 VMess 配置链接...${COLOR_RESET}"
            if ! command -v jq &> /dev/null; then
                echo -e "${COLOR_YELLOW}  警告: 'jq' 命令未找到。无法生成多个优选地址的 VMess 或 Clash 订阅。${COLOR_RESET}"
            elif ! command -v base64 &> /dev/null; then
                echo -e "${COLOR_RED}  错误: 'base64' 命令未找到。${COLOR_RESET}"
            else
                BASE64_DECODE_CMD="base64 -d"; BASE64_ENCODE_CMD="base64 -w0"
                if [[ "$(uname)" == "Darwin" ]]; then BASE64_DECODE_CMD="base64 -D"; BASE64_ENCODE_CMD="base64"; fi
                BASE64_PART=$(echo "$ORIGINAL_VMESS_LINK" | sed 's/vmess:\/\///')
                JSON_CONFIG=$($BASE64_DECODE_CMD <<< "$BASE64_PART" 2>/dev/null)

                if [ -z "$JSON_CONFIG" ]; then
                    echo -e "${COLOR_RED}    ✗ VMess 链接解码失败。${COLOR_RESET}"
                else
                    ORIGINAL_PS=$(echo "$JSON_CONFIG" | jq -r .ps 2>/dev/null); if [[ -z "$ORIGINAL_PS" || "$ORIGINAL_PS" == "null" ]]; then ORIGINAL_PS="节点"; fi
                    if [ ${#PREFERRED_ADD_LIST[@]} -eq 0 ]; then
                        echo -e "${COLOR_YELLOW}    警告: 优选IP列表为空，使用默认。${COLOR_RESET}"
                        PREFERRED_ADD_LIST=("cloudflare.182682.xyz" "joeyblog.net")
                    fi
                    UNIQUE_PREFERRED_ADD_LIST=($(echo "${PREFERRED_ADD_LIST[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
                    echo -e "${COLOR_GREEN}  生成的多个优选地址 VMess 配置链接:${COLOR_RESET}"
                    for target_add in "${UNIQUE_PREFERRED_ADD_LIST[@]}"; do
                        SANITIZED_TARGET_ADD=$(echo "$target_add" | sed 's/[^a-zA-Z0-9_.-]/_/g')
                        NEW_PS="${ORIGINAL_PS}-优选-${SANITIZED_TARGET_ADD}"
                        MODIFIED_JSON=$(echo "$JSON_CONFIG" | jq --arg new_add "$target_add" --arg new_ps "$NEW_PS" '.add = $new_add | .ps = $new_ps')
                        if [ -n "$MODIFIED_JSON" ]; then
                            MODIFIED_BASE64=$(echo -n "$MODIFIED_JSON" | $BASE64_ENCODE_CMD)
                            GENERATED_VMESS_LINK="vmess://${MODIFIED_BASE64}"
                            echo -e "    ${COLOR_WHITE_BOLD}${GENERATED_VMESS_LINK}${COLOR_RESET}"
                            GENERATED_VMESS_LINKS_ARRAY+=("$GENERATED_VMESS_LINK")
                        else
                            echo -e "${COLOR_YELLOW}      为地址 $target_add 生成 VMess 失败。${COLOR_RESET}"
                        fi
                    done
                fi
            fi
        fi
        echo

        if [ ${#GENERATED_VMESS_LINKS_ARRAY[@]} -gt 0 ]; then
            if ! command -v jq &> /dev/null; then
                echo -e "${COLOR_YELLOW}  警告: 'jq' 未找到，无法生成 Clash 订阅。${COLOR_RESET}"
            else
                echo -e "${COLOR_MAGENTA}--- Clash 订阅链接 (通过 api.wcc.best) ---${COLOR_RESET}"
                RAW_VMESS_STRING=""; for i in "${!GENERATED_VMESS_LINKS_ARRAY[@]}"; do RAW_VMESS_STRING+="${GENERATED_VMESS_LINKS_ARRAY[$i]}"; if [ $i -lt $((${#GENERATED_VMESS_LINKS_ARRAY[@]} - 1)) ]; then RAW_VMESS_STRING+="|"; fi; done
                ENCODED_VMESS_STRING=$(echo -n "$RAW_VMESS_STRING" | jq -Rr @uri)
                CONFIG_URL_RAW="https://raw.githubusercontent.com/byJoey/test/refs/heads/main/tist.ini"; CONFIG_URL_ENCODED=$(echo -n "$CONFIG_URL_RAW" | jq -Rr @uri)
                CLASH_API_BASE_URL="https://api.wcc.best/sub"
                CLASH_API_PARAMS="target=clash&url=${ENCODED_VMESS_STRING}&insert=false&config=${CONFIG_URL_ENCODED}&emoji=true&list=false&tfo=false&scv=true&fdn=false&expand=true&sort=false&new_name=true"
                FINAL_CLASH_API_URL="${CLASH_API_BASE_URL}?${CLASH_API_PARAMS}"

                echo -e "${COLOR_GREEN}  ✓ Clash 订阅 URL:${COLOR_RESET}"
                echo -e "    ${COLOR_WHITE_BOLD}${FINAL_CLASH_API_URL}${COLOR_RESET}"
            fi
        else
            echo -e "${COLOR_YELLOW}  没有可用的 VMess 链接来生成 Clash 订阅。${COLOR_RESET}"
        fi
        echo

        SUB_SAVE_STATUS=$(echo "$RAW_SB_OUTPUT" | grep "\.\/\.tmp\/sub\.txt saved successfully")
        if [ -n "$SUB_SAVE_STATUS" ]; then
            echo -e "${COLOR_GREEN}  ✓ 订阅文件 (.tmp/sub.txt):${COLOR_RESET} 已成功保存。"
        fi

        INSTALL_COMPLETE_MSG=$(echo "$RAW_SB_OUTPUT" | grep "安装完成" | head -n 1)
        if [ -n "$INSTALL_COMPLETE_MSG" ]; then
            echo -e "${COLOR_GREEN}  ✓ 状态:${COLOR_RESET} $INSTALL_COMPLETE_MSG"
        fi

        UNINSTALL_CMD_MSG=$(echo "$RAW_SB_OUTPUT" | grep "一键卸载命令：")
        if [ -n "$UNINSTALL_CMD_MSG" ]; then
            UNINSTALL_ACTUAL_CMD=$(echo "$UNINSTALL_CMD_MSG" | sed 's/一键卸载命令：//' | awk '{$1=$1;print}')
            echo -e "${COLOR_RED}  一键卸载命令:${COLOR_RESET} ${COLOR_WHITE_BOLD}${UNINSTALL_ACTUAL_CMD}${COLOR_RESET}"
        fi
    fi

    print_header "部署完成与支持信息" "${COLOR_GREEN}"
    echo -e "${COLOR_GREEN}  IBM-sb-ws 节点部署流程已执行完毕!${COLOR_RESET}"
    echo
    echo -e "${COLOR_GREEN}  感谢使用! 如有问题或建议，请联系:${COLOR_RESET}"
    echo -e "${COLOR_GREEN}    Joey's Feedback TG: ${COLOR_WHITE_BOLD}https://t.me/+ft-zI76oovgwNmRh${COLOR_RESET}"
    echo -e "${COLOR_GREEN}    老王's TG 群组:    ${COLOR_WHITE_BOLD}https://t.me/vps888${COLOR_RESET}"
    print_separator
}

# 运行部署
run_deployment

exit 0
