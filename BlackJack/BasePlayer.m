//
//  BasePlayer.m
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "BasePlayer.h"
#import "PlayingCard.h"

@implementation BasePlayer

-(int) cardPoints
{
    int total = 0;
    for (int i = 0; i < [self.cards count]; i++) {
        PlayingCard *card = (PlayingCard *)self.cards[i];
        if (card.faceUp) {
            if (card.rank > 10) {
                total += 10;
            } else if (card.rank == 1) { // quer dizer que é o Ás
                total += 11;
            } else {
                total += card.rank;
            }
        }
    }
    return total;
}

-(NSMutableArray *)cards
{
    if(!_cards)
        _cards = [[NSMutableArray alloc] init];
    return _cards;
}


@end
