#import <UIKit/UIKit.h>

#import "app_delegate.h"

int main(
  int length_parameters,
  char** parameters
) {
  NSString* name_class_app_delegate;

  @autoreleasepool {
    name_class_app_delegate = NSStringFromClass([AppDelegate class]);
  }

  return UIApplicationMain(
    length_parameters,
    parameters,
    nil,
    name_class_app_delegate
  );
}
