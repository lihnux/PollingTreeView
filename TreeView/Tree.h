//
//  Tree.h
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import <Foundation/Foundation.h>

@class TextFieldCell;

@interface Tree : NSObject {
    NSUInteger rectInitHeight;
}

@property (nonatomic, strong)   NSMutableArray  *children;
@property (nonatomic, assign)   UInt8           mode;
@property (nonatomic, weak)     NSView          *view;

@property (nonatomic, strong)   TextFieldCell   *text;
@property (nonatomic, strong)   NSButtonCell    *radioButton;
@property (nonatomic, strong)   NSButtonCell    *switchButton;

- (id)initWithView:(NSView*)aView;
- (void)switchMode:(UInt8)mode;

- (id)addNewNodeWithType:(UInt8)type title:(NSString*)title content:(NSString*)content;

- (BOOL)addRootNode:(UInt8)type;
- (void)addChildNodeBySelectedNode;
- (void)enterEditMode:(NSPoint)mousePoint;
- (void)enterEditSelectedNode;
- (void)enterEditByMousePoint:(NSPoint)mousePoint;
- (BOOL)deleteSelectedNode;

- (void)treeDrawInRect:(NSRect)rect;

- (BOOL)mouseUpHittest:(NSPoint)mousePoint result:(BOOL*)result;

@end

