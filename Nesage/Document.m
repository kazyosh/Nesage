//
//  Document.m
//  Nesage
//
// Copyright (c) 2018 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import "Nebiki.h"
#import "Document.h"

@interface Document ()
@property FSEventStreamRef fseventStream;
@property NSString *css;
@property NSString *cssHilightJs;
@end

@implementation Document
- (NSString *)htmlString {
    return [Meboshi toHtmlWithTitle:self.fileURL.lastPathComponent data:self.markdownData];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"]];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    self.markdownData = data;
    return YES;
}

- (void)setFileURL:(NSURL *)fileURL
{
    [super setFileURL:fileURL];
    self.markdownData = [NSData dataWithContentsOfURL:self.fileURL];
    
}

- (void)presentedItemDidChange
{
    self.markdownData = [NSData dataWithContentsOfURL:self.fileURL];
}

- (void)exportAsHtml:(NSURL *)exportURL
{
    NSString *html = self.htmlString;
    if ([html writeToURL:exportURL atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        self.exportURL = exportURL;
    }
}

- (void)exportAsPdf:(NSView *)view exportURL:(NSURL *)exportURL
{
    NSMutableDictionary* pd = [NSMutableDictionary
                               dictionaryWithDictionary:[[NSPrintInfo sharedPrintInfo] dictionary]];
    [pd setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
    [pd setObject:exportURL forKey:NSPrintJobSavingURL];
    
    NSPrintInfo* pi = [[NSPrintInfo alloc] initWithDictionary:pd];
    [pi setHorizontalPagination:NSAutoPagination];
    [pi setVerticalPagination:NSAutoPagination];
    [pi setVerticallyCentered:NO];
    
    NSPrintOperation* po = [NSPrintOperation printOperationWithView:view
                                                          printInfo:pi];
    [po setShowsPrintPanel:NO];
    [po setShowsProgressPanel:NO];
    
    if ([po runOperation]) {
        self.exportURL = exportURL;
    }
}

@end
