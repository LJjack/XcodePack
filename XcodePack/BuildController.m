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


@interface BuildController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet BDDragView *dragView;
@property (weak) IBOutlet NSButton *runBtn;
@property (weak) IBOutlet NSProgressIndicator *indicator;

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
    [oPanel setAllowedFileTypes:[self fileTypes]];
    
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
        [pack build];
    });
}

- (NSArray *)fileTypes {
    return @[@"xcodeproj",@"xcworkspace"];
}
@end
