# FanTune

一款简洁、原生的 macOS 风扇监控与温控工具。

[官方网站](https://fantune.app) · [English](#english)

FanTune 通过 AppleSMC 读取 Mac 的实时温度与风扇状态，并提供三种容易理解的散热策略。应用使用原生 AppKit 构建，支持菜单栏运行、实时温度展示与安全的自动控制恢复。

> 当前版本：1.0.2 · 支持 macOS 14 及以上 · Universal（Apple Silicon 与 Intel）

## 主要功能

- 实时显示 CPU、GPU、SSD 温度
- 读取风扇数量、实际转速、目标转速和固件转速范围
- 提供“悄悄吹”“舒服吹”“大力吹”三种温控策略
- 温度曲线实时更新
- 支持菜单栏常驻及自定义展示内容
- 支持登录 Mac 后自动启动
- 一次授权后由本机辅助服务执行风扇控制
- 应用退出或辅助服务失联时自动恢复 macOS 温控
- 原生白色界面、动态风扇与气流效果

## 安装

1. 前往 [FanTune 官网](https://fantune.app) 下载最新的 Universal 安装镜像。
2. 打开 DMG，将 **FanTune** 拖入 **Applications（应用程序）**。
3. 首次启动时，按照应用内提示完成系统授权。

如果 macOS 提示无法验证开发者，请在 Finder 中右键点击 FanTune，选择“打开”，并再次确认；也可以前往“系统设置 → 隐私与安全性”允许打开。

## 从源码构建

### 环境要求

- macOS 14 或更高版本
- Xcode Command Line Tools
- 支持 AppleSMC 的 Mac

### 构建应用

```bash
./build-app.sh
```

应用将生成在 `dist/FanTune.app`。

### 构建 DMG

生成安装镜像还需要 Node.js、npm 和 ImageMagick：

```bash
./build-dmg.sh
```

默认输出为 `dist/FanTune-1.0.2-Universal.dmg`。

## 工作原理与安全保护

FanTune 的界面进程不会直接以管理员权限持续运行。需要控制风扇时，应用会安装并连接本机辅助服务，由辅助服务访问 AppleSMC。控制目标始终限制在固件报告的最低与最高转速范围内。

为避免异常退出后风扇停留在手动模式，辅助服务包含失联保护；应用正常退出时也会主动将风扇控制权归还 macOS。

手动调整风扇会暂时覆盖系统自动温控。请勿修改、移除或绕过项目中的转速边界与恢复保护。

## 项目结构

```text
Native/                 AppKit 应用与 AppleSMC 辅助服务
Resources/              应用图标和 DMG 安装界面资源
Sources/FanTune/         SwiftUI 原型代码
Info.plist               macOS 应用信息
build-app.sh             Universal 应用构建脚本
build-dmg.sh             DMG 构建脚本
THIRD_PARTY_NOTICES.txt  第三方组件声明
```

## 贡献

欢迎提交 Issue 和 Pull Request。提交代码前，请确保应用能够成功构建，并重点验证温度采样、策略切换、菜单栏生命周期以及自动恢复温控行为。

## 许可证

本仓库目前尚未包含开源许可证。在许可证发布前，代码版权由项目作者保留；公开可见不代表自动授予复制、修改或分发权限。

---

## English

A clean, native fan monitoring and thermal control utility for macOS.

[Official Website](https://fantune.app) · [中文](#fantune)

FanTune reads live temperatures and fan data through AppleSMC and provides three approachable cooling profiles. Built with native AppKit, it supports menu bar operation, live temperature display, and automatic restoration of macOS fan control.

> Current version: 1.0.2 · Requires macOS 14 or later · Universal (Apple Silicon and Intel)

## Features

- Live CPU, GPU, and SSD temperature readings
- Fan count, actual RPM, target RPM, and firmware RPM range
- Three cooling profiles: Quiet, Balanced, and Performance
- A continuously updating temperature chart
- Menu bar operation with configurable metrics
- Launch at login
- A local privileged helper for fan control after authorization
- Automatic restoration of macOS fan control on exit or helper disconnect
- Native light interface with animated fan and airflow effects

## Installation

1. Download the latest Universal disk image from the [FanTune website](https://fantune.app).
2. Open the DMG and drag **FanTune** into **Applications**.
3. Launch FanTune and follow the in-app instructions to complete system authorization.

If macOS cannot verify the developer, Control-click FanTune in Finder, choose **Open**, and confirm again. You can also allow the app from **System Settings → Privacy & Security**.

## Build from Source

### Requirements

- macOS 14 or later
- Xcode Command Line Tools
- A Mac with AppleSMC support

### Build the app

```bash
./build-app.sh
```

The application is generated at `dist/FanTune.app`.

### Build the DMG

Creating the installer also requires Node.js, npm, and ImageMagick:

```bash
./build-dmg.sh
```

The default output is `dist/FanTune-1.0.2-Universal.dmg`.

## How It Works and Safety

The FanTune UI does not run continuously with administrator privileges. When fan control is needed, the app installs and connects to a local privileged helper that communicates with AppleSMC. Requested speeds are always clamped to the minimum and maximum RPM values reported by the firmware.

The helper includes a disconnect failsafe, and the app explicitly returns fan control to macOS during a normal shutdown. This prevents fans from remaining in manual mode after an unexpected interruption.

Manual fan control temporarily overrides macOS automatic thermal management. Do not remove or bypass the RPM limits and recovery safeguards included in the project.

## Project Structure

```text
Native/                 AppKit application and AppleSMC helper
Resources/              App icon and DMG installer assets
Sources/FanTune/         SwiftUI prototype sources
Info.plist               macOS application metadata
build-app.sh             Universal application build script
build-dmg.sh             DMG build script
THIRD_PARTY_NOTICES.txt  Third-party notices
```

## Contributing

Issues and pull requests are welcome. Before submitting code, make sure the app builds successfully and verify temperature sampling, profile switching, menu bar lifecycle, and automatic restoration of macOS fan control.

## License

This repository does not currently include an open-source license. Until a license is published, copyright is retained by the project author; public source availability does not grant permission to copy, modify, or redistribute the code.
