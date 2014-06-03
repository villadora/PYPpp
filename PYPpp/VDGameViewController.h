//
//  VDGameViewController.h
//  PYPpp
//
//  Created by villadora on 14-5-29.
//  Copyright (c) 2014年 villadora. All rights reserved.
//

#import "VDBaseViewController.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "VDGame.h"

@interface VDGameViewController : VDBaseViewController<IFlyRecognizerViewDelegate, GameDelegate>
{
    VDGame                  * _game;
    IFlyRecognizerView      * _iflyRecognizerView;
    NSString                * _result;
}

- (void) initGame;


@end
