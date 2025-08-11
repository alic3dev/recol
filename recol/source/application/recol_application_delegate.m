#include <application/recol_application_delegate.h>

#include <termination.h>

@implementation recol_application_delegate {}

- (BOOL) application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions {
  return 1;
}

- (void) applicationWillTerminate: (NSNotification*) notification {
  termination_terminate();
}

@end
