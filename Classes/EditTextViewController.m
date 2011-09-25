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

// Remove/pop this view controller, but instead of the navigation controller's transition, do a fade.
- (void)fadeAway;

@end


@implementation EditTextViewController

@synthesize currentText, currentTextTextView, delegate, titleBarButtonItem;

- (IBAction)cancelEditing:(id)sender {
	
	[self fadeAway];
}

- (void)dealloc {
	
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
	//aTransition.duration = 1.0;
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

- (IBAction)saveEditing:(id)sender {
	
	// Save current Text.
	self.currentText.text = self.currentTextTextView.text;
	TextMemoryAppDelegate *aTextMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	NSError *error;
	[aTextMemoryAppDelegate.managedObjectContext save:&error];
	
	// Notify the delegate.
	[self.delegate editTextViewControllerDidFinishEditing:self];
	
	[self fadeAway];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
	self.currentTextTextView = nil;
	self.titleBarButtonItem = nil;
}



@end
