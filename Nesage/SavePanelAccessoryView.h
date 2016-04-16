//
//  SavePanelAccessoryView.h
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>

@interface SavePanelAccessoryView : NSView
@property (strong) IBOutlet NSComboBox  *fileFormat;
@property (nonatomic, copy, readonly) NSString *selectedFileFormat;
- (void)changeFileExtension:(NSString *)newExtension;
@end
