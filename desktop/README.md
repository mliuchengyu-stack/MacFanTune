# MacFanTune

一款面向 macOS 的原生风扇监控与调速应用，支持 Apple Silicon，并包含可交互的官网演示界面。

## 功能

- 读取 AppleSMC 风扇数量、实际 RPM、目标 RPM 和硬件转速范围
- 悄悄吹、舒服吹、大力吹三种控制策略
- 一次管理员授权的本机辅助服务
- 15 秒失联保护，自动归还 macOS 温控
- 原生 AppKit 白色界面与动态风扇、气流效果
- HTML/CSS/JavaScript 交互演示

## 构建原生应用

```bash
./build-app.sh
```

生成结果位于 `dist/FanTune.app`。

## 官网演示

直接打开 `index.html`，或使用任意静态文件服务预览。网页仅模拟温度和风扇控制，不会访问 AppleSMC。

## 安全提示

手动风扇控制会覆盖 macOS 的自动热管理。应用会限制目标转速在固件报告范围内，并在正常退出或辅助服务失联时恢复自动控制。
