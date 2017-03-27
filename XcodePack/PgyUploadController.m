//
//  PgyUploadController.m
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/27.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "PgyUploadController.h"
#import "NSImage+LJQRCode.h"
#import "AFNetworking.h"
#import "PgyConfig.h"

@interface PgyUploadController ()
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *appNameField;

@end

@implementation PgyUploadController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.path) {
        [self uploadPgy:self.path];
    }
}

- (void)uploadPgy:(NSString *)path {
    NSString *fileName = [path componentsSeparatedByString:@"/"].lastObject;
    NSString *urlString = @"https://qiniu-storage.pgyer.com/apiv1/app/upload";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    parameters[@"uKey"] = [defaults objectForKey:kUserKey]?:@"";
    parameters[@"_api_key"] = [defaults objectForKey:kApiKey]?:@"";
    NSString *pwd = [defaults objectForKey:kPwdKey];
    if (pwd.length) {
        parameters[@"password"] = pwd;
        parameters[@"installType"] = @"2";
    }
    parameters[@"updateDescription"] = [defaults objectForKey:kDestKey]?:@"";
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" fileName:fileName mimeType:@"form-data" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
    [[manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressIndicator.doubleValue = uploadProgress.fractionCompleted * 100;
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = responseObject[@"data"];
            NSString *appName = data[@"appName"];
            NSString *appURL = [NSString stringWithFormat:@"https://www.pgyer.com/%@",data[@"appShortcutUrl"]];
            if (appURL) {
                NSImage *image = [NSImage lj_createQRCodeWithString:appURL size:150];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                    self.appNameField.stringValue = appName;
                });
            }
        }
        NSLog(@"%@  %@", responseObject, error);
    }] resume];
}

@end
