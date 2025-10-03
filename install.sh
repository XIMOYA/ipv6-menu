#!/bin/bash

# ==============================================================================
#
# install.sh - 用于安装 ipv6-menu.sh 脚本的引导程序
#
# 这个脚本会自动从 GitHub 下载最新的 ipv6-menu.sh，
# 并将其安装到 /usr/local/bin/ 目录下，使其成为一个系统命令。
#
# ==============================================================================

# --- 配置 ---
# 请将下面的 URL 替换为您自己 ipv6-menu.sh 脚本的真实 Raw URL
SOURCE_URL="https://raw.githubusercontent.com/XIMOYA/ipv6-menu/main/ipv6-menu.sh"
# 定义安装后的命令名和路径
INSTALL_PATH="/usr/local/bin/ipv6-menu"

# --- 函数定义 ---

# 函数：输出带颜色的信息
print_message( ) {
    case "$1" in
        "green")  COLOR="\033[0;32m";;
        "red")    COLOR="\033[0;31m";;
        "yellow") COLOR="\033[0;33m";;
        "blue")   COLOR="\033[0;34m";;
        *)        COLOR="\033[0m";;
    esac
    NC="\033[0m" # No Color
    echo -e "${COLOR}$2${NC}"
}

# 函数：检查并请求 root 权限
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_message "yellow" "安装过程需要管理员权限来写入系统目录。"
        # 重新以 sudo 方式运行脚本自身
        exec sudo "$0" "$@"
    fi
}

# --- 主逻辑 ---

# 确保以 root 权限运行
check_root

print_message "blue" "🚀 开始安装 ipv6-menu 工具..."

# 步骤 1: 下载脚本到目标路径
print_message "blue" "正在从 GitHub 下载脚本..."
if curl -sSL "$SOURCE_URL" -o "$INSTALL_PATH"; then
    print_message "green" "✅ 下载成功。"
else
    print_message "red" "❌ 下载失败！请检查网络或 URL 是否正确: $SOURCE_URL"
    exit 1
fi

# 步骤 2: 添加执行权限
print_message "blue" "正在设置执行权限..."
if chmod +x "$INSTALL_PATH"; then
    print_message "green" "✅ 权限设置成功。"
else
    print_message "red" "❌ 权限设置失败！"
    exit 1
fi

echo
print_message "green" "🎉 ipv6-menu 工具已成功安装！"
print_message "yellow" "现在您可以在任何地方使用 'sudo ipv6-menu' 命令来运行它。"
echo

exit 0
