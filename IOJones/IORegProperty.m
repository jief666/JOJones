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

@implementation IORegProperty {
    @private
    id _value;
    NSInteger _type, _subtype;
}

static NSUInteger boolType, dictType, arrType, dataType, strType, numType, dateType;

+(void)load {
    boolType = CFBooleanGetTypeID();
    dictType = CFDictionaryGetTypeID();
    arrType = CFArrayGetTypeID();
    dataType = CFDataGetTypeID();
    strType = CFStringGetTypeID();
    numType = CFNumberGetTypeID();
    dateType = CFDateGetTypeID();
}

+(NSArray *)arrayWithDictionary:(NSDictionary *)dictionary {
    NSMutableArray *properties = [NSMutableArray array];
    for (NSString *key in dictionary)
        [properties addObject:[[IORegProperty alloc] initWithValue:[dictionary objectForKey:key] forKey:key]];
    return [properties copy];
}
-(instancetype)initWithValue:(id)value forKey:(id)key {
    self = [super init];
    if (self) {
        _key = [key copy];
        _type = CFGetTypeID((__bridge CFTypeRef)value);
        if (_type == dictType && [value count]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSString *str in value)
                [array addObject:[[IORegProperty alloc] initWithValue:[value objectForKey:str] forKey:str]];
            _children = [array copy];
        }
        else if (_type == arrType && [value count]) {
            NSMutableArray *array = [NSMutableArray array];
            NSUInteger i = 0;
            for (id obj in value)
                [array addObject:[[IORegProperty alloc] initWithValue:obj forKey:@(i++)]];
            _children = [array copy];
        }
        else _value = value;
        if (_type == dataType) _subtype = [_value isTextual] ? [[_value macromanStrings] count] : -1;
        else if (_type == numType) _subtype = [_value nSize];
    }
    return self;
}

-(NSDictionary *)dictionaryRepresentation {
    if (_type == dictType)
        return _children.count?[NSDictionary dictionaryWithObjects:[_children valueForKey:@"dictionaryRepresentation"] forKeys:[_children valueForKey:@"key"]]:@{};
    else if (_type == arrType)
        return _children.count?[_children valueForKey:@"dictionaryRepresentation"]:@[];
    return _value;
}
-(NSString *)description {
    if (_type == boolType) return [_value boolValue]?@"True":@"False";
    else if (_type == dictType || _type == arrType)
        return [NSString stringWithFormat:@"%ld value%s", _children.count, _children.count==1?"":"s"];
    else if (_type == numType)
        return [NSString stringWithFormat:@"0x%llx", [_value longLongValue]];
    else if (_type == dataType) {
        if (_subtype > 0) return [NSString stringWithFormat:@"<\"%@\">", [[_value macromanStrings] componentsJoinedByString:@"\",\""]];
        else return [_value groupedDescription:2];
    }
    else return [_value description];
}
-(NSColor *)descriptionColor {
    return _type == dictType || _type == arrType?NSColor.grayColor:NSColor.blackColor;
}
-(NSFont *)descriptionFont {
    return _type == dataType && _subtype <= 0?[NSFont userFixedPitchFontOfSize:NSFont.smallSystemFontSize-1]:[NSFont systemFontOfSize:NSFont.smallSystemFontSize];
}
-(NSString *)briefDescription {
    if (_type == boolType) return [_value boolValue]?@"True":@"False";
    else if (_type == dictType || _type == arrType)
        return [NSString stringWithFormat:@"%@ of %ld value%s", self.typeString, _children.count, _children.count==1?"":"s"];
    else if (_type == numType)
        return [NSString stringWithFormat:@"0x%llx", [_value longLongValue]];
    else if (_type == dataType)
        return [NSString stringWithFormat:@"Data of %ld byte%s", [_value length], [_value length]==1?"":"s"];
    else return [_value description];
}
-(NSString *)metaData {
    if (_type == strType) return @"NUL-terminated ASCII string";
    else if (_type == dataType) {
        if (_subtype == 1) return [NSString stringWithFormat:@"%ld bytes interpreted as a string in MacRoman encoding", [_value length]];
        else if (_subtype > 1) return [NSString stringWithFormat:@"%ld bytes interpreted as %ld strings in MacRoman encoding", [_value length], _subtype];
        else return [NSString stringWithFormat:@"%ld byte%s autoformatted as hexadecimal bytes in host byte order", [_value length], [_value length]==1?"":"s"];
    }
    else if (_type == numType) return [NSString stringWithFormat:@"%ld-byte number interpreted in native byte order", _subtype];
    else return nil;
}
-(NSInteger)type {
    return _type;
}
-(NSInteger)subtype {
    return _subtype;
}
-(NSString *)typeString{
    if (_type == boolType) return @"Boolean";
    else if (_type == dictType) return @"Dictionary";
    else if (_type == strType) return @"String";
    else if (_type == arrType) return @"Array";
    else if (_type == numType) return @"Number";
    else if (_type == dataType) return @"Data";
    else if (_type == dateType) return @"Date";
    else return @"Unknown";
}

@end
