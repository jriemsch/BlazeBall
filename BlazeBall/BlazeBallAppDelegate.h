//  Created by Jens Riemschneider on 9/18/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlazeBallView.h"

@class RootViewController;

@interface BlazeBallAppDelegate : NSObject <UIApplicationDelegate> {
    BlazeBallView* _glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BlazeBallView *glView;
@property (nonatomic, retain) RootViewController *rootViewController;

@end
