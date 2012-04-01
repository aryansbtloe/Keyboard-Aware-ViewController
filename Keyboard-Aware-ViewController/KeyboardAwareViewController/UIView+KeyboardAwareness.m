//
//  UIView+KeyboardAwareness.m
//  YouAppi
//
//  Created by Avraham Shukron on 2/7/12.
//  Copyright (c) 2012 Quickode. All rights reserved.
//

#import "UIView+KeyboardAwareness.h"

@implementation UIView (KeyboardAwareness)
-(UIResponder *) findFirstResponder
{
	if (self.isFirstResponder) 
	{
        return self;
    }
    for (UIView *subView in self.subviews) 
	{
		UIResponder *maybe = [subView findFirstResponder];
        if (maybe)
            return maybe;
    }
    return nil;
}
@end
