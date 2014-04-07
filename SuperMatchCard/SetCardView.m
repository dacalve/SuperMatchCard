//
//  SetCardView.m
//  SuperCard
//
//  Created by David Calvert on 3/18/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "SetCardView.h"
#import "Grid.h"

@interface SetCardView()

@property (nonatomic) CGFloat figureScaleFactor;

@end

@implementation SetCardView

#define DEFAULT_FIGURE_SCALE_FACTOR 90.0

#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90
#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0
#define SYMBOL_LINE_WIDTH 0.02;
static NSString* const SQUIGGLE = @"squiggle";
static NSString* const OVAL = @"oval";
static NSString* const DIAMOND = @"diamond";
static NSString* const STRIPED = @"striped";
static NSString* const SOLID = @"solid";
static NSString* const UNFILLED = @"unfilled";

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

- (void)setUp
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.card = [[SetCard alloc] init];
}

- (void)awakeFromNib
{
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Create squigglies
        [self setUp];
        
    }
    return self;
}

#pragma mark - Properties

@synthesize figureScaleFactor = _figureScaleFactor;

- (CGFloat)figureScaleFactor
{
    if (!_figureScaleFactor) {
        _figureScaleFactor = DEFAULT_FIGURE_SCALE_FACTOR;
    }
    return _figureScaleFactor;
}

- (void)setFigureScaleFactor:(CGFloat)figureScaleFactor
{
    _figureScaleFactor = figureScaleFactor;
    [self setNeedsDisplay];
}

- (void)setCard:(SetCard *)card
{
    _card = card;
    self.number = card.number;
    self.color = card.color;
    self.figure = card.figure;
    self.shade = card.shade;
    [self setNeedsDisplay];
}

- (void)setNumber:(NSUInteger)number
{
    _number = number;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)setFigure:(NSString *)figure
{
    _figure = figure;
    [self setNeedsDisplay];
}

- (void)setShade:(NSString *)shade
{
    _shade = shade;
    [self setNeedsDisplay];
}

- (void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}

#pragma mark - Drawing methods

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    
    [roundedRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    

    if (self.figure == SQUIGGLE) {
        [self drawSquiggles];
    } else if (self.figure == DIAMOND) {
        [self drawDiamonds];
    } else if (self.figure == OVAL) {
        [self drawOvals];
    }
}

- (void)drawSquiggles
{
    CGFloat addX = self.bounds.size.width/DEFAULT_FIGURE_SCALE_FACTOR;
    CGFloat addY = self.bounds.size.height/DEFAULT_FIGURE_SCALE_FACTOR;
    
    for (int i = 0; i < self.number; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGFloat starter = ((3 - self.number)/6.0) * self.bounds.size.width;
//        NSLog(@"i=%d starter=%f",i,starter);
        CGFloat incrementer = i * self.bounds.size.width/3.0;
        CGFloat startX = 0.0 + starter + incrementer;
        CGFloat startY = self.bounds.size.height/6;
        // Set the starting point of the shape.
        [path moveToPoint:CGPointMake(startX, startY )];
        
        // Draw the lines.
        [path addLineToPoint:CGPointMake(startX + (20.0 * addX), startY + (0.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (30.0 * addX), startY + (20.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (20.0 * addX), startY + (40.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (30.0 * addX), startY + (60.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (10.0 * addX), startY + (60.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (0.0 * addX), startY + (40.0 * addY))];
        [path addLineToPoint:CGPointMake(startX + (10.0 * addX), startY + (20.0 * addY))];
        [path closePath];
        
        [self shadePath:path];
    }
}

- (void)drawDiamonds
{
    CGFloat addX = self.bounds.size.width/DEFAULT_FIGURE_SCALE_FACTOR;
    CGFloat addY = self.bounds.size.height/DEFAULT_FIGURE_SCALE_FACTOR;
    
    CGFloat starter = ((3 - self.number)/6.0) * self.bounds.size.width;
    //        NSLog(@"i=%d starter=%f",i,starter);
    
    for (int i = 0; i < self.number; i++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGFloat incrementer = i * self.bounds.size.width/3.0;
        CGFloat startX = 0.0 + starter + incrementer;
        CGFloat startY = self.bounds.size.height/6;
        // Set the starting point of the shape.
        [path moveToPoint:CGPointMake(startX + 15.0 * addX, startY + 0.0 *addY)];
        [path addLineToPoint:CGPointMake(startX + 30.0 * addX, startY + 30.0 * addY)];
        [path addLineToPoint:CGPointMake(startX + 15.0 * addX, startY + 60.0 * addY)];
        [path addLineToPoint:CGPointMake(startX + 0.0 * addX, startY + 30.0 * addY)];

        [path closePath];
        
        [self shadePath:path];
    }
}

- (void)drawOvals
{
    CGFloat addX = self.bounds.size.width/DEFAULT_FIGURE_SCALE_FACTOR;
    CGFloat addY = self.bounds.size.height/DEFAULT_FIGURE_SCALE_FACTOR;
    CGFloat starter = ((3 - self.number)/6.0) * self.bounds.size.width;
    
    for (int i = 0; i < self.number; i++) {
        
        CGFloat incrementer = i * self.bounds.size.width/3.0;
        CGFloat startX = 0.0 + starter + incrementer;
        CGFloat startY = self.bounds.size.height/6;
    
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(startX, startY, 30.0 * addX, 60.0 * addY)];
        
        [self shadePath:path];
    }
    
}

#define STRIPES_OFFSET 0.06
#define STRIPES_ANGLE 5

- (void)shadePath:(UIBezierPath *)path
{
    //to color the fill and stroke
    path.lineWidth = 2.0;
    if ([self.shade isEqualToString:SOLID]) {
        [self.color setFill];
        [path fill];
    } else if ([self.shade isEqualToString:STRIPED]) {
        [self.color setFill];
        [path fill];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        [path addClip];
        UIBezierPath *stripes = [[UIBezierPath alloc] init];
        CGPoint start = self.bounds.origin;
        CGPoint end = start;
        CGFloat dy = self.bounds.size.height * STRIPES_OFFSET;
        end.x += self.bounds.size.width;
        start.y += dy * STRIPES_ANGLE;
        for (int i = 0; i < 1 / STRIPES_OFFSET; i++) {
            [stripes moveToPoint:start];
            [stripes addLineToPoint:end];
            start.y += dy;
            end.y += dy;
        }
        stripes.lineWidth = self.bounds.size.width / 2 * SYMBOL_LINE_WIDTH;
        [stripes stroke];
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    } else if ([self.shade isEqualToString:UNFILLED]) {
        [self.color setStroke];
        [[UIColor clearColor] setFill];
    }
    [path stroke];
}


@end
