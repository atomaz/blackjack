//
//  Deck.m
//  Matchismo
//
//  Created by Alice Tomaz on 14/04/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

@interface Deck()

@end

@implementation Deck

//@synthesize cards = _cards;

- (NSMutableArray *)cards {
    if(!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (void)addCard:(Card *)card atTop:(BOOL)atTop {
    
    if(atTop) {
        [self.cards insertObject:card atIndex:0];
    } else {
        [self.cards addObject:card];
    }
}

- (Card *)drawRandomCard {
    Card *randomCard = nil;
    
    if(self.cards.count) {
        unsigned index = arc4random() % self.cards.count;
        randomCard = self.cards[index];
        [self.cards removeObjectAtIndex:index];
    }
    
    return randomCard;
}

- (int) numberOfCardsInDeck {
    return 19; // [self.cards count];
}


@end
