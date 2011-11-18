//
//  RootViewController.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DefaultData.h"
#import "EditTextViewController.h"
#import "FontSizeViewController.h"
#import "OverlayView.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Text.h"
#import "TextMemoryAppDelegate.h"
#import "TextsTableViewController.h"
#import "WordOverlayView.h"

// Set to YES to show UI for launch image. Can capture in simulator: control key -> Edit menu -> Copy Screen -> in GraphicConverter or Preview, File -> New from clipboard.
BOOL createLaunchImages = NO;

// Title for action-sheet button for adding a new text.
NSString *addTextTitleString = @"Add a New Text";

// Title for action-sheet button for deleting text.
NSString *deleteTextTitleString = @"Delete This Text";

// Title for action-sheet button for editing text.
NSString *editTextTitleString = @"Edit Current Title and Text";

// Title for segmented control segment for showing first letters.
NSString *firstLetterTextModeTitleString = @"First Letters";

// Title for segmented control segment for showing full text.
NSString *fullTextModeTitleString = @"Full Text";

NSString *testWidthString = @"_abcdefghijklmnopqrstuvwxyzabcdefghijklm_";

// Private category for private methods.
@interface RootViewController ()

// Segment in segmented control for switching to first-letter mode.
@property (nonatomic) NSUInteger firstLettersSegmentIndex;

// Segment in segmented control for switching to full-text mode.
@property (nonatomic) NSUInteger fullTextSegmentIndex;

// Once we create this, we'll keep it in memory and just reuse it.
@property (nonatomic, retain) UIPopoverController *popoverController;

// Add a new text and show it.
- (void)addANewText;

// Start key-value observing.
- (void)addObservers;

// Delete the current text.
- (void)deleteCurrentText;

// Go to editing view for the current text.
- (void)editCurrentText;

// Given a text view, set its width to span the test string. Also, keep the view centered.
- (void)maintainRelativeWidthOfTextView:(UITextView *)theTextView;

// Stop key-value observing.
- (void)removeObservers;

// Show only the first letter of each word (plus punctuation).
- (void)showFirstLettersOnly;

// Show the entire text (vs. only first letters).
- (void)showFullText;

// Make sure the correct title and text is showing. (And that the text's mode is correct.)
- (void)updateTitleAndTextShowing;

@end

@implementation RootViewController

@synthesize addTextBarButtonItem, bottomToolbar, currentText, currentTextTextView, editTextBarButtonItem, textToShowSegmentedControl, titleLabel, topToolbar, trashBarButtonItem;
@synthesize firstLettersSegmentIndex, fullTextSegmentIndex, popoverController;

- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	// Check the title of the button index. Act appropriately.
	if (buttonIndex != -1) {
		
		NSString *buttonTitle = [theActionSheet buttonTitleAtIndex:buttonIndex];
		if ( [buttonTitle isEqualToString:editTextTitleString] ) {
			
			[self editCurrentText];
		} else if ( [buttonTitle isEqualToString:addTextTitleString] ) {
			
			[self addANewText];
		} else if ( [buttonTitle isEqualToString:deleteTextTitleString] ) {
			
			[self deleteCurrentText];
		}
	}
	
	// Re-enable toolbars, in case they were disabled.
	self.topToolbar.userInteractionEnabled = YES;
	self.bottomToolbar.userInteractionEnabled = YES;
}

- (void)addANewText {
	
	// Add text and save.
	TextMemoryAppDelegate *aTextMemoryAppDelegate = (TextMemoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *aManagedObjectContext = [aTextMemoryAppDelegate managedObjectContext];
	Text *aText = (Text *)[NSEntityDescription insertNewObjectForEntityForName:@"Text" inManagedObjectContext:aManagedObjectContext];
	[aTextMemoryAppDelegate saveContext];
	
	// Show new text, fading into it.
	CATransition *aTransition = [CATransition animation];
	aTransition.duration = fadeTransitionDuration;
	[self.navigationController.view.layer addAnimation:aTransition forKey:nil];
	self.currentText = aText;
}

- (void)addObservers {
	
	// Watch for changes to the current text.
	[self addObserver:self forKeyPath:@"currentText" options:0 context:nil];
}

- (IBAction)changeTextModeToShow:(UISegmentedControl *)theSegmentedControl {
	
	if (theSegmentedControl.selectedSegmentIndex == self.fullTextSegmentIndex) {
		
		[self showFullText];
	} else if (theSegmentedControl.selectedSegmentIndex == self.firstLettersSegmentIndex) {
		
		[self showFirstLettersOnly];
	}
}

- (IBAction)confirmAddText:(id)sender {
	
	// Ask user to confirm/choose via an action sheet.
	UIActionSheet *anActionSheet;
	anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:addTextTitleString, nil];
	[anActionSheet showFromBarButtonItem:self.addTextBarButtonItem animated:NO];
	[anActionSheet release];
	
	// Disable toolbar with this button.
	self.topToolbar.userInteractionEnabled = NO;
}

- (IBAction)confirmDeleteCurrentText:(id)sender {
	
	// If a default text, tell why it can't be deleted. Else, ask user to confirm via an action sheet.
		
	UIActionSheet *anActionSheet;
	if ([self.currentText isDefaultData]) {
		
		anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Can't Delete Examples", nil];
		
		// Disable buttons. This action sheet is informational only.
		anActionSheet.userInteractionEnabled = NO;
		
	} else {
		
		anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:deleteTextTitleString otherButtonTitles:nil];
	}
	[anActionSheet showFromBarButtonItem:self.trashBarButtonItem animated:NO];
	[anActionSheet release];
	
	// Disable toolbar with this button.
	self.bottomToolbar.userInteractionEnabled = NO;
}

- (IBAction)confirmEditCurrentText:(id)sender {
	
	// If a default text, tell why it can't be edited. Else, ask user to confirm/choose via an action sheet.
	
	UIActionSheet *anActionSheet;
	if ([self.currentText isDefaultData]) {
		
		anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Can't Edit Examples", nil];
		
		// Disable buttons. This action sheet is informational only.
		anActionSheet.userInteractionEnabled = NO;
		
	} else {
		
		anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:editTextTitleString, nil];
	}
	[anActionSheet showFromBarButtonItem:self.editTextBarButtonItem animated:NO];
	[anActionSheet release];
	
	// Disable toolbar with this button.
	self.topToolbar.userInteractionEnabled = NO;
}

- (void)dealloc {
	
	[self removeObservers];
	
	self.popoverController.delegate = nil;
	[popoverController release];
	
	[introText_ release];
    
	[addTextBarButtonItem release];
	[bottomToolbar release];
	[currentText release];
	[currentTextTextView release];
	[editTextBarButtonItem release];
	[textToShowSegmentedControl release];
	[titleLabel release];
	[topToolbar release];
	[trashBarButtonItem release];
	
	[super dealloc];
}

- (void)deleteCurrentText {
	
	// This has no visible transition, but it seems okay since the deletion action sheet takes some time to disappear.
	TextMemoryAppDelegate *aTextMemoryAppDelegate = (TextMemoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *aManagedObjectContext = [aTextMemoryAppDelegate managedObjectContext];
	[aManagedObjectContext deleteObject:self.currentText];
	[aTextMemoryAppDelegate saveContext];
	
	self.currentText = [self introText];
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)editCurrentText {
	
	EditTextViewController *anEditTextViewController = [(EditTextViewController *)[EditTextViewController alloc] initWithText:self.currentText contentOffset:self.currentTextTextView.contentOffset font:self.currentTextTextView.font];
	anEditTextViewController.delegate = self;
	
	// Show the editing view. Instead of the navigation controller's transition, do a fade.
	CATransition *aTransition = [CATransition animation];
	aTransition.duration = fadeTransitionDuration;
	[self.navigationController.view.layer addAnimation:aTransition forKey:nil];
	[self.navigationController pushViewController:anEditTextViewController animated:NO];
	
	[anEditTextViewController release];
}

- (IBAction)editText:(id)sender {
	
	// If a default text, tell why it can't be edited. Else, proceed to editing view.
	
	if ([self.currentText isDefaultData]) {
	
		UIActionSheet *anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Can't Edit Examples", nil];
		
		// Disable buttons. This action sheet is informational only.
		anActionSheet.userInteractionEnabled = NO;
		
		[anActionSheet showFromBarButtonItem:self.editTextBarButtonItem animated:NO];
		[anActionSheet release];
		
		// Disable toolbar with this button.
		self.bottomToolbar.userInteractionEnabled = NO;
	} else {
		
		EditTextViewController *anEditTextViewController = [(EditTextViewController *)[EditTextViewController alloc] initWithText:self.currentText contentOffset:self.currentTextTextView.contentOffset font:self.currentTextTextView.font];
		anEditTextViewController.delegate = self;
		
		// Show the editing view. Instead of the navigation controller's transition, do a fade.
		CATransition *aTransition = [CATransition animation];
		aTransition.duration = fadeTransitionDuration;
		[self.navigationController.view.layer addAnimation:aTransition forKey:nil];
		[self.navigationController pushViewController:anEditTextViewController animated:NO];
		
		[anEditTextViewController release];
	}
}

- (void)editTextViewControllerDidFinishEditing:(EditTextViewController *)sender {
	
	self.currentTextTextView.contentOffset = sender.contentOffset;
	[self updateTitleAndTextShowing];
}

- (void)fontSizeViewControllerDidChangeFontSize:(FontSizeViewController *)theFontSizeViewController {
	
	NSString *currentFontName = self.currentTextTextView.font.fontName;
	UIFont *newFont = [UIFont fontWithName:currentFontName size:theFontSizeViewController.currentFontSize];
	self.currentTextTextView.font = newFont;
	[self maintainRelativeWidthOfTextView:self.currentTextTextView];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)theTapGestureRecognizer {
	
	// If not showing first letters, show them. Else, show full text.
	
	if (self.textToShowSegmentedControl.selectedSegmentIndex != self.firstLettersSegmentIndex) {
		
		self.textToShowSegmentedControl.selectedSegmentIndex = self.firstLettersSegmentIndex;
	} else {
		
		self.textToShowSegmentedControl.selectedSegmentIndex = self.fullTextSegmentIndex;
	}
}

/*
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)thePinchGestureRecognizer {
	
	// If pinch in (velocity < 0), show first letters. Else, show full text. We'll do this by mimicking the user tapping the segmented control.

	if ((thePinchGestureRecognizer.velocity < 0) && 
		(self.textToShowSegmentedControl.selectedSegmentIndex != self.firstLettersSegmentIndex)) {
		
		self.textToShowSegmentedControl.selectedSegmentIndex = self.firstLettersSegmentIndex;
	} else if ((thePinchGestureRecognizer.velocity > 0) && 
			   (self.textToShowSegmentedControl.selectedSegmentIndex != self.fullTextSegmentIndex)) {
		
		self.textToShowSegmentedControl.selectedSegmentIndex = self.fullTextSegmentIndex;
	}
}
 */

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

- (void)maintainRelativeWidthOfTextView:(UITextView *)theTextView {
	
	CGFloat newWidth = [testWidthString sizeWithFont:theTextView.font].width;
	
	// Width must be even to avoid subpixel boundaries.
	if ((int)newWidth % 2 != 0) {
		newWidth += 1;
	}
	
	CGRect newFrame = theTextView.frame;
	newFrame.size.width = newWidth;
	newFrame.origin.x = (self.view.frame.size.width - newFrame.size.width) / 2;
	theTextView.frame = newFrame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// If the current text changed, then update the view's title and text.
	if ([keyPath isEqualToString:@"currentText"]) {
		
		[self updateTitleAndTextShowing];
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

- (IBAction)showFontSizePopover:(id)sender {

	if (!self.popoverController.popoverVisible) {
		
		// Create the view controller for the popover.
		FontSizeViewController *aFontSizeViewController = [[FontSizeViewController alloc] init];
		aFontSizeViewController.delegate = self;
		aFontSizeViewController.currentFontSize = self.currentTextTextView.font.pointSize;
		UIViewController *aViewController = aFontSizeViewController;
		
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

- (void)updateTitleAndTextShowing {
	
	self.titleLabel.text = self.currentText.title;
	if (self.textToShowSegmentedControl.selectedSegmentIndex == self.firstLettersSegmentIndex) {
		[self showFirstLettersOnly];
	} else {
		[self showFullText];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	if (createLaunchImages) {
		
		self.topToolbar.items = nil;
		self.titleLabel.text = @"";
		self.currentTextTextView.text = @"";
		self.bottomToolbar.items = nil;
	} else {
	
		// Start KVO. 
		[self addObservers];
		
		// Set up segmented control for showing first letters.
		self.fullTextSegmentIndex = 0;
		self.firstLettersSegmentIndex = 1;
		[self.textToShowSegmentedControl setTitle:fullTextModeTitleString forSegmentAtIndex:self.fullTextSegmentIndex];
		[self.textToShowSegmentedControl setTitle:firstLetterTextModeTitleString forSegmentAtIndex:self.firstLettersSegmentIndex];
		
		// Add word overlay view to detect taps on words. Add single-tap gesture recognizer.
		WordOverlayView *aWordOverlayView = [[WordOverlayView alloc] initWithFrame:self.currentTextTextView.frame];
		aWordOverlayView.textView = self.currentTextTextView;
		aWordOverlayView.textView.delegate = aWordOverlayView;
		//aWordOverlayView.delegate = self;
		[self.view addSubview:aWordOverlayView];
		// add action later
		UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
		aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
		// may not need gesture recognizer
		//[aWordOverlayView addGestureRecognizer:aSingleTapGestureRecognizer];
		[aSingleTapGestureRecognizer release];
		[aWordOverlayView release];
		
		// Add overlay view on top of all views.
		CGRect windowMinusBarsFrame = CGRectMake(0, self.currentTextTextView.frame.origin.y, self.view.frame.size.width, self.currentTextTextView.frame.size.height);
		OverlayView *anOverlayView = [[OverlayView alloc] initWithFrame:windowMinusBarsFrame];
		anOverlayView.textViewToIgnore = self.currentTextTextView;
		[self.view addSubview:anOverlayView];
		
		/*
		// Add pinch gesture recognizer.
		UIPinchGestureRecognizer *aPinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
		//[someView addGestureRecognizer:aPinchGestureRecognizer];
		[aPinchGestureRecognizer release];
		 */
		
		// Add double-tap gesture recognizer.
		UITapGestureRecognizer *aDoubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
		aDoubleTapGestureRecognizer.numberOfTapsRequired = 2;
		[anOverlayView addGestureRecognizer:aDoubleTapGestureRecognizer];
		[aDoubleTapGestureRecognizer release];
		
		[anOverlayView release];
		
		// Align text view so it doesn't appear to shift later.
		[self maintainRelativeWidthOfTextView:self.currentTextTextView];
		
		// Set initial text.
		self.currentText = [self introText];
	}
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	[self removeObservers];
	
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.popoverController.delegate = nil;
	self.popoverController = nil;
	self.addTextBarButtonItem = nil;
	self.bottomToolbar = nil;
	self.currentTextTextView = nil;
	self.editTextBarButtonItem = nil;
	self.textToShowSegmentedControl = nil;
	self.titleLabel = nil;
	self.topToolbar = nil;
	self.trashBarButtonItem = nil;
}

@end
