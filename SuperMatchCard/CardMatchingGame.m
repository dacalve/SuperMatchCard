//
//  CardMatchingGame.m
//  MatchCardGame
//
//  Created by David Calvert on 2/17/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()

@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, readwrite) NSInteger lastScore;
@property (nonatomic, strong) NSMutableArray *cards; // array of Card
@property (nonatomic, readwrite) NSArray *currentCards;
@property (nonatomic) BOOL multiPassMatch;


-(NSMutableArray *)setUpWorkingCardArrays:(Card *)card;

@end
@implementation CardMatchingGame

- (NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc]init];
    }
    return _cards;
}

static const int DEFAULT_MATCH_MODE = 3;
static const BOOL DEFAULT_MULTI_PASS = NO;

//- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
//{
//    self = [super init]; //super's designated initializer
//    if (self) {
//        [self matchMode:DEFAULT_MATCH_MODE usingMultiPassMatch:DEFAULT_MULTI_PASS];
//        for (int i = 0; i < count; i++) {
//            Card *card = [deck drawRandomCard];
//            if (card) {
//                [self.cards addObject:card];
//            } else {
//                self = nil;
//                break;
//            }
//            
//        }
//    }
//    return self;
//}

- (void)matchMode:(NSUInteger)cardsToMatch usingMultiPassMatch:(BOOL)multiPassMatch
{
    self.howManyCardsToMatch = 2;
    if (cardsToMatch > 2) {
        self.howManyCardsToMatch = cardsToMatch;
    }
    self.multiPassMatch = multiPassMatch;
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

- (void)chooseCardAtIndex:(NSUInteger)index
{
    self.lastScore = 0;
    Card *card = [self cardAtIndex:index];
    
    
    if (!card.isMatched) {
        if (card.isChosen) {
            card.chosen = NO;
        } else {
            
            NSMutableArray *workingCards = [self setUpWorkingCardArrays:card];
            
            if ([workingCards count] == self.howManyCardsToMatch) {
                
                int matchScore = 0;
                Card *matchingCard = workingCards[0];
                [workingCards removeObjectAtIndex:0];
                
                if (self.multiPassMatch) {
                    while ([workingCards count] > 0) {
                        matchScore += [matchingCard match:workingCards];
                        matchingCard = workingCards[0];
                        [workingCards removeObjectAtIndex:0];
                    }
                    
                } else {
                    matchScore += [matchingCard match:workingCards];
                }

                if (matchScore) {
                    self.lastScore = matchScore * MATCH_BONUS;
                    self.score += self.lastScore;
                    card.matched = YES;
                    [self matchCurrentCards];
                    
                } else {
                    self.lastScore = -MISMATCH_PENALTY;
                    self.score += self.lastScore;
                    [self unchooseCurrentCards];
                }
                self.score += -COST_TO_CHOOSE;

            }
            card.chosen = YES;
        }
    }

    NSLog(@"last score:%d",self.lastScore);
}

-(NSMutableArray *)setUpWorkingCardArrays:(Card *)card
{
    //build an array of the cards we are going to match and make this list public for controller.
    NSMutableArray *selectedCards = [[NSMutableArray alloc]init];
    for (Card *otherCard in self.cards) {
        if ((otherCard.isChosen)&&(!otherCard.isMatched)) {
            [selectedCards insertObject:otherCard atIndex:0];
        }
    }
    
    //populate currentCards with an array of all currently selected cards.
    [selectedCards insertObject:card atIndex:0];  //add current card to end of array.
    self.currentCards = [selectedCards copy];
    return selectedCards; //return array of cards without the current card for match calc processing.
}

-(void)matchCurrentCards
{
    for (Card *otherCard in self.currentCards) {
        otherCard.matched = YES;
    }
}

-(void)unchooseCurrentCards
{
    for (Card *otherCard in self.currentCards) {
        otherCard.chosen = NO;
    }
}





@end
