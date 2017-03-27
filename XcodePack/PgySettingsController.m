//
//  PgySettingsController.m
//  XcodePack
//
//  Created by 刘俊杰 on 2017/3/24.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "PgySettingsController.h"
#import "PgyConfig.h"

@interface PgySettingsController ()

@property (weak) IBOutlet NSTextField *userKeyField;
@property (weak) IBOutlet NSTextField *apiKeyField;
@property (weak) IBOutlet NSTextField *pwdField;
@property (unsafe_unretained) IBOutlet NSTextView *destTextView;
@property (weak) IBOutlet NSPopUpButton *selectedBtn;

@end

@implementation PgySettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    self.userKeyField.stringValue = [defauts objectForKey:kUserKey]?:@"";
    self.apiKeyField.stringValue = [defauts objectForKey:kApiKey]?:@"";
    self.pwdField.stringValue = [defauts objectForKey:kPwdKey]?:@"";
    self.destTextView.string = [defauts objectForKey:kDestKey]?:@"";
    [self.selectedBtn selectItemAtIndex:[defauts integerForKey:kSelectedKey]];
}

- (IBAction)selectedBtn:(NSPopUpButton *)sender {
    self.pwdField.enabled = [sender.titleOfSelectedItem isEqualToString:@"密码安装"];
}

- (IBAction)clickCloseBtn:(NSButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pgySttingsControllerDidClosed:)]) {
        [self.delegate pgySttingsControllerDidClosed:self];
    }
    [self dismissController:nil];
}

- (IBAction)sureBtn:(NSButton *)sender {
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    [defauts setObject:self.userKeyField.stringValue forKey:kUserKey];
    [defauts setObject:self.apiKeyField.stringValue forKey:kApiKey];
    [defauts setInteger:self.selectedBtn.indexOfSelectedItem forKey:kSelectedKey];
    [defauts setObject:self.pwdField.stringValue forKey:kPwdKey];
    [defauts setObject:self.destTextView.string forKey:kDestKey];
    [defauts synchronize];
}

@end
