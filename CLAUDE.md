# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 Inno Setup 的 Dufs 文件服务器 Windows 安装程序。将 Dufs (Rust 轻量级文件服务器) 打包成安装程序,提供环境配置和右键菜单集成。

## 项目结构

```
dufstray/
├── setup.iss              # Inno Setup 安装脚本
├── dufs-launcher.bat      # 批处理启动器(带自动关闭)
├── config.yaml            # 配置文件(可选)
├── dufs.exe               # Dufs 可执行文件 (需从官方下载)
├── favicon.ico            # 右键菜单图标 (从 SVG 转换)
├── .gitignore             # Git 忽略规则
└── CLAUDE.md              # 本文档
```

编译后生成: `output/dufs-setup.exe`

## 核心架构

### 右键菜单集成 (setup.iss)

通过注册表实现三个位置的右键菜单:

1. **文件夹图标** → `HKCR\Directory\shell\DufsHere` → 参数 `%1`
2. **文件夹背景** → `HKCR\Directory\Background\shell\DufsHere` → 参数 `%V`
3. **驱动器** → `HKCR\Drive\shell\DufsHere` → 参数 `%1`

所有菜单调用 `dufs-launcher.bat` 并传递路径参数。

**图标**: 使用自定义 `favicon.ico` (从 mdi--share-all.svg 转换而来)

### PATH 环境变量管理 (setup.iss)

Pascal 代码自动管理系统 PATH:
- **安装**: `AddToPath()` 添加安装目录到 PATH
- **卸载**: `RemoveFromPath()` 清理 PATH
- **注册表**: `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`

### 启动脚本逻辑 (dufs-launcher.bat)

1. **接收路径参数**: 切换到目标工作目录 (`cd /d`)
2. **读取配置文件**: 从安装目录的 `config.yaml` 读取 `auto_shutdown_seconds`
3. **默认超时设置**: 测试阶段默认 10 秒,生产环境建议 1800 秒(30分钟)
4. **智能查找 dufs.exe**: 优先 PATH,备用安装目录
5. **后台启动服务**: 使用 `start /b` 后台运行 dufs
6. **自动关闭定时器**: 使用 `timeout` 命令倒计时
7. **强制停止进程**: 超时后使用 `taskkill /f` 强制关闭 dufs.exe
8. **错误处理**: 完善的目录访问和命令查找错误提示

### 配置文件 (config.yaml)

放置在安装目录(与 dufs-launcher.bat 同目录),用于自定义设置:

```yaml
# 自动关闭时间(秒)
# 测试: 10
# 生产: 1800 (30分钟)
auto_shutdown_seconds: 1800
```

**优先级**: config.yaml > 脚本默认值(10秒)

## 常用命令

### 编译安装程序

**前提**:
- 安装 Inno Setup: https://jrsoftware.org/isdl.php
- 下载 dufs.exe: https://github.com/sigoden/dufs/releases

**编译**:
```bash
# 图形界面: 右键 setup.iss → Compile
# 命令行:
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss
```

**测试**:
```bash
# 测试启动脚本
dufs-launcher.bat "D:\test"

# 安装并测试
output\dufs-setup.exe  # 需管理员权限
```

## 快速修改

### 自动关闭时间
```batch
set "DEFAULT_TIMEOUT=10"  # dufs-launcher.bat:6 (脚本默认值)
```
或在安装目录创建 `config.yaml`:
```yaml
auto_shutdown_seconds: 1800  # 30分钟
```

### 版本号
```pascal
#define MyAppVersion "1.0.0"  // setup.iss:5
```

### 右键菜单文本
```pascal
ValueData: "Start Dufs Here"  // setup.iss:50,55,60
```

### 右键菜单图标
```pascal
ValueData: "{app}\favicon.ico"  // setup.iss:52,57,62
```
图标来源: Material Design Icons 的 share-all 图标,通过 SVG 转 ICO 生成

### 安装路径
```pascal
DefaultDirName={autopf}\{#MyAppName}  // setup.iss:20
```

## 调试技巧

**检查注册表**:
```
regedit → HKCR\Directory\shell\DufsHere\command
```

**检查 PATH**:
```bash
echo %PATH%
where dufs
```

**批处理调试**: 在 dufs-launcher.bat 添加 `echo` 显示参数和路径

## 注意事项

- **管理员权限**: 安装时必需(修改注册表和环境变量)
- **环境变量生效**: 需重启 CMD 或重新登录
- **编码**: 所有文件使用 ANSI 编码,英文注释(避免乱码)
- **兼容性**: Windows 7+, 建议 Inno Setup 6.x
