//
//  IOReg.h
//  IOJones
//
//  Created by PHPdev32 on 3/13/13.
//  Licensed under GPLv3, full text at http://www.gnu.org/licenses/gpl-3.0.txt
//

@class Document;

#import "IORegNode.h"


@interface IORegRoot : IORegNode

@property (readonly) bool isLoaded;
-(instancetype)initWithNode:(IORegObj *)root on:(NSString *)plane;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary on:(NSMapTable *)table;
-(void)filter:(NSString *)filter;

@end
