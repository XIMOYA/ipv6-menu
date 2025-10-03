#!/bin/bash

# ==============================================================================
#
# ipv6-menu.sh - 一个通过交互式菜单快速开启、关闭或检查IPv6状态的脚本
#
# 使用方法:
#   直接运行 ./ipv6-menu.sh (需要sudo权限)
#
# ==============================================================================

# 定义需要修改的sysctl参数
IPV6_PARAMS=(
    "net.ipv6.conf.all.disable_ipv6"
    "net.ipv6.conf.default.disable_ipv6"
    "net.ipv6.conf.lo.disable_ipv6"
)
SYSCTL_CONF="/etc/sysctl.conf"

# --- 函数定义 ---

# 函数：输出带颜色的信息
print_message() {
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

# 函数：检查脚本是否以root权限运行
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_message "red" "错误：此脚本需要以 root 权限运行。请使用 'sudo ./ipv6-menu.sh'"
        exit 1
    fi
}

# 函数：启用IPv6
enable_ipv6() {
    print_message "blue" "🚀 正在启用 IPv6..."
    
    # 1. 临时启用 (立即生效)
    for param in "${IPV6_PARAMS[@]}"; do
        sysctl -w "${param}=0" > /dev/null
    done

    # 2. 永久启用 (修改配置文件)
    for param in "${IPV6_PARAMS[@]}"; do
        # 使用sed命令删除禁用IPv6的行
        sed -i "/^${param//./\\.}[[:space:]]*=[[:space:]]*1/d" "$SYSCTL_CONF"
    done
    
    sysctl -p > /dev/null
    print_message "green" "✅ IPv6 已成功启用！"
}

# 函数：禁用IPv6
disable_ipv6() {
    print_message "blue" "🚀 正在禁用 IPv6..."

    # 1. 临时禁用 (立即生效)
    for param in "${IPV6_PARAMS[@]}"; do
        sysctl -w "${param}=1" > /dev/null
    done

    # 2. 永久禁用 (修改配置文件)
    for param in "${IPV6_PARAMS[@]}"; do
        # 先删除可能存在的旧配置，再添加新配置，避免重复
        sed -i "/^${param//./\\.}/d" "$SYSCTL_CONF"
        echo "${param} = 1" >> "$SYSCTL_CONF"
    done

    sysctl -p > /dev/null
    print_message "green" "✅ IPv6 已成功禁用！"
}

# 函数：检查当前状态
check_status() {
    # 检查核心参数 `net.ipv6.conf.all.disable_ipv6` 的值
    status=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
    
    if [ "$status" -eq 0 ]; then
        print_message "green" "当前状态: 🟢 已启用"
        echo "IPv6 地址信息:"
        ip -6 addr | grep 'inet6' | sed 's/^[ \t]*/  /g'
    else
        print_message "red" "当前状态: 🔴 已禁用"
    fi
}

# 函数：显示主菜单
show_menu() {
    clear
    print_message "blue" "=============================="
    print_message "blue" "    IPv6 状态管理脚本"
    print_message "blue" "=============================="
    echo
    check_status
    echo
    print_message "yellow" "请选择要执行的操作:"
    echo "  1. 启用 IPv6"
    echo "  2. 禁用 IPv6"
    echo "  3. 刷新状态"
    echo "  4. 退出脚本"
    echo
}

# --- 主逻辑 ---

# 检查root权限
check_root

# 循环显示菜单，直到用户选择退出
while true; do
    show_menu
    read -p "请输入选项 [1-4]: " choice

    case "$choice" in
        1)
            enable_ipv6
            read -p "按 [Enter] 键返回主菜单..."
            ;;
        2)
            disable_ipv6
            read -p "按 [Enter] 键返回主菜单..."
            ;;
        3)
            # 刷新状态就是重新显示菜单，所以什么都不用做
            print_message "blue" "状态已刷新。"
            sleep 1
            ;;
        4)
            print_message "yellow" "脚本已退出。"
            break
            ;;
        *)
            print_message "red" "无效输入！请输入 1 到 4 之间的数字。"
            sleep 2
            ;;
    esac
done

exit 0

