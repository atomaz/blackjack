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
@property (weak, nonatomic) IBOutlet UILabel *cashLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCardsLabel;

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

@end

@implementation GameViewController


- (Turn *)turn
{
    if(!_turn) {
        self.turn = [[Turn alloc] initTurnUsingDeck:[[PlayingCardDeck alloc] init]];
        
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

-(void) initGame
{
        
    NSLog(@"Dando as cartas");
    // distribui as cartas
    [self.turn newTurn];
    
    self.currentPlayerTurn = nil;
    
    // atualização das cartas pós jogo, evitando que as
    // cartas do jogo anterior sejam exibidas
    [self updateCardViews];
    
    
    NSLog(@"Atualizando a view");
    // atualiza a view
    [self updateUI];
    
    // seta como o primeiro jogador 
    self.currentPlayerTurn = self.turn.players[0];
}

-(void) updateCardViews
{
    //humano
    [self.playerHandCardsView.cards removeAllObjects];
    for (UIView *v in self.playerHandCardsView.subviews) {
        [v removeFromSuperview];
    }
    [self.playerHandCardsView setNeedsDisplay];
    
    // agente aleatório
    [self.randomAgentHandCardsView.cards removeAllObjects];
    for (UIView *v in self.randomAgentHandCardsView.subviews) {
        [v removeFromSuperview];
    }
    [self.randomAgentHandCardsView setNeedsDisplay];
    
    
    // agente com heurística
    [self.heuristicAgentHandCardsView.cards removeAllObjects];
    for (UIView *v in self.heuristicAgentHandCardsView.subviews) {
        [v removeFromSuperview];
    }
    [self.heuristicAgentHandCardsView setNeedsDisplay];
    
    [self.dealerHandCardsView.cards removeAllObjects];
    for (UIView *v in self.dealerHandCardsView.subviews) {
        [v removeFromSuperview];
    }
    [self.dealerHandCardsView setNeedsDisplay];
}

-(void) endTurn
{
    // dá a vez para os outros dois agentes
    self.currentPlayerTurn = self.turn.players[1];
    [self randomAgentTurn:(Player *)self.currentPlayerTurn];
    
    self.currentPlayerTurn = self.turn.players[2];
    [self randomAgentTurn:(Player *)self.currentPlayerTurn];
    

    // dealer termina virando a carta e distribuindo os pontos
    self.currentPlayerTurn = self.turn.dealer;
    self.dealerTurn = YES;
    [self updateUI];
    
    
    // Vez do dealer ... Só joga se todos terminaram. Compra se somente se tiver menos de 17 pontos
    [self.turn dealerTurn];
    
    
    // faz a contagem dos pontos e redistribui as apostas
    [self.turn endTurn];
    self.dealerTurn = NO;
    self.currentPlayerTurn = nil;
    
    [self updateUI];
    
}



-(void)randomAgentTurn:(Player *)agent
{
    Player *randomAgent = self.turn.players[1];
    double randomBid = 15;
    
    [randomAgent setBid:randomBid];
    
    int randomNumber = arc4random() % 100;
    
    if (randomNumber <= 25) {
        [self.turn hitCardFor:randomAgent];
        [self.turn standFor:randomAgent];
    } else if (randomNumber <= 50) {
        [self.turn surrenderFor:randomAgent];
    } else if (randomNumber <= 75) {
        [self.turn doubleDownFor:randomAgent];
        [self.turn standFor:randomAgent];
    } else {
        [self.turn standFor:randomAgent];
    }
    
}


-(void) heuristicAgentTurn:(Player *)agent
{
    int points = [agent cardPoints];
    while ( points < 17) {
        int probability = arc4random() % 100;
        
        if (probability < 5 && [self.turn.dealer cardPoints] == 10) {
            [self.turn surrenderFor:agent];
            return;
        } else if (points >= 12 && points <= 14 && !agent.doubledown && probability <= 40) {
            [self.turn doubleDownFor:agent];
        } else {
            [self.turn hitCardFor:agent];
        }
    }
    // pontuação >= 17 e não desistiu
    [self.turn standFor:agent];
    
}


-(void) updateUI
{
    
    // player 0
    Player *human = (Player *)[self.turn.players objectAtIndex:0];
    Player *randomAgent = (Player *)[self.turn.players objectAtIndex:1];
    Player *heuristicAgent = (Player *)[self.turn.players objectAtIndex:2];

    self.pointsLabel.text = [[NSString alloc] initWithFormat:@"%d", [human cardPoints]];
    self.cashLabel.text =[[NSString alloc] initWithFormat:@"R$ %d", [human cash]];
    //self.numberOfCardsLabel.text = [[NSString alloc] stringByAppendingFormat:@"%d cards", [self.deck numberOfCardsInDeck]];
    
    
    if (self.currentPlayerTurn == nil) {
        
        [self drawCardsFromPlayer:human usingView:self.playerHandCardsView];
        [self drawCardsFromPlayer:randomAgent usingView:self.randomAgentHandCardsView];
        [self drawCardsFromPlayer:heuristicAgent usingView:self.heuristicAgentHandCardsView];
        [self drawCardsFromPlayer:self.turn.dealer usingView:self.dealerHandCardsView];
        
//        [UIView transitionFromView:self.playerHandCardsView toView:self.randomAgentHandCardsView duration:3 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear completion:nil];
//        
//       
//        
//        [UIView transitionFromView:self.randomAgentHandCardsView toView:self.heuristicAgentHandCardsView duration:3 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear completion:nil];
//        
//        
//        
//        [UIView transitionFromView:self.heuristicAgentHandCardsView toView:self.dealerHandCardsView duration:3 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear completion:nil];
        
       
        
        
        
    } else if (self.currentPlayerTurn == human) {
        
        [self drawCardsFromPlayer:human usingView:self.playerHandCardsView];
        
    } else if (self.currentPlayerTurn == randomAgent) {
        
        [self drawCardsFromPlayer:randomAgent usingView:self.randomAgentHandCardsView];
        
    } else if (self.currentPlayerTurn == heuristicAgent) {
        
        [self drawCardsFromPlayer:heuristicAgent usingView:self.heuristicAgentHandCardsView];
        
    } else if (self.currentPlayerTurn == self.turn.dealer) {
        
        [self drawCardsFromPlayer:self.turn.dealer usingView:self.dealerHandCardsView];
    }
    
    
    // desenhando novas cartas
   
    
    
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
        
        [self updateMessageUsingAnimationWithStatus:[self.turn statusTurnMessageForPlayer:[self.turn.players objectAtIndex:0]]];

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

-(void)drawCardsFromPlayer:(BasePlayer *)player usingView:(HandCardsView *)view
{
    for (PlayingCard *card in player.cards) {
        card.faceUp = YES;
        // inicializa a view
        if (![view.cards containsObject:card]) {
            [view.cards addObject:card];
        }
        
    }
    
    [view setNeedsDisplay];
    
}


- (IBAction)setBid:(id)sender
{
    Player *p = [self.turn.players objectAtIndex:0];
    p.bid = self.slider.value;
    [self.cashLabel setText:[[NSString alloc] initWithFormat:@"R$ %d",p.cash]];
    [self initGame];
}


- (IBAction)changeBid:(UISlider *)sender {
    self.bidLabel.text = [[NSString alloc] initWithFormat:@"R$ %.f", sender.value];
}


- (IBAction)stand:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    [self updateMessageUsingAnimationWithStatus:[self.turn standFor:p]];
    
    // exibr msg
    [self endTurn];
}

- (IBAction)hit:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    [self updateMessageUsingAnimationWithStatus: [self.turn hitCardFor:p]];
    
    [self updateUI];
}

- (IBAction)doubleDown:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    [self updateMessageUsingAnimationWithStatus:[self.turn doubleDownFor:p]];
    
    [self updateUI];    
}

- (IBAction)surrender:(id)sender
{
    
    Player *p =[self.turn.players objectAtIndex:0];
    [self updateMessageUsingAnimationWithStatus:[self.turn surrenderFor:p]];
    
    [self endTurn];
    
    [self updateUI];
}

-(void) updateMessageUsingAnimationWithStatus:(NSString *) message
{

    [self.messageLabel setText:message];
    [self.messageLabel setAlpha:0.0];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
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
                                 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
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
     }];}




@end
