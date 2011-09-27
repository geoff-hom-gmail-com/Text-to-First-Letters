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

@interface RootViewController : UIViewController <EditTextViewControllerDelegate, TextsTableViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate> {

@private
    Text *introText_;
}

// Toolbar at the bottom of the screen.
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;

// The current text.
@property (nonatomic, retain) Text *currentText;

// Text view for showing the current text.
@property (nonatomic, retain) IBOutlet UITextView *currentTextTextView;

@property (nonatomic, retain, readonly) Text *introText;

// A switch controlling whether first letters or full text is shown.
@property (nonatomic, retain) IBOutlet UISwitch *showFirstLettersSwitch;

// The title of the current text.
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// Toolbar at the top of the screen.
@property (nonatomic, retain) IBOutlet UIToolbar *topToolbar;

// The trash button (for deleting the current text).
@property (nonatomic, retain) IBOutlet UIBarButtonItem *trashBarButtonItem;

// UIActionSheetDelegate method. Since the action sheet was dismissed, clear its reference. Also check if the delete button was tapped.
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

// Add a new text and open it for editing.
- (IBAction)addAText:(id)sender;

// User tapped to delete the current text. Ask for confirmation.
- (IBAction)confirmDeleteCurrentText:(id)sender;

// Show view for editing the current text.
- (IBAction)editText:(id)sender;

// EditTextViewControllerDelegate method. Since the text may have changed, update the view.
- (void)editTextViewControllerDidFinishEditing:(EditTextViewController *)sender;

// UIPopoverControllerDelegate method. Since the popover was dismissed, re-enable the corresponding toolbar.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

// Show/hide popover for selecting a text.
- (IBAction)showTextsPopover:(id)sender;

// TextsTableViewDelegate method. Since the user selected a text, dismiss the popover and show the text.
- (void)textsTableViewControllerDidSelectText:(TextsTableViewController *)sender;

@end
