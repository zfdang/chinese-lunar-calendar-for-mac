# 1.MAC下的状态栏万年历
## 功能说明、界面、使用方法见：

### [calendar.zfdang.com](https://calendar.zfdang.com)

# 2.Code Explanation
This is a menubar app which shows a simple chinese lunar calendar for OSX.

There are three different implementations for this app:

### 2.0. WanNianLiSwift (recommended, macOS 13+)
A native rewrite in Swift (AppKit + SwiftUI) with the same features, no WebView.
Lunar dates come from Foundation's Chinese calendar (verified day by day against the Hong Kong Observatory tables).
Build with `WanNianLiSwift/scripts/build-app.sh` (Command Line Tools only). See [WanNianLiSwift/README.md](WanNianLiSwift/README.md).

### 2.1. WanNianLi
this project is using the official NSStatusItem to implement the menubar app.
Its posittion in the icon bar can't be moved.

### 2.2. CLCLauncher + CLCMenuExtra
these two projects are using the un-official NSMenuExtra (hacking way) to implement the menubar app. 
The calendar icon works in the same way with system's icon. You can use CMD+Drag to move it or remove it.

CLCLauncher: this project is a agent application, which launch "MenuCracker.menu" & "CLCMenuExtra.menu"

It dependens on MenuCracker.menu and CLCMenuExtra.menu (these two bundles will be packed into CLCLauncher.app as resources)


CLCMenuExtra: this project finishs the actual functionality.
this bundle is using un-official NSMenuExtra API.


# 3.Referrences
http://duhanebel.wordpress.com/2010/04/02/nsmenuextra-how-to-work-with-undocumented-apis/

https://github.com/aschuch/AXStatusItemPopup

http://sourceforge.net/projects/menucracker/


# 4.License
[MIT](LICENSE)。旧版目录中的第三方组件使用各自的许可证（AFNetworking: MIT，MenuCracker: Artistic License）。

更新历史见 [CHANGELOG.md](CHANGELOG.md)，发布流程见 [RELEASE.md](RELEASE.md)。
