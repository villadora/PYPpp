//
//  VDGameViewController.m
//  PYPpp
//
//  Created by villadora on 14-5-29.
//  Copyright (c) 2014年 villadora. All rights reserved.
//

#import "VDGameViewController.h"
#import "PinYin4Objc.h"

#import "Definition.h"


@interface VDGameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *stickbtn;

@property (weak, nonatomic) IBOutlet UIButton *nextAnswer;

@property (weak, nonatomic) IBOutlet UIButton *py1;

@property (weak, nonatomic) IBOutlet UIButton *py2;

@property (weak, nonatomic) IBOutlet UIButton *py3;

@property (weak, nonatomic) IBOutlet UIButton *py4;


@property (weak, nonatomic) IBOutlet UILabel *left;
@property (weak, nonatomic) IBOutlet UILabel *right;

@property (weak, nonatomic) IBOutlet UILabel *input;

@property (weak, nonatomic) IBOutlet UILabel *counter;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation VDGameViewController
- (IBAction)exitGame:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)startInput:(id)sender {
    self.input.text = @"";
    [_iflyRecognizerView start];
    [_game pauseTurn];
    NSLog(@"start listenning...");
}


- (void) initGame
{
    _game = [[VDGame alloc] init];
    
    _game.delegate = self;
    
    [self.input setText:@""];
    
    NSString *initString = [NSString stringWithFormat:@"appid=%@",APPID];
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center initParam:initString];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter:@"domain" value:@"iat"];
    [_iflyRecognizerView setParameter:@"vad_eos" value:@"500"];
    [_iflyRecognizerView setParameter:@"asr_audio_path" value:nil];
    
    [_game initGame];
    [_game start];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [[UIImage imageNamed:@"game_bg.jpeg"] drawInRect:self.view.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initGame];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma game delegate

- (void) onInfo:(NSString *)info {
    self.infoLabel.text = info;
}

- (void) pinYinInit:(NSArray *)pinyins withStick:(NSString *)stickPinYin {
    [self.stickbtn setTitle:stickPinYin forState:UIControlStateNormal];
    
    NSArray * btns = [[NSArray alloc]initWithObjects:self.py1, self.py2, self.py3, self.py4, nil];
    
    for (int i = 0; i < [pinyins count]; i++) {
        UIButton *bt = btns[i];
        [bt setTitle:pinyins[i] forState:UIControlStateNormal];
    }
}

- (void) onPlayerChange:(int)player {
    if(player == 1) {
        [self.left setTextColor:[UIColor grayColor]];
        [self.right setTextColor:[UIColor blueColor]];
    }else {
        [self.left setTextColor:[UIColor redColor]];
        [self.right setTextColor:[UIColor grayColor]];
    }
}


- (void) onPinYinValueMove:(NSArray *)seq withDirection:(int)direct {
    NSArray * btns = [[NSArray alloc] initWithObjects:self.py1, self.py2, self.py3, self.py4, nil];

    for(UIButton *bt in btns) {
        int move = 0 * direct;
        for(int i = 0; i < [seq count]; ++i) {
            if([bt.currentTitle isEqualToString:seq[i]]) {
                move += 80 * direct;
            }
        }
        
        if(move != 0) {
            [UIView animateWithDuration:1 animations:^{
                NSLog(@"Button animated %@ move: %d", bt.titleLabel.text, move);
                [bt setFrame:CGRectMake(bt.frame.origin.x+move, bt.frame.origin.y, bt.frame.size.width, bt.frame.size.height)];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void) onTurnTimerFired:(int)rem {
    self.counter.text = [NSString stringWithFormat:@"%d",rem];
}

- (void) onGameEnd:(int)winner {
    
}

#pragma mark delegate
- (void)onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }

    // 处理结果

    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@。.，,／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\"?？"];
    


    if([result isEqualToString:@"。"]) // 忽略句号
        return;
    
    if([result hasPrefix:@"，"])
        return;

    NSString *rs = [result stringByTrimmingCharactersInSet:set];
    
    NSLog(@"%@", rs);
    self.input.text = [NSString stringWithFormat:@"%@%@",self.input.text, rs];
}

- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *)error
{
    NSLog(@"errorCode:%d",[error errorCode]);

    if([error errorCode] == 0) {
        // 识别成功
        [_game giveAnswer:self.input.text];
    }else {
        self.infoLabel.text =  @"识别错误";
    }
    
    [_game resumeTurn];
}

@end
