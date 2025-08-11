#include <application/recol_application_delegate.h>

#include <termination.h>

#import <UIKit/UIKit.h>

int main(
  int length_parameters,
  char** parameters
) {
  NSString* name_class_app_delegate;

  @autoreleasepool {
    name_class_app_delegate = NSStringFromClass([recol_application_delegate class]);
  }
  
  termination_initialize();

  return UIApplicationMain(
    length_parameters,
    parameters,
    nil,
    name_class_app_delegate
  );
}
