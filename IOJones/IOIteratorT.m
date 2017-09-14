//
//  Disk.m
//  MountDaemon
//
//  Created by Jief on 18/07/17.
//  Copyright © 2017 Jief. All rights reserved.
//
// jief : see https://stackoverflow.com/questions/16922158/how-do-i-iterate-through-io-kits-keys

#import <IOKit/kext/KextManager.h>
#import <IOKit/IOKitLib.h>
#import "IOIteratorT.h"
#import "IOObjectT.h"



@implementation IOIteratorT

+(IOIteratorT*)IORegistryCreateIterator_plane:(NSString*)plane;
{
    if ( !plane ) return nil;
    IOIteratorT* newIOIteratorT = [[self alloc] init];
    if ( !newIOIteratorT ) return nil;
    kern_return_t ret = IORegistryCreateIterator(kIOMasterPortDefault, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], 0, &(newIOIteratorT->_io_iterator));
    if ( ret != KERN_SUCCESS ) return nil;
    return newIOIteratorT;
}

+(IOIteratorT*)IORegistryEntryCreateIterator_entry:(IOObjectT*)ioObject plane:(NSString*)plane;
{
    if ( !ioObject ) return nil;
    if ( !plane ) return nil;
    IOIteratorT* newIOIteratorT = [[self alloc] init];
    if ( !newIOIteratorT ) return nil;
    kern_return_t ret = IORegistryEntryCreateIterator(ioObject.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], 0, &(newIOIteratorT->_io_iterator));
    if ( ret != KERN_SUCCESS ) return nil;
    return newIOIteratorT;
}

+(IOIteratorT*)IORegistryEntryGetChildIterator_entry:(IOObjectT*)ioObject plane:(NSString*)plane;
{
    if ( !ioObject ) return nil;
    if ( !plane ) return nil;
    IOIteratorT* newIOIteratorT = [[IOIteratorT alloc] init];
    if ( !newIOIteratorT ) return nil;
    kern_return_t ret = IORegistryEntryGetChildIterator(ioObject.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], &(newIOIteratorT->_io_iterator));
    if ( ret != KERN_SUCCESS ) return nil;
    return newIOIteratorT;
}

+(IOIteratorT*)IOServiceAddMatchingNotification_port:(IONotificationPortRef)notifyPort
                                               notificationType:(NSString*)notificationType
                                               matching:(CFDictionaryRef)matching
                                               callback:(IOServiceMatchingCallback)callback
                                               refCon:(id)refCon;
{
    if ( !notifyPort ) return nil;
    if ( !notificationType ) return nil;
    if ( !matching ) return nil;
    if ( !callback ) return nil;
    if ( !refCon ) return nil;
    IOIteratorT* newIOIteratorT = [[IOIteratorT alloc] init];
    if ( !newIOIteratorT ) return nil;
    kern_return_t ret = IOServiceAddMatchingNotification(notifyPort, notificationType.UTF8String, matching, callback, (__bridge void *)refCon, &(newIOIteratorT->_io_iterator));
    if ( ret != KERN_SUCCESS ) return nil;
    return newIOIteratorT;
}

-(void)dealloc
{
//NSLog(@"IOIteratorT dealloc");
    IOObjectRelease(_io_iterator);
}

-(IOObjectT*)IOIteratorNext;
{
    return [IOObjectT IOIteratorNext_iterator:self];
}

-(kern_return_t)IORegistryIteratorEnterEntry;
{
    return IORegistryIteratorEnterEntry(self.io_iterator);
}

-(kern_return_t)IORegistryIteratorExitEntry;
{
    return IORegistryIteratorExitEntry(self.io_iterator);
}

@end
