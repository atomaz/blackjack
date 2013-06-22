//
//  Turn.m
//  BlackJack
//
//  Created by Alice Tomaz on 20/06/13.
//  Copyright (c) 2013 Alice Tomaz. All rights reserved.
//

#import "Turn.h"
#import "BasePlayer.h"
#import "Player.h"
#import "Dealer.h"
#import "PlayingCardDeck.h"

@implementation Turn


// **************** ações comuns ao player e ao dealer ********************
-(NSString *) hitCardFor:(BasePlayer *)basePlayer
{
    [basePlayer.cards addObject:[self.deck drawRandomCard]];
    return [self statusTurnMessageForPlayer:basePlayer];
}

-(NSString *) standFor:(BasePlayer *)basePlayer
{
    [self.standedPlayers addObject:basePlayer];
    return [self statusTurnMessageForPlayer:basePlayer];
}

// ********************** ações do player *****************
-(NSString *) doubleDownFor:(Player *)player
{
    [player doubleBid];
    Card *card = [self.deck drawRandomCard];
    // card.faceUp = NO; // não sei se a carta deverá estar virada para baixo ou não ...
    
    [player.cards addObject:card];
    return [self statusTurnMessageForPlayer:player];
}

-(NSString *) surrenderFor:(Player *)player
{
    [self.surrendedPlayers addObject:player];
    return [self statusTurnMessageForPlayer:player];

}

// ******************  ações do dealer ********************
-(void)dealerTurn
{
    // o dealer terminou de jogar .. começa a contagem de cartas e distribuição do dinheiro
    int sp = [self.surrendedPlayers count];
    int stp = [self.standedPlayers count];
    int all = [self.players count];
    
    
    // o dealer só começa a jogar quando todos já jogaram (standed) ou desistiram (surrended)
    if (sp + stp == all) {
        
        // se o dealer tiver menos de 17 pontos pega outra carta até que tenha mais
        while ([self.dealer cardPoints] <= 17) {
            [self hitCardFor:self.dealer];
        }      
        
    } // fim do if
    
}

-(void) endTurn
{
    // somente os jogadores que decidiram continuar
    for (Player *p in self.standedPlayers) {
        
        if ([self.dealer cardPoints] > 21) {
            // jogador ganha se a pontuação dele for menor ou igual a 21
            if ([p cardPoints] <= 21) {
                [p receiveBid];
            } else {
                [p payBid];
            }
        } else if ([p cardPoints] != [self.dealer cardPoints]) {
            if ([p cardPoints] > 21) {
                // jogador perde
                [p payBid];
            } else if ([p cardPoints] == 21) {
                // jogador ganha
                [p receiveBid];
            } else if ([p cardPoints] > [self.dealer cardPoints]) {
                // Se o valor da mão de um jogador for maior que a do Dealer, então o jogador ganha.
                [p receiveBid];
            } else {
                // Se o valor da mão de um jogador for menor que a do Dealer, então o jogador paga.
                [p payBid];
            }
        } else {
            // jogador fez a mesma pontuação que o dealer não perde nem ganha
            [p cancelBid];
        }
        
        [self insertAtDeckCardsFrom:p];
        
    }
    
    [self.standedPlayers removeAllObjects];
    
    // para os jogadores que desistiram, pagam metade da aposta
    for (Player *player in self.surrendedPlayers) {
        [player surrendBid];
        // devolve carta ao deck
        [self insertAtDeckCardsFrom:player];
    }
    [self.surrendedPlayers removeAllObjects];
    
    // coloca as cartas do dealer de volta no deck
    [self insertAtDeckCardsFrom:self.dealer];
}


// ***************  métodos auxiliares ******************

-(void)insertAtDeckCardsFrom:(BasePlayer *)basePlayer
{
    for (PlayingCardDeck *c in basePlayer.cards) {
        // adiciona no deck a carta
        [self.deck addCard:(Card *)c atTop:NO];
    }
    // retira a carta do jogador
    [basePlayer.cards removeAllObjects];
}

-(NSMutableArray *)standedPlayers
{
    if(!_standedPlayers)
        _standedPlayers = [[NSMutableArray alloc] init];
    return _standedPlayers;
}

-(NSMutableArray *)surrendedPlayers
{
    if (!_surrendedPlayers) {
        _surrendedPlayers = [[NSMutableArray alloc] init];
    }
    return _surrendedPlayers;
}

-(NSMutableArray *)players
{
    if (!_players) {
        _players = [[NSMutableArray alloc] init];
    }
    return _players;
}

-(NSString *) statusTurnMessageForPlayer:(BasePlayer *)p
{
    if ([p cardPoints] == 21) {
        return @"Blackjack! You won!";
    } else if ([p cardPoints] > 21 || [self.surrendedPlayers indexOfObject:p] != NSNotFound) {
        return @"Ops... Good luck next time.";
    } else {
        return @"You still have chance!";
    }
}

@end
