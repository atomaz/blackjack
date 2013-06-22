//
//  PlayingCard.h
//  Matchismo
//
//  Created by Alice Tomaz on 14/04/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong,nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;

@end
