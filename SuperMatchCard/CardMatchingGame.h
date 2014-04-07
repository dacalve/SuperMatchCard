//
//  CardMatchingGame.h
//  MatchCardGame
//
//  Created by David Calvert on 2/17/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"
#import "Card.h"

@interface CardMatchingGame : NSObject

//designated initializer
//- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck;

- (void)match:(NSMutableArray *)workingCards withCard:(Card *)card;

//- (Card *)cardAtIndex:(NSUInteger)index;

- (void)matchMode:(NSUInteger)cardsToMatch usingMultiPassMatch:(BOOL)multiPassMatch;

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly)NSInteger lastScore;
//@property (nonatomic, readonly) NSArray *currentCards;
@property (nonatomic) NSUInteger howManyCardsToMatch;

@end
