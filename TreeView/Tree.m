//
//  Tree.m
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import "Tree.h"
#import "TreeNode.h"
#import "TextFieldCell.h"

@implementation Tree

#pragma mark - Life Cycle

- (id)initWithView:(NSView*)aView {
    self = [super self];
    
    if (self) {
        self.view = aView;
        self.children = [NSMutableArray array];
        
        self.text = [[TextFieldCell alloc] init];
        [self.text setWraps:YES];
        [self.text setEditable:YES];
        
        self.radioButton = [[NSButtonCell alloc] init];
        [self.radioButton setWraps:YES];
        [self.radioButton setButtonType:NSRadioButton];
        
        self.switchButton = [[NSButtonCell alloc] init];
        [self.switchButton setWraps:YES];
        [self.switchButton setButtonType:NSSwitchButton];
    }
    
    return self;
}

- (void)switchMode:(UInt8)mode {
    
    self.mode = mode;
    
    for (TreeNode * node in self.children) {
        [node switchMode:mode];
    }
}


#pragma mark - Prviate Methods
- (void)swithSelectedNodeByDeleteIndex:(NSUInteger)delIndex {
    
    if (self.children.count > 0) {
        NSUInteger nextSelectIndex = (delIndex <= self.children.count - 1) ? delIndex : (self.children.count - 1);
        TreeNode *node = [self.children objectAtIndex:nextSelectIndex];
        node.selected = YES;
    }
}

#pragma mark - Tree Actions (Add, Delete, Find, Edit)

- (id)addNewNodeWithType:(UInt8)type title:(NSString*)title content:(NSString*)content {
    
    TreeNode *newNode = [[TreeNode alloc] initWithTree:self parent:nil title:title content:content type:type mode:self.mode];
    
    [self.children addObject:newNode];
    
    return newNode;
}

- (BOOL)addRootNode:(UInt8)type {
    
    TreeNode *newNode = [[TreeNode alloc] initWithTree:self parent:nil title:@"" content:@"" type:type mode:self.mode];
    
    __weak NSMutableIndexSet *selectedIdx = [NSMutableIndexSet indexSet];
    [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
        if (rootNode.selected) {
            [selectedIdx addIndex:idx];
            *stop = YES;
        }
    }];
    
    if (self.children.count > 0 && selectedIdx.count > 0) {
        ([selectedIdx firstIndex] == self.children.count - 1) ? [self.children addObject:newNode] : [self.children insertObject:newNode atIndex:[selectedIdx firstIndex] + 1];
    }
    else {
        [self.children addObject:newNode];
    }
    
    // Add the some new child for the new root node
    switch (type) {
        case pollingSingleRoot:
        case pollingMutipleRoot:
            [newNode addNewNodeWithTitle:@"" content:@""];
            [newNode addNewNodeWithTitle:@"" content:@""];
            break;
        case pollingShortAnswerRoot:
            [newNode addNewNodeWithTitle:@"" content:@""];
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)addChildNodeBySelectedNode {
    if (self.mode == pollingCreateMode) {
        [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
            *stop = [rootNode addNewNodeBySelectedNode];
        }];
    }
    
}

- (void)enterEditMode:(NSPoint)mousePoint {
    if (self.mode == pollingCreateMode) {
        [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
            *stop = [rootNode enterEditSelectedNode];
        }];
    }
    else {
        [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
            *stop = [rootNode enterEditByMousePoint:mousePoint];
        }];
    }
}

- (void)enterEditSelectedNode {
    
    if (self.mode == pollingCreateMode) {
        [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
            *stop = [rootNode enterEditSelectedNode];
        }];
    }
}

- (void)enterEditByMousePoint:(NSPoint)mousePoint {
    [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
        *stop = [rootNode enterEditByMousePoint:mousePoint];
    }];
}

- (BOOL)deleteSelectedNode {
    if (self.mode == pollingCreateMode) {
        
        __weak NSMutableIndexSet *delRootIndex         = [NSMutableIndexSet indexSet];
        __weak NSMutableIndexSet *delChildRootIndex    = [NSMutableIndexSet indexSet];
        __block BOOL isDeleted = NO;
        [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
            if (rootNode.selected) {
                [delRootIndex addIndex:idx];
                *stop = TRUE;
            }
            else {
                isDeleted = *stop = [rootNode deleteSelectedNode];
                if (*stop) {
                    [delChildRootIndex addIndex:idx];
                }
            }
        }];
        
        if (delRootIndex.count > 0) {
            [self.children removeObjectsAtIndexes:delRootIndex];
            isDeleted = YES;
            
            [self swithSelectedNodeByDeleteIndex:[delRootIndex firstIndex]];
        }
        else if (delChildRootIndex.count > 0) {
            TreeNode *node = [self.children objectAtIndex:[delChildRootIndex firstIndex]];
            if (node.type == pollingShortAnswerRoot || node.children.count < 2) {
                [self.children removeObjectsAtIndexes:delChildRootIndex];
                [self swithSelectedNodeByDeleteIndex:[delChildRootIndex firstIndex]];
            }
        }
        
        return isDeleted;
    }
    
    return NO;
}

#pragma mark - Drawing Methods

- (void)treeDrawInRect:(NSRect)rect {
    
    if (rectInitHeight == 0) {
        rectInitHeight = rect.size.height;
    }
    
    __block NSRect nodeRect = NSMakeRect(kMargin, kMargin, rect.size.width - kMargin * 2, 0.0);
    
    [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
        [rootNode drawInRect:&nodeRect];
    }];
    
    if (nodeRect.origin.y + kMargin > rect.size.height) {
        NSRect newRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, nodeRect.origin.y + kMargin);
        [self.view setFrame:newRect];
    }
    else {
        if (rect.size.height > rectInitHeight) {
            NSRect newRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, nodeRect.origin.y + kMargin);
            [self.view setFrame:newRect];
        }
    }
}

#pragma mark - Mouse Actions

- (BOOL)mouseUpHittest:(NSPoint)mousePoint result:(BOOL *)result{
    
    __block BOOL        ret     = NO;
    __block NSUInteger  stopIdx = NSUIntegerMax;
    
    [self.children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
        
        switch (self.mode) {
            case pollingCreateMode:
                if (idx > stopIdx) {
                    [rootNode clearAllSelectState];
                }
                else {
                    [rootNode clearAllSelectState];
                    ret = [rootNode mouseUpHittest:mousePoint result:result];
                    
                    if (ret) {
                        stopIdx = idx;
                    }
                }
                break;
            case pollingAnswerMode:
                ret = *stop = [rootNode mouseUpHittest:mousePoint result:result];
                break;
            default:
                break;
        }
    }];
    
    return ret;
}

@end
