//
//  TextFieldCell.h
//  TreeView
//
//  Created by Paul Li on 12/12/13.
//
//

#import <Cocoa/Cocoa.h>

@interface TextFieldCell : NSTextFieldCell {
    BOOL bold;
    BOOL italic;
}

@property (nonatomic, assign, getter = isBold)      BOOL bold;
@property (nonatomic, assign, getter = isItalic)    BOOL italic;

@end
