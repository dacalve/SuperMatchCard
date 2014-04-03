//
//  CardViewController.m
//  SuperMatchCard
//
//  Created by David Calvert on 3/31/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "CardViewController.h"


@interface CardViewController ()


@end

@implementation CardViewController

#define DEFAULT_ASPECT_RATIO 1.0
#define DEFAULT_NUMBER_OF_CARDS 12

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] init];
//        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count] usingDeck:[self createDeck]];
        
//      self.history = [[NSMutableArray alloc] init];//track history of card choices.
    }
    return _game;
}

-(Deck *) createDeck //abstract method
{
    return nil;
}

- (IBAction)deal:(id)sender
{
    //abstract method
}

-(void) updateUI
{
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d",self.game.score];
}

@end
