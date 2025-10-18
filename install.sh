#!/bin/bash

# ==============================================================================
#
# install.sh - 用于安装或卸载 ipv6-menu 工具的引导程序
#
# 使用方法:
#   安装: curl ... | bash
#   卸载: curl ... | bash -s uninstall
#
# ==============================================================================

# --- 配置 ---
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
        print_message "yellow" "此操作需要管理员权限来修改系统目录。"
        # 重新以 sudo 方式运行脚本自身，并传递所有参数
        exec sudo bash -c "$(curl -sSL $0)" -- "$@"
    fi
}

# 函数：执行安装
do_install() {
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
}

# 函数：执行卸载
do_uninstall() {
    print_message "blue" "🚀 开始卸载 ipv6-menu 工具..."

    # 检查文件是否存在
    if [ -f "$INSTALL_PATH" ]; then
        print_message "blue" "正在删除文件: $INSTALL_PATH"
        if rm "$INSTALL_PATH"; then
            print_message "green" "✅ 文件已成功删除。"
        else
            print_message "red" "❌ 文件删除失败！"
            exit 1
        fi
    else
        print_message "yellow" "⚠️ 未找到已安装的 ipv6-menu 工具，无需卸载。"
    fi
    
    echo
    print_message "green" "🎉 ipv6-menu 工具已成功卸载！"
}

# --- 主逻辑 ---

# 确保以 root 权限运行
check_root

# 根据传入的第一个参数决定执行安装还是卸载
# 如果没有参数，默认为安装
ACTION=${1:-install}

case "$ACTION" in
    install)
        do_install
        ;;
    uninstall)
        do_uninstall
        ;;
    *)
        print_message "red" "错误: 无效的操作 '$ACTION'。有效操作为 'install' 或 'uninstall'。"
        exit 1
        ;;
esac

exit 0
