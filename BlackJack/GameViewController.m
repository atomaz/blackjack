//
//  GameViewController.m
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "GameViewController.h"
#import "PlayingCardDeck.h"
#import "Turn.h"
#import "Player.h"
#import "PlayingCard.h"
#import "PlayingCardCollectionViewCell.h"
#import "PlayingCardView.h"
#import "HandCardsView.h"

@interface GameViewController ()

// MAIN ENTITIES
@property (strong, nonatomic) PlayingCardDeck* deck;
@property (strong, nonatomic) Turn* turn;
@property (nonatomic) BOOL dealerTurn;
@property (strong, nonatomic) BasePlayer *currentPlayerTurn;



// LABELS
@property (weak, nonatomic) IBOutlet UILabel *bidLabel;

@property (weak, nonatomic) IBOutlet UILabel *humanCashLabel;
@property (weak, nonatomic) IBOutlet UILabel *randomCashLabel;
@property (weak, nonatomic) IBOutlet UILabel *heuristicCashLabel;

@property (weak, nonatomic) IBOutlet UILabel *humanPoints;
@property (weak, nonatomic) IBOutlet UILabel *randomPoints;
@property (weak, nonatomic) IBOutlet UILabel *heuristicPoints;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


@property (weak, nonatomic) IBOutlet UISlider *slider;


// TURN BUTTONS
@property (weak, nonatomic) IBOutlet UIButton *bidButton;
@property (weak, nonatomic) IBOutlet UIButton *hitButton;
@property (weak, nonatomic) IBOutlet UIButton *doubleDownButton;
@property (weak, nonatomic) IBOutlet UIButton *standButton;
@property (weak, nonatomic) IBOutlet UIButton *surrenderButton;

// HAND CARD VIEWS
@property (weak, nonatomic) IBOutlet HandCardsView *playerHandCardsView;
@property (weak, nonatomic) IBOutlet HandCardsView *dealerHandCardsView;
@property (weak, nonatomic) IBOutlet HandCardsView *randomAgentHandCardsView;
@property (weak, nonatomic) IBOutlet HandCardsView *heuristicAgentHandCardsView;

// CROWNS IMAGES
@property (weak, nonatomic) IBOutlet UIImageView *humanCrownImage;
@property (weak, nonatomic) IBOutlet UIImageView *randomAgentCrownImage;
@property (weak, nonatomic) IBOutlet UIImageView *heuristicAgentCrownImage;


@property (weak, nonatomic) IBOutlet UITextView *messageTextArea;


@end

@implementation GameViewController



//

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureCrowns];
    self.messageLabel.text = @"";
    self.messageTextArea.text = @"";
    self.messageTextArea.editable = NO;
}

-(void) configureCrowns
{
    
    self.humanPoints.transform = CGAffineTransformMakeRotation(-0.75);
    
    //[self.humanCrownImage addSubview:self.humanPoints];
    
    self.randomPoints.transform = CGAffineTransformMakeRotation(-0.75);
    
   // [self.randomAgentCrownImage addSubview:self.randomPoints];
    
    self.heuristicPoints.transform = CGAffineTransformMakeRotation(-0.75);
    //[self.heuristicAgentCrownImage addSubview:self.heuristicPoints];
}

- (IBAction)setBid:(id)sender
{
    Player *p = [self.turn.players objectAtIndex:0];
    p.bid = self.slider.value;
    [self.humanCashLabel setText:[[NSString alloc] initWithFormat:@"%d",p.cash]];
    [self updateMessageUsingAnimationWithStatus:[NSString stringWithFormat:@"Your bid: %d", p.bid]];
    [self initGame];
}

-(void) initGame
{
    [self updateMessageUsingAnimationWithStatus:@"**** NEW TURN ****"];
    [self updateMessageUsingAnimationWithStatus:@"Giving cards ... "];
    // distribui as cartas
    [self.turn newTurn];
    
    self.currentPlayerTurn = nil;
    
    // atualização das cartas pós jogo, evitando que as
    // cartas do jogo anterior sejam exibidas
    [self updateCardViews];
    
    [self configureCrowns];
    
    NSLog(@"Atualizando a view");
    // atualiza a view
    [self updateUI];
    
    [self updateMessageUsingAnimationWithStatus:@"**** Your turn ****"];
    self.currentPlayerTurn = self.turn.players[0];
}

-(void) updateCardViews
{
    [self animateHandCardView:self.playerHandCardsView];
    
    [self animateHandCardView:self.randomAgentHandCardsView];
    
    [self animateHandCardView:self.heuristicAgentHandCardsView];
    
    [self animateHandCardView:self.dealerHandCardsView];
    
}

-(void) animateHandCardView:(HandCardsView *)view
{
    int originalx = view.frame.origin.x;
    int originaly = view.frame.origin.y;
    view.frame = CGRectMake(self.view.frame.size.width/2, -40, self.playerHandCardsView.frame.size.width, self.playerHandCardsView.frame.size.height);
    
    [UIView animateWithDuration:1 animations:^{
        view.frame = CGRectMake(originalx,originaly,
                                self.playerHandCardsView.frame.size.width,
                                self.playerHandCardsView.frame.size.height);
    }];
    
    //humano
    [view.cards removeAllObjects];
    for (UIView *v in view.subviews) {
        [v removeFromSuperview];
    }
    [view setNeedsDisplay];
}

-(void) updateUI
{
    
    Player *human = (Player *)[self.turn.players objectAtIndex:0];
    Player *randomAgent = (Player *)[self.turn.players objectAtIndex:1];
    Player *heuristicAgent = (Player *)[self.turn.players objectAtIndex:2];
    
    [self.humanPoints setText:[[NSString alloc] initWithFormat:@"%d", [human cardPoints]]];
    [self.randomPoints setText:[[NSString alloc] initWithFormat:@"%d", [randomAgent cardPoints]]];
    [self.heuristicPoints setText:[[NSString alloc] initWithFormat:@"%d", [heuristicAgent cardPoints]]];
    
    [self.humanCashLabel setText:[[NSString alloc] initWithFormat:@"%d", [human cash]]];
    [self.randomCashLabel setText:[[NSString alloc] initWithFormat:@"%d", [randomAgent cash]]];
    [self.heuristicCashLabel setText:[[NSString alloc] initWithFormat:@"%d", [heuristicAgent cash]]];
    
    
    if (self.currentPlayerTurn == nil) {
        
        [self drawCardsFromPlayer:human usingView:self.playerHandCardsView];
        [self drawCardsFromPlayer:randomAgent usingView:self.randomAgentHandCardsView];
        [self drawCardsFromPlayer:heuristicAgent usingView:self.heuristicAgentHandCardsView];
        [self drawCardsFromPlayer:self.turn.dealer usingView:self.dealerHandCardsView];
        
    } else if (self.currentPlayerTurn == human) {
        
        [self drawCardsFromPlayer:human usingView:self.playerHandCardsView];
        
    } else if (self.currentPlayerTurn == randomAgent) {
        
        [self drawCardsFromPlayer:randomAgent usingView:self.randomAgentHandCardsView];
        
    } else if (self.currentPlayerTurn == heuristicAgent) {
        
        [self drawCardsFromPlayer:heuristicAgent usingView:self.heuristicAgentHandCardsView];
        
    } else if (self.currentPlayerTurn == self.turn.dealer) {
        
        [self drawCardsFromPlayer:self.turn.dealer usingView:self.dealerHandCardsView];
    }
    
    // mostra as cartas e os botões
    
    if (human.bid) {
        // oculta os botões da aposta
        self.slider.hidden = YES;
        self.bidButton.hidden = YES;
        
        self.hitButton.hidden = NO;
        self.doubleDownButton.hidden = NO;
        self.doubleDownButton.enabled = !human.doubledown;
        self.standButton.hidden = NO;
        self.surrenderButton.hidden = NO;
        
        // se houver aposta, seta o valor da aposta.
        self.bidLabel.text =[[NSString alloc] initWithFormat:@"R$ %d", [human bid]];
        
        
    } else {
        self.slider.hidden = NO;
        self.bidButton.hidden = NO;
        
        self.hitButton.hidden = YES;
        self.doubleDownButton.hidden = YES;
        self.standButton.hidden = YES;
        self.surrenderButton.hidden = YES;
        
        
        // se não houver aposta, pega o valor corrente do slider
        self.bidLabel.text =[[NSString alloc] initWithFormat:@"R$ %.f", self.slider.value];
        
        [self updateMessageUsingAnimationWithStatus:@""];
    }
    
}


- (Turn *)turn
{
    if(!_turn) {
        self.turn = [[Turn alloc] initTurnUsingDeck:[[PlayingCardDeck alloc] initWithNumberOfDecks:3]];
        
        NSLog(@"Criando um jogador");
        
        Player *humanPlayer = [[Player alloc] initWithCash:self.slider.maximumValue];
        [self.turn.players addObject:humanPlayer];
        
        // adicionar agentes
        Player *randomPlayer = [[Player alloc] initWithCash:self.slider.maximumValue];
        [self.turn.players addObject:randomPlayer];
        
        Player *heuristicPlayer = [[Player alloc] initWithCash:self.slider.maximumValue];
        [self.turn.players addObject:heuristicPlayer];
        
        
        self.dealerTurn = NO;
    }
    return _turn;
    
}


-(void) endTurn
{
    // dá a vez para os outros dois agentes
    self.currentPlayerTurn = self.turn.players[1];
    [self randomAgentTurn:(Player *)self.currentPlayerTurn];
    
    [self updateUI];
    
    self.currentPlayerTurn = self.turn.players[2];
    [self heuristicCountAgentTurn:(Player *)self.currentPlayerTurn];
    
    [self updateUI];
        
    // dealer termina virando a carta e distribuindo os pontos
    self.currentPlayerTurn = self.turn.dealer;
    self.dealerTurn = YES;
    
    [self updateMessageUsingAnimationWithStatus:@"**** Dealer ****"];
    [self updateMessageUsingAnimationWithStatus:@"Flipping last card."];
    // vira a última carta do dealer
    PlayingCard *facedDownCard = self.turn.dealer.cards[1];
    facedDownCard.faceUp = YES;
    
    [self updateUI];
    
    // Vez do dealer ... Só joga se todos terminaram. Compra se somente se tiver menos de 17 pontos
    [self.turn dealerTurn];
    
    [self updateUI];
    
    [self updateMessageUsingAnimationWithStatus:@"**** END ****"];
    
    // faz a contagem dos pontos e redistribui as apostas
    [self.turn endTurn];
    self.dealerTurn = NO;
    self.currentPlayerTurn = nil;

    [self updateUI];
    
}


-(void)randomAgentTurn:(Player *)agent
{
    
    [self updateMessageUsingAnimationWithStatus:@"**** Agente R ****"];
    [self updateMessageUsingAnimationWithStatus:@"Bid: 15."];
    double randomBid = 15;
    
    [agent setBid:randomBid];
    
    int randomNumber = arc4random() % 100;
    
    [self updateMessageUsingAnimationWithStatus:[NSString stringWithFormat:@"Prob.: %d.", randomNumber]];
    
    if (randomNumber <= 25) {
        [UIView animateWithDuration:3 animations:^{
            [self updateMessageUsingAnimationWithStatus:@"Action: Hit."];
            [self.turn hitCardFor:agent];
            [self updateMessageUsingAnimationWithStatus:@"Action: Stand."];
            [self.turn standFor:agent];
        }];
    } else if (randomNumber <= 50) {
        [self updateMessageUsingAnimationWithStatus:@"Action: Surrender."];
        [self.turn surrenderFor:agent];
    } else if (randomNumber <= 75) {
        [self updateMessageUsingAnimationWithStatus:@"Action: Double Down."];
        [self.turn doubleDownFor:agent];
        [self updateMessageUsingAnimationWithStatus:@"Action: Stand."];
        [self.turn standFor:agent];
    } else {
        [self updateMessageUsingAnimationWithStatus:@"Action: Stand."];
        [self.turn standFor:agent];
    }
    
}

-(void) heuristicAgentTurn:(Player *)agent
{
    [self updateMessageUsingAnimationWithStatus:@"**** Agent H Turn! ****"];
    [self updateMessageUsingAnimationWithStatus:@"Bid: 15."];
    double randomBid = 15;    
    [agent setBid:randomBid];

    int points = [agent cardPoints];
    int probability = arc4random() % 100;
     [self updateMessageUsingAnimationWithStatus:[NSString stringWithFormat:@"Prob.: %d.", probability]];
    
    while ( points < 17) {
        
        if (probability < 5 && [self.turn.dealer cardPoints] == 10) {
            [self updateMessageUsingAnimationWithStatus:@"Action: Surrender."];
            [self.turn surrenderFor:agent];
            return;
        } else if (points >= 12 && points <= 14 && !agent.doubledown && probability <= 40) {
            [self updateMessageUsingAnimationWithStatus:@"Action: DoubleDown."];
            [self.turn doubleDownFor:agent];
        } else {
            [self updateMessageUsingAnimationWithStatus:@"Action: Hit."];
            [self.turn hitCardFor:agent];
        }
        points = [agent cardPoints];
    }
    // pontuação >= 17 e não desistiu
    [self updateMessageUsingAnimationWithStatus:@"Action: Stand."];
    [self.turn standFor:agent];
    
}


-(void) heuristicCountAgentTurn:(Player *)agent
{
    [self updateMessageUsingAnimationWithStatus:@"**** Agent H Turn! ****"];
    [self updateMessageUsingAnimationWithStatus:@"Bid: 15."];
    double randomBid = 15;
    [agent setBid:randomBid];
    
    // probabilidade de tirar uma carta cuja a pontuação seja menor ou igual a 21
    double probability;
    
    while ([agent cardPoints] < 17) {
        

        probability = [self calcProbability];
        
        [self updateMessageUsingAnimationWithStatus:[NSString stringWithFormat:@"Prob.: %f.", probability]];
        
        if (probability < 0.50 || [self.turn.dealer cardPoints] == 10) {
            [self updateMessageUsingAnimationWithStatus:@"Action: Surrender."];
            [self.turn surrenderFor:agent];
            return;
        } else if (!agent.doubledown && probability >= 0.75 ) {
            [self updateMessageUsingAnimationWithStatus:@"Action: DoubleDown."];
            [self.turn doubleDownFor:agent];
        } else {
            [self updateMessageUsingAnimationWithStatus:@"Action: Hit."];
            [self.turn hitCardFor:agent];
        }

    }
    
    // pontuação >= 17 e não desistiu
    [self updateMessageUsingAnimationWithStatus:@"Action: Stand."];
    [self.turn standFor:agent];
    

}
 

-(double) calcProbability {
    double probability = 0;
    
    int x = 21 - [self.currentPlayerTurn cardPoints];
    
    for (PlayingCard *c in [self.turn.deck cards]) {
        int index = c.rank;
        if (index <= x) {
            probability++;
        }
    }
    // probabilidade de tirar uma carta cuja a pontuação seja menor ou igual a 21
    probability /= [[self.turn.deck cards] count];
    
    return probability;
}

-(void)drawCardsFromPlayer:(BasePlayer *)player usingView:(HandCardsView *)view
{
    for (PlayingCard *card in player.cards) {
        // inicializa a view
        if (![view.cards containsObject:card]) {
            [view.cards addObject:card];
        }
        
    }
    
    [view setNeedsDisplay];
    
}


- (IBAction)changeBid:(UISlider *)sender {
    
    // ALTERAR !!!!
    //self.bidLabel.text = [[NSString alloc] initWithFormat:@"R$ %.f", sender.value];
}


- (IBAction)stand:(id)sender
{
    [self updateMessageUsingAnimationWithStatus:@"You stand."];
    Player *p =[self.turn.players objectAtIndex:0];
    [self.turn standFor:p];
    
    // exibr msg
    [self endTurn];
}

- (IBAction)hit:(id)sender
{
    [self updateMessageUsingAnimationWithStatus:@"You hit."];
    Player *p =[self.turn.players objectAtIndex:0];
    [self.turn hitCardFor:p];
    
    [self updateUI];
}

- (IBAction)doubleDown:(id)sender
{
    [self updateMessageUsingAnimationWithStatus:@"You doubledown"];
    Player *p =[self.turn.players objectAtIndex:0];
    [self.turn doubleDownFor:p];
    
    [self updateUI];    
}

- (IBAction)surrender:(id)sender
{
    [self updateMessageUsingAnimationWithStatus:@"You surrender"];
    Player *p =[self.turn.players objectAtIndex:0];
    [self.turn surrenderFor:p];
    
    [self endTurn];
    
    [self updateUI];
}

-(void) updateMessageUsingAnimationWithStatus:(NSString *) message
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@",self.messageTextArea.text,message];
    [self.messageTextArea setText:msg];
    NSLog(@"%@", message);
    
    [self.messageLabel setText:message];
    [self.messageLabel setAlpha:0.0];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void)
     {
         [self.messageLabel setAlpha:1.0];
     }
                     completion:^(BOOL finished)
     {
         if(finished)
         {
             [UIView animateWithDuration:1.5
                                   delay:4
                                 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction| UIViewAnimationOptionBeginFromCurrentState
                              animations:^(void)
              {
                  [self.messageLabel setAlpha:0.0];
              }
              completion:^(BOOL finished)
              {
                  if(finished)
                      NSLog(@"Hurray. Label fadedIn & fadedOut");
              }];
         }
     }];

}




@end
