//
//  PlayingCardView.h
//  SuperCard
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingCard.h"

@interface PlayingCardView : UIView

@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;
@property (nonatomic, getter = isFaceUp) BOOL faceUp;
@property (nonatomic, getter = isChosen) BOOL chosen;
@property (strong, nonatomic) PlayingCard *card;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;

//- (void)swipe:(UISwipeGestureRecognizer *)gesture;



@end
