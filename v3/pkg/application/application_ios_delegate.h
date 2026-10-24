//go:build ios

#ifndef application_ios_delegate_h
#define application_ios_delegate_h

#import <UIKit/UIKit.h>

@class WailsViewController;

@interface WailsAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableArray<WailsViewController *> *viewControllers;
@end

// The window's owner since iOS 27, which refuses to launch an app built with
// that SDK unless it adopts the UIScene life cycle (TN3187). The app declares
// it in Info.plist's UIApplicationSceneManifest; it builds the window from the
// scene and hands it to the app delegate, where the rest of the runtime keeps
// looking for it.
@interface WailsSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

#endif /* application_ios_delegate_h */