#if TARGET_OS_MAC
#import "TUIKit.h"
#elif (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <UIKit/UIKit.h>
#endif

#ifndef USE_CGIDENTICON
#define USE_CGIDENTICON
#endif
void render_identicon_patch(CGContextRef ctx, CGFloat x, CGFloat y, CGFloat size, long patch, long turn, BOOL invert, CGColorRef foreColor, CGColorRef backColor);

void render_identicon(CGContextRef ctx, int32_t code, unsigned int size, CGColorSpaceRef colorSpace);

void gloss_effect(CGContextRef ctx, unsigned int size, CGColorSpaceRef colorSpace);

void CGContextAddRoundRect(CGContextRef context, CGRect rect, CGFloat radius);
void CGContextClipToRoundCornerRect(CGContextRef context, CGRect rect, CGFloat radius);

#if TARGET_OS_MAC
@interface TUIImage (CGIdenticon)
+ (TUIImage *)identiconImageWithUserName:(NSString *)userName;
@end
#elif (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
@interface UIImage (CGIdenticon)
+ (UIImage *)identiconImageWithUserName:(NSString *)userName;
@end
#endif
