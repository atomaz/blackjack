//
//  Turn.h
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePlayer.h"
#import "Player.h"
#import "Dealer.h"
#import "PlayingCardDeck.h"


@interface Turn : NSObject

@property (strong, nonatomic) PlayingCardDeck *deck;
@property (strong, nonatomic, readonly) NSMutableArray *tempDeck;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) Dealer *dealer;
@property (strong, nonatomic) NSMutableArray* standedPlayers;
@property (strong, nonatomic) NSMutableArray* surrendedPlayers;

// ações comuns ao player e ao dealer
-(NSString *) hitCardFor:(BasePlayer *)basePlayer;
-(NSString *) standFor:(BasePlayer *)basePlayer;

// ações do player
-(NSString *) doubleDownFor:(Player *)player;
-(NSString *) surrenderFor:(Player *)player;


-(id)initTurnUsingDeck: (Deck *)deck;

// ações do dealer
-(void)dealerTurn;

-(void) endTurn;
-(bool) newTurn;
-(NSString *) statusTurnMessageForPlayer:(BasePlayer *)p;

@end
