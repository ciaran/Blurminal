#import "Blurminal.h"
#import "JRSwizzle.h"

typedef void* CGSConnectionID;
extern OSStatus CGSNewConnection (const void** attr, CGSConnectionID* id);

@implementation NSWindow (TTWindow)
// Found here:
// http://www.aeroxp.org/board/index.php?s=d18e98cabed9ce5ad27f9449b4e2298f&showtopic=8984&pid=116022&st=0&#entry116022
- (void)enableBlur
{
	CGSConnectionID _myConnection;
	CGSNewConnection(NULL , &_myConnection);

	uint32_t __compositingFilter = 0;
	CGSNewCIFilterByName (_myConnection, (CFStringRef)@"CIGaussianBlur", &__compositingFilter);

	NSDictionary* optionsDict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Blurminal Radius"] forKey:@"inputRadius"];
	CGSSetCIFilterValuesFromDictionary(_myConnection, __compositingFilter, (CFDictionaryRef)optionsDict);

	CGSAddWindowFilter(_myConnection, [self windowNumber], __compositingFilter, 1);
}

- (id)Blurred_initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if(self = [self Blurred_initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation])
	{
		if([self isKindOfClass:NSClassFromString(@"TTWindow")] || [self isKindOfClass:NSClassFromString(@"VisorWindow")])
		{
			// The window has to be onscreen to get a windowNumber, so we run the enableBlur after the event loop
			[self performSelector:@selector(enableBlur) withObject:nil afterDelay:0]; // FIXME
		}
	}
	return self;
}
@end

@implementation Blurminal
+ (void)load
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithFloat:1.0],@"Blurminal Radius",
		nil]];
	[[NSWindow class] jr_swizzleMethod:@selector(initWithContentRect:styleMask:backing:defer:) withMethod:@selector(Blurred_initWithContentRect:styleMask:backing:defer:) error:NULL];
}
@end
