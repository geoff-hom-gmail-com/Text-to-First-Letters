//
//  WordOverlayView.m
//  Text-to-First-Letters
//
//  Created by Geoffrey Hom on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WordOverlayView.h"

// Private category for private methods.
@interface WordOverlayView ()

// For the substring up to and including the given index, return the substring's height, relative to the view's frame.
- (NSUInteger)actualSubstringHeightForIndex:(NSUInteger)index;

// Return the size of the text in the text view, not including top padding, right padding, left padding, or the scroll bar. (Bottom padding is currently not accounted for.)
- (CGSize)actualTextViewSize;

// Return the range for the line at the given point.
- (NSRange)substringRangeForLineAtPoint:(CGPoint)point;

//?
- (NSRange)frontBorderRangeForLineAtPoint:(CGPoint)point;

//?
- (NSUInteger)startOfLineIndexForFrontBorderRange:(NSRange)frontBorderRange;

//?
- (NSUInteger)startOfLineIndexAtPoint:(CGPoint)point;

//
- (NSArray *)substringIndexForLineAtPoint:(CGPoint)point lowIndex:(NSUInteger)lowIndex highIndex:(NSUInteger)highIndex currentIndex:(NSUInteger)currentIndex;

// Return the word (in the text view) under the given point. If none, return nil.
- (NSString *)wordUnderPoint:(CGPoint)point;

@end

@implementation WordOverlayView

@synthesize textView;

- (NSUInteger)actualSubstringHeightForIndex:(NSUInteger)index {
	
	NSUInteger textViewVerticalPadding = 12;
	
	// The substring should include the character at the index.
	NSString *substring = [self.textView.text substringToIndex:(index + 1)];
	
	CGSize substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
	//UILineBreakModeWordWrap
	NSUInteger actualSubstringHeight = substringSize.height + textViewVerticalPadding;
	//NSLog(@"WOV aSHFI. Index:%d: Substring:%@: height:%d", index, substring, actualSubstringHeight);
	return actualSubstringHeight;
}

- (CGSize)actualTextViewSize {
	
	// Actual text view width is shortened by x. For the starting font, x = 12 - 18 seems to work. (What x should be exactly is unclear.)
	NSUInteger textViewHorizontalPadding = 6; // 7
	NSUInteger textViewVerticalPadding = 12;
	NSUInteger scrollBarWidth = 0; // 4
	
	CGSize actualTextViewSize = self.textView.bounds.size;
	actualTextViewSize.width = actualTextViewSize.width - (2 * textViewHorizontalPadding) - scrollBarWidth;
	actualTextViewSize.height = actualTextViewSize.height - textViewVerticalPadding;
	
	return actualTextViewSize;
}

- (void)dealloc {
	
	[textView release];
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)textViewDidChangeSelection:(UITextView *)theTextView {
	
	NSLog(@"WOV tVDCS:%@", NSStringFromRange(theTextView.selectedRange) );
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	
	// testing with just logging the correct word for now. later, will send the range of the word to delegate.
	
	NSLog(@"WOV pI event detected:%@", NSStringFromCGPoint(point) );
	
//	[self.textView closestPositionToPoint:point];
	//NSLog(@"WOV pI test2");
	
	// Do something only if the point is within the textview.
	if ( [self.textView pointInside:point withEvent:event] ) {
		
		NSString *touchedWord = [self wordUnderPoint:point];
		if (touchedWord) {
			NSLog(@"word found: %@", touchedWord);
		} else {
			NSLog(@"no word under tap");
		}
	}

	BOOL answer;
	answer = NO;
	
	return answer;
}

- (NSString *)wordUnderPoint:(CGPoint)point {
	
	/*
	 NSUInteger startOfLineIndex = [self startOfLineIndexAtPoint:point];
	NSLog(@"startOfLineIndex:%d", startOfLineIndex);
	NSString *substring = [self.textView.text substringWithRange:NSMakeRange(startOfLineIndex, 20) ];
	NSLog(@"start of line:%@", substring);
	*/
	
	NSRange lineAtPointRange = [self substringRangeForLineAtPoint:point];
	NSLog(@"lineAtPointRange:%@", NSStringFromRange(lineAtPointRange) );
	NSString *substring = [self.textView.text substringWithRange:lineAtPointRange];
	NSLog(@"Line at point:%@", substring);
	
	
	//NSRange wordUnderPointRange = [self substringRangeForWordInLineAtPoint:point startOfLineIndex:startOfLineIndex];
	
	//NSString *wordUnderPointString = [self.textView.text substringWithRange:wordUnderPointRange];
	//NSLog(@"word under point:|%@|", wordUnderPointString);
	// if word is only whitespace, return nil?
	//return wordUnderPointString;
	
	return nil;
}

- (NSRange)substringRangeForLineAtPoint:(CGPoint)point {
	
	// We'll find the index for the start of the line, then the index for the end of the line. While searching for the start of the line, we'll use that info to aid the search for the end of the line.
	
	// Check the start and end of the string. If the point is above or below the entire text, return NSNotFound.
	
	NSInteger maxIndexBeforeLine;
	NSUInteger minIndexOnLine;
	NSUInteger maxIndexOnLine;
	NSInteger minIndexAfterLine;
	
	NSUInteger currentIndex = 0;
	NSUInteger actualSubstringHeight = [self actualSubstringHeightForIndex:currentIndex];
	CGFloat lineHeight = self.textView.font.lineHeight;
	if (point.y < actualSubstringHeight - lineHeight) {
		
		return NSMakeRange(NSNotFound, 0);
	} else if (point.y <= actualSubstringHeight) {
		
		maxIndexBeforeLine = currentIndex - 1;
		minIndexOnLine = currentIndex;
	} else {
		
		maxIndexBeforeLine = currentIndex;
		minIndexOnLine = [self.textView.text length] - 1;
	}
	
	currentIndex = [self.textView.text length] - 1;
	actualSubstringHeight = [self actualSubstringHeightForIndex:currentIndex];
	if (point.y > actualSubstringHeight) {
		
		return NSMakeRange(NSNotFound, 0);
	} else if (point.y >= actualSubstringHeight - lineHeight) {
		
		maxIndexOnLine = currentIndex;
		minIndexAfterLine = maxIndexOnLine + 1;
	} else {
		
		maxIndexOnLine = 0;
		minIndexAfterLine = currentIndex;
	}

	while (maxIndexBeforeLine + 1 != minIndexOnLine) {
		
		//NSLog(@"test2: maxIndexBeforeLine:%d minIndexOnLine:%d ", maxIndexBeforeLine, minIndexOnLine);
		
		// Pick an index in between. Calculate that substring's height.
		
		currentIndex = (maxIndexBeforeLine + minIndexOnLine) / 2;
		actualSubstringHeight = [self actualSubstringHeightForIndex:currentIndex];
		
		// Compare the substring's height to the point's y value.
		
		// If the current index is after the line.
		if (point.y < actualSubstringHeight - lineHeight) {
			
			minIndexOnLine = currentIndex;
			minIndexAfterLine = currentIndex;
			
		// If the current index is before the line.
		} else if (point.y > actualSubstringHeight) {
			
			maxIndexBeforeLine = currentIndex;
			maxIndexOnLine = currentIndex;
			
		// If the current index is on the line.
		} else {
			
		//	NSLog(@"index on line:%d", currentIndex);
			minIndexOnLine = currentIndex;
			maxIndexOnLine = currentIndex;
		}		
	}
	//NSLog(@"test2.1: maxIndexBeforeLine:%d minIndexOnLine:%d ", maxIndexBeforeLine, minIndexOnLine);
	
	// T, newline, newline, l is 0, 1, 2, 3
	// line 4, 6-x is right
	// line 2, should be 3-4, is reported as 5
	// line 3 should be 5, is reported as 6
	//NSLog(@"testing:%@|", [self.textView.text substringWithRange:NSMakeRange(3, 4) ] );
	
	while (minIndexAfterLine != maxIndexOnLine + 1) {
		
	//	NSLog(@"test3: maxIndexOnLine:%d minIndexAfterLine:%d ", maxIndexOnLine, minIndexAfterLine);
		
		// Pick an index in between. Calculate that substring's height.
		
		currentIndex = (maxIndexOnLine + minIndexAfterLine) / 2;
		actualSubstringHeight = [self actualSubstringHeightForIndex:currentIndex];
		
		// Compare the substring's height to the point's y value.
		
		// If the current index is after the line.
		if (point.y < actualSubstringHeight - lineHeight) {
			
			minIndexAfterLine = currentIndex;
			
		// If the current index is before the line. (Shouldn't happen if the start of line was determined correctly.)
		} else if (point.y > actualSubstringHeight) {
			
			;
			
		// If the current index is on the line.
		} else {

			//NSLog(@"index on line:%d", currentIndex);
			maxIndexOnLine = currentIndex;
		}		
	}
	//NSLog(@"test3.1: maxIndexOnLine:%d minIndexAfterLine:%d ", maxIndexOnLine, minIndexAfterLine);
	
	
	//NSLog(@"test4: minIndexOnLine:%d maxIndexOnLine:%d ", minIndexOnLine, maxIndexOnLine);
		
	// If the calculated start of the line is in the middle of a word, we really want the index at the start of the word, because the word wrap will put it on the line. We'll get the index by scanning backward to the previous whitespace.
	
	NSRange lastWhitespaceRange = [self.textView.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, minIndexOnLine + 1) ];
	if (lastWhitespaceRange.location == NSNotFound) {
		minIndexOnLine = 0;
	} else {
		minIndexOnLine = lastWhitespaceRange.location + 1;
	}
	
	//NSLog(@"test5: minIndexOnLine:%d maxIndexOnLine:%d ", minIndexOnLine, maxIndexOnLine);
	
	// If the calculated end of the line is in the middle of a word, we really want the index of the previous whitespace, because the word wrap will move the word to the next line. We'll get the index by scanning backward to the previous whitespace.
	
	lastWhitespaceRange = [self.textView.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(minIndexOnLine, maxIndexOnLine - minIndexOnLine + 1) ];
	if (lastWhitespaceRange.location == NSNotFound) {
		;
	} else {
		maxIndexOnLine = lastWhitespaceRange.location;
	}
	
	//NSLog(@"test6: minIndexOnLine:%d maxIndexOnLine:%d ", minIndexOnLine, maxIndexOnLine);
	
	NSRange lineRange = NSMakeRange(minIndexOnLine, maxIndexOnLine - minIndexOnLine + 1);
	return lineRange;
}

// Return the string index for the start of the line at the given point.
- (NSUInteger)startOfLineIndexAtPoint:(CGPoint)point {
	
	// Get a range which starts before the line (or at 0) and ends on the line.
	NSRange frontBorderRange = [self frontBorderRangeForLineAtPoint:point];
	//NSLog(@"frontBorderRange:%@", NSStringFromRange(frontBorderRange) );
	NSUInteger startOfLineIndex = [self startOfLineIndexForFrontBorderRange:frontBorderRange];
	
	/*
	
	NSUInteger startingGuessIndex = [self.textView.text length] * 0.5 - 1;
	NSArray *lowHighSubstringIndexArray = [self substringIndexForLineAtPoint:point lowIndex:0 highIndex:[self.textView.text length] currentIndex:startingGuessIndex];
	NSUInteger substringIndex = [(NSNumber *)[lowHighSubstringIndexArray objectAtIndex:2] unsignedIntValue];
	NSUInteger beforeLineIndex = [(NSNumber *)[lowHighSubstringIndexArray objectAtIndex:0] unsignedIntValue];
	NSRange borderRange = NSMakeRange(beforeLineIndex, substringIndex - beforeLineIndex + 1);
	
	NSUInteger startOfLineIndex = [self startOfLineIndexForEndOfRange:borderRange heightToMatch:heightToMatch];
	 */
	return startOfLineIndex;
}

// For the given point, return a range of string indices. The range ends on an index corresponding to the line containing the point, but the range begins before that line (or at 0).
- (NSRange)frontBorderRangeForLineAtPoint:(CGPoint)point {
	
	//NSUInteger textViewHorizontalPadding = 8;
	NSUInteger textViewVerticalPadding = 12;
	CGFloat lineHeight = self.textView.font.lineHeight;
	
	//CGSize actualTextViewSize = self.textView.bounds.size;
//	actualTextViewSize.width = actualTextViewSize.width - (2 * textViewHorizontalPadding);
	
	NSUInteger lowIndex = 0;
	NSUInteger highIndex = [self.textView.text length] - 1;
	NSUInteger currentIndex = highIndex / 2;
	NSUInteger newIndex;
	
	NSString *substring;
	CGSize substringSize;
	
	BOOL lineFound = NO;
	do {
		
		// Calculate the size of the substring.
		
		substring = [self.textView.text substringToIndex:currentIndex];
		substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
		substringSize.height = substringSize.height + textViewVerticalPadding;
		
		// If correct line not found, calculate new indices.
		
		if (substringSize.height < point.y) {
			
			newIndex = (currentIndex + highIndex) / 2;
			if (newIndex != currentIndex) {
				
				lowIndex = currentIndex;
				currentIndex = newIndex;
			} else {
				
				break; 
			}
		} else if (substringSize.height - lineHeight > point.y) {
			
			newIndex = (currentIndex + lowIndex) / 2;
			if (newIndex != currentIndex) {
				
				highIndex = currentIndex;
				currentIndex = newIndex;
			} else {
				
				break; 
			}
		} else {
			
			lineFound = YES;
		}
	} while (!lineFound);
	
	return NSMakeRange(lowIndex, currentIndex - lowIndex + 1);
}

// For the given range, return the string index at the start of the corresponding line. The given range should end on an index corresponding to the desired line, and the range should begin before that line (or at 0).
- (NSUInteger)startOfLineIndexForFrontBorderRange:(NSRange)frontBorderRange {
	
	// Get baseline.
	
	//NSUInteger textViewHorizontalPadding = 8;
	NSUInteger textViewVerticalPadding = 12;
	//NSUInteger scrollBarWidth = 6;
	
	//CGSize actualTextViewSize = self.textView.bounds.size;
//	actualTextViewSize.width = actualTextViewSize.width - (2 * textViewHorizontalPadding) - scrollBarWidth;
	
	NSUInteger afterIndex = frontBorderRange.location + frontBorderRange.length - 1;
	NSString *substring = [self.textView.text substringToIndex:afterIndex];
	CGSize substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
	CGFloat heightToMatch = substringSize.height + textViewVerticalPadding;
	
	// Check start of range. If the height isn't different, then assume the start of the range is the start of the line.
	
	NSUInteger beforeIndex = frontBorderRange.location;
	substring = [self.textView.text substringToIndex:beforeIndex];
	substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
	substringSize.height = substringSize.height + textViewVerticalPadding;
	if (substringSize.height == heightToMatch) {
		
		return beforeIndex;
	}
	
	// Calculate a middle index.
	
	NSUInteger currentIndex = (beforeIndex + afterIndex) / 2;
	
	// Check the height of the current index. Use that to narrow the range. Repeat until the range is as small as possible.
	
	BOOL startOfLineFound = NO;
	do {
		
		// Calculate the size of the substring.
		
		//NSLog(@"testing3, currentIndex:%d", currentIndex);
		substring = [self.textView.text substringToIndex:currentIndex];
		substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
		substringSize.height = substringSize.height + textViewVerticalPadding;
	//	NSLog(@"substring size:%@", NSStringFromCGSize(substringSize) );
		
		// Narrow the range.
		if (substringSize.height == heightToMatch) {
			
			afterIndex = currentIndex;
			
		} else {
			
			beforeIndex = currentIndex;
		}
		
		// If the start of the line was not found, calculate new indices.
		if (afterIndex - beforeIndex == 1) {
			
			startOfLineFound = YES;
		} else {
			
			currentIndex = (beforeIndex + afterIndex) / 2;
		}
	} while (!startOfLineFound);
	
	// If the found index is in the middle of a word, we really want the index at the start of the word. We'll do this by scanning backward to the last whitespace.
	
	NSRange lastWhitespaceRange = [self.textView.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, afterIndex + 1) ];
	if (lastWhitespaceRange.location == NSNotFound) {
		afterIndex = 0;
	} else {
		afterIndex = lastWhitespaceRange.location + 1;
	}
	
	return afterIndex;
}

/*
- (NSUInteger)substringRangeForWordInLineAtPoint:(CGPoint)point index:index {
	
	// Given a string index that is in the line containing the point. Need to find the range of the word containing the point.
	// Need to find at least the starting character in the line. Do this by going backward to the previous line at least, then splitting the distance, character by character, until the y-coordinate changes.
	// Start at the current index; get the coordinates. If go forward to the next word end or backward to the next word start. Keep going until it matches or the y-coordinate changes.
	
	NSLog(@"WOV sRFWINAP index:%d", index);
	
	NSUInteger textViewHorizontalPadding = 8;
	NSUInteger textViewVerticalPadding = 12;
	CGFloat lineHeight = self.textView.font.lineHeight;
	
	NSString *substring = [self.textView.text substringToIndex:index];
	CGSize substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:actualTextViewSize lineBreakMode:UILineBreakModeWordWrap];
	NSUInteger heightToMatch = substringSize.height;
	
	//NSLog(@"substring size:%@", NSStringFromCGSize(substringSize) );
	
	// get index of start of line, given a point and an index
	NSUInteger startOfLineIndex = [self startOfLineIndexAtPoint:(CGPoint)point indexInLine:index];
	
	// given the text and the starting index, return the index of the start of the current word (if in a word) or the previous word (if in whitespace)
	// if it's the start of the string, we need to break
	NSUInteger startOfWordIndex = index;
	NSInteger startOfPreviousWordIndex = [self startOfWordBeforeIndex:index];
	do {
		startOfPreviousWordIndex = [self startOfWordBeforeIndex:startOfWordIndex];
		if (startOfPreviousWordIndex == -1) {
			break;
		}
		substring = [self.textView.text substringToIndex:startOfPreviousWordIndex];
		substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:actualTextViewSize lineBreakMode:UILineBreakModeWordWrap];
		if (substringSize.height == heightToMatch) {
			startOfFirstWordInLineIndex
		}
	} while (substringSize.height == heightToMatch);
	
	
	
	
	if (substringSize.width) {
		<#statements#>
	}
	
}
 */

- (NSArray *)substringIndexForLineAtPoint:(CGPoint)point lowIndex:(NSUInteger)lowIndex highIndex:(NSUInteger)highIndex currentIndex:(NSUInteger)currentIndex {

	// Check if the string index is on the same line as the point. If the index is too small, choose a larger one. If too large, choose a smaller one. Else, return the index.
	// actually, once I have the index, I want to refine and return the index at the start of the line.
	
	NSLog(@"WOV sIFLAP, low:%d, high:%d, current:%d", lowIndex, highIndex, currentIndex);
	
	//NSUInteger textViewHorizontalPadding = 8;
	NSUInteger textViewVerticalPadding = 12;
	CGFloat lineHeight = self.textView.font.lineHeight;
	
	//NSLog(@"current line height:%f", lineHeight);
	
	
	//CGSize actualTextViewSize = self.textView.bounds.size;
//	actualTextViewSize.width = actualTextViewSize.width - (2 * textViewHorizontalPadding);
	
	NSString *substring = [self.textView.text substringToIndex:currentIndex];
	CGSize substringSize = [substring sizeWithFont:self.textView.font constrainedToSize:[self actualTextViewSize] lineBreakMode:UILineBreakModeWordWrap];
	substringSize.height = substringSize.height + textViewVerticalPadding;
	
	//NSLog(@"substring size:%@", NSStringFromCGSize(substringSize) );
	
	NSArray *answerArray = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:lowIndex], [NSNumber numberWithUnsignedInt:highIndex], [NSNumber numberWithUnsignedInt:currentIndex], [NSNumber numberWithFloat:substringSize.height], nil];
	
	if (substringSize.height < point.y) {
		
		NSUInteger newIndex = (currentIndex + highIndex) / 2;
		if (newIndex != currentIndex) {
			
			answerArray = [self substringIndexForLineAtPoint:point lowIndex:currentIndex highIndex:highIndex currentIndex:newIndex];
		}
	} else if (substringSize.height - lineHeight > point.y) {
		
		NSUInteger newIndex = (currentIndex + lowIndex) / 2;
		if (newIndex != currentIndex) {
			
			answerArray = [self substringIndexForLineAtPoint:point lowIndex:lowIndex highIndex:currentIndex currentIndex:newIndex];
		}
	}
	
	return answerArray;
}

@end
