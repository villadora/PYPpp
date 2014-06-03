//
//  VDStartViewController.m
//  PYPpp
//
//  Created by villadora on 14-5-24.
//  Copyright (c) 2014年 villadora. All rights reserved.
//

#import "VDStartViewController.h"
#import "VDGameViewController.h"

@interface VDStartViewController ()

- (void) startNewGame;


@end

@implementation VDStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [[UIImage imageNamed:@"start_bg.jpeg"] drawInRect:self.view.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    return self;
}


- (void) startNewGame {
    
    VDGameViewController* controller = [[VDGameViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)startBtnClick:(id)sender {
    [self startNewGame];
}

- (IBAction)exitBtnClick:(id)sender {
    exit(0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
