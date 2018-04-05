#import <Foundation/Foundation.h>

@interface Section : NSObject

@property (assign, nonatomic) NSInteger         sectionNumber;
@property (strong, nonatomic) NSMutableArray    *itemsArray;

@end
