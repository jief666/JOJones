//
//  IOReg.h
//  IOJones
//
//  Created by PHPdev32 on 3/13/13.
//  Licensed under GPLv3, full text at http://www.gnu.org/licenses/gpl-3.0.txt
//

@class Document;

@class IORegNode;
@class IOObjectT;


@interface IORegObj : NSObject

@property (readonly) NSString *bundle, *currentName, *filteredProperty;
@property (readonly) NSArray *classChain, *paths, *sortedPaths;
@property (readonly) id displayName;
@property (readonly) NSDictionary *dictionaryRepresentation;
@property (readonly) bool isActive, isMatched, isRegistered, isService;
@property (readonly) NSSet *registeredNodes;
@property (assign) Document *document;
@property IORegStatus status;
@property NSString *ioclass, *name;
@property NSDate *added, *removed;
@property NSUInteger entryID;
@property NSUInteger kernel;
@property NSUInteger user;
@property NSUInteger busy;
@property NSUInteger state;
@property (readonly) NSArray *properties;
@property NSDictionary *planes;

-(instancetype)initWithEntry:(IOObjectT*)entry for:(Document *)document;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary for:(Document *)document;
+(NSArray *)systemPlanes;
+(NSString *)systemName;
+(NSString *)systemType;

-(void)addProperties:(NSSet *)objects;
-(void)registerNode:(IORegNode *)node;

@end
