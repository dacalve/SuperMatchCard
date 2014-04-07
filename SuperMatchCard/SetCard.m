//
//  SetCard.m
//  MatchCardGame
//
//  Created by David Calvert on 2/27/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "SetCard.h"



@implementation SetCard

#define MAX_NUMBER_OF_FIGURES 3

+(NSUInteger)maxNumber
{
    return MAX_NUMBER_OF_FIGURES;
}

+(NSArray *)validFigures
{
    return @[@"squiggle",@"diamond",@"oval"];
}

+(NSArray *)validColors
{
    UIColor *redColor = [UIColor redColor];
    UIColor *greenColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.3 alpha:1.0];
    UIColor *purpleColor = [UIColor purpleColor];
    return @[redColor,greenColor,purpleColor];
}


+(NSArray *)validShades
{
    NSString *solid = @"solid";
    NSString *striped = @"striped";
    NSString *unfilled = @"unfilled";
    return @[solid,striped,unfilled];
}


-(int) match:(NSArray *)otherCards
{
    int score = 0;
    BOOL sameNumber = YES;
    BOOL sameColor = YES;
    BOOL sameFigure = YES;
    BOOL sameShading = YES;
    //each feature must be all the same or all different.
    //is same number?
    for (SetCard *otherCard in otherCards) {
        if (!(otherCard.number == self.number)) {
            sameNumber = NO;
            break;
        }
    }
    //is same color?
    for (SetCard *otherCard in otherCards) {
        if (![self compareColor:self.color toSecondColor:otherCard.color]) {
            sameColor = NO;
            break;
        }
    }
     //is same shape?
    for (SetCard *otherCard in otherCards) {
        if (![otherCard.figure isEqualToString:self.figure]) {
            sameFigure = NO;
            break;
        }
    }
    //is same number?
    for (SetCard *otherCard in otherCards) {
        if (!([otherCard.shade isEqualToString:self.shade])) {
            sameShading = NO;
            break;
        }
    }
    
    if (sameNumber) {
        score +=3;
    }
    
    if (sameColor) {
        score += 3;
    }
    
    if (sameFigure) {
        score += 3;
    }
    
    if  (sameShading) {
        score += 3;
    }

    return score;
}

- (BOOL)compareColor:(UIColor *)firstColor toSecondColor:(UIColor *)toSecondColor {
	BOOL areColorsEqual = CGColorEqualToColor(firstColor.CGColor, toSecondColor.CGColor);
	return areColorsEqual;
}


@end
