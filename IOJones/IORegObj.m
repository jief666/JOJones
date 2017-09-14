//
//  IOReg.m
//  IOJones
//
//  Created by PHPdev32 on 3/13/13.
//  Licensed under GPLv3, full text at http://www.gnu.org/licenses/gpl-3.0.txt
//

#import "IORegNode.h"
#import "IORegRoot.h"
#import "IORegObj.h"
#import "IORegProperty.h"

#import "IOObjectT.h"
#import "IOIteratorT.h"

#import "Document.h"
#import "Base.h"
#import "IOKitLibPrivate.h"
#include <mach/mach.h>

@implementation IORegObj {
    @private
    NSHashTable *_nodes;
}
static NSArray *systemPlanes;
static NSString *systemName, *systemType;
static NSDictionary *red, *green;

+(void)load
{
    red = @{NSForegroundColorAttributeName:[NSColor redColor], NSStrikethroughStyleAttributeName:@1};
    green = @{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:0 green:0.75 blue:0 alpha:1], NSUnderlineStyleAttributeName:@1};
    struct host_basic_info info;
    UInt32 size = sizeof(struct host_basic_info);
    char *type, *subtype;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&info, &size);
    systemName = [NSHost.currentHost localizedName];
    slot_name(info.cpu_type, info.cpu_subtype, &type, &subtype);
    systemType = [NSString stringWithCString:type encoding:NSMacOSRomanStringEncoding];
//    io_registry_entry_t root = IORegistryGetRootEntry(kIOMasterPortDefault);
    IOObjectT* root = [IOObjectT IORegistryGetRootEntry];
    NSMutableArray *planes = [NSMutableArray array];
//    for (NSString *plane in [(__bridge_transfer NSDictionary *)IORegistryEntryCreateCFProperty(root, CFSTR("IORegistryPlanes"), kCFAllocatorDefault, 0) allValues]) {
    for (NSString *plane in [[root IORegistryEntryCreateCFProperty_key:@"IORegistryPlanes"] allValues]) {
        if ([plane isEqualToString:@kIOServicePlane]) [planes insertObject:plane atIndex:0];
        else [planes addObject:plane];
    }
    systemPlanes = [planes copy];
//    IOObjectRelease(root);
}
+(NSArray *)systemPlanes {
    return systemPlanes;
}
+(NSString *)systemName {
    return systemName;
}
+(NSString *)systemType {
    return systemType;
}

-(instancetype)initWithEntry:(IOObjectT*)entryT for:(Document *)document
{
    //io_registry_entry_t entry = entryT.io_object;
    self = [super init];
    if (self) {
        _added = [NSDate date];
        _nodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsOpaqueMemory];
        _document = document;
//        io_name_t globalname = {};
//        IORegistryEntryGetName(entry, globalname);
//        _name = [NSString stringWithCString:globalname encoding:NSMacOSRomanStringEncoding];
        _name = [entryT name];
//        IOObjectGetClass(entry, globalname);
//        _ioclass = [NSString stringWithCString:globalname encoding:NSMacOSRomanStringEncoding];
        _ioclass = [entryT IOObjectGetClass];
//        _kernel = IOObjectGetKernelRetainCount(entry) - 1;
//        _user = IOObjectGetUserRetainCount(entry) - 1;
        _kernel = [entryT IOObjectGetKernelRetainCount] - 1;
        _user = [entryT IOObjectGetUserRetainCount] - 1;
//        uint64_t entryid = 0;
//        IORegistryEntryGetRegistryEntryID(entry, &entryid);
//        _entryID = entryid;
        _entryID = [entryT IORegistryEntryGetRegistryEntryID];
        uint64_t state = 0;
        uint32_t busy = 0;
//        CFMutableDictionaryRef properties;
//        IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0);
//        _properties = [IORegProperty arrayWithDictionary:(__bridge_transfer NSMutableDictionary *)properties];
        _properties = [IORegProperty arrayWithDictionary:[entryT IORegistryEntryCreateCFProperties]];
        NSMutableDictionary *planes = [NSMutableDictionary dictionary];
        for (NSString *plane in systemPlanes) {
//            if (!IORegistryEntryInPlane(entry, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding])) continue;
            if (![entryT IORegistryEntryInPlane_plane:plane]) continue;
            if ([plane isEqualToString:@kIOServicePlane]) {
//                IOServiceGetState(entry, &state);
//                IOServiceGetBusyState(entry, &busy);
                state = [entryT IOServiceGetState];
                busy = [entryT IOServiceGetBusyState];
            }
//            io_name_t location = {}, name = {};
//            io_string_t path = {};
//            IORegistryEntryGetLocationInPlane(entryT.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], location);
//            IORegistryEntryGetNameInPlane(entryT.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], name);
//            IORegistryEntryGetPath(entryT.io_object, [plane cStringUsingEncoding:NSMacOSRomanStringEncoding], path);
//            [planes setObject:@{@"name":[NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding], @"location":[NSString stringWithCString:location encoding:NSMacOSRomanStringEncoding], @"path":[NSString stringWithCString:path encoding:NSMacOSRomanStringEncoding]} forKey:plane];
            NSString* location;
            NSString* name;
            NSString* path;
            location = [entryT IORegistryEntryGetLocationInPlane_plane:plane];
            if ( !location ) location = [[NSString alloc] init];
            name = [entryT IORegistryEntryGetNameInPlane_plane:plane];
            if ( !name ) name = [[NSString alloc] init];
            path = [entryT IORegistryEntryGetPath_plane:plane];
            if ( !path ) path = [[NSString alloc] init];
            [planes setObject:@{@"name":name, @"location":location, @"path":path} forKey:plane];
        }
        _busy = busy;
        _state = state;
        _planes = [planes copy];
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary for:(Document *)document {
    self = [super init];
    if (self) {
        _document = document;
        _ioclass = [dictionary objectForKey:@"class"];
        _added = [dictionary objectForKey:@"added"];
        _removed = [dictionary objectForKey:@"removed"];
        _name = [dictionary objectForKey:@"name"];
        _status = [[dictionary objectForKey:@"status"] intValue];
        _state = [[dictionary objectForKey:@"state"] longLongValue];
        _busy = [[dictionary objectForKey:@"busy"] longLongValue];
        _kernel = [[dictionary objectForKey:@"kernel"] longLongValue];
        _user = [[dictionary objectForKey:@"user"] longLongValue];
        _entryID = [[dictionary objectForKey:@"id"] longLongValue];
        _planes = [dictionary objectForKey:@"planes"];
        _properties = [IORegProperty arrayWithDictionary:[dictionary objectForKey:@"properties"]];
    }
    return self;
}
-(void)addProperties:(NSSet *)objects {
    muteWithNotice(self, properties, _properties = [self.properties arrayByAddingObjectsFromArray:objects.allObjects]);
}
-(void)registerNode:(IORegNode *)node;
{
    [_nodes addObject:node];
}
-(NSSet *)registeredNodes {
    return _nodes.setRepresentation;
}

-(NSDictionary *)dictionaryRepresentation {
    if (_removed)
        return @{@"class":_ioclass, @"added":_added, @"removed":_removed, @"name":_name, @"status":@(_status), @"state":@(_state), @"busy":@(_busy), @"kernel":@(_kernel), @"user":@(_user), @"id":@(_entryID), @"properties":[NSDictionary dictionaryWithObjects:[_properties valueForKey:@"dictionaryRepresentation"] forKeys:[_properties valueForKey:@"key"]], @"planes":_planes};
    return @{@"class":_ioclass, @"added":_added, @"name":_name, @"status":@(_status), @"state":@(_state), @"busy":@(_busy), @"kernel":@(_kernel), @"user":@(_user), @"id":@(_entryID), @"properties":[NSDictionary dictionaryWithObjects:[_properties valueForKey:@"dictionaryRepresentation"] forKeys:[_properties valueForKey:@"key"]], @"planes":_planes};
}
-(NSArray *)classChain {
    NSArray *chain;
    if ((chain = [_document.allClasses chainForKey:_ioclass]))
        return chain;
    NSMutableArray *temp = [NSMutableArray arrayWithObject:_ioclass];
    NSString *superclass, *class = _ioclass;
    while (![_document.allClasses objectForKey:class] && (superclass = (__bridge_transfer NSString *)IOObjectCopySuperclassForClass((__bridge CFStringRef)class)))
        if ((class = [_document.allClasses setObject:superclass forKey:class]) == superclass)
            [temp addObject:class];
        else
            break;
    [temp addObjectsFromArray:[_document.allClasses chainForKey:class]];
    return [temp copy];
}
-(NSString *)bundle {
    NSString *bundle;
    if ((bundle = [_document.allBundles objectForEquivalentKey:_ioclass])) return bundle;
    bundle = (__bridge_transfer NSString *)IOObjectCopyBundleIdentifierForClass((__bridge CFStringRef)_ioclass);
    return [_document.allBundles setObject:[bundle isEqualToString:@"__kernel__"]?[_document.allBundles objectForKey:@"OSObject"]:bundle forKey:_ioclass];
}
-(NSArray *)paths {
    return [_planes.allValues valueForKeyPath:@"path"];
}
-(NSArray *)sortedPaths {
    NSString *plane = _document.selectedPlane.plane;
    NSMutableArray *paths = [self.paths mutableCopy];
    if (paths.count > 1) {
        for (NSString *path in paths)
            if ([path hasPrefix:plane]) {
                [paths removeObject:path];
                [paths insertObject:path atIndex:0];
                break;
            }
    }
    return [paths copy];
}
-(NSString *)currentName {
    NSDictionary *plane;
    NSString *planeName;
    if ((plane = [_planes objectForKey:_document.selectedPlane.plane]) && (planeName = [plane objectForKey:@"name"])) {
        NSString *location;
        if ((location = [plane objectForKey:@"location"]).length)
            return [NSString stringWithFormat:@"%@@%@", planeName, location];
        else return planeName;
    }
    else return _name;
}
+(NSSet *)keyPathsForValuesAffectingDisplayName {
    return [NSSet setWithObjects:@"status", nil];
}
-(id)displayName {
    switch (_status) {
        case IORegStatusInitial: return self.currentName;
        case IORegStatusPublished: return [[NSAttributedString alloc] initWithString:self.currentName attributes:green];
        case IORegStatusTerminated: return [[NSAttributedString alloc] initWithString:self.currentName attributes:red];
    }
}
-(bool)isActive {
    return (_state & kIOServiceInactiveState) == 0;
}
-(bool)isRegistered {
    return (_state & kIOServiceRegisteredState) != 0;
}
-(bool)isMatched {
    return (_state & kIOServiceMatchedState) != 0;
}
-(bool)isService {
    return ![_ioclass isEqualToString:@"IORegistryEntry"];
}
-(NSString *)filteredProperty {
    NSString *property = [[NSUserDefaults.standardUserDefaults dictionaryForKey:@"find"] objectForKey:@"property"];
    for (IORegProperty *obj in _properties)
        if ([obj.key isEqualToString:property])
            return obj.briefDescription;
    return nil;
}

@end
