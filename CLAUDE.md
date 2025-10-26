# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 Inno Setup 的 Dufs 文件服务器 Windows 安装程序。将 Dufs (Rust 轻量级文件服务器) 打包成安装程序,提供环境配置和右键菜单集成。

## 项目结构

```
dufstray/
├── setup.iss              # Inno Setup 安装脚本
├── dufs-launcher.bat      # 批处理启动器
├── dufs.exe               # Dufs 可执行文件 (需从官方下载)
├── favicon.ico          # 右键菜单图标 (从 SVG 转换)
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

1. 接收路径参数并切换工作目录 (`cd /d`)
2. 智能查找 dufs.exe (优先 PATH,备用安装目录)
3. 启动 dufs 服务
4. 错误处理和用户提示

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
