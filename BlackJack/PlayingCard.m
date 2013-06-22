//
//  PlayingCard.m
//  Matchismo
//
//  Created by Alice Tomaz on 14/04/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit;

- (NSString *)contents {
    NSArray *rankString = [PlayingCard rankStrings];
    return [rankString[self.rank] stringByAppendingString:self.suit];
}
+ (NSArray *)validSuits {
    return @[@"♥",@"♦",@"♠",@"♣"];
}
- (void)setSuit:(NSString *)suit {
    if ([[PlayingCard validSuits] containsObject:suit])
        _suit = suit;
}
- (NSString *)suit {
    return _suit ? _suit : @"?";
}
+ (NSArray *)rankStrings {
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSUInteger)maxRank {
    return [self rankStrings].count -1;
}
- (void)setRank:(NSUInteger)rank {
    if (rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}

- (int)match:(NSArray *)otherCards
{
    int score = 0;

    
    for (PlayingCard *card in otherCards) {
        if(card.rank == self.rank) {
            score += 4;
        } else {
            score = 0;
            break;
        }
    }

    if (!score) {
        for (PlayingCard *card in otherCards) {
            if(card.suit == self.suit) {
                score += 1;
            } else {
                score = 0;
                break;
            }
        }
    }
    
    return score;
}

@end
