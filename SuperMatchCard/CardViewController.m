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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"Layout subviews! bounds.width=%f, bounds.height=%f", self.boundingView.bounds.size.width,self.boundingView.bounds.size.height);
    if ([self.boundingView.subviews count] == 0) {
        [self createCardViews];
        return;
    }
    
    self.grid = [self createGrid];
    
    if (self.grid.inputsAreValid) {
        
        int count = 0;
        for (UIView *view in self.boundingView.subviews) {
            //increment row and column to process the grid as we process list of views.
            int row = count/self.grid.columnCount;
            int col = count%self.grid.columnCount;
            [self moveCardView:view toRow:row andColumn:col];
            count++;
        }
    } else {
        NSLog(@"Inputs are not valid.");
    }
}
- (Grid *)portraitGrid
{
    if (!_portraitGrid) {
        _portraitGrid = [self createOrientedGrid];
    }
    return _portraitGrid;
}

- (Grid *)landscapeGrid
{
    if (!_landscapeGrid) {
        _landscapeGrid = [self createOrientedGrid];
    }
    return _landscapeGrid;
}

- (Grid *)createOrientedGrid
{
    Grid *newGrid = [[Grid alloc] init];
    newGrid.cellAspectRatio = self.aspectRatio;
    newGrid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
    newGrid.minimumNumberOfCells = self.numberOfCards;
    return newGrid;
}

-(CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] init];
        
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
    self.game = nil;
    NSMutableArray *pointsToReplace = [self getAllPointsToReplace];
    [self replaceCards:pointsToReplace];
    [self updateUI];
}

- (void)dropWithFrame:(CGRect)frame
{
    //abstract method
}

- (void)replaceCards:(NSMutableArray *)pointsToReplace
{
    //abstract method
}

-(void) updateUI
{
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d",self.game.score];
}

- (void)moveCardView:(UIView *)view toRow:(int)row andColumn:(int)col
{
    NSLog(@"This is row:%i col:%i rowcount:%i colcount:%i",row,col,self.grid.rowCount, self.grid.columnCount);
    CGRect frame = [self.grid frameOfCellAtRow:row inColumn:col];
    
    [UIView transitionWithView:view
                      duration:1.0
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        view.frame = frame;
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

- (void)createCardViews
{
    self.grid = [self createGrid];
    if (self.grid.inputsAreValid) {
        for (NSUInteger row = 0; row < self.grid.rowCount; row++) {
            for (NSUInteger col = 0; col < self.grid.columnCount; col++) {
                [self dropWithFrame:[self.grid frameOfCellAtRow:row inColumn:col]];
            }
        }
    }
}

- (Grid *)createGrid
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        return self.landscapeGrid;
    }
    return self.portraitGrid;
}

- (NSMutableArray *)getAllPointsToReplace
{
    NSMutableArray *pointsToReplace = [[NSMutableArray alloc] init];
    for (int row = 0; row < self.grid.rowCount; row++) {
        for (int col = 0; col < self.grid.columnCount; col++) {
            NSIntegerPoint pointToReplace = NSIntegerPointMake(row, col);
            NSValue *pointObj = [NSValue value:&pointToReplace withObjCType:@encode(NSIntegerPoint)];
            [pointsToReplace addObject:pointObj];
        }
    }
    return pointsToReplace;
}

#pragma mark - C Functions

CG_INLINE NSIntegerPoint
NSIntegerPointMake(NSInteger x, NSInteger y)
{
    struct NSIntegerPoint point;
    point.x = x;
    point.y = y;
    return point;
}

CG_INLINE bool
NSIntegerPointEqualToPoint(NSIntegerPoint point1, NSIntegerPoint point2)
{
    return point1.x == point2.x && point1.y == point2.y;
}
@end
