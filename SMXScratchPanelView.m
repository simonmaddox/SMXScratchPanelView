//
//  SMXScratchPanelView.m
//  SMXScratchPanelView
//
//  Created by Simon Maddox on 07/04/2011.
//  Copyright 2011 Simon Maddox. All rights reserved.
//

#import "SMXScratchPanelView.h"
#import <QuartzCore/QuartzCore.h>

#define Overlap 80

@interface SMXScratchPanelView () {
	CGPoint _lastPoint;
	UIImageView *_scratchArea;	
	UILabel *_code;
	CGSize _scratchSize;
	NSMutableSet *_revealPoints;
}

- (void) removeRectFromPointSet:(CGRect)rect;
- (UIImage *) initialImage;
@end

@implementation SMXScratchPanelView

@synthesize revealPoints, delegate, revealed;

- (id) initWithFrame:(CGRect)frame
{
	// If we create this view with a slightly larger frame, you'll be able to begin the scratch slightly outside the view
	CGRect overlapFrame = CGRectMake(frame.origin.x - Overlap, frame.origin.y - Overlap, frame.size.width + (Overlap * 2), frame.size.height + (Overlap * 2));
	
	self = [super initWithFrame:overlapFrame];
    if (self) {
		
		_scratchSize = CGSizeMake(20, 20);
		
		_code = [[UILabel alloc] initWithFrame:CGRectMake(Overlap, Overlap, frame.size.width, frame.size.height)];
		[_code setTextAlignment:UITextAlignmentCenter];
		[_code setFont:[UIFont boldSystemFontOfSize:24]];
		[_code setBackgroundColor:[UIColor clearColor]];
		[_code setLineBreakMode:UILineBreakModeClip];
		[_code setAdjustsFontSizeToFitWidth:YES];
		
		_scratchArea = [[UIImageView alloc] initWithFrame:_code.frame];
		_scratchArea.image = [self initialImage];
		_scratchArea.opaque = YES;
		_scratchArea.clipsToBounds = YES;
		_scratchArea.layer.cornerRadius = 7.0;
		
		[self addSubview:_scratchArea];
		
		[self insertSubview:_code belowSubview:_scratchArea];
				
		[self addObserver:self forKeyPath:@"revealPoints" options:NSKeyValueObservingOptionNew context:nil];
		
		self.revealPoints = [NSMutableSet set];
		
		NSInteger numberOfRevealPoints = 5;
		numberOfRevealPoints += 2; // Keep the reveal points away from the edge
		NSInteger offset = frame.size.width / numberOfRevealPoints;
		
		for (NSInteger i = 1; i < numberOfRevealPoints - 1; i++){
			[self.revealPoints addObject:[NSValue valueWithCGRect:CGRectMake(offset * i, frame.size.height / 2, 1, 1)]];
		}
	}
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	_lastPoint = [touch locationInView:_scratchArea];
	_lastPoint.y -= _scratchSize.height / 2;	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint currentPoint = [touch locationInView:_scratchArea];
	currentPoint.y -= _scratchSize.height / 2;
	
	UIGraphicsBeginImageContext(_scratchArea.frame.size);
	[_scratchArea.image drawInRect:CGRectMake(0, 0, _scratchArea.frame.size.width, _scratchArea.frame.size.height)];
	
	CGRect rect = CGRectMake(_lastPoint.x, _lastPoint.y, _scratchSize.width, _scratchSize.height);
	
	[self removeRectFromPointSet:rect];
	
	CGContextClearRect (UIGraphicsGetCurrentContext(), rect);
	_scratchArea.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	_lastPoint = currentPoint;
}

- (UIImage *) initialImage
{
	
	UIView *initialView = [[UIView alloc] initWithFrame:self.frame];
	[initialView setBackgroundColor:[UIColor colorWithRed:206.0/255 green:207.0/255 blue:207.0/255 alpha:1]];
	
	UIGraphicsBeginImageContext(initialView.bounds.size);
	[initialView.layer renderInContext:UIGraphicsGetCurrentContext()];	
	UIImage *initialImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return initialImage;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
}

- (void) setCode:(NSString *)code
{
	[_code setText:code];
}

- (void)setRevealed:(BOOL)isRevealed
{
	[_scratchArea setHidden:isRevealed];
}

- (void) removeRectFromPointSet:(CGRect)rect
{	
	NSMutableSet *temp = [self.revealPoints copy];
	
	for (NSValue *value in [temp allObjects]){
		CGRect pointRect = [value CGRectValue];
			
		if (CGRectIntersectsRect(rect, pointRect)){
			[self willChangeValueForKey:@"revealPoints"];
			[self.revealPoints removeObject:value];
			[self didChangeValueForKey:@"revealPoints"];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"revealPoints"]){
		if ([self.revealPoints count] == 0){
			[self.delegate didRevealCodeForScratchPanelView:self];
		}
	}
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"revealPoints"];
}

@end
