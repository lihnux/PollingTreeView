//
//  TreeView.h
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import <Cocoa/Cocoa.h>

@class Tree;

@interface TreeView : NSView

@property (nonatomic, strong) Tree *tree;

- (void)initTreeWithMode:(UInt8)mode;

- (void)switchMode;

@end
