//go:build ios && !server
#import "application_ios_delegate.h"
#import "../events/events_ios.h"
#import "application_ios.h"
extern void processApplicationEvent(unsigned int, void* data);
extern void processWindowEvent(unsigned int, unsigned int);
extern bool hasListeners(unsigned int);
extern void iosApplicationDidLaunch(void);
// WailsIOSMain (app's generated main_ios.go) runs the user's main()/app.Run().
// The delegate starts it AFTER UIKit has launched (see below).
extern void WailsIOSMain(void);
// Registers the UNUserNotificationCenter delegate so local notifications are
// shown while the app is in the foreground (and taps are handled). Apple
// requires this be set before launch finishes, hence the call below.
extern void ios_notifications_init(void);

@implementation WailsAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set the global appDelegate reference. The window is not made here: under
    // the scene life cycle it belongs to a UIWindowScene, which UIKit connects
    // after this returns (WailsSceneDelegate, application_ios_scene_delegate.m).
    appDelegate = self;
    if (!self.viewControllers) {
        self.viewControllers = [NSMutableArray array];
    }
    // Register the notification-center delegate before launch finishes so local
    // notifications appear while the app is foregrounded (otherwise iOS delivers
    // them silently and no banner is shown).
    ios_notifications_init();
    // Unconditional launch signal for the Go runtime. platformRun waits on
    // this and emits ApplicationDidFinishLaunching from the Go side once the
    // event listeners are wired up - emitting it from here would race the Go
    // runtime's startup and the event could be dropped.
    // Start the Go runtime NOW — only after UIKit has delivered the launch.
    // The window may not exist yet (the scene connects later, and not at all on
    // a background launch); a WebView created before it is attached when it
    // arrives (WailsSceneDelegate). Starting Go earlier (concurrently with UIApplicationMain)
    // intermittently corrupts the FrontBoard launch handshake on a physical
    // device, so this method never fires (blank cold launch / 0x8BADF00D). Run it
    // on a background thread so app.Run()'s blocking loop never touches the main
    // thread. WailsIOSMain -> user main() -> app.Run(); the window's run() then
    // creates the WebView.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        WailsIOSMain();
    });
    return YES;
}
// GENERATED EVENTS START
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if( hasListeners(EventApplicationDidBecomeActive) ) {
        processApplicationEvent(EventApplicationDidBecomeActive, NULL);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if( hasListeners(EventApplicationDidEnterBackground) ) {
        processApplicationEvent(EventApplicationDidEnterBackground, NULL);
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    if( hasListeners(EventApplicationDidFinishLaunching) ) {
        processApplicationEvent(EventApplicationDidFinishLaunching, NULL);
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    if( hasListeners(EventApplicationDidReceiveMemoryWarning) ) {
        processApplicationEvent(EventApplicationDidReceiveMemoryWarning, NULL);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if( hasListeners(EventApplicationWillEnterForeground) ) {
        processApplicationEvent(EventApplicationWillEnterForeground, NULL);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if( hasListeners(EventApplicationWillResignActive) ) {
        processApplicationEvent(EventApplicationWillResignActive, NULL);
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if( hasListeners(EventApplicationWillTerminate) ) {
        processApplicationEvent(EventApplicationWillTerminate, NULL);
    }
}

// GENERATED EVENTS END
@end
