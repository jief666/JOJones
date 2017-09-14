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


@implementation IORegNode
//static NSDateFormatter *dateFormatter;
//static NSPredicate *hideBlock;

@synthesize node = _node;

//+(void)load{
//    dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//    hideBlock = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
//        return [[evaluatedObject node] status] != IORegStatusTerminated;
//    }];
//}

+(NSDateFormatter*)dateFormatter;
{
  static NSDateFormatter *dateFormatter = nil;
    if ( !dateFormatter ) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

+(NSPredicate*)hideBlock;
{
static NSPredicate *hideBlock = nil;
    if ( !hideBlock ) {
        hideBlock = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            return [[evaluatedObject node] status] != IORegStatusTerminated;
        }];
    }
    return hideBlock;
}

-(instancetype)initWithNode:(IORegObj *)node on:(IORegNode *)parent{
    self = [super init];
    if (self) {
        _node = node;
        _plane = parent.plane;
        _parent = parent;
        if (parent.children) [parent.children addObject:self];
        else parent.children = [NSMutableArray arrayWithObject:self];
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary on:(IORegNode *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _plane = parent.plane;
        _node = (__bridge IORegObj *)(NSMapGet(parent.node.document.allObjects, (void *)[[dictionary objectForKey:@"node"] longLongValue]));
        if ([[dictionary objectForKey:@"children"] count]) {
            _children = [NSMutableArray array];
            for (NSDictionary *ioreg in [dictionary objectForKey:@"children"])
                [_children addObject:[[IORegNode alloc] initWithDictionary:ioreg on:self]];
        }
    }
    return self;
}
-(void)setNode:(IORegObj *)aNode {
    [aNode registerNode:self];
    _node = aNode;
}
-(IORegObj *)node {
    return _node;
}
-(NSMutableArray *)children {
    return _node.document.hiding?[[_children filteredArrayUsingPredicate:[IORegNode hideBlock]] mutableCopy]:_children;
}
-(NSDictionary *)dictionaryRepresentation {
    return _children.count
    ? @{@"node":@(_node.entryID), @"children": [_children valueForKey:@"dictionaryRepresentation"]}
    : @{@"node":@(_node.entryID)};
}
-(NSIndexPath *)indexPath {
    NSUInteger length = 1, index = 0;
    IORegNode *node = self;
    while (![node isKindOfClass:IORegRoot.class] && length++)
        node = node->_parent;
    NSUInteger indexes[(index = length)];
    node = self;
    while (index > 0) {
        indexes[--index]=[node->_parent->_children indexOfObject:node];
        node = node->_parent;
    }
    return [NSIndexPath indexPathWithIndexes:indexes length:length];
}
-(NSMutableSet *)flat {
    NSMutableSet *flat = [NSMutableSet setWithObject:self];
    for (IORegNode *child in _children) [flat unionSet:child.flat];
    return flat;
}
-(NSString *)metaData {
    if (_node.status == IORegStatusTerminated)
        return [NSString stringWithFormat:@"%@\nDiscovered: %@\nTerminated: %@", _node.name, [[IORegNode dateFormatter] stringFromDate:_node.added], [[IORegNode dateFormatter] stringFromDate:_node.removed]];
    return [NSString stringWithFormat:@"%@\nDiscovered: %@", _node.name, [[IORegNode dateFormatter] stringFromDate:_node.added]];
}
-(void)walk:(IOIteratorT*)iterator
{
    IOObjectT* object;
    while ((object = iterator.IOIteratorNext))
    {
        bool stop = false;
        IORegObj *obj = [_node.document addObject:object];
        for (IORegNode *child in _children)
        {
            if (child.node == obj) {
                stop = true;
                break;
            }
        }
        if (stop) continue;
        IORegNode *child = [[IORegNode alloc] initWithNode:obj on:self];
        if ( [iterator IORegistryIteratorEnterEntry] == KERN_SUCCESS) [child walk:iterator];
    }
    [iterator IORegistryIteratorExitEntry];
}
-(void)mutate {
    IOObjectT* entry = [IOObjectT IOServiceGetMatchingService_entryID:_node.entryID];
    IOIteratorT* it = [entry IORegistryEntryCreateIterator_plane:self.plane];
    [self walk:it];

//    io_iterator_t it;
//    io_registry_entry_t entry = IOServiceGetMatchingService(kIOMasterPortDefault, IORegistryEntryIDMatching(_node.entryID));
//    IORegistryEntryCreateIterator(entry, [_plane cStringUsingEncoding:NSMacOSRomanStringEncoding], 0, &it);
//    [self walk:it];
//    IOObjectRelease(it);
}

@end
