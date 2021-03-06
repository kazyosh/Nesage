#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>

#import "../../Nebiki/Nebiki.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    @autoreleasepool {
        
        // Load the property list from the URL
        NSURL *nsurl = (__bridge NSURL *)url;
        NSLog(@"***** %@", [nsurl absoluteString]);
        NSData *data = [NSData dataWithContentsOfURL:nsurl];

        if (QLPreviewRequestIsCancelled(preview)) return noErr;
        
        NSString *markdownStyle = @"github";
        NSString *codeHilightStyle = @"github";
        if (@available(macOS 10_14, *)) {
            if ([[NSAppearance currentAppearance].name isEqual:NSAppearanceNameDarkAqua]) {
                markdownStyle = @"dark";
                codeHilightStyle = @"solarized-dark";
            }
        }
        NSString *html = [Meboshi toHtmlWithTitle:[nsurl lastPathComponent]
                                             data:data
                              optionalHeaderItems:@[@"<link rel=\"stylesheet\" type=\"text/css\" href=\"cid:css\">"]
                                    markdownStyle:@"dark"
                                 codeHilightStyle:@"solarized-dark"];
        NSMutableString *css = [NSMutableString stringWithString:[Meboshi cssForCodeHilightStyle:markdownStyle]];
        [css appendString:[Meboshi cssForMarkdownStyle:codeHilightStyle]];

        // Put metadata and attachment in a dictionary
        NSDictionary *properties = @{ // properties for the HTML data
                                     (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
                                     (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html",
                                     (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @{
                                             @"css" : @{
                                                     (__bridge NSString*)kQLPreviewPropertyMIMETypeKey : @"text/css",
                                                     (__bridge NSString*)kQLPreviewPropertyAttachmentDataKey: css,
                                                     }
                                             }
                                     };
        
        // Pass preview data and metadata/attachment dictionary to QuickLook
        QLPreviewRequestSetDataRepresentation(preview,
                                              (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                              kUTTypeHTML,
                                              (__bridge CFDictionaryRef)properties);
        NSLog(@"%@", options);
    }
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
