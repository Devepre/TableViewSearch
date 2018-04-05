#import "Student.h"
#import "NSString+Random.h"

@implementation Student

- (instancetype)init {
    NSString *name = [[NSString randomAlphanumericString] capitalizedString];
    NSString *surname = [[NSString randomAlphanumericString] capitalizedString];
    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:arc4random() % 2000000];
    self = [self initWithName:name
                   andSurname:surname
                 andBirthDate:birthDate];
    return self;
}

- (instancetype)initWithName:(NSString *)name andSurname:(NSString *)surname andBirthDate:(NSDate *)birthDate {
    self = [super init];
    if (self) {
        self.name = name;
        self.surname = surname;
        self.birthDate = birthDate;
    }
    return self;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.name, self.surname];
}

@end
