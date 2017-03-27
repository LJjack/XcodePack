//
//  PgySettingsController.h
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/24.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PgySettingsController;

@protocol PgySettingsControllerDelegate <NSObject>

@optional
- (void)pgySttingsControllerDidClosed:(PgySettingsController *)controller;

@end

@interface PgySettingsController : NSViewController

@property (nonatomic, weak) id<PgySettingsControllerDelegate> delegate;

@end
