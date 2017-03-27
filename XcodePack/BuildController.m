//
//  BuildController.m
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "BuildController.h"
#import "PgySettingsController.h"
#import "XcodePack-Swift.h"
#import "AFNetworking.h"
#import "BDDragView.h"
#import "PgyConfig.h"

@interface BuildController ()<PgySettingsControllerDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet BDDragView *dragView;
@property (weak) IBOutlet NSButton *runBtn;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSButton *uploadPgyBtn;

@property (nonatomic, copy) NSString *projectPath;

@end


@implementation BuildController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.dragView.didFinishPath = ^(NSString *path) {
        weakSelf.textView.string = path;
        weakSelf.projectPath = path;
    };
    
    [self handleUploadPgyBtnState];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)clickUploadPgyBtn:(NSButton *)sender {
    if (sender.state == 1) {
        [self performSegueWithIdentifier:@"showPgySettings" sender:nil];
    }
}


- (IBAction)clickAddBtn:(NSButton *)sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setResolvesAliases:YES];
    [oPanel setAllowedFileTypes:@[@"xcodeproj",@"xcworkspace"]];
    [oPanel beginSheetModalForWindow:[self.view window]
                   completionHandler:^(NSInteger returnCode) {
       if (returnCode == NSModalResponseOK) {
           self.projectPath = oPanel.URLs.firstObject.path;
       }
    }];
}

- (IBAction)clickRunBtn:(NSButton *)sender {
    self.dragView.hidden = YES;
    self.textView.string = @"";
    sender.enabled = NO;
    self.indicator.hidden = NO;
    [self.indicator startAnimation:nil];
    self.uploadPgyBtn.enabled = NO;
    
    NSString *project = self.projectPath.lastPathComponent;
    NSString *path = self.projectPath.stringByDeletingLastPathComponent;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AutoPack *pack = [[AutoPack alloc] init:path project:project];
        pack.runningLog = ^(NSString *log) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *outputString = [NSString stringWithFormat:@"%@ \n %@", self.textView.string,log];
                self.textView.string = outputString;
                NSRange range = NSMakeRange(outputString.length, 0);
                [self.textView scrollRangeToVisible:range];
            });
        };
        pack.didFinish = ^(int32_t stauts, NSString *path) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator stopAnimation:nil];
                self.uploadPgyBtn.enabled = YES;
                if (stauts == 0 && self.uploadPgyBtn.state) {
                    [self uploadPgy:path];
                }
            });
        };
        [pack build];
    });
}

#pragma mark - PgySettingsControllerDelegate

- (void)pgySttingsControllerDidClosed:(PgySettingsController *)controller {
    [self handleUploadPgyBtnState];
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
    
    NSURLSessionUploadTask * uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@  %@", responseObject, error);
    }];
    [uploadTask resume];
}

- (void)handleUploadPgyBtnState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userKey = [defaults objectForKey:kUserKey];
    self.uploadPgyBtn.state = userKey.length != 0?1:0;
}

#pragma mark - Nav

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPgySettings"]) {
        PgySettingsController * controller = [segue destinationController];
        controller.delegate = self;
    }
}

@end
