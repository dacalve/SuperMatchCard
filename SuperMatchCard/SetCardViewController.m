//
//  SetCardViewController.m
//  SuperMatchCard
//
//  Created by David Calvert on 3/31/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "SetCardViewController.h"
#import "SetCardView.h"
#import "SetCard.h"
#import "Grid.h"
#import "SetCardDeck.h"

@interface SetCardViewController ()
@property (weak, nonatomic) IBOutlet UIView *boundingView;
@property (weak, nonatomic) IBOutlet SetCardView *setCardView;
@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) SetCardDeck *deck;


@end

@implementation SetCardViewController

- (IBAction)replaceThreeCards:(id)sender {
    [self unselectCards];
    [self replaceCards];
}

- (Deck *)deck
{
    if (!_deck) _deck = [[SetCardDeck alloc] init];
    return _deck;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"Layout subviews! bounds.width=%f, bounds.height=%f", self.boundingView.bounds.size.width,self.boundingView.bounds.size.height);
    if ([self.boundingView.subviews count] == 0) {
        [self createSetCardViews];
        return;
    }
    
    self.grid = nil;
    self.grid = [[Grid alloc] init];
    self.grid.cellAspectRatio = 1.0;
    self.grid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
    self.grid.minimumNumberOfCells = 12;
    
    
    if (self.grid.inputsAreValid) {
        
        int row = 0;
        int col = 0;
        for (SetCardView *view in self.boundingView.subviews) {
            CGRect frame = [self.grid frameOfCellAtRow:row inColumn:col];
            [UIView transitionWithView:view
                              duration:.75
                               options:UIViewAnimationOptionCurveEaseIn
                            animations:^{
                                view.frame = frame;
                            }
                            completion:^(BOOL finished) {
                                
                            }
             ];
            
            
            //increment row and column to process the grid as we process list of views.
            if(row < self.grid.rowCount) {
                if (col < self.grid.columnCount-1) {
                    col++;
                } else {
                    col = 0;
                    row++;
                }
            }
        }
    } else {
        NSLog(@"Inputs are not valid.");
    }
}

- (void)createSetCardViews
{
    self.grid = [[Grid alloc] init];
    self.grid.cellAspectRatio = 1.0;
    self.grid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
    self.grid.minimumNumberOfCells = 12;
    if (self.grid.inputsAreValid) {
        for (NSUInteger row = 0; row < self.grid.rowCount; row++) {
            for (NSUInteger col = 0; col < self.grid.columnCount; col++) {
                [self dropWithFrame:[self.grid frameOfCellAtRow:row inColumn:col]];
                
            }
        }
    }
}

- (void)dropWithFrame:(CGRect)frame
{
    SetCardView *dropView = [[SetCardView alloc] initWithFrame:frame];
    dropView.alpha = 0.0;
    
    [dropView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)]];
    
    [dropView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    [self drawRandomSetCard:dropView];
    [self.boundingView addSubview:dropView];
    [UIView transitionWithView:dropView
                      duration:1.0
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [dropView setAlpha:1.0];
                    }
                    completion:^(BOOL finished) {
                        // cleanup viewOld
                    }
     ];
}

- (void)dropWithFrame:(CGRect)frame forSetCardView:(SetCardView *)movingView
{
    
    [UIView transitionWithView:movingView
                      duration:1.0
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        movingView.frame = frame;
                    }
                    completion:^(BOOL finished) {
                        // cleanup viewOld
                    }
     ];
}



- (void)removeCardAtRow:(NSUInteger)row column:(NSUInteger)col
{
    //find view in boundingView
    CGPoint hitPoint = [self.grid centerOfCellAtRow:row inColumn:col];
    
    UIView *viewToRemove = [self.boundingView hitTest:hitPoint withEvent:nil];
    //remove from superview
    if ([viewToRemove isKindOfClass:[SetCardView class]]) {
        [UIView transitionWithView:viewToRemove
                          duration:.75
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            CGPoint vanishingPoint = CGPointMake(50.0, -50.0);
                            viewToRemove.center = vanishingPoint;
                        }
                        completion:^(BOOL finished) {
                            [viewToRemove removeFromSuperview];
                        }
         ];
    }
}

#pragma mark - Interface

#define NUMBER_OF_CARDS_TO_REPLACE 3

struct NSIntegerPoint {
    NSInteger x;
    NSInteger y;
};
typedef struct NSIntegerPoint NSIntegerPoint;

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

- (NSMutableArray *)findPointsToReplace
{
    int countOfCards = 0;
    NSMutableArray *pointsToReplace = [[NSMutableArray alloc] init];
    int tries = 0;
    while (countOfCards < NUMBER_OF_CARDS_TO_REPLACE && tries < 10) {
        tries++;
        int row = arc4random()%self.grid.rowCount;
        int col = arc4random()%self.grid.columnCount;
        NSIntegerPoint pointToReplace = NSIntegerPointMake(row, col);
        for (NSValue *pointValue in pointsToReplace) {
            NSIntegerPoint point;
            [pointValue getValue:&point];
            if (NSIntegerPointEqualToPoint(point, pointToReplace)) {
                continue;
            }
        }
        
        NSValue *pointObj = [NSValue value:&pointToReplace withObjCType:@encode(NSIntegerPoint)];
        [pointsToReplace addObject:pointObj];
        countOfCards++;
    }
    return pointsToReplace;
}

- (void)replaceCards
{
    NSMutableArray *pointsToReplace = [self findPointsToReplace];
    for (NSValue *pointValue in pointsToReplace) {
        NSIntegerPoint point;
        [pointValue getValue:&point];
        
        [self removeCardAtRow:point.x column:point.y];
        
        [self dropWithFrame:[self.grid frameOfCellAtRow:point.x inColumn:point.y]];
    }
}

- (void)unselectCards
{
    for (UIView *view in self.boundingView.subviews) {
        if ([view isKindOfClass:[SetCardView class]]) {
            
            SetCardView *setCardView = (SetCardView *)view;
            if (setCardView.isChosen) {
                [UIView transitionWithView:setCardView
                                  duration:.75
                                   options:UIViewAnimationOptionCurveEaseIn
                                animations:^{
                                    [setCardView setAlpha:1.0];
                                }
                                completion:^(BOOL finished) {
                                    setCardView.chosen = NO;
                                }
                 ];
            }
        }
    }
}

#pragma mark - Gestures

- (IBAction)swipe:(UILongPressGestureRecognizer *)sender
{
    SetCardView *cardView = (SetCardView *)(sender.view);
    if (cardView) {
        
        [UIView transitionWithView:cardView
                          duration:.75
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [cardView setAlpha:0.25];
                        }
                        completion:^(BOOL finished) {
                            cardView.chosen = YES;
                        }
         ];
    }
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    SetCardView *cardView = (SetCardView *)(sender.view);
    if (cardView) {
        
        [UIView transitionWithView:cardView
                          duration:.75
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [cardView setAlpha:0.25];
                        }
                        completion:^(BOOL finished) {
                            cardView.chosen = YES;
                        }
         ];
    }
}

- (void)drawRandomSetCard:(SetCardView *)cardView
{
    Card *card = [self.deck drawRandomCard];
    if ([card isKindOfClass:[SetCard class]]) {
        SetCard *setCard = (SetCard *)card;
        cardView.number = setCard.number;
        cardView.color = setCard.color;
        cardView.figure = setCard.figure;
        cardView.shade = setCard.shade;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
