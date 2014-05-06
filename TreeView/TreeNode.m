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

- (void)switchMode:(UInt8)mode {
    
    self.mode = mode;
    
    if ([self isRootNode]) {
        for (TreeNode * node in self.children) {
            [node switchMode:mode];
        }
    }
}


#pragma mark - Private Help Methods

- (BOOL)isRootNode {
    if (self.type & pollingRoot) {
        return YES;
    }
    return NO;
}

- (UInt8)removeRootType {
    return self.type & ~(pollingRoot);
}

- (NSRect)textFiledRect:(NSRect*)rect withTextCell:(TextFieldCell*)text{
    
    text.bold   = NO;
    text.italic = NO;
    [text setBordered:NO];
    [text setHighlighted:NO];
    
    if ([self isRootNode]) {
        text.bold   = YES;
        text.title  = self.title;
    }
    else {
        text.title  = self.content;
        if (self.type == pollingShortAnswer) {
            [text setBordered:YES];
        }
    }
    
    if (self.mode == pollingCreateMode) {
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
        
        [text setHighlighted:self.selected];
    }
    
    CGFloat height = [text sizeForCurrentTitle].height + 3.0;
    
    if (height < 20.0) {
        height = 20.0;
    }
    
    self.textRect = NSMakeRect(rect->origin.x, rect->origin.y, rect->size.width, height);
    
    [text drawWithFrame:self.textRect inView:self.tree.view];
    
    return self.textRect;
}

- (void)drawButtonWithFrame:(NSRect*)buttonRect {
    
    NSButtonCell *button = nil;
    switch (self.type) {
        case pollingSingle:
            button = self.tree.radioButton;
            break;
        case pollingMutiple:
            button = self.tree.switchButton;
            break;
        default:
            break;
    }
    
    if (self.mode == pollingAnswerMode) {
        if (self.selected) {
            [button setState:NSOnState];
        }
        else {
            [button setState:NSOffState];
        }

    }
    
    
    NSUInteger idx = [self.parent.children indexOfObject:self];
    
    UInt16 alpha = idx / 26;
    
    if (alpha == 0) {
        button.title = [NSString stringWithFormat:@"%c.", (char)('a' + idx%26)];
    }
    else if (alpha > 0 && alpha < 26) {
        button.title = [NSString stringWithFormat:@"%c%c.", (char)('a' + alpha - 1), (char)('a' + idx%26)];
    }
    else if (alpha >= 26 && alpha < 476) {
        UInt8 beta = alpha / 26;
        button.title = [NSString stringWithFormat:@"%c%c%c.", (char)('a' + beta - 1), (char)('a' + alpha%26), (char)('a' + idx%26)];
    }
    
    [button drawWithFrame:*buttonRect inView:self.tree.view];
}

- (void)swithSelectedNodeByDeleteIndex:(NSUInteger)delIndex {
    
    if (self.children.count > 0) {
        NSUInteger nextSelectIndex = (delIndex <= self.children.count - 1) ? delIndex : (self.children.count - 1);
        TreeNode *node = [self.children objectAtIndex:nextSelectIndex];
        node.selected = YES;
    }
}

- (NSRect)getWholeNodeArea {
    
    if (self.children.count > 0) {
        NSRect lastNodeRect = [[self.children lastObject] nodeRect];
        return NSMakeRect(self.nodeRect.origin.x, self.nodeRect.origin.y, self.nodeRect.size.width, lastNodeRect.origin.y + lastNodeRect.size.height + kRRMargin - self.nodeRect.origin.y);
    }
    
    return self.nodeRect;
}

- (void)enterEdit {
    
    if (editTextView == nil) {
        editTextView = [[NSText alloc] initWithFrame:self.textRect];
    }
    
    if ([self isRootNode]) {
        [self.tree.text setTitle:self.title];
    }
    else {
        [self.tree.text setTitle:self.content];
    }
    [self.tree.text setBackgroundColor:[NSColor redColor]];
    [self.tree.text editWithFrame:self.textRect inView:self.tree.view editor:editTextView delegate:self event:nil];
    [editTextView setBackgroundColor:[NSColor lightGrayColor]];
    [editTextView setDrawsBackground:YES];
    [editTextView setSelectedRange:NSMakeRange(0, editTextView.string.length)];
}

#pragma mark - Tree Node Actions (Add, Delete, Find, Edit)

- (id)addNewNodeWithTitle:(NSString*)aTitle content:(NSString*)aContent {
    
    @autoreleasepool {
        TreeNode *newNode = nil;
        
        if ([self isRootNode]) {
            newNode = [[TreeNode alloc] initWithTree:self.tree parent:self title:aTitle content:aContent type:[self removeRootType] mode:self.mode];
            [self.children addObject:newNode];
        }
        else {
            NSUInteger idx = [self.parent.children indexOfObject:self];
            if (idx != NSNotFound) {
                newNode = [[TreeNode alloc] initWithTree:self.tree parent:self.parent title:aTitle content:aContent type:self.type mode:self.mode];
                if (idx == self.parent.children.count - 1) {
                    [self.parent.children addObject:newNode];
                }
                else {
                    [self.parent.children insertObject:newNode atIndex:idx + 1];
                }
            }
        }
        
        return newNode;
    }
}

- (BOOL)addNewNodeBySelectedNode {
    if (self.mode == pollingCreateMode) {
        if (self.selected) {
            if (self.type == pollingShortAnswerRoot || self.type == pollingShortAnswerRoot) {
                return YES;
            }
            
            [self addNewNodeWithTitle:@"" content:@""];
        }
        else {
            __block BOOL ret = NO;
            [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
                ret = *stop = [child addNewNodeBySelectedNode];
            }];
            
            return ret;
        }
    }
    
    return NO;
}

- (BOOL)enterEditSelectedNode {
    
    if (self.mode == pollingCreateMode) {
        
        if (self.selected) {
            
            if (self.type != pollingShortAnswer) {
                [self enterEdit];
            }
            
            return YES;
        }
        else {
            __block BOOL ret = NO;
            [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
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
            
            if (NSPointInRect(mousePoint, self.nodeRect)) {
                return YES;
            }
            else {
                [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop) {
                    *stop = [child enterEditByMousePoint:mousePoint];
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, self.nodeRect)) {
            if (self.type == pollingShortAnswer) {
                [self enterEdit];
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)deleteSelectedNode {
    if (self.mode == pollingCreateMode) {
        __weak NSMutableIndexSet *delIndexes = [NSMutableIndexSet indexSet];
        [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
            if (child.selected) {
                [delIndexes addIndex:idx];
                *stop = YES;
            }
        }];
        
        if (delIndexes.count > 0) {
            [self.children removeObjectsAtIndexes:delIndexes];
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
    
    [self.tree.text endEditing:editTextView];
}

#pragma mark - Drawing Methods

- (void)childNodeDrawInRect:(NSRect*)rect {
    
    NSRect tmpRect, buttonRect;
    
    tmpRect = NSMakeRect(rect->origin.x + kButtonWidth, rect->origin.y, rect->size.width - kButtonWidth, 0.0);
    
    [self textFiledRect:&tmpRect withTextCell:self.tree.text];
    
    buttonRect  = NSMakeRect(rect->origin.x, rect->origin.y, kButtonWidth, self.textRect.size.height);
    [self drawButtonWithFrame:&buttonRect];
    
    self.nodeRect = NSUnionRect(self.textRect, buttonRect);
    
    rect->origin.y += kCCMargin + self.nodeRect.size.height;
}

- (void)drawInRect:(NSRect*)rect {
    
    if ([self isRootNode]) {
        // Draw self first
        self.nodeRect = [self textFiledRect:rect withTextCell:self.tree.text];
        
        // Change the draw rect
        rect->origin.x      += kRCMarginH;
        rect->origin.y      += kRCMarginV + self.nodeRect.size.height;
        rect->size.width    -= kRCMarginH;
        
        // Draw the child nodes
        for (NSUInteger idx = 0; idx < self.children.count; idx++) {
            TreeNode *child = [self.children objectAtIndex:idx];
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
    [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
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
            
            if (NSPointInRect(mousePoint, self.nodeRect)) {
                self.selected = YES;
                if (result) {
                    *result = YES;
                }
            }
            else {
                [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
                    *stop = [child mouseUpHittest:mousePoint result:result];
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, self.nodeRect)) {
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
            
            if (!NSPointInRect(mousePoint, self.nodeRect)) {
                
                [self.children enumerateObjectsUsingBlock:^(TreeNode *child, NSUInteger idx, BOOL *stop){
                    BOOL oldStop = *stop;
                    *stop = [child mouseUpHittest:mousePoint result:result];
                    if (self.type == pollingSingleRoot) {
                        *stop = oldStop;
                    }
                }];
            }
        }
    }
    else {
        if (NSPointInRect(mousePoint, self.nodeRect)) {
            if (self.type == pollingMutiple) {
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
            if (self.type == pollingSingle) {
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
        if (self.mode == pollingCreateMode) {
            return [self createModeMouseUpHittest:mousePoint result:result];
        }
        else {
            return [self answerModeMouseUpHittest:mousePoint result:result];
        }
    }
}

@end