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
@synthesize children;
@synthesize mode;
@synthesize view;
@synthesize text;
@synthesize radioButton;
@synthesize switchButton;

#pragma mark - Life Cycle

- (id)initWithView:(NSView*)aView {
    self = [super self];
    
    if (self) {
        view = aView;
        self.children = [[NSMutableArray alloc] init];
        
        text = [[TextFieldCell alloc] init];
        [text setWraps:YES];
        [text setEditable:YES];
        
        radioButton = [[NSButtonCell alloc] init];
        [radioButton setWraps:YES];
        [radioButton setButtonType:NSRadioButton];
        
        switchButton = [[NSButtonCell alloc] init];
        [switchButton setWraps:YES];
        [switchButton setButtonType:NSSwitchButton];
    }
    
    return self;
}

- (void)dealloc {
    
    [children   release];
    [super      dealloc];
}

#pragma mark - Prviate Methods
- (void)swithSelectedNodeByDeleteIndex:(NSUInteger)delIndex {
    
    if (children.count > 0) {
        NSUInteger nextSelectIndex = (delIndex <= children.count - 1) ? delIndex : (children.count - 1);
        TreeNode *node = [children objectAtIndex:nextSelectIndex];
        node.selected = YES;
    }
}

#pragma mark - Tree Actions (Add, Delete, Find, Edit)

- (id)addNewNodeWithType:(UInt8)type title:(NSString*)title content:(NSString*)content {
    
    TreeNode *newNode = [[[TreeNode alloc] initWithTree:self parent:nil title:title content:content type:type mode:mode] autorelease];
    
    [children addObject:newNode];
    
    return newNode;
}

- (BOOL)addRootNode:(UInt8)type {
    
    TreeNode *newNode = [[[TreeNode alloc] initWithTree:self parent:nil title:@"" content:@"" type:type mode:mode] autorelease];
    
    __block NSMutableIndexSet *selectedIdx = [NSMutableIndexSet indexSet];
    [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
        if (rootNode.selected) {
            [selectedIdx addIndex:idx];
            *stop = YES;
        }
    }];
    
    if (children.count > 0 && selectedIdx.count > 0) {
        ([selectedIdx firstIndex] == children.count - 1) ? [children addObject:newNode] : [children insertObject:newNode atIndex:[selectedIdx firstIndex] + 1];
    }
    else {
        [children addObject:newNode];
    }
    
    // Add the some new child for the new root node
    switch (type) {
        case pollingSingleRoot:
        case pollingMutipleRoot:
            [newNode addNewNodeWithTitle:nil content:@""];
            [newNode addNewNodeWithTitle:nil content:@""];
            break;
        case pollingShortAnswerRoot:
            [newNode addNewNodeWithTitle:nil content:nil];
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)addChildNodeBySelectedNode {
    if (mode == pollingCreateMode) {
        [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
            *stop = [rootNode addNewNodeBySelectedNode];
        }];
    }
    
}

- (void)enterEditSelectedNode {
    
    if (mode == pollingCreateMode) {
        [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
            *stop = [rootNode enterEditSelectedNode];
        }];
    }
}

- (BOOL)deleteSelectedNode {
    if (mode == pollingCreateMode) {
        
        __block NSMutableIndexSet *delRootIndex         = [NSMutableIndexSet indexSet];
        __block NSMutableIndexSet *delChildRootIndex    = [NSMutableIndexSet indexSet];
        __block BOOL isDeleted = NO;
        [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
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
            [children removeObjectsAtIndexes:delRootIndex];
            isDeleted = YES;
            
            [self swithSelectedNodeByDeleteIndex:[delRootIndex firstIndex]];
        }
        else if (delChildRootIndex.count > 0) {
            TreeNode *node = [children objectAtIndex:[delChildRootIndex firstIndex]];
            if (node.type == pollingShortAnswerRoot || node.children.count < 2) {
                [children removeObjectsAtIndexes:delChildRootIndex];
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
    
    [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
        [rootNode drawInRect:&nodeRect];
    }];
    
    if (nodeRect.origin.y + kMargin > rect.size.height) {
        NSRect newRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, nodeRect.origin.y + kMargin);
        [view setFrame:newRect];
    }
    else {
        if (rect.size.height > rectInitHeight) {
            NSRect newRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, nodeRect.origin.y + kMargin);
            [view setFrame:newRect];
        }
    }
}

#pragma mark - Mouse Actions

- (BOOL)mouseUpHittest:(NSPoint)mousePoint result:(BOOL *)result{
    
    __block BOOL        ret     = NO;
    __block NSUInteger  stopIdx = NSUIntegerMax;
    
    [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop) {
        
        switch (mode) {
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
                break;
            default:
                break;
        }
    }];
    
    return ret;
}

@end
