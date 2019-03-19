#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "wax.h"
#import "lua.h"
#import "luaconf.h"
#import "wax_http.h"
#import "wax_json.h"
#import "wax_filesystem.h"

FOUNDATION_EXPORT double waxVersionNumber;
FOUNDATION_EXPORT const unsigned char waxVersionString[];

