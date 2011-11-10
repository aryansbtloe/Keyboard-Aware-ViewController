//
//  KeyboardAwareViewController.h
//  KeyboardAwareViewControllerExample
//
//  Created by Jonathan Joseph Caras on 6/21/11.
//  Copyright 2011 caras and associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardAwareViewController : UIViewController 
{
	UIScrollView *enclosingScrollView;
    UIView *thresholdView;
    UIToolbar *keyboardToolbar;
}

@property (nonatomic , retain) IBOutlet UIToolbar *keyboardToolbar;
@property (nonatomic ,retain)  IBOutlet UIView *thresholdView;
@property (nonatomic , assign) BOOL shouldUseDefaultToolBar;

-(IBAction) hideKeyboard;
@end
