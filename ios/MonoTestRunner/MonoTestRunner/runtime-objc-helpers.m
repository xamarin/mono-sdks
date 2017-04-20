//
//  runtime-objc-helpers.m
//  MonoTestRunner
//
//  Created by Rodrigo Kumpera on 4/19/17.
//  Copyright © 2017 Rodrigo Kumpera. All rights reserved.
//

#import <Foundation/Foundation.h>

const char *
runtime_get_bundle_path (void)
{
    NSBundle *main_bundle = [NSBundle mainBundle];
    NSString *bundle_path;
    
    bundle_path = [main_bundle bundlePath];
    
    const char *result = strdup ([bundle_path UTF8String]);
    
    return result;
}

void
xamarin_log (const unsigned short *unicodeMessage)
{
	// COOP: no managed memory access: any mode.
	int length = 0;
	const unsigned short *ptr = unicodeMessage;
	while (*ptr++)
		length += sizeof (unsigned short);
	NSString *msg = [[NSString alloc] initWithBytes: unicodeMessage length: length encoding: NSUTF16LittleEndianStringEncoding];

#if TARGET_OS_WATCH && defined (__arm__) // maybe make this configurable somehow?
	const char *utf8 = [msg UTF8String];
	int len = strlen (utf8);
	fwrite (utf8, 1, len, stdout);
	if (len == 0 || utf8 [len - 1] != '\n')
		fwrite ("\n", 1, 1, stdout);
	fflush (stdout);
#else
	NSLog (@"%@", msg);
#endif
}