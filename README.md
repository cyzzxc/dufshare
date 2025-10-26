# DufShare

Dufs Windows 安装程序 - 右键启动文件服务器

## 特性

- 右键菜单快速启动
- 自动端口冲突检测
- 定时自动关闭
- 配置文件支持

## 下载

[Releases](https://github.com/cyzzxc/dufshare/releases)

## 使用

1. 安装 `dufshare-setup.exe`
2. 右键任意文件夹 → "Start Dufs Here"
3. 浏览器访问显示的地址

## 配置

安装目录下的 `config.yaml`:

```yaml
auto_shutdown_seconds: 1800  # 30分钟
```

## 许可证

MIT License

**第三方组件**:
- [dufs](https://github.com/sigoden/dufs) - Apache-2.0 OR MIT
