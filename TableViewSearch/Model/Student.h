#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) NSString  *surname;
@property (strong, nonatomic) NSDate    *birthDate;

- (instancetype)initWithName:(NSString *)name andSurname:(NSString *)surname andBirthDate:(NSDate *)birthDate NS_DESIGNATED_INITIALIZER;
- (NSString *)fullName;

@end
