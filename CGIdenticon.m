#import "CGIdenticon.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CommonCrypto/CommonDigest.h>

int patch0[]={ 0, 4, 24, 20 };
int patch1[] = { 0, 4, 20 };
int patch2[] = { 2, 24, 20 };
int patch3[] = { 0, 2,  20, 22 };
int patch4[] = { 2, 14, 22, 10 };
int patch5[] = { 0, 14, 24, 22 };
int patch6[] = { 2, 24, 22, 13, 11, 22, 20 };
int patch7[] = { 0, 14, 22 };
int patch8[] = { 6, 8, 18, 16 };
int patch9[] = { 4, 20, 10, 12, 2 };
int patch10[] = { 0, 2, 12, 10 };
int patch11[] = { 10, 14, 22 };
int patch12[] = { 20, 12, 24 };
int patch13[] = { 10, 2, 12 };
int patch14[] = { 0, 2, 10 };
int * patchTypes[] = { patch0, patch1, patch2, patch3, patch4,
    patch5, patch6, patch7, patch8, patch9, patch10, patch11,
    patch12, patch13, patch14, patch0 };
unsigned int patchTypesLen[] = { 4, 3, 3, 4, 4, 4, 7, 3, 4, 5, 4, 3, 3, 3, 3, 4};
int centerPatchTypes[] = { 0, 4, 8, 15 };

void render_identicon_patch(CGContextRef ctx, CGFloat x, CGFloat y, CGFloat size, long patch, long turn, BOOL invert, CGColorRef foreColor, CGColorRef backColor) {
	patch %= 16;
	turn %= 4;
	if (patch == 15)
		invert = !invert;
    
	int * vertices = patchTypes[patch];
	CGFloat offset = (CGFloat)size / 2;
	CGFloat scale = (CGFloat)size / 4;
    
	CGContextSaveGState(ctx);
    
	// paint background
    CGColorRef fillColor = invert?foreColor:backColor;
    const CGFloat *components = CGColorGetComponents(fillColor);
    
    CGContextSetFillColor(ctx, components);
    CGContextFillRect(ctx, CGRectMake(x, y, size, size));
    
	// build patch path
    CGContextTranslateCTM(ctx, x + offset, y + offset);
    CGContextRotateCTM(ctx, turn * 3.1415926/2);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, (vertices[0]%5*scale - offset), floorf(vertices[0]*0.2) * scale - offset);
	for (int i = 1; i < patchTypesLen[i]; i++) {
        CGContextAddLineToPoint(ctx, vertices[i] % 5 * scale - offset, floorf(vertices[i] * 0.2) * scale - offset);
    }
    CGContextClosePath(ctx);
    
	// offset and rotate coordinate space by patch position (x, y) and
	// 'turn' before rendering patch shape
    
	// render rotated patch using fore color (back color if inverted)

    CGColorRef fillColor2 = invert?backColor:foreColor;
    const CGFloat *components2 = CGColorGetComponents(fillColor2);
    CGContextSetFillColor(ctx, components2);
	CGContextFillPath(ctx);
    
	// restore rotation
	CGContextRestoreGState(ctx);
}
void gloss_effect(CGContextRef ctx, unsigned int size, CGColorSpaceRef colorSpace){
    
    //CGContextSaveGState(ctx);
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorSpace(ctx, colorSpace);
    CGContextSetLineWidth(ctx, 12.);
    const CGFloat strokeComponents0[] = {1,1,1,1};
    const CGFloat strokeComponents1[] = {.4,.5,.4,1};
    CGContextSetStrokeColor(ctx, strokeComponents0);
    CGContextBeginPath(ctx);
    CGContextAddRoundRect(ctx, CGRectMake(2, 2, size-4, size-4), 12);
    CGContextStrokePath(ctx);
    CGContextSetStrokeColor(ctx, strokeComponents1);
    CGContextSetLineWidth(ctx, 3);
    CGContextBeginPath(ctx);
    CGContextAddRoundRect(ctx, CGRectMake(4, 4, size-8, size-8), 6);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    CGContextBeginTransparencyLayer(ctx, NULL);

    const CGFloat components1[]={1,1,1,0.3,1,1,1,0.6};
    const CGFloat locations[]={0,1};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components1, locations, 2);
    CGContextDrawRadialGradient(ctx, gradient, CGPointMake(size/2, size*2), size/2, CGPointMake(size/2, size*1.7), size*1.3, 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextBeginPath(ctx);
    CGContextAddRoundRect(ctx, CGRectMake(0, 0, size, size), 6);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    CGContextEndTransparencyLayer(ctx);
}
void render_identicon(CGContextRef ctx, int32_t code, unsigned int size, CGColorSpaceRef colorSpace) {
	if (!ctx || !code || !size) return;
    NSLog(@"code: %x",code);
	CGFloat patchSize = (CGFloat)size / 3;
	int middleType = centerPatchTypes[code & 3];
	int middleInvert = ((code >> 2) & 1) != 0;
	int cornerType = (code >> 3) & 15;
	int cornerInvert = ((code >> 7) & 1) != 0;
	int cornerTurn = (code >> 8) & 3;
	int sideType = (code >> 10) & 15;
	int sideInvert = ((code >> 14) & 1) != 0;
	int sideTurn = (code >> 15) & 3;
	int blue = (code >> 16) & 31;
	int green = (code >> 21) & 31;
	int red = (code >> 27) & 31;
    CGFloat foreColorComp[] = {.9*(red<<3)/(CGFloat)255, .9*(green<<3)/(CGFloat)255, .85*(blue<<3)/(CGFloat)255, 1};
    CGFloat backColorComp[] = {.95, .95, .92, 1.};
    CGColorRef foreColor = CGColorCreate(colorSpace, foreColorComp);
    CGColorRef backColor = CGColorCreate(colorSpace, backColorComp);
   
	// middle patch
	render_identicon_patch(ctx, patchSize, patchSize, patchSize, middleType, 0, middleInvert, foreColor, backColor);
	// side patchs, starting from top and moving clock-wise
	render_identicon_patch(ctx, patchSize, 0, patchSize, sideType, sideTurn++, sideInvert, foreColor, backColor);
	render_identicon_patch(ctx, patchSize * 2., patchSize, patchSize, sideType, sideTurn++, sideInvert, foreColor, backColor);
	render_identicon_patch(ctx, patchSize, patchSize * 2., patchSize, sideType, sideTurn++, sideInvert, foreColor, backColor);
	render_identicon_patch(ctx, 0, patchSize, patchSize, sideType, sideTurn++, sideInvert, foreColor, backColor);
	// corner patchs, starting from top left and moving clock-wise
	render_identicon_patch(ctx, 0, 0, patchSize, cornerType, cornerTurn++, cornerInvert, foreColor, backColor);
	render_identicon_patch(ctx, patchSize * 2, 0, patchSize, cornerType, cornerTurn++, cornerInvert, foreColor, backColor);
	render_identicon_patch(ctx, patchSize * 2, patchSize * 2, patchSize, cornerType, cornerTurn++, cornerInvert, foreColor, backColor);
	render_identicon_patch(ctx, 0, patchSize * 2, patchSize, cornerType, cornerTurn++, cornerInvert, foreColor, backColor);
    
    CGColorRelease(foreColor);
    CGColorRelease(backColor);
    
}
#define IDENTICON_SIZE (96)
#if TARGET_OS_MAC
@implementation TUIImage (CGIdenticon)
+ (TUIImage *)identiconImageWithUserName:(NSString *)userName {
    const char *cStr = [userName UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1( cStr, (CC_LONG)strlen(cStr), result );
    uint32_t code = ((result[0] & 0xFF) << 24) | ((result[1] & 0xFF) << 16)
    | ((result[2] & 0xFF) << 8) | (result[3] & 0xFF);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, IDENTICON_SIZE, IDENTICON_SIZE, 8, 4*96, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorSpace(ctx, colorSpace);
    render_identicon(ctx, code, IDENTICON_SIZE, colorSpace);
    gloss_effect(ctx, IDENTICON_SIZE);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    TUIImage *ret = [TUIImage imageWithCGImage:imageRef];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    return ret;
}
@end
#elif (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
void CGContextAddRoundRect(CGContextRef context, CGRect rect, CGFloat radius)
{
	radius = MIN(radius, rect.size.width / 2);
	radius = MIN(radius, rect.size.height / 2);
	radius = floor(radius);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
}


@implementation UIImage (CGIdenticon)
+ (UIImage *)identiconImageWithUserName:(NSString *)userName {
    const char *cStr = [userName UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1( cStr, (CC_LONG)strlen(cStr), result );
    uint32_t code = ((result[0] & 0xFF) << 24) | ((result[1] & 0xFF) << 16)
    | ((result[2] & 0xFF) << 8) | (result[3] & 0xFF);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, IDENTICON_SIZE, IDENTICON_SIZE, 8, 4*IDENTICON_SIZE, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorSpace(ctx, colorSpace);
    render_identicon(ctx, code, IDENTICON_SIZE, colorSpace);
    gloss_effect(ctx, IDENTICON_SIZE, colorSpace);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

@end

#endif
