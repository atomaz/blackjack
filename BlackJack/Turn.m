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
#import "PlayingCard.h"

@interface Turn ()

// deck temporário. Só é visível na classe Turn
@property (strong, nonatomic, readwrite) NSMutableArray *tempDeck;

@end

@implementation Turn

-(id)initTurnUsingDeck: (PlayingCardDeck *)deck
{
    self = [super init];
    if (self) {
        self.deck = deck;
        self.tempDeck = [[NSMutableArray alloc] init];
        self.dealer = [[Dealer alloc] init];
    }
    
    return self;
}


// **************** ações comuns ao player e ao dealer ********************
-(NSString *) hitCardFor:(BasePlayer *)basePlayer
{
    Card *c = (PlayingCard *) [self.deck drawRandomCard];
    c.faceUp = YES;
    [basePlayer.cards addObject:c];
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
    card.faceUp = YES;
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
    for (PlayingCard *c in self.tempDeck) {
        NSLog(@"%d %@", c.rank, c.suit);
    }
    
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
    }
    
    // para os jogadores que desistiram, pagam metade da aposta
    for (Player *player in self.surrendedPlayers) {
        [player surrendBid];
    }
    
}


//
-(bool) newTurn
{
    
    bool newGame = NO;
    // primeiro remove as cartas existentes
    for (Player *p in self.players) {
         [self insertAtTempDeckCardsFrom:p];
    }
    [self insertAtTempDeckCardsFrom:self.dealer];
    
    // se o número de carta de decks for inferior ao
    // número de jogadores vezes 4 o turno acaba
    if ([self.deck numberOfCardsInDeck] < [self.players count] * 4) {
        // retorna um novo jogo contendo todas as cartas
        
        for (PlayingCard *card in self.tempDeck) {
            [self.deck addCard:card atTop:NO];
        }
        newGame = YES;
    }
    
    // Cada jogador recebe inicialmente duas cartas
    for (Player *p in self.players) {
        PlayingCard *c = (PlayingCard *)[self.deck drawRandomCard];
        c.faceUp = YES;
        [p.cards addObject:c];
        c = (PlayingCard *)[self.deck drawRandomCard];
        c.faceUp = YES;
        [p.cards addObject:c];
    }
    
    PlayingCard *c = (PlayingCard *)[self.deck drawRandomCard];
    c.faceUp = YES;
    [self.dealer.cards addObject:c];
    c = (PlayingCard *)[self.deck drawRandomCard];
    c.faceUp = NO;
    [self.dealer.cards addObject:c];
    
    return newGame;
    
}

// ***************  métodos auxiliares ******************

-(void)insertAtTempDeckCardsFrom:(BasePlayer *)basePlayer
{
    for (PlayingCard *card in basePlayer.cards) {
        // adiciona no deck temporário a carta já usada
        [self.tempDeck addObject:card];
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
