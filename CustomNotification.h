//
//  CustomNotification.h
//  ShreeAirlines
//
//  Created by NetprophetsMAC on 2/12/19.
//  Copyright © 2019 Netprophets. All rights reserved.
//

#import <UIKit/UIKit.h>
#define APP [UIApplication sharedApplication].delegate
#define isIOS7 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
#define PUSH_VIEW [CustomNotification sharedPushView]

#define CLOSE_PUSH_SEC 5
#define MAX_HEIGHT_FOR_NOTIFICATION 150

#define HEIGHT_OF_NOTIFICATION 70
#define SHOW_ANIM_DUR 0.5
#define HIDE_ANIM_DUR 0.35
#define HIDE_ANIM_DUR_extra 0.6
NS_ASSUME_NONNULL_BEGIN
@protocol AGPushNoteViewDelegate <NSObject>
@optional
- (void)pushNoteDidAppear; // Called after the view has been fully transitioned onto the screen. (equel to completion block).
- (void)pushNoteWillDisappear; // Called before the view is hidden, after the message action block.
@end
@interface CustomNotification : UIView
+ (void)showWithNotificationMessage:(NSString *)message;
+ (void)showWithNotificationMessage:(NSString *)message completion:(void (^)(void))completion;
+ (void)close;
+ (void)closeWitCompletion:(void (^)(void))completion;
+ (void)awake;

+ (void)setMessageAction:(void (^)(NSString *message))action;
+ (void)setDelegateForPushNote:(id<AGPushNoteViewDelegate>)delegate;

@property (nonatomic, weak) id<AGPushNoteViewDelegate> pushNoteDelegate;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSTimer *closeTimer;
@property (strong, nonatomic) NSString *currentMessage;
@property (strong, nonatomic) NSMutableArray *pendingPushArr;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UILabel *lbl_AppName;

@property (weak, nonatomic) IBOutlet UIImageView *img_AppIcon;
@property (strong, nonatomic) void (^messageTapActionBlock)(NSString *message);
@end

NS_ASSUME_NONNULL_END
