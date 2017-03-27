//
//  BuildController.m
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "BuildController.h"
#import "PgySettingsController.h"
#import "PgyUploadController.h"
#import "XcodePack-Swift.h"
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
                if (stauts != 0) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = @"警告";
                    alert.informativeText = @"出错，可能是证书的问题！";
                    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                        
                    }];
                } else if (stauts == 0 && self.uploadPgyBtn.state) {
                    [self performSegueWithIdentifier:@"showUpload" sender:path];
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
    } else if ([segue.identifier isEqualToString:@"showUpload"]) {
        PgyUploadController *controller = [segue destinationController];
        controller.path = sender;
    }
}

@end
