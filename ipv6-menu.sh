#!/bin/bash

# ==============================================================================
#
# ipv6-menu.sh - v1.1
# 一个通过交互式菜单快速开启、关闭或检查IPv6状态的脚本
#
# v1.1 更新: 解决了启用IPv6后公网地址不恢复的问题，通过重启网络接口
#           或服务来强制刷新。同时优化了状态检测逻辑。
#
# ==============================================================================

# 定义需要修改的sysctl参数
IPV6_PARAMS=(
    "net.ipv6.conf.all.disable_ipv6"
    "net.ipv6.conf.default.disable_ipv6"
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
        print_message "red" "错误：此脚本需要以 root 权限运行。请使用 'sudo ipv6-menu'"
        exit 1
    fi
}

# 函数：启用IPv6
enable_ipv6() {
    print_message "blue" "🚀 正在启用 IPv6..."
    
    # 1. 永久启用 (修改配置文件)
    for param in "${IPV6_PARAMS[@]}"; do
        sed -i "/^${param//./\\.}[[:space:]]*=[[:space:]]*1/d" "$SYSCTL_CONF"
    done
    
    # 2. 临时启用 (立即生效)
    sysctl -p > /dev/null
    for param in "${IPV6_PARAMS[@]}"; do
        sysctl -w "${param}=0" > /dev/null
    done

    # 3. 【关键修复】触发网络服务刷新以重新获取IPv6地址
    print_message "blue" "正在尝试刷新网络服务以获取 IPv6 地址..."
    if command -v nmcli &> /dev/null; then
        # 适用于使用 NetworkManager 的系统 (如 Ubuntu Desktop, CentOS/RHEL GUI)
        print_message "yellow" "检测到 NetworkManager，正在重新加载连接..."
        nmcli networking off && nmcli networking on
    elif command -v systemctl &> /dev/null && systemctl is-active --quiet networking.service; then
        # 适用于使用传统 networking 服务的系统 (如旧版 Debian/Ubuntu Server)
        print_message "yellow" "检测到 networking.service，正在重启..."
        systemctl restart networking.service
    elif command -v systemctl &> /dev/null && systemctl is-active --quiet systemd-networkd.service; then
        # 适用于使用 systemd-networkd 的系统
        print_message "yellow" "检测到 systemd-networkd，正在重启..."
        systemctl restart systemd-networkd.service
    else
        print_message "red" "警告：未能检测到主流网络管理服务。可能需要您手动重启网络或服务器才能恢复公网IPv6。"
    fi
    
    sleep 2 # 等待网络服务稳定
    print_message "green" "✅ IPv6 启用流程已完成！"
}

# 函数：禁用IPv6
disable_ipv6() {
    print_message "blue" "🚀 正在禁用 IPv6..."

    # 1. 永久禁用 (修改配置文件)
    for param in "${IPV6_PARAMS[@]}"; do
        sed -i "/^${param//./\\.}/d" "$SYSCTL_CONF"
        echo "${param} = 1" >> "$SYSCTL_CONF"
    done

    # 2. 临时禁用 (立即生效)
    sysctl -p > /dev/null
    for param in "${IPV6_PARAMS[@]}"; do
        sysctl -w "${param}=1" > /dev/null
    done

    print_message "green" "✅ IPv6 已成功禁用！"
}

# 函数：检查当前状态
check_status() {
    # 【优化】更可靠的状态检测：检查是否存在公网IPv6地址
    if ip -6 addr | grep -q "inet6.*global"; then
        print_message "green" "当前状态: 🟢 已启用 (检测到公网 IPv6 地址)"
        echo "IPv6 地址信息:"
        ip -6 addr | grep 'inet6' | sed 's/^[ \t]*/  /g'
    elif [[ $(sysctl -n net.ipv6.conf.all.disable_ipv6) -eq 0 ]]; then
        print_message "yellow" "当前状态: 🟡 已启用 (但未检测到公网 IPv6 地址)"
        echo "系统已允许IPv6，但网络接口可能未获取到公网地址。"
        echo "IPv6 地址信息:"
        ip -6 addr | grep 'inet6' | sed 's/^[ \t]*/  /g'
    else
        print_message "red" "当前状态: 🔴 已禁用"
    fi
}

# 函数：显示主菜单 (与之前版本相同)
show_menu() {
    clear
    print_message "blue" "=============================="
    print_message "blue" "    IPv6 状态管理脚本 v1.1"
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

# --- 主逻辑 (与之前版本相同) ---
check_root
while true; do
    show_menu
    read -p "请输入选项 [1-4]: " choice
    case "$choice" in
        1) enable_ipv6; read -p "按 [Enter] 键返回主菜单...";;
        2) disable_ipv6; read -p "按 [Enter] 键返回主菜单...";;
        3) print_message "blue" "状态已刷新。"; sleep 1;;
        4) print_message "yellow" "脚本已退出。"; break;;
        *) print_message "red" "无效输入！"; sleep 2;;
    esac
done
exit 0
