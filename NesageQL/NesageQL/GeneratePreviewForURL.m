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
        
        NSString *html = [Meboshi toHtmlWithTitle:[nsurl lastPathComponent]
                                             data:data
                                    markdownStyle:[Meboshi markdownStyles][0]
                                 codeHilightStyle:[Meboshi codeHilightStyles][0]];
//        NSString *html = [NSString stringWithContentsOfURL:nsurl encoding:NSUTF8StringEncoding error:nil];
//        NSLog(@"***** %@", html);

        // Put metadata and attachment in a dictionary
        NSDictionary *properties = @{ // properties for the HTML data
                                     (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
                                     (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html",
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
