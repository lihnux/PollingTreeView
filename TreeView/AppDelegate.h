//
//  AppDelegate.h
//  TreeView
//
//  Created by Paul Li on 12/11/13.
//
//

#import <Cocoa/Cocoa.h>

@class TreeView;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSWindow       *window;
    IBOutlet NSScrollView   *scrollView;
    //IBOutlet TreeView       *treeView;
}

@property (nonatomic) IBOutlet TreeView *treeView;

- (IBAction)addSingleQiz:(id)sender;
- (IBAction)addMultipleQiz:(id)sender;
- (IBAction)addShotAnswerQiz:(id)sender;
- (IBAction)addAnswer:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)switchTreeMode:(id)sender;

@end
