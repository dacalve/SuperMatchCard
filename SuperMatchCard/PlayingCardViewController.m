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

#define NUMBER_OF_PLAYING_CARDS 12
#define DEFAULT_SCALE_FACTOR 0.86
#define PLAYING_CARD_ASPECT_RATIO 0.75
#define NUMBER_OF_CARDS_TO_MATCH 2

static const CGSize DROP_SIZE = { 60, 80 };

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.aspectRatio = PLAYING_CARD_ASPECT_RATIO;
    self.numberOfCards = NUMBER_OF_PLAYING_CARDS;
	// Do any additional setup after loading the view, typically from a nib.
    [self.boundingView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    
    self.panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    self.gatherPoint = CGPointMake(self.boundingView.bounds.size.width/2, self.boundingView.bounds.size.height/2);
}

- (void)willRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"from portrait:%i  from landscape:%i",fromInterfaceOrientation == UIDeviceOrientationPortrait, fromInterfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (IBAction)deal:(id)sender
{
    NSMutableArray *pointsToReplace = [self getAllPointsToReplace];
    [self replaceCards:pointsToReplace];
    self.game = nil;
    [self updateUI];
}

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

- (void)replaceCards:(NSMutableArray *)pointsToReplace
{
    for (NSValue *pointValue in pointsToReplace) {
        NSIntegerPoint point;
        [pointValue getValue:&point];
        
        [self removeCardAtRow:point.x column:point.y];
        
        [self dropWithFrame:[self.grid frameOfCellAtRow:point.x inColumn:point.y]];
    }
}

- (void)removeCardAtRow:(NSUInteger)row column:(NSUInteger)col
{
    //find view in boundingView
    CGPoint hitPoint = [self.grid centerOfCellAtRow:row inColumn:col];
    
    UIView *viewToRemove = [self.boundingView hitTest:hitPoint withEvent:nil];
    //remove from superview
    if ([viewToRemove isKindOfClass:[PlayingCardView class]]) {
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

- (void)drawRandomPlayingCard:(PlayingCardView *)cardView
{
    if (!cardView.card.rank) {
        Card *card = [self.deck drawRandomCard];
        if ([card isKindOfClass:[PlayingCard class]]) {
            PlayingCard *playingCard = (PlayingCard *)card;
            cardView.card = playingCard;
//            cardView.rank = playingCard.rank;
//            cardView.suit = playingCard.suit;
        }
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self transitionCardSelection:sender];
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
    
    NSMutableArray *workingCardViews = [[NSMutableArray alloc] init];
    for (PlayingCardView *playingCardView in self.boundingView.subviews) {
        if (playingCardView.isFaceUp) {
            [workingCardViews addObject:playingCardView];
        }
    }
    
    [UIView transitionWithView:cardView
                      duration:.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationCurveEaseIn
                    animations:^{
                        cardView.faceUp = !cardView.faceUp;
                    }
                    completion:^(BOOL finished) {
                        if (finished && cardView.faceUp){
                            [self completeSelectedCardTransition:workingCardViews withCardView:cardView];
                            
                        }
                    }
     ];
}

- (void)completeSelectedCardTransition:(NSMutableArray *)workingCardViews withCardView:(PlayingCardView *)cardView
{
    if ([workingCardViews count] != NUMBER_OF_CARDS_TO_MATCH - 1) {
        return; //Don't do anything until number of cards to match is selected.
    }
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    for (PlayingCardView *view in workingCardViews) {
        [cards addObject:view.card];
    }
    [self.game match:cards withCard:cardView.card];
    
    
    if (self.game.lastScore > 0) {
        //replace cardviews with new cardviews
        [workingCardViews addObject:cardView];//add currently selected card to cards to replace.
        for (PlayingCardView *playingCardView in workingCardViews) {
            CGRect replaceFrame = playingCardView.frame;
            [self removeCardView:playingCardView];
            //Add a new card to the existing frame
            [self dropWithFrame:replaceFrame]; //will the view remain in memory if I use its frame?
        }
        
    } else {
        //if 3 cards selected, unselect all cards
        [self unselectCards:workingCardViews];
        NSLog(@"Not a match!");
    }
    //update scoreLabel
    [self updateUI];
}

- (void)removeCardView:(UIView *)viewToRemove
{
    if ([viewToRemove isKindOfClass:[PlayingCardView class]]) {
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

- (void)unselectCards:(NSMutableArray *)workingCardViews
{
    for (UIView *view in workingCardViews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            
            PlayingCardView *playingCardView = (PlayingCardView *)view;
            
            if (playingCardView.isFaceUp) {
                [UIView transitionWithView:playingCardView
                                  duration:.75
                                   options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationCurveEaseIn
                                animations:^{
                                    playingCardView.faceUp = !playingCardView.faceUp;
                                }
                                completion:^(BOOL finished) {
                                    playingCardView.chosen = NO;
                                    playingCardView.card.chosen = NO;
                                    playingCardView.card.matched = NO;
                                }
                 ];
            }
        }
    }
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

- (void)transitionCardSelection:(UISwipeGestureRecognizer *)sender
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
