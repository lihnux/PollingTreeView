//
//  TreeNode.m
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import "Tree.h"
#import "TreeNode.h"
#import "TextFieldCell.h"

@implementation TreeNode
@synthesize tree;
@synthesize parent;
@synthesize title;
@synthesize content;
@synthesize selected;
@synthesize type;
@synthesize mode;
@synthesize children;
@synthesize nodeRect;
@synthesize textRect;

#pragma mark - Life Cycle

- (id)initWithTree:(Tree*)aTree parent:(TreeNode*)aParent title:(NSString*)aTitle content:(NSString*)aContent type:(UInt8)aType mode:(UInt8)aMode {
    self = [super init];
    
    if (self) {
        self.tree       = aTree;
        self.parent     = aParent;
        self.title      = aTitle;
        self.content    = aContent;
        self.type       = aType;
        self.mode       = aMode;
        
        if ([self isRootNode]) {
            self.children = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)dealloc {
    [editTextView   release];
    [title          release];
    [content        release];
    [children       release];
    
    [super dealloc];
}

#pragma mark - Private Help Methods

- (BOOL)isRootNode {
    if (type & pollingRoot) {
        return YES;
    }
    return NO;
}

- (UInt8)removeRootType {
    return type & ~(pollingRoot);
}

- (NSRect)textFiledRect:(NSRect*)rect withTextCell:(NSTextFieldCell*)text{
    
    if ([self isRootNode]) {
        text.title = title;
    }
    else {
        text.title = content;
    }
    
    [text setHighlighted:selected];
    
    CGFloat height = [text cellSizeForBounds:NSMakeRect(0.0, 0.0, rect->size.width, 1000.0)].height;
    
    if (height < 20.0) {
        height = 20.0;
    }
    
    return NSMakeRect(rect->origin.x, rect->origin.y, rect->size.width, height);
}

- (void)drawButtonWithFrame:(NSRect*)buttonRect {
    
    NSButtonCell *button = nil;
    switch (type) {
        case pollingSingle:
            button = tree.radioButton;
            break;
        case pollingMutiple:
            button = tree.switchButton;
            break;
        default:
            break;
    }
    
    [button setTitle:[NSString stringWithFormat:@"%d.", [parent.children indexOfObject:self] + 1]];
    
    [button drawWithFrame:*buttonRect inView:tree.view];
}

#pragma mark - Tree Node Actions (Add, Delete, Find, Edit)

- (id)addNewNodeWithTitle:(NSString*)aTitle content:(NSString*)aContent {
    
    @autoreleasepool {
        TreeNode *newNode = nil;
        
        if ([self isRootNode]) {
            newNode = [[[TreeNode alloc] initWithTree:tree parent:self title:aTitle content:aContent type:[self removeRootType] mode:mode] autorelease];
            [children addObject:newNode];
        }
        else {
            NSUInteger idx = [parent.children indexOfObject:self];
            if (idx != NSNotFound) {
                newNode = [[[TreeNode alloc] initWithTree:tree parent:parent title:aTitle content:aContent type:type mode:mode] autorelease];
                if (idx == parent.children.count - 1) {
                    [parent.children addObject:newNode];
                }
                else {
                    [parent.children insertObject:newNode atIndex:idx + 1];
                }
            }
        }
        
        return newNode;
    }
}

- (BOOL)enterEditSelectedNode {
    
    if (mode == pollingCreateMode) {
        
        if (self.selected) {
            
            if (editTextView == nil) {
                editTextView = [[NSText alloc] initWithFrame:textRect];
            }
            
            if ([self isRootNode]) {
                [tree.text setTitle:title];
            }
            else {
                [tree.text setTitle:content];
            }
            [tree.text setBackgroundColor:[NSColor redColor]];
            [tree.text editWithFrame:textRect inView:tree.view editor:editTextView delegate:self event:nil];
            [editTextView setBackgroundColor:[NSColor lightGrayColor]];
            [editTextView setDrawsBackground:YES];
            [editTextView setSelectedRange:NSMakeRange(0, editTextView.string.length)];
            return YES;
        }
        else {
            __block BOOL ret = NO;
            [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
                ret = *stop = [child enterEditSelectedNode];
            }];
            
            return ret;
        }
        
    }
    return NO;
}

#pragma mark - NSText Delegate

- (void)textDidEndEditing:(NSNotification *)notification {
    
    if ([self isRootNode]) {
        self.title = [editTextView string];
    }
    else {
        self.content = [editTextView string];
    }
    
    [tree.text endEditing:editTextView];
}

#pragma mark - Drawing Methods

- (void)childNodeDrawInRect:(NSRect*)rect {
    
    NSRect tmpRect      = NSMakeRect(rect->origin.x + kButtonWidth, rect->origin.y, rect->size.width - kButtonWidth, 0.0);
    textRect            = [self textFiledRect:&tmpRect withTextCell:tree.text];
    NSRect buttonRect   = NSMakeRect(rect->origin.x, rect->origin.y, kButtonWidth, textRect.size.height);
    
    nodeRect = NSUnionRect(textRect, buttonRect);
    
    [self drawButtonWithFrame:&buttonRect];
    
    textRect.origin.y += 1.0;
    [tree.text drawWithFrame:textRect inView:tree.view];
    
    rect->origin.y += kCCMargin + nodeRect.size.height;
}

- (void)drawInRect:(NSRect*)rect {
    
    if ([self isRootNode]) {
        // Draw self first
        textRect = nodeRect = [self textFiledRect:rect withTextCell:tree.text];
        [tree.text drawWithFrame:nodeRect inView:tree.view];
        
        // Change the draw rect
        rect->origin.x      += kRCMarginH;
        rect->origin.y      += kRCMarginV + nodeRect.size.height;
        rect->size.width    -= kRCMarginH;
        
        // Draw the child nodes
        for (NSUInteger idx = 0; idx < children.count; idx++) {
            TreeNode *child = [children objectAtIndex:idx];
            [child childNodeDrawInRect:rect];
        }
        
        rect->origin.x      -= kRCMarginH;
        rect->size.width    += kRCMarginH;
        rect->origin.y      -= kCCMargin - kRRMargin;
    }
}

#pragma mark - Public Methods

- (void)clearAllSelectState {
    self.selected = NO;
    [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
        child.selected = NO;
    }];
}

#pragma mark - Mouse Actions

- (BOOL)createModeMouseUpHittest:(NSPoint)mousePoint result:(BOOL*)result {
    
    BOOL ret = NO;
    
    *result = NO;
    
    if ([self isRootNode]) {
        // test the Root and Children whole Rect Area
        NSRect lastNodeRect = [[children lastObject] nodeRect];
        NSRect wholeRect = NSMakeRect(nodeRect.origin.x, nodeRect.origin.y, nodeRect.size.width, lastNodeRect.origin.y + lastNodeRect.size.height + kRRMargin - nodeRect.origin.y);
        
        if (NSPointInRect(mousePoint, wholeRect)) {
            ret = YES;
            
            if (NSPointInRect(mousePoint, nodeRect)) {
                self.selected = YES;
                *result = YES;
            }
            else {
                __block BOOL childRet = NO;
                [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
                    *stop = childRet = [child mouseUpHittest:mousePoint result:result];
                }];
                *result = childRet;
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, nodeRect)) {
            self.selected = YES;
            ret = *result = YES;
        }
        else {
            ret = *result = NO;
        }
    }
    
    return ret;
}

- (BOOL)mouseUpHittest:(NSPoint)mousePoint result:(BOOL *)result{
    
    @autoreleasepool {
        if (mode == pollingCreateMode) {
            return [self createModeMouseUpHittest:mousePoint result:result];
        }
        else {
            return NO;
        }
    }
}

@end