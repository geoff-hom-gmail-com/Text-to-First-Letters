//
//  Text.h
//  Text Memory
//
//  Created by Geoffrey Hom on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Text :  NSManagedObject  {
}

@property (nonatomic, retain) NSString *firstLetterText;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;

@end