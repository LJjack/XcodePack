//
//  BuildController.m
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "BuildController.h"
#import "BDDragView.h"

#import "XcodePack-Swift.h"

#import "AFNetworking.h"

@interface BuildController ()

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
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
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

- (void)uploadPgy:(NSString *)path {
    NSString *fileName = [path componentsSeparatedByString:@"/"].lastObject;
    NSString *urlString = @"https://qiniu-storage.pgyer.com/apiv1/app/upload";
    NSDictionary *parameters = @{@"uKey":@"c1d70843df29d3f5addd57af95a381ca",
                                 @"_api_key":@"de68eda891fae6b185d92362f74f6159",
                                 @"installType":@"2",
                                 @"password":@"bj123456"};
    
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

@end
