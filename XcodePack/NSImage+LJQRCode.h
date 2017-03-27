//
//  NSImage+LJQRCode.h
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (LJQRCode)


/**
 *  生成二维码
 * 二维码的实现是将字符串传递给滤镜，滤镜直接转换生成二维码图片
 *
 *  @param text 字符串
 *  @param size 大小
 *
 *  @return 二维码图像
 */
+ (NSImage *)lj_createQRCodeWithString:(NSString *)text size:(CGFloat)size;

@end
