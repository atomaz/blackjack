//
//  PlayingCardCollectionViewCell.h
//  Matchismo
//
//  Created by Alice Tomaz on 20/05/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingCardView.h"

@interface PlayingCardCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;

@end
