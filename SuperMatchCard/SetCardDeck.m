//
//  SetCardDeck.m
//  MatchCardGame
//
//  Created by David Calvert on 2/27/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

-(instancetype)init
{
    self = [super init];
    if (self) {
        for (NSString *figure in SetCard.validFigures) {
            for (UIColor *color in SetCard.validColors) {
                for (NSString *shade in SetCard.validShades) {
                    for (NSUInteger number = 0; number < SetCard.maxNumber; number++) {
                        SetCard *card = [[SetCard alloc] init];
                        card.number = number+1; //valid numbers are 1 , 2 or 3.
                        card.figure = figure;
                        card.color = color;
                        card.shade = shade;
                        [self addCard:card];
                    }

                }
            }
        }
    }
    
    return self;
}


@end
