//
//  RootViewController.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Text;

@interface RootViewController : UIViewController {

@private
    Text *introText_;
}

// The current text.
@property (nonatomic, retain) Text *currentText;

// Text view for showing the current text.
@property (nonatomic, retain) IBOutlet UITextView *currentTextTextView;

@property (nonatomic, retain, readonly) Text *introText;

// If showing full text, show first letters only. And vice versa.
- (IBAction)toggleFirstLetters:(id)sender;

@end
