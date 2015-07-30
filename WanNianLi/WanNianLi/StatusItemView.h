//
//  StatusItemView.h
//  CLCStatusItem
//
//  Created by Zhengfa DANG on 2015-7-30.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Protocol to handle StatusItem actions
@protocol StatusItemActionProtocol <NSObject>

@optional
- (void)leftClickOnStatusItem;
- (void)rightClickOnStatusItem;

@end



// StatusItemView: customized view to show icon in menubar
@interface StatusItemView : NSControl {
    BOOL _isHighlighted;

    NSImage *_image;
    NSImage *_alternateImage;
    NSMenu *_menu;
    NSMenu *_rightMenu;
}

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *alternateImage;
@property (nonatomic, retain) NSMenu *menu;
@property (nonatomic, retain) NSMenu *rightMenu;

@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, unsafe_unretained) id<StatusItemActionProtocol> delegate;


- (id)initWithStatusItem:(NSStatusItem *)statusItem;

-(void)popUpMenu;               //pops up the currently stored menu
-(void)popUpRightMenu;          //if right menu is set, pops up right menu
-(void)popUpMenu:(NSMenu*)menu; //pops up the passed menu


@end
