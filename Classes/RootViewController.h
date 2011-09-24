//
//  RootViewController.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextsTableViewController.h"

@class Text;

@interface RootViewController : UIViewController <TextsTableViewDelegate> {

@private
    Text *introText_;
}

// The current text.
@property (nonatomic, retain) Text *currentText;

// Text view for showing the current text.
@property (nonatomic, retain) IBOutlet UITextView *currentTextTextView;

@property (nonatomic, retain, readonly) Text *introText;

// Switch controlling whether first letters or full text is shown.
@property (nonatomic, retain) IBOutlet UISwitch *showFirstLettersSwitch;

// The title of the current text.
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleBarButtonItem;

// Show/hide popover for selecting a text.
// if user taps toolbar or button, does it dismiss popover? if outside popover, does it dismiss?
- (IBAction)showTextsPopover:(id)sender;

// If showing full text, show first letters only. And vice versa.
- (IBAction)toggleFirstLetters:(id)sender;

// TextsTableViewDelegate method. Since the user selected a text, dismiss the popover and show the text.
- (void)textSelected:(Text *)theText;

@end
