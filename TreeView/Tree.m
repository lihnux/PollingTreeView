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

#pragma mark - Tree Actions (Add, Delete, Find, Edit)

- (id)addNewNodeWithType:(UInt8)type title:(NSString*)title content:(NSString*)content {
    
    TreeNode *newNode = [[[TreeNode alloc] initWithTree:self parent:nil title:title content:content type:type mode:mode] autorelease];
    
    [children addObject:newNode];
    
    return newNode;
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
        
        __block NSMutableIndexSet *delIndexes = [NSMutableIndexSet indexSet];
        __block BOOL isDeleted = NO;
        [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
            if (rootNode.selected) {
                [delIndexes addIndex:idx];
                *stop = TRUE;
            }
            else {
                isDeleted = *stop = [rootNode deleteSelectedNode];
            }
        }];
        
        if (delIndexes.count > 0) {
            [children removeObjectsAtIndexes:delIndexes];
            isDeleted = YES;
        }
        
        return isDeleted;
    }
    
    return NO;
}

#pragma mark - Drawing Methods

- (void)treeDrawInRect:(NSRect)rect {
    
    __block NSRect nodeRect = NSMakeRect(kMargin, kMargin, rect.size.width - kMargin * 2, 0.0);
    
    [children enumerateObjectsUsingBlock:^(TreeNode *rootNode, NSUInteger idx, BOOL *stop){
        [rootNode drawInRect:&nodeRect];
    }];
    
    /*
    for (NSUInteger idx = 0; idx < children.count; idx++) {
        TreeNode *rootNode = [children objectAtIndex:idx];
        [rootNode drawInRect:&nodeRect inView:view withTextCell:text withButtonCell:button];
    }
    */
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
