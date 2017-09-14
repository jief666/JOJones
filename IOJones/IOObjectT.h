//
//  Disk.h
//  MountDaemon
//
//  Created by Jief on 18/07/17.
//  Copyright © 2017 Jief. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IOIteratorT;

@interface IOObjectT : NSObject
{
 @public
}

@property (readonly) io_object_t io_object;

+(IOObjectT*)with:(io_object_t)object;
+(IOObjectT*)IOServiceGetMatchingService_entryID:(NSUInteger)entryID;
+(IOObjectT*)IOServiceGetMatchingService_matching:(CFMutableDictionaryRef)matching;
+(IOObjectT*)IOIteratorNext_iterator:(IOIteratorT*)iterator;
+(IOObjectT*)IORegistryGetRootEntry;


-(NSString*)name;
-(NSString*)IOObjectGetClass;
-(uint32_t)IOObjectGetKernelRetainCount;
-(uint32_t)IOObjectGetUserRetainCount;
-(uint64_t)IOServiceGetState;
-(uint32_t)IOServiceGetBusyState;
-(bool)IORegistryEntryInPlane_plane:(NSString*)plane;
-(NSString*)IORegistryEntryGetLocationInPlane_plane:(NSString*)plane;
-(NSString*)IORegistryEntryGetNameInPlane_plane:(NSString*)plane;
-(NSString*)IORegistryEntryGetPath_plane:(NSString*)plane;

-(NSDictionary*)IORegistryEntryCreateCFProperties;
-(NSDictionary*)IORegistryEntryCreateCFProperty_key:(NSString*)key;

//-(IOIteratorT*)childIterator;
//-(IOIteratorT*)iteratorPlane:(NSString*)plane;

-(UInt64)IORegistryEntryGetRegistryEntryID;
-(IOIteratorT*)IORegistryEntryCreateIterator_plane:(NSString*)plane;
-(IOIteratorT*)IORegistryEntryGetChildIterator_plane:(NSString*)plane;
-(IOObjectT*)IOServiceAddInterestNotification_port:(IONotificationPortRef)notifyPort
                                interestType:(NSString*)interestType
                                callback:(IOServiceInterestCallback)callback
                                refCon:(id)refCon;


//-(IOObjectT*)getTheOnlyChildNamed:(NSString*)childName;
//-(IOObjectT*)getTheOnlyChildNamed_T:(NSString*)childName;
//-(IOObjectT*)getTheOnlyChild;
@end
