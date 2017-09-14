//
//  IOReg.h
//  IOJones
//
//  Created by PHPdev32 on 3/13/13.
//  Licensed under GPLv3, full text at http://www.gnu.org/licenses/gpl-3.0.txt
//

#import "IORegNode.h"
#import "IORegObj.h"

@class Document;
@class IOIteratorT;

@interface IORegNode : NSObject

@property (assign) IORegNode *parent;
@property IORegObj *node;
@property (nonatomic) NSMutableArray *children;
@property NSString *plane;
@property (readonly) NSIndexPath *indexPath;
@property (readonly) NSString *metaData;
@property (readonly) NSMutableSet *flat;
@property (readonly) NSDictionary *dictionaryRepresentation;

-(instancetype)initWithNode:(IORegObj *)node on:(IORegNode *)parent;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary on:(IORegNode *)parent;
-(void)mutate;
-(void)walk:(IOIteratorT*)iterator;

@end
