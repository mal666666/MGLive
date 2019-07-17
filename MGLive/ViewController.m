//
//  ViewController.m
//  MGLive
//
//  Created by Mac on 2019/7/15.
//  Copyright © 2019 马 爱林. All rights reserved.
//

#import "ViewController.h"
#import "LiveViewController.h"
#import "ShowViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)rightItemClick:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"直播" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入房间号";
        textField.keyboardType =UIKeyboardTypePhonePad;
    }];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"开直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alert.textFields.firstObject.text.length) {
            LiveViewController *live =[[LiveViewController alloc]init];
            live.roomId =alert.textFields.firstObject.text;
            [self presentViewController:live animated:YES completion:nil];
        }
    }];
    UIAlertAction *sure1 = [UIAlertAction actionWithTitle:@"看直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alert.textFields.firstObject.text.length) {
            ShowViewController *show =[[ShowViewController alloc]init];
            show.roomId =alert.textFields.firstObject.text;
            [self presentViewController:show animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:sure];
    [alert addAction:sure1];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}


@end
