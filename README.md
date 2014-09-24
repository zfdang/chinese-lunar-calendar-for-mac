# Chinese Lunar Calendar for Mac
This is a MenuExtra bundle which shows a simple chinese lunar calendar.

You can use CMD+Drag to move the location of this item.

## Code Structure
there are two projects in this application.

### 1. CLCLauncher
this application is a agent application, which launch "MenuCracker.menu" & "CLCMenuExtra.menu"

It dependens on MenuCracker.menu and CLCMenuExtra.menu (these two bundles will be packed into CLCLauncher.app as resources)

### 2. CLCMenuExtra
This bundle finishs the actual funcationalityy.
this bundle is using un-official NSMenuExtra interfaces.



## Referrences
http://duhanebel.wordpress.com/2010/04/02/nsmenuextra-how-to-work-with-undocumented-apis/
http://sourceforge.net/projects/menucracker/
