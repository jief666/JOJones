//
//  IOReg.h
//  IOJones
//
//  Created by PHPdev32 on 3/13/13.
//  Licensed under GPLv3, full text at http://www.gnu.org/licenses/gpl-3.0.txt
//

@class Document;


@interface IORegProperty : NSObject

@property NSString *key;
@property NSArray *children;
@property (readonly) NSInteger type, subtype;
@property (readonly) NSString *typeString, *description, *metaData, *briefDescription;
@property (readonly) NSColor *descriptionColor;
@property (readonly) NSFont *descriptionFont;
@property (readonly) NSDictionary *dictionaryRepresentation;

+(NSArray *)arrayWithDictionary:(NSDictionary *)dictionary;

@end
