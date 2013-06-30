//
//  PlayingCardDeck.m
//  Matchismo
//
//  Created by Alice Tomaz on 14/04/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

-(id)init {
    self = [super init];
    
    if (self) {
        [self createSingleDeck];
    }
    
    return self;
}

-(id)initWithNumberOfDecks:(int)numberOfDecks {
    self = [super init];
    
    if (self) {
        for (int i = 0; i < numberOfDecks; i++) {
            [self createSingleDeck];
        }
    }
    
    return self;
}

-(void) createSingleDeck
{
    for (NSString *suit in [PlayingCard validSuits]) {
        for (NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank++) {
            PlayingCard *card = [[PlayingCard alloc] init];
            card.rank = rank;
            card.suit = suit;
            [self addCard:card atTop:YES];
        }
    }
}

@end
