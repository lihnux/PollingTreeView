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
        self.title      = (aTitle == nil)   ? @"" : aTitle;
        self.content    = (aContent == nil) ? @"" : aContent;
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

- (NSRect)textFiledRect:(NSRect*)rect withTextCell:(TextFieldCell*)text{
    
    text.bold   = NO;
    text.italic = NO;
    [text setBordered:NO];
    [text setHighlighted:NO];
    
    if ([self isRootNode]) {
        text.bold   = YES;
        text.title  = title;
    }
    else {
        text.title  = content;
        if (self.type == pollingShortAnswer) {
            [text setBordered:YES];
            //[text setHighlighted:selected];
        }
    }
    
    if (mode == pollingCreateMode) {
        if ([self isRootNode]) {
            if (text.title.length == 0) {
                text.title  = @"Type your question";
                text.italic = YES;
            }
        }
        else {
            if (text.title.length == 0 && self.type != pollingShortAnswer) {
                text.title  = @"Type your selection content";
                text.italic = YES;
            }
        }
        
        [text setHighlighted:selected];
    }
    //CGFloat height = [text cellSizeForBounds:NSMakeRect(0.0, 0.0, rect->size.width, 1000.0)].height;
    
    CGFloat height = [text sizeForCurrentTitle].height + 3.0;
    
    if (height < 20.0) {
        height = 20.0;
    }
    
    textRect = NSMakeRect(rect->origin.x, rect->origin.y, rect->size.width, height);
    
    [text drawWithFrame:textRect inView:tree.view];
    
    return textRect;
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
    
    if (self.selected) {
        [button setState:NSOnState];
    }
    else {
        [button setState:NSOffState];
    }
    
    NSUInteger idx = [parent.children indexOfObject:self];
    
    UInt16 alpha = idx / 26;
    
    if (alpha == 0) {
        button.title = [NSString stringWithFormat:@"%c.", 'a' + idx%26];
    }
    else if (alpha > 0 && alpha < 26) {
        button.title = [NSString stringWithFormat:@"%c%c.", 'a' + alpha - 1, 'a' + idx%26];
    }
    else if (alpha >= 26 && alpha < 476) {
        UInt8 beta = alpha / 26;
        button.title = [NSString stringWithFormat:@"%c%c%c.", 'a' + beta - 1, 'a' + alpha%26, 'a' + idx%26];
    }
    
    [button drawWithFrame:*buttonRect inView:tree.view];
}

- (void)swithSelectedNodeByDeleteIndex:(NSUInteger)delIndex {
    
    if (children.count > 0) {
        NSUInteger nextSelectIndex = (delIndex <= children.count - 1) ? delIndex : (children.count - 1);
        TreeNode *node = [children objectAtIndex:nextSelectIndex];
        node.selected = YES;
    }
}

- (NSRect)getWholeNodeArea {
    
    if (children.count > 0) {
        NSRect lastNodeRect = [[children lastObject] nodeRect];
        return NSMakeRect(nodeRect.origin.x, nodeRect.origin.y, nodeRect.size.width, lastNodeRect.origin.y + lastNodeRect.size.height + kRRMargin - nodeRect.origin.y);
    }
    
    return nodeRect;
}

- (void)enterEdit {
    
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

- (BOOL)addNewNodeBySelectedNode {
    if (mode == pollingCreateMode) {
        if (self.selected) {
            if (self.type == pollingShortAnswerRoot || self.type == pollingShortAnswerRoot) {
                return YES;
            }
            
            [self addNewNodeWithTitle:@"" content:@""];
        }
        else {
            __block BOOL ret = NO;
            [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
                ret = *stop = [child addNewNodeBySelectedNode];
            }];
            
            return ret;
        }
    }
    
    return NO;
}

- (BOOL)enterEditSelectedNode {
    
    if (mode == pollingCreateMode) {
        
        if (self.selected) {
            
            if (self.type != pollingShortAnswer) {
                [self enterEdit];
            }
            
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

- (BOOL)enterEditByMousePoint:(NSPoint)mousePoint {
    
    if ([self isRootNode]) {
        if (NSPointInRect(mousePoint, [self getWholeNodeArea])) {
            
            if (NSPointInRect(mousePoint, nodeRect)) {
                return YES;
            }
            else {
                [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
                    *stop = [child enterEditByMousePoint:mousePoint];
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, nodeRect)) {
            if (type == pollingShortAnswer) {
                [self enterEdit];
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)deleteSelectedNode {
    if (mode == pollingCreateMode) {
        __block NSMutableIndexSet *delIndexes = [NSMutableIndexSet indexSet];
        [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
            if (child.selected) {
                [delIndexes addIndex:idx];
                *stop = YES;
            }
        }];
        
        if (delIndexes.count > 0) {
            [children removeObjectsAtIndexes:delIndexes];
            [self swithSelectedNodeByDeleteIndex:[delIndexes firstIndex]];
            return YES;
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
    
    NSRect tmpRect, buttonRect;
    
    tmpRect = NSMakeRect(rect->origin.x + kButtonWidth, rect->origin.y, rect->size.width - kButtonWidth, 0.0);
    
    [self textFiledRect:&tmpRect withTextCell:tree.text];
    
    buttonRect  = NSMakeRect(rect->origin.x, rect->origin.y, kButtonWidth, textRect.size.height);
    [self drawButtonWithFrame:&buttonRect];
    
    nodeRect    = NSUnionRect(textRect, buttonRect);
    
    rect->origin.y += kCCMargin + nodeRect.size.height;
}

- (void)drawInRect:(NSRect*)rect {
    
    if ([self isRootNode]) {
        // Draw self first
        nodeRect = [self textFiledRect:rect withTextCell:tree.text];
        
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
    
    if (result) {
        *result = NO;
    }
    
    if ([self isRootNode]) {
        // test the Root and Children whole Rect Area
        
        if (NSPointInRect(mousePoint, [self getWholeNodeArea])) {
            ret = YES;
            
            if (NSPointInRect(mousePoint, nodeRect)) {
                self.selected = YES;
                if (result) {
                    *result = YES;
                }
            }
            else {
                [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
                    *stop = [child mouseUpHittest:mousePoint result:result];
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, nodeRect)) {
            self.selected = YES;
            ret = YES;
            if (result) {
                *result = YES;
            }
        }
    }
    
    return ret;
}

- (BOOL)answerModeMouseUpHittest:(NSPoint)mousePoint result:(BOOL*)result {
    
    BOOL ret = NO;
    
    if (result) {
        *result = NO;
    }
    
    if ([self isRootNode]) {
        
        if (NSPointInRect(mousePoint, [self getWholeNodeArea])) {
            
            ret = YES;
            
            if (!NSPointInRect(mousePoint, nodeRect)) {
                
                [children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
                    BOOL oldStop = *stop;
                    *stop = [child mouseUpHittest:mousePoint result:result];
                    if (type == pollingSingleRoot) {
                        *stop = oldStop;
                    }
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, nodeRect)) {
            if (type == pollingMutiple) {
                self.selected = !(self.selected);
            }
            else {
                self.selected = YES;
            }
            ret = YES;
            
            if (result) {
                *result = YES;
            }
        }
        else {
            if (type == pollingSingle) {
                if (self.selected) {
                    self.selected = NO;
                }
            }
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
            return [self answerModeMouseUpHittest:mousePoint result:result];
        }
    }
}

@end