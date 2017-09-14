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

@implementation IORegRoot {
    @private
    NSMutableArray *_pleated;
}
static NSPredicate *filterBlock;

+(void)load {
    filterBlock = [NSPredicate predicateWithBlock:^BOOL(IORegNode* evaluatedIORegNode, NSDictionary *bindings){
        IORegObj* evaluatedObject = [evaluatedIORegNode node];
        NSString *value = [bindings objectForKey:@"value"];
        for (NSString *key in [bindings objectForKey:@"keys"]) {
            if ([key isEqualToString:@"name"]) {
                if ([[evaluatedObject name] rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound)
                    return true;
            }
            else if ([key isEqualToString:@"bundle"])
            {
                if ([[(IORegObj *)evaluatedObject bundle] rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound)
                    return true;
            }
            else if ([key isEqualToString:@"class"]) {
                if ([[evaluatedObject ioclass] rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound)
                    return true;
            }
            else if ([key isEqualToString:@"inheritance"]) {
                if ([[evaluatedObject classChain] containsRange:value])
                    return true;
            }
            else if ([key isEqualToString:@"keys"]) {
                if ([[[evaluatedObject properties] valueForKey:@"key"] containsRange:value])
                return true;
            }
            else if ([key isEqualToString:@"values"]) {
//NSLog(@"%@", evaluatedObject.name);
if ( [evaluatedObject isKindOfClass:IORegObj.class] &&  [ evaluatedObject.name isEqualToString:@"IOHDIXHDDriveOutKernel"] ) {
    NSLog(@"break");
}
                NSArray* prop = [evaluatedObject properties];
                NSArray* prop2 = [prop valueForKey:@"value"];
                if ([prop2 containsRange:value]) {
                    return true;
                }
                for (IORegProperty* p in prop) {
                    if ( p.type == 18 ) {
//                        for (
                        if ( [[p.children valueForKey:@"value"] containsRange:value] ) {
                            return true;
                        }
                    }
                }
            }
            else if ([key isEqualToString:@"state"])
            {
                if ([evaluatedObject isActive]) {
                    if ([@"Active" rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound) return true;
                }
                else if ([evaluatedObject isRegistered]) {
                    if ([@"Registered" rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound) return true;
                }
                else if ([evaluatedObject isMatched]) {
                    if ([@"Matched" rangeOfString:value options:NSCaseInsensitiveSearch].location != NSNotFound) return true;
                }
            }
        }
        return false;
    }];
}

-(instancetype)initWithNode:(IORegObj *)root on:(NSString *)plane{
    self = [super init];
    if (self) {
        self.node = root;
        self.plane = plane;
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary on:(NSMapTable *)table {
    self = [super init];
    if (self) {
        self.node = (__bridge IORegObj *)(NSMapGet(table, (void *)[[dictionary objectForKey:@"root"] longLongValue]));
        self.plane = [dictionary objectForKey:@"plane"];
        if ([[dictionary objectForKey:@"children"] count]) {
            self.children = [NSMutableArray array];
            for (NSDictionary *ioreg in [dictionary objectForKey:@"children"])
                [self.children addObject:[[IORegNode alloc] initWithDictionary:ioreg on:self]];
        }
    }
    return self;
}
-(void)filter:(NSString *)filter {
    if (filter.length) {
        NSDictionary *bindings = @{@"value":filter, @"keys":[[[NSUserDefaults.standardUserDefaults dictionaryForKey:@"find"] keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop){
            return [obj boolValue] && ![key isEqualToString:@"property"] && ![key isEqualToString:@"showAll"];
        }] allObjects]};
        self.children = [[[self.flat objectsPassingTest:^BOOL(IORegNode * obj, BOOL *stop){
            return [filterBlock evaluateWithObject:obj substitutionVariables:bindings];
        }] allObjects] mutableCopy];
    }
    else if (_pleated) self.children = _pleated;
}
-(NSDictionary *)dictionaryRepresentation {
    return @{@"root":@(self.node.entryID), @"plane":self.plane, @"children":[_pleated valueForKey:@"dictionaryRepresentation"]};
}
-(NSMutableArray *)children{
    if (![super children]) {
        _pleated = super.children = [NSMutableArray array];
        [self mutate];
    }
    else if (!_pleated) _pleated = super.children;
    return [super children];
}
-(NSMutableSet *)flat {//TODO: cache for speed, invalidate on notification
    NSMutableSet *flat = [NSMutableSet setWithObject:self];
    for (IORegNode *child in _pleated) [flat unionSet:child.flat];
    return flat;
}
-(bool)isLoaded {
    return (_pleated);
}
-(void)mutate
{
    IOIteratorT* it = [IOIteratorT IORegistryCreateIterator_plane:self.plane];
//    io_iterator_t it;
//    IORegistryCreateIterator(kIOMasterPortDefault, [self.plane cStringUsingEncoding:NSMacOSRomanStringEncoding], 0, &it);
    [self walk:it];
//    IOObjectRelease(it);
}

@end
