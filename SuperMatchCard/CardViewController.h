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

- (IBAction)deal:(id)sender;

- (Deck *)createDeck; //abstract method

- (void)updateUI;

@end
