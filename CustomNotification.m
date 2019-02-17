//
//  CustomNotification.m
//  ShreeAirlines
//
//  Created by NetprophetsMAC on 2/12/19.
//  Copyright © 2019 Netprophets. All rights reserved.
//

#import "CustomNotification.h"

@implementation CustomNotification
static CustomNotification *_sharedPushView;

+ (instancetype)sharedPushView
{
    @synchronized([self class])
    {
        if (!_sharedPushView){
            NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed: @"CustomNotification" owner:self options:nil];
            for (id currentObject in nibArr)
            {
                if ([currentObject isKindOfClass:[CustomNotification class]])
                {
                    _sharedPushView = (CustomNotification *)currentObject;
                    break;
                }
            }
            [_sharedPushView setUpUI];
        }
        return _sharedPushView;
    }
    // to avoid compiler warning
    return nil;
}

+ (void)setDelegateForPushNote:(id<AGPushNoteViewDelegate>)delegate {
    [PUSH_VIEW setPushNoteDelegate:delegate];
}

#pragma mark - Lifecycle (of sort)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect f = self.frame;
        CGFloat width = [UIApplication sharedApplication].keyWindow.bounds.size.width;
        self.frame = CGRectMake(f.origin.x, f.origin.y, width, f.size.height);
    }
    return self;
}

- (void)setUpUI {
    CGRect f = self.frame;
    CGFloat width = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat height = HEIGHT_OF_NOTIFICATION;
    self.frame = CGRectMake(f.origin.x, -height, width, height);
    
    CGRect cvF = self.containerView.frame;
    self.containerView.frame = CGRectMake(5, cvF.origin.y, self.frame.size.width-5, cvF.size.height);
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.masksToBounds = true;
    _closeButton.hidden = true;
    self.img_AppIcon.image =  [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]  objectAtIndex:0]];
    self.lbl_AppName.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    ;
    
    //OS Specific:
   
    
    self.layer.zPosition = MAXFLOAT;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTapAction)];
    self.messageLabel.userInteractionEnabled = YES;
    [self.messageLabel addGestureRecognizer:msgTap];
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction)];
//    doubleTap.numberOfTapsRequired =2;
//    [_sharedPushView addGestureRecognizer:doubleTap];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(didSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;

    _sharedPushView.userInteractionEnabled = YES;
    [_sharedPushView addGestureRecognizer:swipeUp];
    [_sharedPushView addGestureRecognizer:swipeDown];

    //:::[For debugging]:::
    //            self.containerView.backgroundColor = [UIColor yellowColor];
    //            self.closeButton.backgroundColor = [UIColor redColor];
    //            self.messageLabel.backgroundColor = [UIColor greenColor];
    
    [APP.window addSubview:PUSH_VIEW];
    //    [self performSelector:@selector(close) withObject:nil afterDelay:2];
}

+ (void)awake {
    if (PUSH_VIEW.frame.origin.y == 0) {
        [APP.window addSubview:PUSH_VIEW];
    }
}

+ (void)showWithNotificationMessage:(NSString *)message {
    [CustomNotification showWithNotificationMessage:message completion:^{
        //Nothing.
    }];
}

+ (void)showWithNotificationMessage:(NSString *)message completion:(void (^)(void))completion {
    
    PUSH_VIEW.currentMessage = message;
    
    if (message) {
        [PUSH_VIEW.pendingPushArr addObject:message];
        
        PUSH_VIEW.messageLabel.text = message;
        APP.window.windowLevel = UIWindowLevelStatusBar;
        
        CGRect f = PUSH_VIEW.frame;
        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, HEIGHT_OF_NOTIFICATION);
        [APP.window addSubview:PUSH_VIEW];
        [APP.window bringSubviewToFront:PUSH_VIEW];
        //Show
        [UIView animateWithDuration:SHOW_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect f = PUSH_VIEW.frame;
            
            PUSH_VIEW.frame = CGRectMake(f.origin.x, 7, f.size.width, f.size.height);
            
        } completion:^(BOOL finished) {
            completion();
            if ([PUSH_VIEW.pushNoteDelegate respondsToSelector:@selector(pushNoteDidAppear)]) {
                [PUSH_VIEW.pushNoteDelegate pushNoteDidAppear];
            }
        }];
        
        //Start timer (Currently not used to make sure user see & read the push...)
        PUSH_VIEW.closeTimer = [NSTimer scheduledTimerWithTimeInterval:CLOSE_PUSH_SEC target:[CustomNotification class] selector:@selector(close) userInfo:nil repeats:NO];
    }
}
+ (void)closeWitCompletion:(void (^)(void))completion {
    if ([PUSH_VIEW.pushNoteDelegate respondsToSelector:@selector(pushNoteWillDisappear)]) {
        [PUSH_VIEW.pushNoteDelegate pushNoteWillDisappear];
    }
    
    [PUSH_VIEW.closeTimer invalidate];
    
    [UIView animateWithDuration:HIDE_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect f = PUSH_VIEW.frame;
        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, f.size.height);
        PUSH_VIEW.containerView.backgroundColor = [UIColor lightGrayColor];
        PUSH_VIEW.containerView.alpha = 0.6;
        PUSH_VIEW.closeButton.hidden = true;
    } completion:^(BOOL finished) {
        CGRect f = PUSH_VIEW.frame;
        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, HEIGHT_OF_NOTIFICATION);
        [PUSH_VIEW handlePendingPushJumpWitCompletion:completion];
    }];
}

//+ (void)closeWitCompletionWithExtraTime:(void (^)(void))completion {
//    if ([PUSH_VIEW.pushNoteDelegate respondsToSelector:@selector(pushNoteWillDisappear)]) {
//        [PUSH_VIEW.pushNoteDelegate pushNoteWillDisappear];
//    }
//
//    [PUSH_VIEW.closeTimer invalidate];
//
//    [UIView animateWithDuration:HIDE_ANIM_DUR_extra delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        CGRect f = PUSH_VIEW.frame;
//        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, f.size.height);
//        PUSH_VIEW.containerView.backgroundColor = [UIColor lightGrayColor];
//        PUSH_VIEW.containerView.alpha = 0.6;
//        PUSH_VIEW.closeButton.hidden = true;
//    } completion:^(BOOL finished) {
//         CGRect f = PUSH_VIEW.frame;
//        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, HEIGHT_OF_NOTIFICATION);
//
//        [PUSH_VIEW handlePendingPushJumpWitCompletion:completion];
//    }];
//}

+ (void)close {
    [CustomNotification closeWitCompletion:^{
        //Nothing.
    }];
}
//+ (void)closeWithExtraTime {
//    [CustomNotification closeWitCompletionWithExtraTime:^{
//        //Nothing.
//    }];
//}

#pragma mark - Pending push managment
- (void)handlePendingPushJumpWitCompletion:(void (^)(void))completion {
    id lastObj = [self.pendingPushArr lastObject]; //Get myself
    if (lastObj) {
        [self.pendingPushArr removeObject:lastObj]; //Remove me from arr
        NSString *messagePendingPush = [self.pendingPushArr lastObject]; //Maybe get pending push
        if (messagePendingPush) { //If got something - remove from arr, - than show it.
            [self.pendingPushArr removeObject:messagePendingPush];
            [CustomNotification showWithNotificationMessage:messagePendingPush completion:completion];
        } else {
            APP.window.windowLevel = UIWindowLevelNormal;
        }
    }
}

- (NSMutableArray *)pendingPushArr {
    if (!_pendingPushArr) {
        _pendingPushArr = [[NSMutableArray alloc] init];
    }
    return _pendingPushArr;
}

#pragma mark - Actions


- (void)didSwipe:(UISwipeGestureRecognizer*)swipe{
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Swipe Left");
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Swipe Right");
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"Swipe Up");
        [CustomNotification close];
        
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"Swipe Down");
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect f = PUSH_VIEW.frame;
            
            _containerView.backgroundColor = [UIColor whiteColor];
            _containerView.alpha = 1;
            CGSize s = [_currentMessage sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(_messageLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
            if (s.height>MAX_HEIGHT_FOR_NOTIFICATION){
                PUSH_VIEW.frame = CGRectMake(f.origin.x, 7, f.size.width, HEIGHT_OF_NOTIFICATION-17+MAX_HEIGHT_FOR_NOTIFICATION);
                
            }else{
                PUSH_VIEW.frame = CGRectMake(f.origin.x, 7, f.size.width, HEIGHT_OF_NOTIFICATION-17+s.height);
            }
            _closeButton.hidden = false;
            [PUSH_VIEW.closeTimer invalidate];
            
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)closeActionFromButton:(id)sender {
     [CustomNotification close];
}
+ (void)setMessageAction:(void (^)(NSString *message))action {
    PUSH_VIEW.messageTapActionBlock = action;
}

- (void)messageTapAction {
    if (self.messageTapActionBlock) {
        self.messageTapActionBlock(self.currentMessage);
        [CustomNotification close];
    }
}
- (void)doubleTapAction {
    [UIView animateWithDuration:SHOW_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect f = PUSH_VIEW.frame;
        
        PUSH_VIEW.frame = CGRectMake(f.origin.x, 7, f.size.width, f.size.height+80);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)closeActionItem:(UIBarButtonItem *)sender {
    [CustomNotification close];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
