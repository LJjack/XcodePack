//
//  NSAlert+LJAdd.m
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "NSAlert+LJAdd.h"

@implementation NSAlert (LJAdd)

+ (void)lj_alertWithMessage:(NSString *)message infoText:(NSString *)infoText {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = infoText;
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}

@end
