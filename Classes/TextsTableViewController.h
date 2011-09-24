//
//  TextsTableViewController.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Text;

@protocol TextsTableViewDelegate

// Sent after the user selects a row in the texts list.
- (void)textSelected:(Text *)theText;

@end

@interface TextsTableViewController : UITableViewController {
}

// The current text.
@property (nonatomic, retain) Text *currentText;

@property (nonatomic, assign) id <TextsTableViewDelegate> delegate;

@end
