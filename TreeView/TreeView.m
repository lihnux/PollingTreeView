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

@synthesize tree;

#pragma mark - Test Methods

- (void)initFakeTree {
    if (tree == nil) {
        
        self.tree = [[Tree alloc] initWithView:self];
        self.tree.mode = pollingCreateMode;
        
        TreeNode *node = [tree addNewNodeWithType:pollingSingleRoot title:@"test single question" content:nil];
        
        // add three leaf nodes
        TreeNode *childNode = [node addNewNodeWithTitle:nil content:@"Very Good"];
        [node addNewNodeWithTitle:nil content:@"It's Fine"];
        [childNode addNewNodeWithTitle:nil content:@"Very Good2"];
        [node addNewNodeWithTitle:nil content:@"Just so so"];
        
        node = [tree addNewNodeWithType:pollingMutipleRoot title:@"test multiple question" content:nil];
        
        // add three leaf nodes
        [node addNewNodeWithTitle:nil content:@"Very Good2"];
        [node addNewNodeWithTitle:nil content:@"It's Fine2"];
        [node addNewNodeWithTitle:nil content:@"Just so so2"];
    }
}

#pragma mark - Mouse Event

- (void)mouseUp:(NSEvent *)theEvent {
    
    if (theEvent.type == NSLeftMouseUp) {
        BOOL ret = NO;
        [tree mouseUpHittest:[self convertPoint:[theEvent locationInWindow] fromView:nil] result:&ret];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Key Event
- (void)keyDown:(NSEvent *)theEvent {
    
    NSString *chars = theEvent.charactersIgnoringModifiers;
    unichar aChar = [chars characterAtIndex: 0];
    
    switch (aChar) {
        case 3:
        case 13: // Enter Key Event
            [tree enterEditSelectedNode];
            break;
        case 127: // Delete Key Event
            break;
            
        default:
            break;
    }
    
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

- (void)dealloc {
    
    [tree   release];
    [super  dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
	
    // Drawing code here.
    [self initFakeTree];
    
    [tree treeDrawInRect:[self bounds]];
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
