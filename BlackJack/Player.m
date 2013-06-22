//
//  Player.m
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "Player.h"
@interface Player()
@property (readwrite,nonatomic) int cash;
@property (readwrite,nonatomic) int bid;
@end

@implementation Player

-(id) initWithCash:(int)cash
{
    self = [super init];
    
    if(self) {
        self.cash = cash;
        self.bid = 0;
    }
    
    return self;
    
}

-(void) receiveBid
{
    self.cash = self.bid * 2;
}

-(void) payBid
{
    self.bid = 0;
}

-(void) setBid:(int)bid
{
    if(self.cash && (self.cash - bid) >= 0) {
        self.cash -= bid;
        _bid = bid;
    } else {
        _bid = bid;
    }

}

-(void) doubleBid
{
    self.cash -= self.bid; // retira mais metade do montante
    self.bid *= 2; // dobra o valor da aposta
}

// desiste do jogo .. paga metade da aposta
-(void) surrendBid
{
    self.cash += self.bid / 2;
    self.bid = 0;
}

// jogador e dealer fizeram a mesma pontuação. Cancela a aposta
-(void) cancelBid
{
    self.cash += self.bid;
    self.bid = 0;
}


@end
