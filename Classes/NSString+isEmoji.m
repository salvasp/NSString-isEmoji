#import "NSString+isEmoji.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@implementation NSString(Emoji)

- (BOOL)isEmoji {
    @autoreleasepool {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                      options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}
                                      context:nil];
        
        if (rect.size.width / rect.size.height > 1.55f) { return NO; }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
        
        NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
        [self drawWithRect:rect
                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]],
                             NSForegroundColorAttributeName:[UIColor blackColor],
                             NSBackgroundColorAttributeName: [UIColor blackColor]
                             }
                     context:drawingContext];
        
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRef imageRef = [capturedImage CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        
        BOOL colorPixelFound = NO;
        
        int x = 0;
        int y = 0;
        @autoreleasepool {
            while (y < height && !colorPixelFound) {
                while (x < width && !colorPixelFound) {
                    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
                    
                    CGFloat red = (CGFloat)rawData[byteIndex];
                    CGFloat green = (CGFloat)rawData[byteIndex+1];
                    CGFloat blue = (CGFloat)rawData[byteIndex+2];
                    
                    CGFloat h, s, b, a;
                    UIColor *c = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
                    [c getHue:&h saturation:&s brightness:&b alpha:&a];
                    
                    b /= 255.0f;
                    
                    if (b > 0) {
                        colorPixelFound = YES;
                    }
                    
                    x++;
                }
                x=0;
                y++;
            }
        }
        free(rawData);
        return colorPixelFound;
    }
}

@end
