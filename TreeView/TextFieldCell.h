//
//  TextFieldCell.h
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import <Cocoa/Cocoa.h>

@interface TextFieldCell : NSTextFieldCell

@property (nonatomic, assign) BOOL                  bold;
@property (nonatomic, assign) BOOL                  italic;

- (NSSize)sizeForCurrentTitle;

@end
