//
//  Deck.h
//  Matchismo
//
//  Created by Alice Tomaz on 14/04/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

- (void)addCard:(Card *)card atTop:(BOOL)atTop;

- (Card *)drawRandomCard;

@end
