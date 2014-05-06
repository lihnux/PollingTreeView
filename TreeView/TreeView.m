//
//  TreeView.m
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import "TreeView.h"
#import "Tree.h"
#import "TreeNode.h"

@implementation TreeView

#pragma mark - Test Methods

- (void)initTreeWithMode:(UInt8)mode {
    
    self.tree = [[Tree alloc] initWithView:self];
    self.tree.mode = mode;
}

- (void)switchMode {
    [self.tree switchMode:!(self.tree.mode)];
}

#pragma mark - Mouse Event

- (void)mouseUp:(NSEvent *)theEvent {
    
    if (theEvent.type == NSLeftMouseUp) {
        if (theEvent.clickCount == 1) {
            [self.tree mouseUpHittest:[self convertPoint:[theEvent locationInWindow] fromView:nil] result:nil];
            [self setNeedsDisplay:YES];
        }
        else {
            [self.tree enterEditMode:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        }
    }
}

#pragma mark - Key Event
- (void)keyDown:(NSEvent *)theEvent {
    
    NSString *chars = theEvent.charactersIgnoringModifiers;
    unichar aChar = [chars characterAtIndex: 0];
    
    BOOL isNeedUpdateView = NO;
    
    switch (aChar) {
        case 3:
        case 13: // Enter Key Event
            [self.tree enterEditSelectedNode];
            break;
        case 127: // Delete Key Event
            isNeedUpdateView = [self.tree deleteSelectedNode];
            break;
        default:
            break;
    }
    
    [self setNeedsDisplay:isNeedUpdateView];
    
    //[[self window] makeFirstResponder:self];
}

#pragma mark - Override Methods

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
	   
    [self.tree treeDrawInRect:[self frame]];
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
