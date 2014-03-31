//
//  SetCardView.h
//  SuperCard
//
//  Created by David Calvert on 3/18/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetCardView : UIView

@property (nonatomic) NSUInteger number; //1,2,3
@property (strong, nonatomic) UIColor *color; //red, green, purple
@property (strong, nonatomic) NSString *figure; //squiggle, diamond, oval
@property (nonatomic) NSString *shade; //number of shapes (solid, striped, unfilled)
@property (nonatomic) BOOL faceUp;
@property (nonatomic, getter = isChosen) BOOL chosen;


@end
