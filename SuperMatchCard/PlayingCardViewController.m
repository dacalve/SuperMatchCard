//
//  PlayingCardViewController.m
//  SuperMatchCard
//
//  Created by David Calvert on 3/31/14.
//  Copyright (c) 2014 David Calvert. All rights reserved.
//

#import "PlayingCardViewController.h"
#import "PlayingCardView.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "Grid.h"

@interface PlayingCardViewController ()
@property (weak, nonatomic) IBOutlet PlayingCardView *playingCardView;
@property (weak, nonatomic) IBOutlet UIView *boundingView;
@property (strong, nonatomic) Deck *deck;
@property (nonatomic) NSUInteger place;
@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@property (strong, nonatomic) NSMutableArray *snaps;
@property (nonatomic) CGPoint gatherPoint;
@property (nonatomic) BOOL gathered;
@property (nonatomic) CGFloat scaleFactor;

@property (strong, nonatomic) UIGestureRecognizer *panner;
@property (strong, nonatomic) UITapGestureRecognizer *tapper;
@property (nonatomic) NSUInteger initialCount;

@end

@implementation PlayingCardViewController

#define DEFAULT_SCALE_FACTOR 0.86

static const CGSize DROP_SIZE = { 60, 80 };

- (CGFloat)scaleFactor
{
    if (!_scaleFactor) {
        _scaleFactor = DEFAULT_SCALE_FACTOR;
    }
    return _scaleFactor;
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.boundingView];
    }
    return _animator;
}

- (NSMutableArray *)snaps
{
    if (!_snaps) {
        _snaps = [[NSMutableArray alloc] init];
    }
    return _snaps;
}

- (Deck *)deck
{
    if (!_deck) _deck = [[PlayingCardDeck alloc] init];
    return _deck;
}

- (void)drawRandomPlayingCard:(PlayingCardView *)cardView
{
    Card *card = [self.deck drawRandomCard];
    if ([card isKindOfClass:[PlayingCard class]]) {
        PlayingCard *playingCard = (PlayingCard *)card;
        cardView.rank = playingCard.rank;
        cardView.suit = playingCard.suit;
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    PlayingCardView *cardView = (PlayingCardView *)(sender.view);
    if (cardView) {
        if (!cardView.faceUp)
        {
            [self drawRandomPlayingCard:cardView];
        }
        [self animateFlip:cardView];
    }
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    PlayingCardView *cardView = (PlayingCardView *)(sender.view);
    if (cardView) {
        if (!cardView.faceUp)
        {
            [self drawRandomPlayingCard:cardView];
        }
        [self animateFlip:cardView];
        
    }
    
}

- (void)animateFlip:(PlayingCardView *)cardView
{
    [UIView transitionWithView:cardView
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationCurveEaseIn
                    animations:^{
                        cardView.faceUp = !cardView.faceUp;
                    }
                    completion:^(BOOL finished) {
                        // cleanup viewOld
                    }
     ];
}

- (void)pinch:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        int scale = sender.scale;
        if (scale == 0) {
            for (UIView *view in self.boundingView.subviews) {
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:view snapToPoint:self.gatherPoint];
                [self.animator addBehavior:snap];
                [self.snaps addObject:snap];
            }
        }
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        for (UISnapBehavior *snap in self.snaps) {
            [self.animator removeBehavior:snap];
        }
        for (UIView *view in self.boundingView.subviews) {
            [view addGestureRecognizer:self.panner];
        }
        if (!self.tapper) {
            [self.boundingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    for (UIView *view in self.boundingView.subviews) {
        view.center = [sender locationInView:view.superview];
    }
}

- (void)tap:(UITapGestureRecognizer *)sender
{
    
    int row = 0;
    int col = 0;
    for (UIView *view in self.boundingView.subviews) {
        
        [UIView transitionWithView:view
                          duration:.75
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            view.center = [self.grid centerOfCellAtRow:row inColumn:col];
                        }
                        completion:^(BOOL finished) {
                            // cleanup viewOld
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
    //At the end remove the tap and all pan gesture recognizers
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.boundingView removeGestureRecognizer:self.tapper];
        for (UIView *view in self.boundingView.subviews) {
            [view removeGestureRecognizer:self.panner];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.boundingView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    
    self.panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    self.gatherPoint = CGPointMake(self.boundingView.bounds.size.width/2, self.boundingView.bounds.size.height/2);
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"Layout subviews! bounds.width=%f, bounds.height=%f", self.boundingView.bounds.size.width,self.boundingView.bounds.size.height);
    NSLog(@"orientation=%d",[UIApplication sharedApplication].statusBarOrientation);
    if ([self.boundingView.subviews count] == 0) {
        [self createPlayingCardViews];
        return;
    }
    //NSUInteger numberOfCells = self.grid.rowCount * self.grid.columnCount;
    self.grid = nil;
    self.grid = [[Grid alloc] init];
    self.grid.cellAspectRatio = 0.75;
    self.grid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
    
    //    CGFloat aspectOrientationScaleFactor = (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) ? 0.75 : 1.0);
    //    self.grid.minimumNumberOfCells = 12/aspectOrientationScaleFactor;
    self.grid.minimumNumberOfCells = self.initialCount;
    NSLog(@"min#ofcells=%i,rowcount=%i,colcount=%i", self.grid.minimumNumberOfCells,self.grid.rowCount, self.grid.columnCount);
    if (self.grid.inputsAreValid) {
        
        int row = 0;
        int col = 0;
        int count = 0;
        for (PlayingCardView *view in self.boundingView.subviews) {
            if (count < self.initialCount)
            {
                if (row < self.grid.rowCount) {
                    if (col < self.grid.columnCount) {
                        
                        CGRect frame = [self.grid frameOfCellAtRow:row inColumn:col];
                        //                        NSLog(@"count=%i, X=%f, Y=%f",count, frame.origin.x, frame.origin.y);
                        [UIView transitionWithView:view
                                          duration:.75
                                           options:UIViewAnimationOptionCurveEaseIn
                                        animations:^{
                                            view.frame = frame;
                                        }
                                        completion:^(BOOL finished) {
                                            
                                        }
                         ];
                        col++;
                    } else {
                        col = 0;
                        row++;
                    }
                    
                } //else {
                //  continue;
                //}
            }
            count++;
            
        }
    } else {
        NSLog(@"Inputs are not valid.");
    }
}

- (void)createPlayingCardViews
{
    self.grid = nil;
    self.grid = [[Grid alloc] init];
    self.grid.cellAspectRatio = 0.75;//testing 60/80
    self.grid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
    self.grid.minimumNumberOfCells = 12/0.75;
    if (self.grid.inputsAreValid) {
        for (NSUInteger row = 0; row < self.grid.rowCount; row++) {
            for (NSUInteger col = 0; col < self.grid.columnCount; col++) {
                [self dropWithFrame:[self.grid frameOfCellAtRow:row inColumn:col]];
            }
        }
    }
    self.initialCount = self.grid.rowCount * self.grid.columnCount;
}

- (void)dropWithFrame:(CGRect)frame
{
    PlayingCardView *dropView = [[PlayingCardView alloc] initWithFrame:frame];
    dropView.alpha = 0.0;
    
    [dropView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)]];
    
    //fade in the drop view to begin the game.
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

- (void)dropWithFrame:(CGRect)frame atRow:(NSUInteger)row inColumn:(NSUInteger)column
{
    PlayingCardView *dropView = [[PlayingCardView alloc] initWithFrame:frame];
    
    [dropView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)]];
    
    //[dropView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    [self.boundingView addSubview:dropView];
}

- (void)drop
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    frame.origin.x = self.place++ * DROP_SIZE.width + 5;
    frame.origin.y = 20;
    
    PlayingCardView *dropView = [[PlayingCardView alloc] initWithFrame:frame];
    
    [dropView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)]];
    
    [self.boundingView addSubview:dropView];
}

@end
