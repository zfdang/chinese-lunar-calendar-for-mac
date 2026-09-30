# 发布流程

以下是新版 WanNianLiSwift 的发布流程。版本号只来自 git tag，不需要修改代码中的版本号。

## 1. 准备

1. 代码合并到 master，确认 CI（`.github/workflows/release.yml`）通过：
   它会运行农历基准数据校验（`WanNianLiSwift/scripts/check-golden.sh`）并构建两个版本
2. 在 [CHANGELOG.md](CHANGELOG.md) 中把“未发布”一节改为新版本号和日期

## 2. 发布

```bash
git tag v4.2 && git push origin v4.2
```

GitHub Actions 会构建 Apple 芯片和 Intel 芯片两个版本，并创建 GitHub Release
（`WanNianLiSwift-<版本>-AppleSilicon.zip`、`WanNianLiSwift-<版本>-Intel.zip`）。

## 3. 更新网站

网站（calendar.zfdang.com，即仓库中的 `docs/` 目录）提供的下载文件需要更新为新版本：

```bash
WanNianLiSwift/scripts/publish-website.sh v4.2
```

脚本会从 GitHub Release 下载两个安装包，检查架构和版本号后复制到 `docs/`，并更新 `docs/version.json`
（网页上显示的版本号来自这个文件）。之后提交并合并到 master，GitHub Pages 会自动更新。

## 更新假日信息（不需要发布新版本）

国务院每年（一般在 11 月）公布下一年的放假安排后：

1. 在 `docs/data/holidays.json` 中添加新一年的数据，并把 `version` 改为当天日期（如 `20261105`）
2. 合并到 master，GitHub Pages 更新后，用户的应用会在一周内自动更新（也可以在菜单中手动“更新假日信息”）
3. 如果仍需支持旧版应用，用 `WanNianLiSwift/scripts/export-holidays-js.py docs/data/holidays.json WanNianLi/WanNianLi/Resources/vendors/holidays.js` 生成旧版使用的 holidays.js

## 旧版（WanNianLi，Objective-C）

旧版已不再发布新版本。当年的流程是：增加 `WanNianLi/WanNianLi/Resources/vendors/VERSION` 中的版本号、
修改 xib 中的程序版本，用 Xcode 构建后替换网站上的 WanNianLi.app 压缩包。
