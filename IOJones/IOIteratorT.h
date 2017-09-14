//
//  Disk.h
//  MountDaemon
//
//  Created by Jief on 18/07/17.
//  Copyright © 2017 Jief. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IOObjectT;

@interface IOIteratorT : NSObject
{
 @public
     
}

@property (readonly) io_iterator_t io_iterator;

@property (readonly) IOObjectT* IOIteratorNext;

+(IOIteratorT*)IORegistryEntryCreateIterator_entry:(IOObjectT*)ioObject plane:(NSString*)plane;
+(IOIteratorT*)IORegistryEntryGetChildIterator_entry:(IOObjectT*)ioObject plane:(NSString*)plane;
+(IOIteratorT*)IORegistryCreateIterator_plane:(NSString*)plane;
+(IOIteratorT*)IOServiceAddMatchingNotification_port:(IONotificationPortRef)notifyPort
                                               notificationType:(NSString*)notificationType
                                               matching:(CFDictionaryRef)matching
                                               callback:(IOServiceMatchingCallback)callback
                                               refCon:(id)refCon;

-(kern_return_t)IORegistryIteratorEnterEntry;
-(kern_return_t)IORegistryIteratorExitEntry;

@end

