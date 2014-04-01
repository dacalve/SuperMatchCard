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

//- (Grid *)portraitGrid
//{
//    if (!_portraitGrid) {
//        _portraitGrid = [[Grid alloc] init];
//        _portraitGrid.cellAspectRatio = DEFAULT_ASPECT_RATIO;
//        _portraitGrid.minimumNumberOfCells = DEFAULT_NUMBER_OF_CARDS;
//    }
//    return _portraitGrid;
//}

//- (Grid *)landscapeGrid
//{
//    if (!_landscapeGrid) {
//        _landscapeGrid = [[Grid alloc] init];
//        _landscapeGrid.cellAspectRatio = DEFAULT_ASPECT_RATIO;
//        _landscapeGrid.minimumNumberOfCells = DEFAULT_NUMBER_OF_CARDS;
//    }
//    return _landscapeGrid;
//}

- (IBAction)deal:(id)sender
{
    
}

@end
