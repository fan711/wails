//go:build ios
#import "application_ios_delegate.h"
#import "../events/events_ios.h"
#import "application_ios.h"
extern void processApplicationEvent(unsigned int, void* data);
extern bool hasListeners(unsigned int);

// Under the scene life cycle UIKit no longer calls the app delegate's
// applicationDidBecomeActive & co.; it calls these instead. They raise the same
// application events, so nothing listening on the Go side can tell.
static void wailsSceneEvent(unsigned int event) {
    if (hasListeners(event)) {
        processApplicationEvent(event, NULL);
    }
}

@implementation WailsSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    // Start the window with the launch-screen colour (a "LaunchBackground"
    // colour asset, also referenced by UILaunchScreen) so there's no white
    // flash between the launch screen and the first WebView paint. Falls back
    // to white if the asset isn't present.
    UIColor *bg = [UIColor colorNamed:@"LaunchBackground"] ?: [UIColor whiteColor];
    unsigned char r = 255, g = 255, b = 255, a = 255;
    if (ios_get_app_background_color(&r, &g, &b, &a)) {
        bg = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
    }
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    window.backgroundColor = bg;
    // The Go runtime started from didFinishLaunchingWithOptions and may already
    // have made the WebView's controller; if so it is the root, and otherwise a
    // placeholder holds the colour until ios_create_webview_with_id replaces it.
    UIViewController *root = appDelegate.viewControllers.firstObject;
    if (!root) {
        root = [[UIViewController alloc] init];
        root.view.backgroundColor = bg;
    }
    window.rootViewController = root;
    self.window = window;
    appDelegate.window = window;
    [window makeKeyAndVisible];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    wailsSceneEvent(EventApplicationDidBecomeActive);
}

- (void)sceneWillResignActive:(UIScene *)scene {
    wailsSceneEvent(EventApplicationWillResignActive);
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    wailsSceneEvent(EventApplicationWillEnterForeground);
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    wailsSceneEvent(EventApplicationDidEnterBackground);
}
@end
