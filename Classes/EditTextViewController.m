    //
//  EditTextViewController.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditTextViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Text.h"
#import "TextMemoryAppDelegate.h"

// Private category for private methods.
@interface EditTextViewController ()

// The alert view for editing the title.
@property (nonatomic, retain) UIAlertView *titleAlertView;

// The text field for editing the title. Shown in an alert view.
@property (nonatomic, retain) UITextField *titleTextField;

// Remove/pop this view controller, but instead of the navigation controller's transition, do a fade.
- (void)fadeAway;

@end


@implementation EditTextViewController

@synthesize titleAlertView, titleTextField;
@synthesize currentText, currentTextTextView, delegate, titleBarButtonItem;

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1) {
		
		// Save new title.
		self.currentText.title = self.titleTextField.text;
		TextMemoryAppDelegate *aTextMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
		[aTextMemoryAppDelegate saveContext];
		self.titleBarButtonItem.title = [NSString stringWithFormat:@"Editing \"%@\"", self.currentText.title];
	}
}

- (IBAction)cancelEditing:(id)sender {
	
	// Notify the delegate.
	[self.delegate editTextViewControllerDidFinishEditing:self];
	
	[self fadeAway];
}

- (void)dealloc {
	
	[titleAlertView release];
	[titleTextField release];
	
	[currentText release];
	[currentTextTextView release];
	[titleBarButtonItem release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)fadeAway {
	
	CATransition *aTransition = [CATransition animation];
	aTransition.duration = fadeTransitionDuration;
	[self.navigationController.view.layer addAnimation:aTransition forKey:nil];
	[self.navigationController popViewControllerAnimated:NO];
}

- (id)initWithText:(Text *)theText {
	
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		
        self.currentText = theText;
    }
    return self;
}

- (IBAction)renameTitle:(id)sender {
	
	// In iOS 5.0, UIAlertViewStylePlainTextInput should work. Until then, we'll add a text field to the alert view. The alert's message provides space for the text view. 
	UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:@"Rename Title" message:@"\n " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
	UITextField *aTextField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 57.0, 250.0, 27.0)];
	aTextField.borderStyle = UITextBorderStyleRoundedRect;
	aTextField.delegate = self;
	aTextField.returnKeyType = UIReturnKeyDone;
	aTextField.text = self.currentText.title;
	[anAlertView addSubview:aTextField];
	self.titleTextField = aTextField;
	[aTextField release];
	[anAlertView show];
	self.titleAlertView = anAlertView;
	[anAlertView release];
	
	// Show cursor and keyboard.
	[aTextField becomeFirstResponder];
}

- (IBAction)saveEditing:(id)sender {
	
	// Save current Text.
	self.currentText.text = self.currentTextTextView.text;
	TextMemoryAppDelegate *aTextMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	[aTextMemoryAppDelegate saveContext];
	
	// Notify the delegate.
	[self.delegate editTextViewControllerDidFinishEditing:self];
	
	[self fadeAway];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self.titleAlertView dismissWithClickedButtonIndex:1 animated:YES];
	return NO;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.titleBarButtonItem.title = [NSString stringWithFormat:@"Editing \"%@\"", self.currentText.title];
	
	self.currentTextTextView.text = self.currentText.text;
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.titleAlertView = nil;
	self.titleTextField = nil;
	self.currentTextTextView = nil;
	self.titleBarButtonItem = nil;
}

@end
