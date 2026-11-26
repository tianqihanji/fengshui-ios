# 掌上罗盘 · iOS 云端构建仓

传统风水综合盘（31 圈层）SwiftUI 原生工程，由 GitHub Actions 在云端 macOS 上编译出未签名 IPA。

## 目录

```
fengshui-ios/
├─ project.yml                       # XcodeGen 工程定义
├─ Info.plist                       # 显示名「掌上罗盘」、定位文案、竖屏
├─ FengShuiCompass/
│   ├─ FengShuiCompassApp.swift     # App 入口
│   ├─ Models/CompassData.swift     # 31 圈层数据与角度关系
│   ├─ Services/HeadingService.swift  # 磁力计航向（CoreLocation）
│   └─ Views/                        # 盘面与读数面板
├─ .github/workflows/ios-build.yml   # 云端编译未签名 IPA
└─ README.md
```

## 云端出包

推送 main 分支后，Actions 自动运行；也可在 Actions 页手动触发。产物为 `FengShuiCompass-unsigned.ipa`，在运行记录 Artifacts 中下载，保留 90 天。

构建参数：bundle id `com.tianqi.FengShuiCompass`，最低系统 iOS 16.0，arm64，Release，不签名。

## 权限

仅使用定位（磁力计航向与磁偏角换算真北）。模拟器无磁力计，自动落到手动转盘模式；真机需允许定位权限。

## 装到 iPhone

未签名 IPA 用 Sideloadly（或 AltStore）以本人 Apple ID 签名侧载；装完在「设置 → 通用 → VPN 与设备管理」信任开发者。免费账号签名 7 天有效，到期重新签名即可。

## 说明

- 盘面参数与同套网页原型一一对应；流派校改项集中在 `CompassData.swift`。
- 产物署名：汉基科技。
