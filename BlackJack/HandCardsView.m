//
//  HandCardsView.m
//  BlackJack
//
//  Created by Alice Tomaz on 28/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "HandCardsView.h"
#import "PlayingCardView.h"
#import "PlayingCard.h"

@implementation HandCardsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NSMutableArray *)cards
{
    if(!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                           cornerRadius:12.0];
    [[UIColor clearColor] setFill];
    [roundedRect fill];
    
    UIRectFill(self.bounds);
    [roundedRect addClip];
    
    [[UIColor clearColor] setFill];
    [roundedRect fill];
    
    
    [[UIColor clearColor] setStroke];
    [roundedRect stroke];
    
    [self drawCards];
}


-(void)drawCards
{
    CGPoint p;
    p.x = 0;
    p.y = 0;
    
    PlayingCardView *last = nil;
    for (PlayingCard *card in self.cards) {
        PlayingCardView *view = [[PlayingCardView alloc] init];
        view.rank = card.rank;
        view.suit = card.suit;
        view.faceUp = card.faceUp;
        
        [self drawSingleCardView:view atPosition:p];
        p.x += 30;
        //p.y -= 10; // manter na mesma altura.
        
        if (last) {
            [UIView transitionFromView:last
                                toView:view
                              duration:2
                               options: UIViewAnimationOptionShowHideTransitionViews
                            completion:nil];
        }
        
    }
}

-(void) drawSingleCardView:(PlayingCardView *)view atPosition:(CGPoint) point
{
    
    [self addSubview:view];
    CGRect rect = CGRectMake(point.x, point.y, 80.0, 95.0);
    
    view.frame = rect;
    
}


@end
