//
//  SetCard.h
//  MatchCardGame
//
//  Created by David Calvert on 2/27/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "Card.h"


@interface SetCard : Card
@property (nonatomic) NSUInteger number; //1,2,3
@property (strong, nonatomic) UIColor *color; //red, green, purple
@property (strong, nonatomic) NSString *figure; //circle, square, triangle
@property (nonatomic) NSString *shade; //number of shapes (solid, striped, nonfilled)

+(NSUInteger)maxNumber;
+(NSArray *)validFigures;
+(NSArray *)validColors;
+(NSArray *)validShades;

@end
