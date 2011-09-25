//
//  RootViewController.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTextViewController.h"
#import "TextsTableViewController.h"

@class Text;

@interface RootViewController : UIViewController <EditTextViewControllerDelegate, TextsTableViewDelegate> {

@private
    Text *introText_;
}

// The current text.
@property (nonatomic, retain) Text *currentText;

// Text view for showing the current text.
@property (nonatomic, retain) IBOutlet UITextView *currentTextTextView;

@property (nonatomic, retain, readonly) Text *introText;

// A switch controlling whether first letters or full text is shown.
@property (nonatomic, retain) IBOutlet UISwitch *showFirstLettersSwitch;

// The title of the current text.
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleBarButtonItem;

// Show view for editing the current text.
- (IBAction)editText:(id)sender;

// EditTextViewControllerDelegate method. Since the text may have changed, update the view.
- (void)editTextViewControllerDidFinishEditing:(EditTextViewController *)sender;

// Show/hide popover for selecting a text.
- (IBAction)showTextsPopover:(id)sender;

// TextsTableViewDelegate method. Since the user selected a text, dismiss the popover and show the text.
- (void)textsTableViewControllerDidSelectText:(TextsTableViewController *)sender;

@end
