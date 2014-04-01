//
//  CardViewController.h
//  SuperMatchCard
//
//  Created by David Calvert on 3/31/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grid.h"

@interface CardViewController : UIViewController

@property (strong, nonatomic) Grid *grid;

- (IBAction)deal:(id)sender;


@end
