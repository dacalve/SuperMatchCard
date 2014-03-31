//
//  PlayingCard.h
//  MatchCardGame
//
//  Created by David Calvert on 2/14/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;


@end
