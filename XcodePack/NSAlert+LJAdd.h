//
//  NSAlert+LJAdd.h
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (LJAdd)

+ (void)lj_alertWithMessage:(NSString *)message infoText:(NSString *)infoText;

@end
