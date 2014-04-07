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
@property (weak, nonatomic) SetCardView *setCardView;
@property (strong, nonatomic) SetCardDeck *deck;

@end

@implementation SetCardViewController

#define NUMBER_OF_SET_CARDS 16
#define NUMBER_OF_CARDS_TO_REPLACE 3
#define SET_CARD_ASPECT_RATIO 1.0

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.aspectRatio = SET_CARD_ASPECT_RATIO;
    self.numberOfCards = NUMBER_OF_SET_CARDS;
}

- (IBAction)replaceThreeCards:(id)sender {
    [self unselectCards];
    NSMutableArray *pointsToReplace = [self getRandomPointsToReplace];
    [self replaceCards:pointsToReplace];
}

- (IBAction)deal:(id)sender {

}

- (Deck *)deck
{
    if (!_deck) _deck = [[SetCardDeck alloc] init];
    return _deck;
}

- (void)moveSetCardView:(UIView *)view toRow:(int)row andColumn:(int)col
{
    NSLog(@"This is row:%i col:%i rowcount:%i colcount:%i",row,col,self.grid.rowCount, self.grid.columnCount);
    
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

- (NSMutableArray *)getRandomPointsToReplace
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
                continue; //try another random row/col point
            }
        }
        
        NSValue *pointObj = [NSValue value:&pointToReplace withObjCType:@encode(NSIntegerPoint)];
        [pointsToReplace addObject:pointObj];
        countOfCards++;
    }
    return pointsToReplace;
}

- (void)removeCardAtRow:(NSUInteger)row column:(NSUInteger)col
{
    //find view in boundingView
    CGPoint hitPoint = [self.grid centerOfCellAtRow:row inColumn:col];
    
    UIView *viewToRemove = [self.boundingView hitTest:hitPoint withEvent:nil];
    [self removeCardView:viewToRemove];
}

- (void)removeCardView:(UIView *)viewToRemove
{
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

- (void)replaceCards:(NSMutableArray *)pointsToReplace
{
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
                                    setCardView.card.chosen = NO;
                                    setCardView.card.matched = NO;
                                }
                 ];
            }
        }
    }
}

- (void)drawRandomSetCard:(SetCardView *)cardView
{
    Card *card = [self.deck drawRandomCard];
    if ([card isKindOfClass:[SetCard class]]) {
        SetCard *setCard = (SetCard *)card;
        cardView.card = setCard;
        //cardView.number = setCard.number;
        //cardView.color = setCard.color;
        //cardView.figure = setCard.figure;
        //cardView.shade = setCard.shade;
    }
}

#pragma mark - Gestures

- (IBAction)swipe:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self transitionCardSelection:sender];
    }
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self transitionCardSelection:sender];
    }

}

- (void)transitionCardSelection:(UILongPressGestureRecognizer *)sender
{
    SetCardView *cardView = (SetCardView *)(sender.view);
    if (cardView) {
        NSMutableArray *workingCardViews = [[NSMutableArray alloc] init];
        for (SetCardView *setCardView in self.boundingView.subviews) {
            if (setCardView.isChosen) {
                [workingCardViews addObject:setCardView];
            }
        }
        [UIView transitionWithView:cardView
                          duration:.75
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            if (cardView.chosen) {
                                [cardView setAlpha:1.0];
                            } else {
                                [cardView setAlpha:0.25];
                            }
                            cardView.chosen = !cardView.chosen;
                        }
                        completion:^(BOOL finished) {
                            if (finished && cardView.chosen){
                                [self completeSelectedCardTransition:workingCardViews withCardView:cardView];
                                
                            }
                        }
         ];
    }
}

- (void)completeSelectedCardTransition:(NSMutableArray *)workingCardViews withCardView:(SetCardView *)cardView
{
    if ([workingCardViews count] != 2) {
        return; //Don't do anything until 3rd card is selected.
    }
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    for (SetCardView *view in workingCardViews) {
        [cards addObject:view.card];
    }
    [self.game match:cards withCard:cardView.card];
    
    
    if (self.game.lastScore > 0) {
        //replace cardviews with new cardviews
        [workingCardViews addObject:cardView];//add currently selected card to cards to replace.
        for (SetCardView *setCardView in workingCardViews) {
            CGRect replaceFrame = setCardView.frame;
            [self removeCardView:setCardView];
            //Add a new card to the existing frame
            [self dropWithFrame:replaceFrame]; //will the view remain in memory if I use its frame?
        }

        //update scoreLabel
        [self updateUI];

    } else {
        //if 3 cards selected, unselect all cards
        [self unselectCards];
        NSLog(@"Not a match!");
    }
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
