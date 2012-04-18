//
//  KeyboardAwareViewController.m
//  Diamond App
//
//  Created by Jonathan Joseph Caras on 6/21/11.
//  Copyright 2011 caras and associates. All rights reserved.
//

#import "KeyboardAwareViewController.h"
#import "UIView+KeyboardAwareness.h"

@interface KeyboardAwareViewController()
@property (nonatomic , retain) UIScrollView *enclosingScrollView;
@property (nonatomic , readonly) UIView *thresholdView;
@property (nonatomic , assign , readwrite) BOOL shouldAdjustLayoutForKeyboard;
@property (nonatomic , assign , readwrite) BOOL isToolbarSet;
@property (nonatomic , assign) CGRect originalViewFrame;

-(void) removeFromNotificationCenter;
-(void) signInForNotifications;
@end

@implementation KeyboardAwareViewController
@synthesize enclosingScrollView;
@synthesize inputAccessoryView;
@synthesize shouldAdjustLayoutForKeyboard = _shouldAdjustLayoutForKeyboard;
@synthesize originalViewFrame;
@synthesize isToolbarSet;

#pragma mark - Getters
-(UIView *) thresholdView
{
    UIResponder *firstResponder = [self.view findFirstResponder];
    if ([firstResponder isKindOfClass:[UIView class]])
    {
        UIView *view = (UIView *)firstResponder;
        return view;
    }
    return nil;
}

-(void) removeFromNotificationCenter
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) signInForNotifications
{
    [self removeFromNotificationCenter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupToolbar:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollForKeyboardLayout:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToNormalLayout:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) setupToolbar : (NSNotification *) notification
{
    if (! self.isToolbarSet)
    {
        UIResponder *responder = [self.view.window findFirstResponder];
        if (responder)
        {
            if (responder.inputAccessoryView != nil) 
            {
                self.inputAccessoryView = (UIToolbar *)responder.inputAccessoryView;
            }
            else
            {
                if ([responder respondsToSelector:@selector(setInputAccessoryView:)])
                {
                    [(UITextField *)responder setInputAccessoryView:self.inputAccessoryView];
                    self.isToolbarSet = YES;
                    [responder reloadInputViews];
                }
            }
            self.isToolbarSet = YES;
        }
    }
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.shouldAdjustLayoutForKeyboard = YES;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.shouldAdjustLayoutForKeyboard = YES;
    }
    return self;
}

-(void) scrollForKeyboardLayout : (NSNotification *) notification
{
    // The notification is invoked mutiple times for some reason.
    // This is to make sure that all the calculations will be done only once.
    if (self.shouldAdjustLayoutForKeyboard)
    {
        if (self.shouldAdjustLayoutForKeyboard)
        {
            self.shouldAdjustLayoutForKeyboard = NO;
            NSValue *keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
            CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
            
            keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
            CGRect frame = self.enclosingScrollView.frame;
            // Keep the original frame of our view so it'll stay the same.
            
            // Now we are resizing the scroll view to fit the remaining area of the screen
            frame.size.height -= keyboardFrame.size.height;
            
            // Setting the resized frame
            self.enclosingScrollView.frame = frame;
            // Restoring the original frame to the view.
            // This is done because sometimes when you change the frame 
            // of the superview, the subview's frame, might change too.
            self.view.frame = self.originalViewFrame;
            // Thershold point is the lowest point that we want to be visible. 
            // In other words it's the lowest point of the threshold view
            UIView *thresholdView = self.thresholdView;
            CGPoint thresholdOrigin = [self.view convertPoint:thresholdView.frame.origin fromView:thresholdView.superview];
            float thresholdPoint = thresholdOrigin.y + self.thresholdView.frame.size.height;
            // Padding is just for more pleasant result to the eye. 
            float padding = 10.0;
            
            UIWindow *window = self.view.window;
            float windowHeight = window.frame.size.height;
            if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
            {
                windowHeight = window.frame.size.width;
            }
            float topOfKeyboard = windowHeight - keyboardFrame.size.height;
            // Offset is the amount of scrolling that need to be made 
            // in order to get the threshold point inside the visible area.
            float offset = (thresholdPoint - topOfKeyboard) + padding;
            // When the threshold point is already in the visible area the offset will be < 0.
            // In that case we don't want to make any scrolling.
            offset = MAX(offset, 0);
            
            // Based on the offset, now we create the rect for the visible area that we want to scroll to.
            CGSize size = CGSizeMake(keyboardFrame.size.width, topOfKeyboard);
            CGPoint origin = self.view.frame.origin;
            /* ATTENTION
             * This is the most important line. Here we are using the 
             * offet to scroll to the right position.
             */
            origin.y += offset;
            CGRect visible;
            visible.origin = origin;
            visible.size = size;
            
            // Finally, Scroll!
            if (visible.origin.y != self.view.frame.origin.y)
            {
                [self.enclosingScrollView scrollRectToVisible:visible animated:YES];
            }
        }
    }
}

-(void) returnToNormalLayout : (NSNotification *) notification
{
    // Check if we are in keyboard layout.
    if (self.shouldAdjustLayoutForKeyboard == NO)
    {
        NSValue *keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        NSNumber *animationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
        // Now we will restore the frame to the original state.
        CGRect frame = self.enclosingScrollView.frame;
        frame.size.height += keyboardFrame.size.height;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[animationDuration floatValue]];
        self.enclosingScrollView.frame = frame;
        self.view.frame = self.originalViewFrame;
        CGRect visible;
        visible.origin = CGPointZero;
        visible.size = self.view.frame.size;
        [UIView commitAnimations];
        // Scrolling back to original state
        [self.enclosingScrollView scrollRectToVisible:visible animated:YES];
        // Marking as "not in keyboard layout".
        self.shouldAdjustLayoutForKeyboard = YES;
        self.isToolbarSet = NO;
    }
}

-(IBAction) hideKeyboard
{
    UIResponder *first = [[UIApplication sharedApplication].keyWindow findFirstResponder];
    [first resignFirstResponder];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self signInForNotifications];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (! self.enclosingScrollView.superview)
    {
        CGRect frame = self.view.frame;
        self.enclosingScrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
        self.enclosingScrollView.backgroundColor = [UIColor  clearColor];
        self.enclosingScrollView.bounces = NO;
        [self.enclosingScrollView setContentSize:self.view.frame.size];
        frame.origin = CGPointZero;
        self.view.frame = frame;
        self.originalViewFrame = self.view.frame;
        [self.view.superview addSubview:self.enclosingScrollView];
        [self.enclosingScrollView addSubview:self.view];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.shouldAdjustLayoutForKeyboard)
    {
        [self hideKeyboard];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeFromNotificationCenter];
	self.enclosingScrollView = nil;
}

- (void)dealloc
{
    [self removeFromNotificationCenter];
	self.enclosingScrollView = nil;
    self.inputAccessoryView = nil;
    [super dealloc];
}
@end
