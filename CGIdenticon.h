#import "TUIKit.h"

void render_identicon_patch(CGContextRef ctx, CGFloat x, CGFloat y, CGFloat size, long patch, long turn, BOOL invert, CGColorRef foreColor, CGColorRef backColor);

void render_identicon(CGContextRef ctx, int32_t code, unsigned int size);

void gloss_effect(CGContextRef ctx, unsigned int size);

@interface TUIImage (CGIdenticon)
+ (TUIImage *)identiconImageWithUserName:(NSString *)userName;
@end
