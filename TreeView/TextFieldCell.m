//
//  TextFieldCell.m
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import "TextFieldCell.h"

@implementation TextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawWithFrame:cellFrame inView:controlView];

    /*
    if([self isHighlighted]) {
        [[NSColor cyanColor] set];
        NSRectFill(cellFrame);
        
        NSDictionary *attribs = [[[NSMutableDictionary alloc] init] autorelease];
        [attribs setValue:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
        NSMutableParagraphStyle *paraStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        //[paraStyle setFirstLineHeadIndent:12.0];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attribs setValue:paraStyle forKey:NSParagraphStyleAttributeName];
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:14];
        [attribs setValue:font forKey:NSFontAttributeName];
        [[self title] drawInRect:cellFrame withAttributes:attribs];
        
    }
    else {
        NSDictionary *attribs = [[[NSMutableDictionary alloc] init] autorelease];
        [attribs setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSMutableParagraphStyle *paraStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        //[paraStyle setFirstLineHeadIndent:12.0];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attribs setValue:paraStyle forKey:NSParagraphStyleAttributeName];
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:14];
        [attribs setValue:font forKey:NSFontAttributeName];
        [attribs setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        [[self title] drawInRect:cellFrame withAttributes:attribs];
    }
     */
}

@end
