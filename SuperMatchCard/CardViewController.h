//
//  CardViewController.h
//  SuperMatchCard
//
//  Created by David Calvert on 3/31/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardMatchingGame.h"
#import "Grid.h"

@interface CardViewController : UIViewController
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) Grid *grid;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *boundingView;
@property (strong, nonatomic) Grid *portraitGrid;
@property (strong, nonatomic) Grid *landscapeGrid;
@property (nonatomic) double aspectRatio;
@property (nonatomic) int numberOfCards;

struct NSIntegerPoint {
    NSInteger x;
    NSInteger y;
};
typedef struct NSIntegerPoint NSIntegerPoint;

- (IBAction)deal:(id)sender;

- (Deck *)createDeck; //abstract method

- (void)updateUI;

- (void)moveCardView:(UIView *)view toRow:(int)row andColumn:(int)col;

- (void)dropWithFrame:(CGRect)frame;

- (void)replaceCards:(NSMutableArray *)pointsToReplace;

@end
