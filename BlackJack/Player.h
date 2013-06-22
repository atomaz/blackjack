//
//  Player.h
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "BasePlayer.h"

@interface Player : BasePlayer

@property (readonly,nonatomic) int cash; // montante
@property (readonly,nonatomic) int bid; // dinheiro apostado

-(void) receiveBid;
-(void) payBid;
-(void) setBid:(int)bid;
-(void) doubleBid;
-(void) surrendBid;
-(void) cancelBid;

-(id) initWithCash:(int)cash;

@end
