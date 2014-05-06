//
//  TextFieldCell.m
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import "TextFieldCell.h"

@implementation TextFieldCell

// NOTICE: this function must be called before calling the drawWithFrame:inView
// To make sure the cell's height by the attribute string
- (NSSize)sizeForCurrentTitle {
    
    @autoreleasepool {
        
        NSMutableDictionary     *attributes     = [NSMutableDictionary dictionary];
        NSMutableParagraphStyle *paragrahStyle  = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        NSFontManager           *fontManager    = [NSFontManager sharedFontManager];
        NSFont                  *font           = nil;
        
        paragrahStyle.lineBreakMode = NSLineBreakByWordWrapping;
        [attributes setValue:paragrahStyle forKey:NSParagraphStyleAttributeName];
        
        if (self.bold && self.italic) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSBoldFontMask | NSItalicFontMask weight:0 size:14.5];
        }
        else if (self.bold) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSBoldFontMask weight:0 size:14.5];
        }
        else if (self.italic) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSItalicFontMask weight:0 size:13.0];
        }
        else {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSUnboldFontMask | NSUnitalicFontMask weight:0 size:13.0];
        }
        [attributes setValue:font forKey:NSFontAttributeName];
        
        return [self.title sizeWithAttributes:attributes];

    }
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    //[super drawWithFrame:cellFrame inView:controlView];
    
    @autoreleasepool {
        
        NSMutableDictionary     *attributes     = [NSMutableDictionary dictionary];
        NSMutableParagraphStyle *paragrahStyle  = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        NSFontManager           *fontManager    = [NSFontManager sharedFontManager];
        NSFont                  *font           = nil;
        
        paragrahStyle.lineBreakMode = NSLineBreakByWordWrapping;
        [attributes setValue:paragrahStyle forKey:NSParagraphStyleAttributeName];
        
        if (self.bold && self.italic) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSBoldFontMask | NSItalicFontMask weight:0 size:14.5];
        }
        else if (self.bold) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSBoldFontMask weight:0 size:14.5];
        }
        else if (self.italic) {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSItalicFontMask weight:0 size:13.0];
        }
        else {
            font = [fontManager fontWithFamily:@"Helvetica" traits:NSUnboldFontMask | NSUnitalicFontMask weight:0 size:13.0];
        }
        [attributes setValue:font forKey:NSFontAttributeName];

        
        if (self.isHighlighted) {
            
            [[NSColor lightGrayColor] set];
            NSRectFill(cellFrame);
            
            if (self.isBordered) {
                [[NSColor whiteColor] set];
                NSFrameRect(cellFrame);
            }
            
            [attributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        }
        else {
            
            if (self.isBordered) {
                [[NSColor lightGrayColor] set];
                NSFrameRect(cellFrame);
            }
            
            if (self.italic) {
                [attributes setValue:[NSColor grayColor] forKey:NSBackgroundColorAttributeName];
                [attributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            }
            else {
                [attributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
            }
        }
        
        [[self title] drawInRect:cellFrame withAttributes:attributes];
        
    }
}

@end
