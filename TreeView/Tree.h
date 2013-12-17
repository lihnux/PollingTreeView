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
    NSMutableArray  *children;
    
    TextFieldCell   *text;
    NSButtonCell    *radioButton;
    NSButtonCell    *switchButton;
    
    UInt8           mode;
    
    NSView          *view;
    
    NSUInteger      rectInitHeight;
}

@property (nonatomic, retain)   NSMutableArray  *children;
@property (nonatomic, assign)   UInt8           mode;
@property (nonatomic, readonly) NSView          *view;

@property (nonatomic, readonly) TextFieldCell   *text;
@property (nonatomic, readonly) NSButtonCell    *radioButton;
@property (nonatomic, readonly) NSButtonCell    *switchButton;

- (id)initWithView:(NSView*)aView;

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

