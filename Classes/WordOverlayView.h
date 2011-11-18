//
//  WordOverlayView.h
//  Text-to-First-Letters

// Invisible/empty view for positioning above a text view to detect touch events. Detects when a touch event is over a word and sends that info to its delegate.
//
//  Created by Geoffrey Hom on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WordOverlayView : UIView <UITextViewDelegate> {
}

// Text view to let touch events pass through to.
@property (nonatomic, retain) IBOutlet UITextView *textView;

// UIView method override. Return NO so that the event will pass through. However, if the event is on a word, send that info to the delegate.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

// delegate method
- (void)textViewDidChangeSelection:(UITextView *)textView;

@end
