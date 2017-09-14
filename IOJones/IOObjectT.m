//
//  Disk.m
//  MountDaemon
//
//  Created by Jief on 18/07/17.
//  Copyright © 2017 Jief. All rights reserved.
//
// jief : see https://stackoverflow.com/questions/16922158/how-do-i-iterate-through-io-kits-keys

#import "IOObjectT.h"
#import "IOIteratorT.h"

#import "IOKitLibPrivate.h"


@implementation IOObjectT
   
+(IOObjectT*)with:(io_object_t)object;
{
    if ( !object ) return nil;
    IOObjectT* newIOObjectT = [[self alloc] init];
    if ( !newIOObjectT ) return nil;
    newIOObjectT->_io_object = object;
    return newIOObjectT;
}

+(IOObjectT*)IOIteratorNext_iterator:(IOIteratorT*)iterator;
{
    if ( !iterator ) return nil;
    IOObjectT* newIOObjectT = [[self alloc] init];
    if ( !newIOObjectT ) return nil;
    newIOObjectT->_io_object = IOIteratorNext(iterator.io_iterator);
    if ( !newIOObjectT->_io_object ) return nil;
    return newIOObjectT;
}


+(IOObjectT*)IOServiceGetMatchingService_entryID:(NSUInteger)entryID;
{
    if ( !entryID ) return nil;
    IOObjectT* newIOObjectT = [[self alloc] init];
    if ( !newIOObjectT ) return nil;
    newIOObjectT->_io_object = IOServiceGetMatchingService(kIOMasterPortDefault, IORegistryEntryIDMatching(entryID));
    if ( !newIOObjectT->_io_object ) return nil;
    return newIOObjectT;
}

+(IOObjectT*)IOServiceGetMatchingService_matching:(CFMutableDictionaryRef)matching;
{
    if ( !matching ) return nil;
    IOObjectT* newIOObjectT = [[self alloc] init];
    if ( !newIOObjectT ) return nil;
    newIOObjectT->_io_object = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    if ( !newIOObjectT->_io_object ) return nil;
    return newIOObjectT;
}

+(IOObjectT*)IORegistryGetRootEntry;
{
    IOObjectT* newIOObjectT = [[self alloc] init];
    if ( !newIOObjectT ) return nil;
    newIOObjectT->_io_object = IORegistryGetRootEntry(kIOMasterPortDefault);
    if ( !newIOObjectT->_io_object ) return nil;
    return newIOObjectT;
}

-(IOObjectT*)IOServiceAddInterestNotification_port:(IONotificationPortRef)notifyPort
                                interestType:(NSString*)interestType
                                callback:(IOServiceInterestCallback)callback
                                refCon:(id)refCon;
{
    if ( !notifyPort ) return nil;
    if ( !interestType ) return nil;
    if ( !callback ) return nil;
    if ( !refCon ) return nil;
    IOObjectT* newIOObjectT = [[IOObjectT alloc] init];
    if ( !newIOObjectT ) return nil;
    kern_return_t ret = IOServiceAddInterestNotification(notifyPort, self.io_object, interestType.UTF8String, callback, (__bridge void *)refCon, &(newIOObjectT->_io_object));
    if ( ret != KERN_SUCCESS ) return nil;
    return newIOObjectT;
}


-(void)dealloc
{
//NSLog(@"IOObjectT dealloc");
    IOObjectRelease(self.io_object);
}

-(UInt64)IORegistryEntryGetRegistryEntryID;
{
    UInt64 entry;
    IORegistryEntryGetRegistryEntryID(self.io_object, &entry);
    return entry;
}

-(IOIteratorT*)IORegistryEntryCreateIterator_plane:(NSString*)plane;
{
    return [IOIteratorT IORegistryEntryCreateIterator_entry:self plane:plane];
}

-(IOIteratorT*)IORegistryEntryGetChildIterator_plane:(NSString*)plane;
{
    return [IOIteratorT IORegistryEntryGetChildIterator_entry:self plane:plane];
}


-(NSString*)name;
{
    io_name_t name;  
    IORegistryEntryGetName(self.io_object, name);
    return [NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)IOObjectGetClass;
{
    io_name_t name;  
    IOObjectGetClass(self.io_object, name);
    return [NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding];
}
-(uint32_t)IOObjectGetKernelRetainCount;
{
    return IOObjectGetKernelRetainCount(self.io_object);
}

-(uint32_t)IOObjectGetUserRetainCount;
{
    return IOObjectGetUserRetainCount(self.io_object);
}

-(uint64_t)IOServiceGetState;
{
    uint64_t state;
    kern_return_t ret = IOServiceGetState(self.io_object, &state);
    if ( ret != KERN_SUCCESS ) @throw @"IOServiceGetState failed";
    return state;
}

-(uint32_t)IOServiceGetBusyState;
{
    uint32_t state;
    kern_return_t ret = IOServiceGetBusyState(self.io_object, &state);
//    if ( ret != KERN_SUCCESS ) @throw @"IOServiceGetBusyState failed";
    if ( ret != KERN_SUCCESS ) {
        NSLog(@"IOServiceGetBusyState failed");
        return -1;
    }
    return state;
}


-(bool)IORegistryEntryInPlane_plane:(NSString*)plane;
{
    return IORegistryEntryInPlane(self.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding]);
}

-(NSString*)IORegistryEntryGetLocationInPlane_plane:(NSString*)plane;
{
    io_name_t location;
    kern_return_t ret = IORegistryEntryGetLocationInPlane(self.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], location);
//    if ( ret != KERN_SUCCESS ) @throw @"IORegistryEntryGetLocationInPlane failed";
    if ( ret != KERN_SUCCESS ) {
//        NSLog(@"IORegistryEntryGetLocationInPlane failed");
        return nil;
    }
    return [NSString stringWithCString:location encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)IORegistryEntryGetNameInPlane_plane:(NSString*)plane;
{
    io_name_t name;
    kern_return_t ret = IORegistryEntryGetNameInPlane(self.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], name);
//    if ( ret != KERN_SUCCESS ) @throw @"IORegistryEntryGetNameInPlane failed";
    if ( ret != KERN_SUCCESS ) {
//        NSLog(@"IORegistryEntryGetNameInPlane failed");
        return nil;
    }
    return [NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding];
}

-(NSString*)IORegistryEntryGetPath_plane:(NSString*)plane;
{
    io_string_t path;
    kern_return_t ret = IORegistryEntryGetPath(self.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], path);
//    if ( ret != KERN_SUCCESS ) @throw @"IORegistryEntryGetPath failed";
    if ( ret != KERN_SUCCESS ) {
//        NSLog(@"IORegistryEntryGetPath failed");
        return nil;
    }
    NSString* returnValue = [NSString stringWithCString:path encoding:NSMacOSRomanStringEncoding];
    return returnValue;
}




-(NSMutableDictionary*)IORegistryEntryCreateCFProperties;
{
    CFMutableDictionaryRef propertiesTmp;
    IORegistryEntryCreateCFProperties(self.io_object, &propertiesTmp, kCFAllocatorDefault, kNilOptions);
    NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSMutableDictionary *)propertiesTmp];
    return properties;
}

-(NSDictionary*)IORegistryEntryCreateCFProperty_key:(NSString*)key;
{
    CFTypeRef t = IORegistryEntryCreateCFProperty(self.io_object, (__bridge CFStringRef)key, kCFAllocatorDefault, kNilOptions);
    NSDictionary* property = (__bridge_transfer NSDictionary *)t;
    return property;
}

//
//-(IOObjectT*)getTheOnlyChildNamed:(NSString*)childName
//{
//    IOObjectT* returnValue = 0;
//    IOIteratorT* childIterator = 0;
//    IOObjectT* child = 0;
//    
//    childIterator = [self childIterator];
//
//    while ( (child = [childIterator next]) )
//    {  
////NSLog(@"Device name is :  %@\n",[self getNodeName:child]);
//        if ( [childName isEqualToString:[child name]] ) {
//            if ( returnValue == 0 ) {
//                returnValue = child;
//            }else {
//                @throw @"image-path exists twice in IORegistry";
//            }
//        }
//    }
//    return returnValue;
//}
//
//-(IOObjectT*)getTheOnlyChildNamed_T:(NSString*)childName
//{
//    IOObjectT* returnValue = [self getTheOnlyChildNamed:childName];
//    if ( returnValue == 0 ) {
//        @throw [NSString stringWithFormat:@"Object %@ doesn't have a child %@", [self name], childName];
//    }
//    return returnValue;
//}
//
//-(IOObjectT*)getTheOnlyChild
//{
//    IOObjectT* returnValue = 0;
//    IOIteratorT* childIterator = 0;
//    IOObjectT* child = 0;
//    
//    childIterator = [self childIterator];
//
//    while ( (child = [childIterator next]) )
//    {  
////NSLog(@"Device name is :  %@\n",[self getNodeName:child]);
//        if ( returnValue == 0 ) {
//            returnValue = child;
//        }else {
//            @throw [NSString stringWithFormat:@"Node %@ has 2 childs", [self name]];
//        }
//    }
//    return returnValue;
//}

@end


