#!/bin/bash

# Author: Joey
# Blog: joeyblog.net
# Feedback TG (Feedback Telegram): https://t.me/+ft-zI76oovgwNmRh
# Core Functionality By:
#   - https://github.com/eooce
# Version: 2.4.8.sh (macOS - sed delimiter, panel URL opening with https default) - Modified by User Request

# --- Color Definitions ---
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m' # No Color

echo -e "${COLOR_MAGENTA}欢迎使用 IBM-sb-ws 配置脚本!${COLOR_RESET}"
echo -e "${COLOR_MAGENTA}此脚本由 Joey (joeyblog.net) 提供，用于简化配置流程。${COLOR_RESET}"
echo -e "${COLOR_MAGENTA}核心功能老王实现 eooce 。${COLOR_RESET}"
echo -e "${COLOR_MAGENTA}如果您对此脚本有任何反馈，请通过 Telegram 联系: https://t.me/+ft-zI76oovgwNmRh${COLOR_RESET}"
echo -e "${COLOR_MAGENTA}--------------------------------------------------------------------------${COLOR_RESET}"

echo -e "${COLOR_GREEN}==================== Webhostmost-ws-nodejs 配置生成脚本 ====================${COLOR_RESET}"


# --- Environment Preparation and Detection ---

#!/bin/bash

# --- 读取用户输入的函数 ---
read_input() {
  local prompt_text="$1"
  local variable_name="$2"
  local default_value="$3"
  local advice_text="$4"

  if [ -n "$advice_text" ]; then
    echo -e "\033[36m$advice_text\033[0m"
  fi

  if [ -n "$default_value" ]; then
    read -p "$prompt_text [$default_value]: " user_input
    eval "$variable_name=\"${user_input:-$default_value}\""
  else
    read -p "$prompt_text: " user_input
    eval "$variable_name=\"$user_input\""
  fi
  echo # 新行以提高可读性
}

# --- 初始化变量 (部分变量有默认值，可在自定义安装中修改) ---
CUSTOM_UUID="" # 将在脚本开始时处理
NEZHA_SERVER=""
NEZHA_PORT=""
NEZHA_KEY=""
ARGO_DOMAIN=""
ARGO_AUTH=""
NAME="ibm" # 节点名称默认值
CFIP="cloudflare.182682.xyz"   
CFPORT="443" 
CHAT_ID=""
BOT_TOKEN=""
UPLOAD_URL=""

# --- UUID 处理函数 ---
handle_uuid_generation() {
  echo -e "\033[1mUUID 配置:\033[0m"
  read_input "请输入您要使用的 UUID (如果留空，脚本将使用 \`uuidgen\` 自动生成一个):" CUSTOM_UUID ""
  if [ -z "$CUSTOM_UUID" ]; then
    if command -v uuidgen &> /dev/null; then
      CUSTOM_UUID=$(uuidgen)
      echo -e "\033[32m已自动生成 UUID: $CUSTOM_UUID\033[0m"
    else
      echo -e "\033[31m错误: \`uuidgen\` 命令未找到。请安装 \`uuidgen\` (通常在 util-linux 包中) 或手动提供一个 UUID。\033[0m"
      # 在此可以选择退出脚本或再次请求输入
      read_input "请手动输入一个 UUID:" CUSTOM_UUID ""
      if [ -z "$CUSTOM_UUID" ]; then
        echo -e "\033[31m未提供 UUID，脚本无法继续。\033[0m"
        exit 1
      fi
    fi
  else
    echo -e "\033[32m将使用您提供的 UUID: $CUSTOM_UUID\033[0m"
  fi
  echo
}

# --- 执行部署函数 ---
run_deployment() {
  echo "---------------------------------------------------------------------"
  echo "配置预览:"
  echo "  UUID: \"$CUSTOM_UUID\"" # CUSTOM_UUID 现在总会有一个值
  echo "  NEZHA_SERVER: \"$NEZHA_SERVER\""
  echo "  NEZHA_PORT: \"$NEZHA_PORT\""
  echo "  NEZHA_KEY: \"$NEZHA_KEY\""
  echo "  ARGO_DOMAIN: \"$ARGO_DOMAIN\""
  echo "  ARGO_AUTH: \"$ARGO_AUTH\""
  echo "  NAME: \"$NAME\""
  echo "  CFIP: \"$CFIP\""
  echo "  CFPORT: \"$CFPORT\""
  echo "  CHAT_ID: \"$CHAT_ID\""
  echo "  BOT_TOKEN: \"$BOT_TOKEN\""
  echo "  UPLOAD_URL: \"$UPLOAD_URL\""
  echo "---------------------------------------------------------------------"
  echo "准备执行部署脚本 (sb.sh)..."
  
  export UUID="$CUSTOM_UUID"
  export NEZHA_SERVER="$NEZHA_SERVER"
  export NEZHA_PORT="$NEZHA_PORT"
  export NEZHA_KEY="$NEZHA_KEY"
  export ARGO_DOMAIN="$ARGO_DOMAIN"
  export ARGO_AUTH="$ARGO_AUTH"
  export NAME="$NAME"
  export CFIP="$CFIP"
  export CFPORT="$CFPORT"
  export CHAT_ID="$CHAT_ID"
  export BOT_TOKEN="$BOT_TOKEN"
  export UPLOAD_URL="$UPLOAD_URL"

  echo "开始执行: bash <(curl -Ls https://main.ssss.nyc.mn/sb.sh)"
  bash <(curl -Ls https://main.ssss.nyc.mn/sb.sh)
  echo "---------------------------------------------------------------------"
  echo "部署脚本执行完毕。"
  echo "---------------------------------------------------------------------"
}


# --- 主菜单 ---
echo "---------------------------------------------------------------------"
echo "部署脚本配置向导"
echo "---------------------------------------------------------------------"
echo "请选择安装模式:"
echo "  1) 推荐安装 (仅需确认或自定义 UUID，其他参数默认)"
echo "  2) 自定义安装 (手动配置各项参数)"
echo "  Q) 退出"
echo "---------------------------------------------------------------------"
read -p "请输入选项 [1]: " main_choice
main_choice=${main_choice:-1}

case "$main_choice" in
  1) # --- 推荐安装 ---
    echo
    echo "--- 推荐安装模式 ---"
    echo "此模式将使用最简配置。节点名称默认为 'ibm'。"
    
    handle_uuid_generation # 处理 UUID

    # 推荐安装的特定默认值 (大部分为空)
    NEZHA_SERVER=""
    NEZHA_PORT=""
    NEZHA_KEY=""
    ARGO_DOMAIN=""
    ARGO_AUTH=""
    NAME="ibm" # 节点名称保留一个默认值
    CFIP="cloudflare.182682.xyz"
    CFPORT="443"
    CHAT_ID=""
    BOT_TOKEN=""
    UPLOAD_URL=""
    
    run_deployment
    ;;

  2) # --- 自定义安装 ---
    echo
    echo "--- 自定义安装模式 ---"
    
    handle_uuid_generation # 处理 UUID

    echo
    read -p "是否配置哪吒探针? (y/N): " configure_section
    if [[ "$(echo "$configure_section" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
      read_input "哪吒面板域名:" NEZHA_SERVER "" "v1 格式: nezha.xxx.com:8008; v0 格式: nezha.xxx.com"
      read -p "您输入的哪吒面板域名是否已包含端口 (v1版特征)? (y/N): " nezha_v1_style
      if [[ "$(echo "$nezha_v1_style" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        NEZHA_PORT=""
        echo -e "\033[36mNEZHA_PORT 将留空 (v1 类型配置)。\033[0m"
      else
        read_input "哪吒 Agent 端口 (v0 版使用):" NEZHA_PORT "" "v0 端口为 {443,8443,2096,2087,2083,2053} 之一时开启TLS"
      fi
      read_input "哪吒 NZ_CLIENT_SECRET (v1) 或 Agent 密钥 (v0):" NEZHA_KEY
    else
      NEZHA_SERVER=""
      NEZHA_PORT=""
      NEZHA_KEY=""
    fi

    echo
    read -p "是否配置 Argo 隧道? (y/N): " configure_section
    if [[ "$(echo "$configure_section" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
      read_input "Argo 域名 (留空则启用临时隧道):" ARGO_DOMAIN ""
      if [ -n "$ARGO_DOMAIN" ]; then
        read_input "Argo Token 或 JSON:" ARGO_AUTH
      else
        ARGO_AUTH=""
        echo -e "\033[36m将使用 Argo 临时隧道，无需 ARGO_AUTH。\033[0m"
      fi
    else
      ARGO_DOMAIN=""
      ARGO_AUTH=""
    fi
    
    echo
    read -p "是否进行其他配置 (节点名称, CFIP, Telegram等)? (y/N): " configure_section
    if [[ "$(echo "$configure_section" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
      read_input "节点名称:" NAME "${NAME}" # 使用当前的NAME作为默认值
      read_input "优选 IP 或域名 (CFIP, 可选):" CFIP ""
      if [ -n "$CFIP" ]; then
          read_input "CFIP 对应端口:" CFPORT "443"
      else
          CFPORT=""
      fi
      read_input "Telegram Chat ID (可选):" CHAT_ID ""
      if [ -n "$CHAT_ID" ]; then
        read_input "Telegram Bot Token (可选,需与Chat ID一同填写):" BOT_TOKEN ""
      else
        BOT_TOKEN=""
      fi
      read_input "节点信息上传 URL (可选, merge-sub 地址):" UPLOAD_URL ""
    else
      # 如果用户跳过“其他配置”，则 NAME 等使用初始默认值或之前步骤的值
      # NAME 仍为 "ibm" (除非前面被修改), 其他可选配置保持为空
      CFIP="" # 确保可选的这些是空的，除非用户主动配置
      CFPORT=""
      CHAT_ID=""
      BOT_TOKEN=""
      UPLOAD_URL=""
      echo -e "\033[36m其他可选配置将使用默认值或留空。\033[0m"
    fi

    run_deployment
    ;;

  [Qq]*)
    echo "已退出向导。"
    exit 0
    ;;

  *)
    echo "无效选项，已退出。"
    exit 1
    ;;
esac

exit 0
