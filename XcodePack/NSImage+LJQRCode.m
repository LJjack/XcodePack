//
//  NSImage+LJQRCode.m
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "NSImage+LJQRCode.h"

@import CoreImage;

@implementation NSImage (LJQRCode)

+ (NSImage *)lj_createQRCodeWithString:(NSString *)text size:(CGFloat)size{
    CIImage *image = [self createQRCodeImage:text];
    return [self resizeQRCodeImage:image withSize:size];
}

#pragma mark - Private Methods

//使用iOS 7后的CIFilter对象操作，生成二维码图片imgQRCode（会拉伸图片，比较模糊，效果不佳）
+ (CIImage *)createQRCodeImage:(NSString *)source {
    // 1. 实例化一个滤镜
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 1.1 设置filter的默认值
    // 因为之前如果使用过滤镜，输入有可能会被保留，因此，在使用滤镜之前，最好设置恢复默认值
    [filter setDefaults];
    
    // 2. 将传入的字符串转换为NSData
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    
    // 3. 将NSData传递给滤镜(通过KVC的方式，设置inputMessage)
    [filter setValue:data forKey:@"inputMessage"];
    // 4. 设置纠错等级越高；
    //即识别越容易，值可设置为L(Low) |  M(Medium) | Q | H(High)
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    // 5. 由filter输出图像
    return filter.outputImage;
}

+ (NSImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    
    //Release
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    NSSize newSize = NSMakeSize(width, height);
    NSImage *uiImage = [[NSImage alloc] initWithCGImage:imageRefResized size:newSize];
    CGImageRelease(imageRefResized);
    return uiImage;
}


@end
