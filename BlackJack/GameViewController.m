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
#import "CardViewCell.h"

@interface GameViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) PlayingCardDeck* deck;
@property (strong, nonatomic) Turn* turn;
@property (nonatomic) BOOL dealerTurn;

@property (weak, nonatomic) IBOutlet UILabel *bidLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *bidButton;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (weak, nonatomic) IBOutlet UIButton *hitButton;
@property (weak, nonatomic) IBOutlet UIButton *doubleDownButton;
@property (weak, nonatomic) IBOutlet UIButton *standButton;
@property (weak, nonatomic) IBOutlet UIButton *surrenderButton;

@property (weak, nonatomic) IBOutlet UICollectionView *playerCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *dealerCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation GameViewController


// collection view methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"numberOfItemsInSection");
    if (collectionView == self.playerCollectionView) {
        NSLog(@"CollectionView do PLAYER tem %d cartas", [[[self.turn.players objectAtIndex:0] cards] count]);
        return [[[self.turn.players objectAtIndex:0] cards] count];
    } else if (collectionView == self.dealerCollectionView) {
        NSLog(@"CollectionView do DEALER tem %d cartas", [self.turn.dealer.cards count]);
        return [self.turn.dealer.cards count];
    }
    return 0;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemArIdexPath");
    UICollectionViewCell *cell;
    PlayingCard *card = nil;
    
    // player
    if(collectionView == self.playerCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Player Card" forIndexPath:indexPath];
        card = [[[self.turn.players objectAtIndex:0] cards] objectAtIndex: indexPath.item];
 
    // dealer
    } else if (collectionView == self.dealerCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Dealer Card" forIndexPath:indexPath];
        if (indexPath.item < [collectionView numberOfItemsInSection:0] - 1 || self.dealerTurn) {
            card = [self.turn.dealer.cards objectAtIndex:indexPath.item];

        }
    }
    
 
    [self updateCell:cell usingCard:card];

    return cell;

}

-(void)updateCell:(UICollectionViewCell *)cell usingCard:(PlayingCard *)card
{
    if ([cell isKindOfClass:[CardViewCell class]]) {
        CardViewCell *cvc = (CardViewCell *)cell;
        NSString *incognito = @"?";
        if (card) {
                cvc.cardLabelView.text = [card contents];
        } else {
            cvc.cardLabelView.text = incognito;
        }
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playerCollectionView.delegate = self;
    self.playerCollectionView.dataSource = self;
    self.dealerCollectionView.delegate = self;
    self.dealerCollectionView.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) initGame
{
        
        NSLog(@"Dando as cartas");
        // distribui as cartas
        [self dealCards];
        
        NSLog(@"Atualizando a view");
        // atualiza a view
        [self updateUI];
}

-(void) dealCards
{
    self.dealerTurn = NO;
    
    for (Player *p in self.turn.players) {
        [p.cards addObject:[self.turn.deck drawRandomCard]];
        [p.cards addObject:[self.turn.deck drawRandomCard]];
    }
    
   
    [self.turn.dealer.cards addObject:[self.turn.deck drawRandomCard]];
    
    [self.turn.dealer.cards addObject:[self.turn.deck drawRandomCard]];
    
}

-(void) updateUI
{
    
    [self.playerCollectionView reloadData];
    [self.dealerCollectionView reloadData];
    /*[self.dealerCollectionView performBatchUpdates:^{
        [self.dealerCollectionView reloadData];
    }completion:nil];*/
    
    // player 0
    Player *p = (Player *)[self.turn.players objectAtIndex:0];

    self.pointsLabel.text = [[NSString alloc] initWithFormat:@"%d", [p cardPoints]];
    self.cashLabel.text =[[NSString alloc] initWithFormat:@"R$ %d", [p cash]];
    
  
    
    // fazer para o player 1 (outra collection view)
    // fazer para o player 2 ...

    
    // mostra as cartas e os botões
    
    if (p.bid) {
        // oculta os botões da aposta
        self.slider.hidden = YES;
        self.bidButton.hidden = YES;
        
        self.hitButton.hidden = NO;
        self.doubleDownButton.hidden = NO;
        self.standButton.hidden = NO;
        self.surrenderButton.hidden = NO;
        
        // se houver aposta, seta o valor da aposta.
        self.bidLabel.text =[[NSString alloc] initWithFormat:@"R$ %d", [p bid]];
        
        self.messageLabel.text = [self.turn statusTurnMessageForPlayer:[self.turn.players objectAtIndex:0]];

    } else {
        self.slider.hidden = NO;
        self.bidButton.hidden = NO;
        
        self.hitButton.hidden = YES;
        self.doubleDownButton.hidden = YES;
        self.standButton.hidden = YES;
        self.surrenderButton.hidden = YES;
        
        
        // se não houver aposta, pega o valor corrente do slider
        self.bidLabel.text =[[NSString alloc] initWithFormat:@"R$ %.f", self.slider.value];
        
        self.messageLabel.text = @"";
    }


}


- (IBAction)setBid:(id)sender
{
    Player *p = [self.turn.players objectAtIndex:0];
    p.bid = self.slider.value;
    self.cashLabel.text = [[NSString alloc] initWithFormat:@"R$ %d",p.cash];
        
    [self initGame];
}


- (IBAction)changeBid:(UISlider *)sender {
    self.bidLabel.text = [[NSString alloc] initWithFormat:@"R$ %.f", sender.value];
}


- (Turn *)turn
{
    if(!_turn) {
        self.turn = [[Turn alloc] init];
        
        NSLog(@"Criando um jogador");
        
        Player *player = [[Player alloc] initWithCash:self.slider.maximumValue];
        
        
        [self.turn.players addObject:player];
        self.turn.dealer = [[Dealer alloc] init];
        
        NSLog(@"Criando um deck");
        // inicializa o deck
        self.turn.deck = [[PlayingCardDeck alloc] init];
        
        self.dealerTurn = NO;
    }
    return _turn;

}

- (IBAction)stand:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    self.messageLabel.text = [self.turn standFor:p];
    
    // exibr msg
    [self endTurn];
}

- (IBAction)hit:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    self.messageLabel.text = [self.turn hitCardFor:p];
    
    [self updateUI];
}

- (IBAction)doubleDown:(id)sender
{
    Player *p =[self.turn.players objectAtIndex:0];
    self.messageLabel.text = [self.turn doubleDownFor:p];
    
    [self updateUI];    
}

- (IBAction)surrender:(id)sender
{
    
    Player *p =[self.turn.players objectAtIndex:0];
    self.messageLabel.text = [self.turn surrenderFor:p];
    
    [self endTurn];
    
    [self updateUI];
}

-(void) endTurn
{
    // dá a vez para os outros dois agentes
    
    
    
    // dealer termina virando a carta e distribuindo os pontos
    self.dealerTurn = YES;
    [self updateUI];
    
    // se dealer tiver menos de 17 pontos, compra outra carta
    while ([self.turn.dealer cardPoints] < 17) {
        [self.turn hitCardFor:self.turn.dealer];
        [self.dealerCollectionView reloadData];
        sleep(5);
    }
    
    // a new comment
    
    [self.turn dealerTurn];
    
    // faz a contagem dos pontos e redistribui as apostas
    
    
    
    [self.turn endTurn];
    
    // aaa
    
    
    [self updateUI];
    
    // começa um novo turno
    //[self initGame]; // mudar para o Turn.m
}

-(void)agentTurn:(Player *)agent
{
    
    // agente faz alguma coisa
    
}


@end
