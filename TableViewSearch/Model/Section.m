#import "Section.h"

@implementation Section

- (instancetype)init
{
    self = [super init];
    if (self) {
        _itemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
