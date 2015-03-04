$ brew install class-dump
$ class-dump -H /System/Library/PrivateFrameworks/SystemUIPlugin.framework/Versions/A/SystemUIPlugin

============

source files were updated according to:
http://duhanebel.wordpress.com/2010/04/02/nsmenuextra-how-to-work-with-undocumented-apis/

This will create a bunch of .h files in the current working directory. We are interested in NSMenuExtra.h and NSMenuExtraView.h only. 
DockExtra.h is related to Dock’s plugins which is now obsolete in Snow Leopard due to the introduction of Dock Tile Plug-in architecture and NSMenuExtraAnimated.h is a subclass of NSMenuExtra that helps in the creation of MenuExtra with animated images (TimeMachine for example). 
CDStructure.h contains well-knows struct GCPoint, GCRect, GCSize which are already defined in any cocoa project.


Open NSMenuExtra.h, go to line:

- (id)accessibilityHitTest:(struct CGPoint)arg1;
and change it to:

- (id)accessibilityHitTest:(CGPoint)arg1;
Then open NSMenuExtraView.h and do the same changing:

- (id)initWithFrame:(struct CGRect)arg1 menuExtra:(id)arg2;
- (void)drawRect:(struct CGRect)arg1;
to:

- (id)initWithFrame:(CGRect)arg1 menuExtra:(id)arg2;
- (void)drawRect:(CGRect)arg1;
Last thing, open “NSMenuExtra.h” and remove the following line:

#import "NSStatusItem.h"
then open “NSMenuExtraView.h” and remove the following line:

#import "NSView.h"
Now you have all the include files needed to work with a NSMenuExtra.

