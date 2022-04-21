#import "SmblibPlugin.h"
#if __has_include(<smblib/smblib-Swift.h>)
#import <smblib/smblib-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "smblib-Swift.h"
#endif

@implementation SmblibPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmblibPlugin registerWithRegistrar:registrar];
}
@end
