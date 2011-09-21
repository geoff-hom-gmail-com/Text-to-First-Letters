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

// An override of NSManagedObject. Initialize values.
- (void)awakeFromInsert;

// Create text showing only the first letter of each word of the full text. Replace other letters with spaces. Retain punctuation.
- (NSString *)createFirstLetterText;

@end


@implementation Text 

@dynamic firstLetterText, text, title;

- (void)awakeFromInsert {
	
	[super awakeFromInsert];
	
	// Persistent data.
	NSLog(@"Awake from insert");
	// this should not be called for default-data stuff
	self.title = @"Default Title";
	self.text = @"This is the default text.";
	self.firstLetterText = [self createFirstLetterText];
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

@end
