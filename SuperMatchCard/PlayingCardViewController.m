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
@property (weak, nonatomic) PlayingCardView *playingCardView;
@property (weak, nonatomic) IBOutlet UIView *boundingView;
@property (strong, nonatomic) Deck *deck;
@property (nonatomic) NSUInteger place;
@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) Grid *portraitGrid;
@property (strong, nonatomic) Grid *landscapeGrid;
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

#define NUMBER_OF_PLAYING_CARDS 16
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

- (Grid *)portraitGrid
{
    if (!_portraitGrid) {
        _portraitGrid = [[Grid alloc] init];
        _portraitGrid.cellAspectRatio = 0.75;//testing 60/80
        _portraitGrid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
        _portraitGrid.minimumNumberOfCells = NUMBER_OF_PLAYING_CARDS;
    }
    return _portraitGrid;
}

- (Grid *)landscapeGrid
{
    if (!_landscapeGrid) {
        _landscapeGrid = [[Grid alloc] init];
        _landscapeGrid.cellAspectRatio = 0.75;//testing 60/80
        _landscapeGrid.size = CGSizeMake(self.boundingView.bounds.size.width, self.boundingView.bounds.size.height);
        _landscapeGrid.minimumNumberOfCells = NUMBER_OF_PLAYING_CARDS;
    }
    return _landscapeGrid;
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
    int count = 0;
    for (UIView *view in self.boundingView.subviews) {
        int row = count/self.grid.columnCount;
        int col = count%self.grid.columnCount;
        [self movePlayingCardViewToCenter:(UIView*)view toRow:(int)row andColumn:(int)col];
        count++;

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

- (void)willRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"from portrait:%i  from landscape:%i",fromInterfaceOrientation == UIDeviceOrientationPortrait, fromInterfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"Layout subviews! bounds.width=%f, bounds.height=%f", self.boundingView.bounds.size.width,self.boundingView.bounds.size.height);
    NSLog(@"orientation=%d",[UIApplication sharedApplication].statusBarOrientation);
    if ([self.boundingView.subviews count] == 0) {
        [self createPlayingCardViews];
        return;
    }
    self.grid = [self createGrid];
    NSLog(@"min#ofcells=%i,rowcount=%i,colcount=%i", self.grid.minimumNumberOfCells,self.grid.rowCount, self.grid.columnCount);
    if (self.grid.inputsAreValid) {
    
        int count = 0;
        for (PlayingCardView *view in self.boundingView.subviews) {
            int row = count/self.grid.columnCount;
            int col = count%self.grid.columnCount;
            [self movePlayingCardView:view toRow:row andColumn:col];
            count++;
        }
    } else {
        NSLog(@"Inputs are not valid.");
    }
}

- (void)movePlayingCardView:(UIView*)view toRow:(int)row andColumn:(int)col
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

- (void)movePlayingCardViewToCenter:(UIView*)view toRow:(int)row andColumn:(int)col
{
    NSLog(@"This is row:%i col:%i rowcount:%i colcount:%i",row,col,self.grid.rowCount, self.grid.columnCount);
    
    [UIView transitionWithView:view
                      duration:1.0
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        view.center = [self.grid centerOfCellAtRow:row inColumn:col];
                    }
                    completion:^(BOOL finished) {
                        // cleanup viewOld
                    }
     ];
}

- (void)createPlayingCardViews
{
    self.grid = [self createGrid];
    if (self.grid.inputsAreValid) {
        for (NSUInteger row = 0; row < self.grid.rowCount; row++) {
            for (NSUInteger col = 0; col < self.grid.columnCount; col++) {
                [self dropWithFrame:[self.grid frameOfCellAtRow:row inColumn:col]];
            }
        }
    }
    self.initialCount = self.grid.rowCount * self.grid.columnCount;
}

- (Grid *)createGrid
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        return self.landscapeGrid;
    }
    return self.portraitGrid;
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
