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
    
    /*
    NSRect rc = [window frameRectForContentRect:[scrollView bounds]];
    NSRect winFrm = [window frame];
    
    rc.origin = winFrm.origin;
    rc.origin.y -= (rc.size.height - winFrm.size.height);
    
    [window setContentView:scrollView];
    [window setFrame:rc display:YES animate:YES];
     */
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)addSingleQiz:(id)sender {
    [treeView.tree addRootNode:pollingSingleRoot];
    [treeView setNeedsDisplay:YES];
}

- (IBAction)addMultipleQiz:(id)sender {
    [treeView.tree addRootNode:pollingMutipleRoot];
    [treeView setNeedsDisplay:YES];
}

- (IBAction)addShotAnswerQiz:(id)sender {
    [treeView.tree addRootNode:pollingShortAnswerRoot];
    [treeView setNeedsDisplay:YES];
}

- (IBAction)addAnswer:(id)sender {
    [treeView.tree addChildNodeBySelectedNode];
    [treeView setNeedsDisplay:YES];
}

- (IBAction)remove:(id)sender {
    [treeView.tree deleteSelectedNode];
    [treeView setNeedsDisplay:YES];
}

@end
