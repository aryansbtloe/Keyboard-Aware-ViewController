//
//  KeyboardAwareViewController.h
//  KeyboardAwareViewControllerExample
//
//  Created by Avraham Shukron on 6/21/11.
//  Copyright 2011 caras and associates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardAwareViewController : UIViewController 
@property (nonatomic , retain) IBOutlet UIView *inputAccessoryView;
-(IBAction) hideKeyboard;
@end
