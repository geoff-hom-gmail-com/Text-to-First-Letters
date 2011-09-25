//
//  EditTextViewController.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditTextViewController, Text;

@protocol EditTextViewControllerDelegate

// Sent after the user finished editing the text.
- (void)editTextViewControllerDidFinishEditing:(EditTextViewController *)sender;

@end

@interface EditTextViewController : UIViewController {
}

// The current text.
@property (nonatomic, retain) Text *currentText;

// Text view for showing the current text.
@property (nonatomic, retain) IBOutlet UITextView *currentTextTextView;

@property (nonatomic, assign) id <EditTextViewControllerDelegate> delegate;

// The title of the current text.
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleBarButtonItem;

// Cancel any changes and go back to the main view.
- (IBAction)cancelEditing:(id)sender;

// The designated initializer.
- (id)initWithText:(Text *)theText;

// Save changes to current text and go back to the main view.
- (IBAction)saveEditing:(id)sender;

@end
