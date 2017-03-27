//
//  PgyUploadController.h
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PgyUploadController;

@protocol PgyUploadControllerDelegate <NSObject>

@optional
- (void)pgyUploadControllerDidClosed:(PgyUploadController *)controller;

@end


@interface PgyUploadController : NSViewController

@property (nonatomic, copy) NSString *path;
@property (nonatomic, weak) id<PgyUploadControllerDelegate> delegate;

@end
