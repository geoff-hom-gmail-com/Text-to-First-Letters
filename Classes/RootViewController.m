//
//  RootViewController.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DefaultData.h"
#import "RootViewController.h"
#import "Text.h"
#import "TextMemoryAppDelegate.h"
#import "TextsTableViewController.h"

// Private category for private methods.
@interface RootViewController ()

// Once we create this, we'll keep it in memory and just reuse it.
@property (nonatomic, retain) UIPopoverController *popoverController;

// Start key-value observing.
- (void)addObservers;

// Stop key-value observing.
- (void)removeObservers;

// Show only the first letter of each word (plus punctuation).
- (void)showFirstLettersOnly;

// Show the entire text (vs. only first letters).
- (void)showFullText;

@end

@implementation RootViewController

@synthesize currentText, currentTextTextView, showFirstLettersSwitch, titleBarButtonItem;
@synthesize popoverController;

- (void)addObservers {
	
	// Watch for changes to the current text.
	[self addObserver:self forKeyPath:@"currentText" options:0 context:nil];
}

- (void)dealloc {
	
	[self removeObservers];
	
	self.popoverController.delegate = nil;
	[popoverController release];
	
	[introText_ release];
    
	[currentText release];
	[currentTextTextView release];
	[showFirstLettersSwitch release];
	[titleBarButtonItem release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
		
		self.titleBarButtonItem.title = self.currentText.title;
		if (self.showFirstLettersSwitch.on) {
			[self showFirstLettersOnly];
		} else {
			[self showFullText];
		}
	}
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
		UIViewController *aViewController = aTextsTableViewController;
		
		// Create the popover controller, if necessary.
		if (!self.popoverController) {
			
			UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:aViewController];
			//aPopoverController.delegate = self;
			self.popoverController = aPopoverController;
			[aPopoverController release];
		} else {
			self.popoverController.contentViewController = aViewController;
			
		}
		[aViewController release];
		
		// Present popover.
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}	
}

- (void)textSelected:(Text *)theText {
	
	[self.popoverController dismissPopoverAnimated:YES];
	self.currentText = theText;
}

- (IBAction)toggleFirstLetters:(id)sender {
	
	if (self.showFirstLettersSwitch.on) {
		[self showFirstLettersOnly];
	} else {
		[self showFullText];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	// Start KVO. 
	[self addObservers];
	
	// Set initial text.
	self.currentText = [self introText];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	[self removeObservers];
	
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.popoverController.delegate = nil;
	self.popoverController = nil;
	self.currentTextTextView = nil;
	self.showFirstLettersSwitch = nil;
	self.titleBarButtonItem = nil;
}

@end
