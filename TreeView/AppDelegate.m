//
//  AppDelegate.m
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSRect rc = [window frameRectForContentRect:[scrollView bounds]];
    NSRect winFrm = [window frame];
    
    rc.origin = winFrm.origin;
    rc.origin.y -= (rc.size.height - winFrm.size.height);
    
    [window setContentView:scrollView];
    [window setFrame:rc display:YES animate:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
