//
//  DWTagList.m
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 10.0f
#define LABEL_MARGIN 5.0f
#define BOTTOM_MARGIN 5.0f
#define FONT_SIZE 13.0f
#define HORIZONTAL_PADDING 7.0f
#define VERTICAL_PADDING 3.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor lightGrayColor].CGColor
#define BORDER_WIDTH 1.0f

@interface DWTagList()

- (void)touchedTag:(id)sender;

@end

@implementation DWTagList

@synthesize view, textArray;
@synthesize delegate = _delegate;
@synthesize selectionColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        self.selectionColor = [UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    }
    return self;
}

- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    [self display];
}

- (void)setLabelBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self display];
}

- (void)touchedTag:(id)sender {
    UITapGestureRecognizer *t = (UITapGestureRecognizer*)sender;
    UILabel *label = (UILabel*)t.view;
    CGColorRef currentLabelBackgroundColor = label.layer.backgroundColor;
    
    // Must animate UILabel background color using hack
    // http://stackoverflow.com/a/3762950/805882
    [UIView animateWithDuration:0.1 animations:^{
        label.layer.backgroundColor = selectionColor.CGColor;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 animations:^{
                label.layer.backgroundColor = currentLabelBackgroundColor;
            }];
        }
    }];
    
    if(label && self.delegate && [self.delegate respondsToSelector:@selector(selectedTagName:atIndex:)]) {
        [self.delegate selectedTagName:label.text atIndex:label.tag];
    }
}

- (void)display
{
    for (UILabel *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    float totalHeight = 0;
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    int tagNumber = 0;
    for (NSString *text in textArray) {
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width, 1500) lineBreakMode:NSLineBreakByWordWrapping];
        textSize.width += HORIZONTAL_PADDING*2;
        textSize.height += VERTICAL_PADDING*2;
        UILabel *label = nil;
        if (!gotPreviousFrame) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
            totalHeight = textSize.height;
        } else {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + textSize.width + LABEL_MARGIN > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + textSize.height + BOTTOM_MARGIN);
                totalHeight += textSize.height + BOTTOM_MARGIN;
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            }
            newRect.size = textSize;
            label = [[UILabel alloc] initWithFrame:newRect];
        }
        previousFrame = label.frame;
        gotPreviousFrame = YES;
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        label.backgroundColor = [UIColor clearColor];
        if (!lblBackgroundColor) {
            label.layer.backgroundColor = BACKGROUND_COLOR.CGColor;
        } else {
            label.layer.backgroundColor = lblBackgroundColor.CGColor;
        }
        [label setTextColor:TEXT_COLOR];
        [label setText:text];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setShadowColor:TEXT_SHADOW_COLOR];
        [label setShadowOffset:TEXT_SHADOW_OFFSET];
        [label.layer setMasksToBounds:YES];
        [label.layer setCornerRadius:CORNER_RADIUS];
        [label.layer setBorderColor:BORDER_COLOR];
        [label.layer setBorderWidth: BORDER_WIDTH];
        
        //Davide Cenzi, added gesture recognizer to label
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTag:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [label setUserInteractionEnabled:YES];
        [label addGestureRecognizer:gesture];
        
        label.tag = tagNumber;
        tagNumber++;
        [self addSubview:label];
    }
    sizeFit = CGSizeMake(self.frame.size.width, totalHeight + 8.0f);
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    //[self logFrame:self.frame];
}

- (void) logFrame:(CGRect)frame {
    NSLog(@"frame: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (CGSize)fittedSize
{
    return sizeFit;
}

@end
