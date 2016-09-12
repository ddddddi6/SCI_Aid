//
//  Signature.h
//  SCI_Aid
//
//  Created by Dee on 17/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface Signature : NSObject 

- (NSURL*) generateURLWithDevIDAndKey:(NSString*)urlPath;

@end
