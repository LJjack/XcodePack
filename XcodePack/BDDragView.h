//
//  BDDragView.h
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BDDragView : NSView

@property (nonatomic, copy) void(^didFinishPath)(NSString *path);

@end
