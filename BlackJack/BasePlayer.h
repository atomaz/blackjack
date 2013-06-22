//
//  BasePlayer.h
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasePlayer : NSObject

@property (strong, nonatomic) NSMutableArray *cards; // ofPlayingCards

// retorna o total de pontos das cartas que o jogador possui
-(int) cardPoints;

@end
