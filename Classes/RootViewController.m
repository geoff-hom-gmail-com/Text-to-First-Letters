    //
//  RootViewController.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "Text.h"
#import "TextMemoryAppDelegate.h"

// Private category for private methods.
@interface RootViewController ()

// Show only the first letter of each word (plus punctuation).
- (void)showFirstLettersOnly;

// Show the entire text (vs. only first letters).
- (void)showFullText;

@end

@implementation RootViewController

@synthesize currentText, currentTextTextView;


- (void)dealloc {
	
	[introText_ release];
    
	[currentText release];
	[currentTextTextView release];
	
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
		
		// Set initial text.
		self.currentText = [self introText];
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
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title MATCHES 'Introduction'"]; 
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	NSLog(@"fetch done.");
	if (array == nil) {
		NSLog(@"fetch failed?");
	}
	if (array.count == 0) {
		NSLog(@"fetch count 0");
		introText_ = [NSEntityDescription insertNewObjectForEntityForName:@"Text" inManagedObjectContext:aManagedObjectContext];
	} else {
		introText_ = [array objectAtIndex:0];
	}

	return introText_;
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

- (IBAction)toggleFirstLetters:(id)sender {
	
	UISwitch *aSwitch = (UISwitch *)sender;
	if (aSwitch.on) {
		[self showFirstLettersOnly];
	} else {
		[self showFullText];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	// Show the current text's text.
	self.currentTextTextView.text = self.currentText.text;
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.currentTextTextView = nil;
}




@end
