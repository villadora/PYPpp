//
//  VDGame.m
//  PYPpp
//
//  Created by villadora on 14-6-3.
//  Copyright (c) 2014年 villadora. All rights reserved.
//

#import "VDGame.h"
#import "PinYin4Objc.h"

@implementation VDGame

- (id) init {
    _leftWords = [[NSMutableArray alloc] init];
    _rightWords = [[NSMutableArray alloc] init];
    return self;
}

- (void) initGame {
    NSMutableArray *cands = [[NSMutableArray alloc] initWithObjects:@"b", @"p", @"m", @"f",@"d",@"t",@"n",@"l",@"g", @"k", @"h", @"j",@"q", @"x", @"zh", @"ch", @"sh", @"r", @"z", @"c", @"s", @"y", @"w", nil];
    
    self.pinyins = [NSMutableDictionary dictionaryWithCapacity:4];

    int x = arc4random() % [cands count];
    _stickPinYin = [cands objectAtIndex:x];

    [cands removeObjectAtIndex:x];
    
    for (int i = 0; i < 4; i++) {
        int x = arc4random() % [cands count];
        NSString * select = [cands objectAtIndex:x];
        [self.pinyins setObject:[NSString stringWithFormat:@"%d", 0] forKey:[cands objectAtIndex:x]];
        [cands removeObjectAtIndex:x];
//        UIButton *bt = [btns objectAtIndex:i];
//        [bt setTitle:select forState:UIControlStateNormal];
        NSLog(@"%@",select);
    }
    
    if(self.delegate)
        [self.delegate pinYinInit:[self.pinyins allKeys] withStick:_stickPinYin];


    // whose turn
    int turn = arc4random() % 2;
    if(turn == 0) {
        _turn = G_RIGHT;
//        [self.left setTextColor:[UIColor grayColor]];
//        [self.right setTextColor:[UIColor blueColor]];
    }else {
        _turn = G_LEFT;
//        [self.left setTextColor:[UIColor redColor]];
//        [self.right setTextColor:[UIColor grayColor]];
    }
    
    if(self.delegate)
        [self.delegate onPlayerChange:_turn];
    
//    [self.input setText:@""];
//    
//    NSString *initString = [NSString stringWithFormat:@"appid=%@",APPID];
//    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center initParam:initString];
//    _iflyRecognizerView.delegate = self;
//    
//    [_iflyRecognizerView setParameter:@"domain" value:@"iat"];
//    [_iflyRecognizerView setParameter:@"vad_eos" value:@"500"];
//    [_iflyRecognizerView setParameter:@"asr_audio_path" value:nil];

}

// game start
- (void) start {
    [self startTurn];
}

- (void) end {
    [self endTurn];
    
    if(self.delegate) {
        [self.delegate onGameEnd:[self whoWin]];
    }
}

- (void) timerFired {
    _turnTimeCnt--;
    if(self.delegate)
        [self.delegate onTurnTimerFired:_turnTimeCnt];
    
    if(_turnTimeCnt == 0) {
        // timeout end
        [_turnTimer invalidate];
        _turnTimer = nil;
        [self nextTurn];
     }
}

- (void) pauseTurn {
    if(_turnTimer) {
        [_turnTimer invalidate];
        _turnTimer = nil;
    }
}

- (void) resumeTurn {
    if(_turnTimer) {
        [_turnTimer invalidate];
    }
    
    _turnTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

// cancel current game
- (void) cancel {
    _leftWords = nil;
    _rightWords = nil;
    if(_turnTimer) {
        [_turnTimer invalidate];
        _turnTimer = nil;
    }
}


- (void) giveAnswer:(NSString *)answer {
    bool rs = [self verifyAnswer:answer];
    if(rs) {
        // 回答正确
        NSLog(@"正确回答:%@", answer);
        if(_turn == 1) {
            [_rightWords addObject:answer];
        }else {
            [_leftWords addObject:answer];
        }
        
        
        // 获取拼音
        HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
        
        [outputFormat setToneType:ToneTypeWithoutTone];
        [outputFormat setVCharType:VCharTypeWithV];
        [outputFormat setCaseType:CaseTypeLowercase];
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:answer withHanyuPinyinOutputFormat:outputFormat withNSString:@"|"];
        
        NSArray *pys = [outputPinyin componentsSeparatedByString:@"|"];
        NSMutableArray *seq = [[NSMutableArray alloc] init];

        // 判断是否正确
        for (int i = 0; i < [pys count]; i++) {
            NSString *py = pys[i];
            NSLog(@"%@",py);
            if([py hasPrefix:_stickPinYin])
                if([_stickPinYin length] > 1 || [py characterAtIndex:1] != 'h')
                    continue;
            
            
            for(NSString *key in [self.pinyins allKeys]) {
                NSLog(@"%@", key);
                
                NSString *val = self.pinyins[key];
                int v = [val intValue];

                if([py hasPrefix:key]) {
                    if([key length] > 1 || [py characterAtIndex:1] != 'h') {
                        if(_turn == 1) {
                            if(v > 0) {
                                return;
                            }
                            v += 1;
                        }else {
                            if(v < 0) {
                                return;
                            }
                            v -= 1;
                        }
                        self.pinyins[key]=[NSString stringWithFormat:@"%d", v];
                        [seq addObject:key];
                        break;
                    }
                }
            }
        }
        
        if([seq count] > 0 && self.delegate) {
            [self.delegate onPinYinValueMove:seq withDirection:0-_turn];
        }
    
        [self nextTurn];
    }
}

- (bool) verifyAnswer: (NSString*) answer {
    if([answer length] > 5) {
        if(self.delegate)
            [self.delegate onInfo:@"长度超出"];
        return NO;
    }
    
    // 去除重复
    for(int i = 0; i < [_leftWords count]; ++i) {
        if([_leftWords[i] isEqualToString:answer]) {
            NSLog(@"重复答案:%@", answer);
            if(self.delegate)
                [self.delegate onInfo:@"已经使用过"];
            return NO;
        }
    }
    
    for(int i = 0; i < [_rightWords count]; ++i) {
        if([_rightWords[i] isEqualToString:answer]) {
            NSLog(@"重复答案:%@", answer);
            if(self.delegate)
                [self.delegate onInfo:@"已经使用过"];
            return NO;
        }
    }
    
    
    // 获取拼音
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:answer withHanyuPinyinOutputFormat:outputFormat withNSString:@"|"];
    
    NSArray *pys = [outputPinyin componentsSeparatedByString:@"|"];
    
    // print out pinyin
    for(NSString *p in pys) {
        NSLog(@"%@", p);
    }
    
    // copy piyins
    NSMutableDictionary * copy = [[NSMutableDictionary alloc]
                                  initWithCapacity:[self.pinyins count]];
    
    for (NSString *key in [self.pinyins allKeys])
    {
        [copy setValue:[self.pinyins objectForKey:key] forKey:key];
    }
    
    // 判断是否正确
    for (int i = 0; i < [pys count]; i++) {
        BOOL found = NO;
        NSString *py = [pys objectAtIndex:i];
        if([py hasPrefix:_stickPinYin])
            if([_stickPinYin length] > 1 || [py characterAtIndex:1] != 'h')
                continue;
        
        NSEnumerator * enumeratorKey = [copy keyEnumerator];
        for (NSString *key in enumeratorKey) {
            NSString *val =(NSString*) [copy objectForKey:key];
            int v = [val intValue];
            if([py hasPrefix:key]) {
                NSLog(@"%@ %c", key, [py characterAtIndex:1]);
                if([key length] > 1 || ([py length] < 1 || [py characterAtIndex:1]!= 'h')) {
                    if(_turn == 1) {
                        if(v > 0) {
                            if(self.delegate)
                                [self.delegate onInfo: @"超过限制"];
                            return NO;
                        }
                        
                        found = YES;
                        v += 1;
                        [copy setValue:[NSString stringWithFormat:@"%d", v] forKey:key];
                        break;
                    }else {
                        if(v < 0) {
                            if(self.delegate)
                                [self.delegate onInfo:@"超过限制"];
                            return NO;
                        }
                        found = YES;
                        v -= 1;
                        [copy setValue:[NSString stringWithFormat:@"%d", v] forKey:key];
                        break;
                    }
                }
            }
        }
        
        if(!found) {
            if(self.delegate)
                [self.delegate onInfo:@"不匹配"];
            return NO;
        }
        
    }
    
    
    return YES;
}


// start current turn
- (void) startTurn {
    if(_turnTimer)
        [_turnTimer invalidate];
    
    _turnTimeCnt = G_TIME;
    _turnTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    if(self.delegate) {
        [self.delegate onTurnTimerFired: _turnTimeCnt];
    }
}

- (void) endTurn {
    if(_turnTimer) {
        [_turnTimer invalidate];
        _turnTimer = nil;
    }
}

- (void) nextTurn {
    [self endTurn];

    int win = [self whoWin];
    if(win != 0) {
        if(self.delegate)
            [self.delegate onGameEnd:win];
        return;
    }
    
    // 没人获胜，继续
    _turn = 0 - _turn;
    
    if (self.delegate) {
        [self.delegate onPlayerChange:_turn];
    }
    
    [self startTurn];
}


- (int) whoseTurn {
    return _turn;
}


- (int) whoWin
{
    int turn = -2;
    for(NSString * key in [self.pinyins allKeys]) {
        NSString *val = self.pinyins[key];
        NSLog(@"键值为：%@ 值: %@", key, val);
        if(val != nil)
        {
            int v = [val intValue];
            if(turn == -2) {
                turn = v;
            }else {
                if(turn != v) {
                    // 没结束
                    return 0;
                }
            }
        }
    }
    
    // 结束 返回赢家
    if(turn == -2)
        return 0;
    return turn;
}



@end
