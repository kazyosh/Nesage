//
//  SavePanelAccessoryView.m
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import "SavePanelAccessoryView.h"

@interface SavePanelAccessoryView()<NSComboBoxDelegate>
@property (strong) NSView *view;
@end

@implementation SavePanelAccessoryView

- (NSString *)selectedFileFormat
{
    return [self.fileFormat itemObjectValueAtIndex:[self.fileFormat indexOfSelectedItem]];
}

- (id)initWithFrame:(NSRect)frame
{
    NSString* nibName = NSStringFromClass([self class]);
    NSArray *topLevelObjects;
    if ([[NSBundle mainBundle] loadNibNamed:nibName
                                      owner:self
                            topLevelObjects:&topLevelObjects]) {
        for (NSObject *obj in topLevelObjects) {
            if ([obj isKindOfClass:[SavePanelAccessoryView class]]) {
                self = (SavePanelAccessoryView *)obj;
                [self setFrame:frame];
            }
            NSLog(@"topLevelObjects : %@", obj.className);
        }
        if (!self) {
            self = [super initWithFrame:frame];
        }
    }
    else {
        self = [super initWithFrame:frame];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib
{
    [self.fileFormat setStringValue:@"html"];
}

- (void)changeFileExtension:(NSString *)newExtension
{
    
}

@end
