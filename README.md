# ipv6-menu 脚本

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/language-Shell%20Script-blue.svg)](https://www.gnu.org/software/bash/)
[![Compatible with: Ubuntu, Debian, CentOS](https://img.shields.io/badge/Compatible%20with-Ubuntu%2C%20Debian%2C%20CentOS-orange.svg)](#兼容性)

一个为 Linux 服务器设计的交互式 `sysctl` 管理脚本，旨在让您能够通过简单直观的菜单，一键**启用**、**禁用**或**检查**系统的 IPv6 功能。

这个工具会自动修改内核参数并更新 `/etc/sysctl.conf` 配置文件，以确保您的设置在系统重启后依然生效。

---

## ✨ 功能特性

-   **交互式菜单**：提供清晰的数字选项，无需记忆复杂命令。
-   **状态智能显示**：自动检测并以彩色高亮显示当前 IPv6 的启用/禁用状态。
-   **永久生效**：自动更新 `sysctl.conf` 配置文件，确保设置在重启后保持不变。
-   **一键安装**：提供极简的安装命令，方便在新服务器上快速部署。
-   **安全检查**：脚本内置 root 权限检查，引导用户正确使用 `sudo`。
-   **高兼容性**：适用于所有主流的 Linux 发行版，如 Ubuntu, Debian, CentOS 等。

---

## 🚀 一键安装

在您的服务器上执行以下命令，即可完成 `ipv6-menu` 的下载和安装。

**推荐使用 `curl`:**
```bash
curl -sSL https://raw.githubusercontent.com/XIMOYA/ipv6-menu/main/install.sh | bash
```

**或者使用 `wget`:**
```bash
wget -qO- https://raw.githubusercontent.com/XIMOYA/ipv6-menu/main/install.sh | bash
```
安装脚本会自动将 `ipv6-menu` 命令部署到 `/usr/local/bin/` 目录下，使其成为一个全局可用的命令。

---

### 卸载工具

如果您想卸载 `ipv6-menu`，请执行以下命令：

```bash
curl -sSL https://raw.githubusercontent.com/XIMOYA/ipv6-menu/main/install.sh | bash -s uninstall
```

## 🕹️ 如何使用

安装完成后，通过 `sudo ipv6-menu` 命令启动脚本，即可看到操作菜单。

```bash
sudo ipv6-menu
```

您会看到类似下面的界面，根据提示输入数字即可：

![脚本使用截图]()

-   输入 `1`：启用 IPv6。
-   输入 `2`：禁用 IPv6。
-   输入 `3`：刷新并查看当前状态。
-   输入 `4`：安全退出脚本。

---

## 🛡️ 兼容性

本脚本通过修改 `sysctl` 内核参数来控制 IPv6，这是一种通用且标准的方法。因此，它理论上与所有使用 `sysctl` 的现代 Linux 发行版兼容，包括但不限于：

-   Ubuntu (所有版本)
-   Debian (所有版本)
-   CentOS / RHEL / AlmaLinux / Rocky Linux
-   Fedora
-   Arch Linux

---

## 🤝 贡献

欢迎您为这个项目做出贡献！如果您有任何好的想法或发现了 Bug，请随时：

1.  Fork 本仓库。
2.  创建您的功能分支。
3.  提交您的更改。
4.  将分支推送到远程。
5.  开启一个 Pull Request。

---

## 📄 许可证

本项目采用 [MIT 许可证](https://opensource.org/licenses/MIT)授权。详情请见 `LICENSE` 文件。
```
