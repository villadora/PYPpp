//
//  VDGame.h
//  PYPpp
//
//  Created by villadora on 14-6-3.
//  Copyright (c) 2014年 villadora. All rights reserved.
//

#import "Definition.h"
#import <Foundation/Foundation.h>


#ifndef PYPpp_Game_h
#define PYPpp_Game_h

#define G_TIME 30
#define G_LEFT -1
#define G_RIGHT 1

#endif

@protocol GameDelegate <NSObject>

- (void) onInfo:(NSString*)info;

- (void) onGameEnd:(int) winner;

- (void) onPlayerChange:(int) player;

- (void) onPinYinValueMove: (NSArray *) seq withDirection:(int) direct;

- (void) onTurnTimerFired:(int) rem;
- (void) pinYinInit:(NSArray*) pinyins withStick:(NSString*) stickPinYin;

@end

@interface VDGame : NSObject {
    NSMutableArray *_leftWords; // words already used
    NSMutableArray *_rightWords;
    NSString *_stickPinYin;
    int _turn;
    int _turnTimeCnt;
    NSTimer *_turnTimer;
}

@property (assign, nonatomic) id<GameDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *pinyins;

- (void) initGame;

- (void) start;
- (void) cancel;
- (void) end;

- (void) startTurn;
- (void) endTurn;

- (void) pauseTurn;
- (void) resumeTurn;

- (void) nextTurn;
- (void) giveAnswer:(NSString*) answer;


- (int) whoseTurn;


@end
