//
//  SMXScratchPanelView.h
//  SMXScratchPanelView
//
//  Created by Simon Maddox on 07/04/2011.
//  Copyright 2011 Simon Maddox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMXScratchPanelViewDelegate;

@interface SMXScratchPanelView : UIView 

- (void)setCode:(NSString *)code;

@property (nonatomic, weak) id <SMXScratchPanelViewDelegate> delegate;

@property (nonatomic, strong) NSMutableSet *revealPoints;
@property (nonatomic, getter=isRevealed) BOOL revealed;

@end

@protocol SMXScratchPanelViewDelegate <NSObject>

- (void) didRevealCodeForScratchPanelView:(SMXScratchPanelView *)scratchPanelView;

@end