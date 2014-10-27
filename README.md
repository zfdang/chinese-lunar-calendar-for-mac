# 1.MAC下的万年历(状态栏小工具)
## 功能说明、界面、使用方法见：

### [calendar.zfdang.com](http://calendar.zfdang.com)

# 2.Code Explanation
This is a MenuExtra app which shows a simple chinese lunar calendar.

You can use CMD+Drag to move the location of this item.

there are three projects in this application.

### 2.1. CLCLauncher
this application is a agent application, which launch "MenuCracker.menu" & "CLCMenuExtra.menu"

It dependens on MenuCracker.menu and CLCMenuExtra.menu (these two bundles will be packed into CLCLauncher.app as resources)

### 2.2. CLCMenuExtra
This bundle finishs the actual functionality.
this bundle is using un-official NSMenuExtra API.

# 3.Simple Demo for MenuExtra
if you want to learn how to develop menulet application, you can start with v0.1 release. It has a basic framework, but with full functionality:

[v0.1 release](https://github.com/zfdang/chinese-lunar-calendar-for-mac/releases)

# 4.Referrences
http://duhanebel.wordpress.com/2010/04/02/nsmenuextra-how-to-work-with-undocumented-apis/

https://github.com/aschuch/AXStatusItemPopup

http://sourceforge.net/projects/menucracker/

