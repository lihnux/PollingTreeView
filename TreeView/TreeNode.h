//
//  TreeNode.h
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import <Foundation/Foundation.h>

#define kMargin         5.0
#define kRCMarginH      15.0     // Root and Child     (horizontal)
#define kRCMarginV      2.0     // Root and Child     (vertical)
#define kRRMargin       3.0     // Root and Root      (horizontal
#define kCCMargin       1.0     // Child and Child    (vertical)
#define kButtonWidth    40.0    // button width

enum {
    pollingRoot             = 0x1,
    
    pollingSingle           = 0x2,
    pollingSingleRoot       = 0x3,
    
    pollingMutiple          = 0x4,
    pollingMutipleRoot      = 0x5,
    
    pollingShortAnswer      = 0x8,
    pollingShortAnswerRoot  = 0x9,
};

enum {
    pollingCreateMode = 0,
    pollingAnswerMode = 1,
};

@class Tree;
@class TextFieldCell;

@interface TreeNode : NSObject<NSTextDelegate> {
        
    NSText *editTextView;
}

@property (nonatomic, weak)                         Tree            *tree;
@property (nonatomic, weak)                         TreeNode        *parent;
@property (nonatomic, copy)                         NSString        *title;
@property (nonatomic, copy)                         NSString        *content;
@property (nonatomic, assign)                       UInt8           type;
@property (nonatomic, assign)                       UInt8           mode;
@property (nonatomic, assign, getter = isSelected)  BOOL            selected;
@property (nonatomic, strong)                       NSMutableArray  *children;
@property (nonatomic, assign)                       NSRect          nodeRect;
@property (nonatomic, assign)                       NSRect          textRect;

- (id)initWithTree:(Tree*)aTree parent:(TreeNode*)aParent title:(NSString*)aTitle content:(NSString*)aContent type:(UInt8)aType mode:(UInt8)aMode;
- (void)switchMode:(UInt8)mode;

- (id)addNewNodeWithTitle:(NSString*)aTitle content:(NSString*)aContent;
- (BOOL)addNewNodeBySelectedNode;
- (BOOL)enterEditSelectedNode;
- (BOOL)enterEditByMousePoint:(NSPoint)mousePoint;
- (BOOL)deleteSelectedNode;

- (void)drawInRect:(NSRect*)rect;

- (void)clearAllSelectState;

/*
 * 1. Return value means this tree node or its child node handle this mouse up action
 * 2. 'result' BOOL value means the mouse hit into this tree node or its child node
 */
- (BOOL)mouseUpHittest:(NSPoint)mousePoint result:(BOOL*)result;

@end
