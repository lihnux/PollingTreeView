//
//  AppDelegate.m
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import "AppDelegate.h"
#import "TreeView.h"
#import "Tree.h"
#import "TreeNode.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
        
    [self.treeView initTreeWithMode:pollingCreateMode];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)addSingleQiz:(id)sender {
    [self.treeView.tree addRootNode:pollingSingleRoot];
    [self.treeView setNeedsDisplay:YES];
}

- (IBAction)addMultipleQiz:(id)sender {
    [self.treeView.tree addRootNode:pollingMutipleRoot];
    [self.treeView setNeedsDisplay:YES];
}

- (IBAction)addShotAnswerQiz:(id)sender {
    [self.treeView.tree addRootNode:pollingShortAnswerRoot];
    [self.treeView setNeedsDisplay:YES];
}

- (IBAction)addAnswer:(id)sender {
    [self.treeView.tree addChildNodeBySelectedNode];
    [self.treeView setNeedsDisplay:YES];
}

- (IBAction)remove:(id)sender {
    [self.treeView.tree deleteSelectedNode];
    [self.treeView setNeedsDisplay:YES];
}

- (IBAction)switchTreeMode:(id)sender {
    
    [self.treeView switchMode];
    [self.treeView setNeedsDisplay:YES];
}

@end
