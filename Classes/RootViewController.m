//
//  RootViewController.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DefaultData.h"
#import "EditTextViewController.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Text.h"
#import "TextMemoryAppDelegate.h"
#import "TextsTableViewController.h"

// Alert message when user tries to edit/delete a default text.
NSString *triedToEditDefaultTextString = @"The starting texts cannot be changed.";

// Private category for private methods.
@interface RootViewController ()

// When the user tries to delete a text, we show an action sheet. We keep a reference to know if a sheet is already showing.
@property (nonatomic, retain) UIActionSheet *deleteTextActionSheet;

// Once we create this, we'll keep it in memory and just reuse it.
@property (nonatomic, retain) UIPopoverController *popoverController;

// Start key-value observing.
- (void)addObservers;

// Delete the current text.
- (void)deleteCurrentText;

// Stop key-value observing.
- (void)removeObservers;

// Show only the first letter of each word (plus punctuation).
- (void)showFirstLettersOnly;

// Show the entire text (vs. only first letters).
- (void)showFullText;

// If showing full text, show first letters only. And vice versa. Also adjust the switch.
- (void)toggleFirstLetters;

@end

@implementation RootViewController

@synthesize bottomToolbar, currentText, currentTextTextView, showFirstLettersSwitch, titleLabel, topToolbar, trashBarButtonItem;
@synthesize deleteTextActionSheet, popoverController;

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	// Currently, only the action sheet for deleting has a tappable button.
	if (buttonIndex == 0) {
		
		[self deleteCurrentText];
	}
	self.deleteTextActionSheet = nil;
	
	// Re-enable corresponding toolbar. (Currently, the only action sheets that should call this method are for the Delete button.)
	self.bottomToolbar.userInteractionEnabled = YES;
}

- (IBAction)addAText:(id)sender {
	
	NSManagedObjectContext *aManagedObjectContext = [(TextMemoryAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	Text *aText = (Text *)[NSEntityDescription insertNewObjectForEntityForName:@"Text" inManagedObjectContext:aManagedObjectContext];
	self.currentText = aText;
	NSError *error;
	[aManagedObjectContext save:&error];
}

- (void)addObservers {
	
	// Watch for changes to the current text.
	[self addObserver:self forKeyPath:@"currentText" options:0 context:nil];
}

- (void)dealloc {
	
	[self removeObservers];
	
	self.popoverController.delegate = nil;
	[popoverController release];
	self.deleteTextActionSheet.delegate = nil;
	[deleteTextActionSheet release];
	
	[introText_ release];
    
	[bottomToolbar release];
	[currentText release];
	[currentTextTextView release];
	[showFirstLettersSwitch release];
	[titleLabel release];
	[topToolbar release];
	[trashBarButtonItem release];
	
	[super dealloc];
}

- (IBAction)confirmDeleteCurrentText:(id)sender {
	
	// If a default text, tell why it can't be deleted. Else, ask user to confirm via an action sheet.
	
	// Proceed only if not showing a message.
	if (!self.deleteTextActionSheet) {
		
		UIActionSheet *anActionSheet;
		if ([self.currentText isDefaultData]) {
			
			anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Can't Delete Examples", nil];
			
			// Disable buttons. This action sheet is informational only.
			anActionSheet.userInteractionEnabled = NO;
			
		} else {
			
			anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete This Text" otherButtonTitles:nil];
		}
		[anActionSheet showFromBarButtonItem:self.trashBarButtonItem animated:NO];
		self.deleteTextActionSheet = anActionSheet;
		[anActionSheet release];
		
		// Disable toolbar with this button.
		self.bottomToolbar.userInteractionEnabled = NO;
	}
}

- (void)deleteCurrentText {
	
	// This has no visible transition, but it seems okay since the deletion action sheet takes some time to disappear.
	NSManagedObjectContext *aManagedObjectContext = [(TextMemoryAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[aManagedObjectContext deleteObject:self.currentText];
	NSError *error;
	[aManagedObjectContext save:&error];
	self.currentText = [self introText];
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (IBAction)editText:(id)sender {
	
	EditTextViewController *anEditTextViewController = [(EditTextViewController *)[EditTextViewController alloc] initWithText:self.currentText];
	anEditTextViewController.delegate = self;
	
	// Show the editing view. Instead of the navigation controller's transition, do a fade.
	CATransition *aTransition = [CATransition animation];
	//aTransition.duration = 1.0;
	[self.navigationController.view.layer addAnimation:aTransition forKey:nil];
	[self.navigationController pushViewController:anEditTextViewController animated:NO];
	
	[anEditTextViewController release];
}

- (void)editTextViewControllerDidFinishEditing:(EditTextViewController *)sender {
	
	if (self.showFirstLettersSwitch.on) {
		[self showFirstLettersOnly];
	} else {
		[self showFullText];
	}
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
        // Custom initialization.
    }
    return self;
}

- (Text *)introText {
	
	if (introText_ != nil) {
        return introText_;
    }
	
	// Fetch initial text.
	NSManagedObjectContext *aManagedObjectContext = [(TextMemoryAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Text" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title MATCHES %@", welcomeTextTitle]; 
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (array == nil) {
		NSLog(@"RVC: fetch failed?");
	}
	if (array.count == 0) {
		NSLog(@"Warning: RVC iT couldn't find a Text entitled '%@.'", welcomeTextTitle);
	} else {
		introText_ = [array objectAtIndex:0];
	}

	return introText_;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// If the current text changed, then update the view's title and text.
	if ([keyPath isEqualToString:@"currentText"]) {
		
		self.titleLabel.text = self.currentText.title;
		if (self.showFirstLettersSwitch.on) {
			[self showFirstLettersOnly];
		} else {
			[self showFullText];
		}
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
	// Re-enable corresponding toolbar. (Currently, the only popover controller that should call this method is for the Texts button.)
	self.topToolbar.userInteractionEnabled = YES;
}

- (void)removeObservers {
	
	[self removeObserver:self forKeyPath:@"currentText"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)showFirstLettersOnly {
	
	self.currentTextTextView.text = self.currentText.firstLetterText;
}

- (void)showFullText {
	
	self.currentTextTextView.text = self.currentText.text;
}

- (IBAction)showTextsPopover:(id)sender {
	
	if (!self.popoverController.popoverVisible) {
			
		// Create the view controller for the popover.
		TextsTableViewController *aTextsTableViewController = [[TextsTableViewController alloc] init];
		aTextsTableViewController.delegate = self;
		aTextsTableViewController.currentText = self.currentText;
		UIViewController *aViewController = aTextsTableViewController;
		
		// Create the popover controller, if necessary.
		if (!self.popoverController) {
			
			UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:aViewController];
			self.popoverController = aPopoverController;
			[aPopoverController release];
		} else {
			self.popoverController.contentViewController = aViewController;
			
		}
		[aViewController release];
		
		// Resize popover.
		self.popoverController.popoverContentSize = self.popoverController.contentViewController.contentSizeForViewInPopover;
		
		// Present popover.
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		// Disable toolbar (until popover dismissed).
		self.topToolbar.userInteractionEnabled = NO;
	}	
}

- (void)textsTableViewControllerDidSelectText:(TextsTableViewController *)sender {
	
	[self.popoverController dismissPopoverAnimated:YES];
	
	// Dismissing popover programmatically doesn't call this delegate method. But we do cleanup there, so we need to call it.
	[self popoverControllerDidDismissPopover:nil];
	
	self.currentText = sender.currentText;
}

- (void)toggleFirstLetters {
	
	if (self.showFirstLettersSwitch.on) {
		self.showFirstLettersSwitch.on = NO;
		[self showFullText];
	} else {
		self.showFirstLettersSwitch.on = YES;
		[self showFirstLettersOnly];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	// Start KVO. 
	[self addObservers];
	
	// Set initial text.
	self.currentText = [self introText];
	
	// Disable the switch's animation, to allow faster work. To do this, we'll add a custom (invisible) button over the switch. When the button is tapped, it will do the work the switch would normally do, except the switch's status will also be set, programmatically, without animation.
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton addTarget:self action:@selector(toggleFirstLetters) forControlEvents:UIControlEventTouchUpInside];
	aButton.frame = self.showFirstLettersSwitch.frame;
	[self.view addSubview:aButton];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	[self removeObservers];
	
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.popoverController.delegate = nil;
	self.popoverController = nil;
	self.deleteTextActionSheet.delegate = nil;
	self.deleteTextActionSheet = nil;
	self.bottomToolbar = nil;
	self.currentTextTextView = nil;
	self.showFirstLettersSwitch = nil;
	self.titleLabel = nil;
	self.topToolbar = nil;
	self.trashBarButtonItem = nil;
}

@end
