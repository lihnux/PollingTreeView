//
//  TreeView.h
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import <Cocoa/Cocoa.h>

@class Tree;

@interface TreeView : NSView {
    Tree *tree;
}

@property (retain) Tree *tree;

@end
