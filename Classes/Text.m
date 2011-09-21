// 
//  Text.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Text.h"

// Private category for private methods.
@interface Text ()

// Start key-value observing.
- (void)addObservers;

// An override of NSManagedObject. Add observers.
- (void)awakeFromFetch;

// An override of NSManagedObject. Initialize values. Add observers.
- (void)awakeFromInsert;

// Create text showing only the first letter of each word of the full text. Replace other letters with spaces. Retain punctuation.
- (NSString *)createFirstLetterText;

// Stop key-value observing.
- (void)removeObservers;

// An override of NSManagedObject. Remove observers. Note: This may not work with deletion-undo, since the observer will be removed upon deletion but then not added back. Can test when editing text live.
- (void)willTurnIntoFault;

@end


@implementation Text 

@dynamic firstLetterText, isDefaultData_, text, title;

- (void)addObservers {

	// Watch for bricks being added or deleted.
	[self addObserver:self forKeyPath:@"text" options:0 context:nil];
}

- (void)awakeFromFetch {

	[super awakeFromFetch];
	[self addObservers];
}

- (void)awakeFromInsert {
	
	[super awakeFromInsert];
	[self addObservers];
	
	// Persistent data.
	NSLog(@"Awake from insert");
	self.isDefaultData = NO;
	self.title = @"Default Title";
	self.text = @"This is the default text.";
}

- (NSString *)createFirstLetterText {
	
	// this should be called only when the text changes. not each time it's loaded or each time the switch is done. only when first made and when edited.
	// I could trigger this by kvo on the text property.
	NSLog(@"Text: createFirstLetterText");
	
	// Go through the text, one character at a time. If previous character was a letter and this is also a letter, then replace with a space. Otherwise, keep it.
	NSString *spaceString = @" ";
	NSCharacterSet *letterCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	NSMutableString *aMutableFirstLetterText = [NSMutableString stringWithCapacity:self.text.length];
	BOOL previousCharacterWasLetter = NO;
	unichar character;
	NSString *characterToAddString;
	BOOL currentCharacterIsLetter;
	BOOL addSpace;
	for (int i = 0; i < self.text.length; i++) {
		
		currentCharacterIsLetter = NO;
		character = [self.text characterAtIndex:i];
		if ( [letterCharacterSet characterIsMember:character] ) {
			currentCharacterIsLetter = YES;
		}
		
		addSpace = NO;
		if (previousCharacterWasLetter && currentCharacterIsLetter) {
			addSpace = YES;
		}
		
		if (addSpace) {
			[aMutableFirstLetterText appendString:spaceString];
		} else {
			characterToAddString = [NSString stringWithCharacters:&character length:1];
			[aMutableFirstLetterText appendString:characterToAddString];
		}
		
		previousCharacterWasLetter = currentCharacterIsLetter;
	}
	return aMutableFirstLetterText;
}

- (BOOL)isDefaultData {
	
	return [self.isDefaultData_ boolValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// If the text was changed, then update the first-letter text.
	if ([keyPath isEqualToString:@"text"]) {
		
		NSLog(@"Text oVFKP: text changed.");
		self.firstLetterText = [self createFirstLetterText];
	}
}

- (void)removeObservers {

	// Stop watching for changes to the text.
	[self removeObserver:self forKeyPath:@"text"];
}

- (void)setIsDefaultData:(BOOL)value {
	
	self.isDefaultData_ = [NSNumber numberWithBool:value];
}
 
- (void)willTurnIntoFault {
	
	[super willTurnIntoFault];
	[self removeObservers];
}

@end
