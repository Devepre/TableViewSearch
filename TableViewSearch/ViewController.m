#import "ViewController.h"
#import "NSString+Random.h"
#import "NSString+DateString.h"
#import "Student.h"
#import "Section.h"

typedef NS_ENUM(NSInteger, StudentSortOption) {
    StudentSortOptionBirthDate,
    StudentSortOptionName,
    StudentSortOptionSurbame,
};

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray        *studentsArray;
@property (strong, nonatomic) NSArray<Section *>    *sectionsArray;
@property (strong, nonatomic) NSOperation           *operation;
@property (strong, nonatomic) NSOperationQueue      *operationQueue;
@property (assign, nonatomic) StudentSortOption     sortOption;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSInteger sizeArray = 50;
    self.studentsArray = [[NSMutableArray alloc] initWithCapacity:sizeArray];
    for (int i = 0; i < sizeArray; i++) {
        [self.studentsArray addObject:[[Student alloc] init]];
    }
    
    StudentSortOption sortOption = StudentSortOptionBirthDate;
    [self sortStudentsArrayByOption:sortOption];
    self.sectionsArray = [self generateSectionsFromArray:self.studentsArray withFilter:nil byOption:sortOption];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.sectionsArray objectAtIndex:section] itemsArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"studentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
   
    Student *student = [[[self.sectionsArray objectAtIndex:indexPath.section] itemsArray] objectAtIndex:indexPath.row];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", [student fullName], [NSString dateWithString:student.birthDate]];
    cell.textLabel.text = text;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *result = [[self.sectionsArray objectAtIndex:section] sectionName];
    return result;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:self.sectionsArray.count];
    for (int i = 0; i < self.sectionsArray.count; i++) {
        NSString *title = [[self.sectionsArray objectAtIndex:i] sectionName];
        [temp addObject: title];
    }
    
    return [NSArray arrayWithArray:temp];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self generateSectionsInBackgroundFromArray:self.studentsArray
                                     withFilter:self.searchBar.text
                                       byOption:self.sortOption
                                completionBlock:^{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.tableView reloadData];
                                    });
                                }];
}

#pragma mark - Additional Methods
- (NSArray*) generateSectionsFromArray:(NSArray<Student *> *)arrayStudents withFilter:filterString byOption:(StudentSortOption)option{
    NSMutableArray *sectionsArray = [NSMutableArray array];

    NSString *currentLetter = nil;
    
    switch (option) {
        case 0:
            for (Student *student in arrayStudents) {
                if (filterString && [filterString length] > 0 && [student.fullName rangeOfString:filterString].location == NSNotFound) {
                    continue;
                }
                
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:student.birthDate];
                NSInteger currentMonth = [components month];
                
                Section *currentSection = [self getSectionForNumber:(NSInteger)currentMonth inSectionsArray:sectionsArray];
                if (currentSection) {
                    [currentSection.itemsArray addObject:student];
                } else {
                    currentSection = [[Section alloc] init];
                    currentSection.sectionNumber = currentMonth;
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.locale = [NSLocale currentLocale];
                    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(currentMonth - 1)];
                    
                    currentSection.sectionName = monthName;
                    [currentSection.itemsArray addObject:student];
                    [sectionsArray addObject:currentSection];
                }
                
            }
            break;
        case 1:
            for (int i = 0; i < arrayStudents.count; i++) {
                NSString *string = [[arrayStudents objectAtIndex:i] name];
                if (filterString && [filterString length] > 0 && [string rangeOfString:filterString].location == NSNotFound) {
                    continue;
                }
                NSString *firstLetter = [string substringToIndex:1];
                Section *section = nil;
                if (![currentLetter isEqualToString:firstLetter]) {
                    section = [[Section alloc] init];
                    section.sectionName = firstLetter;
                    section.itemsArray = [NSMutableArray array];
                    currentLetter = firstLetter;
                    [sectionsArray addObject:section];
                } else {
                    section = [sectionsArray lastObject];
                }
                [section.itemsArray addObject:[arrayStudents objectAtIndex:i]];
            }
            break;
        case 2:
            for (int i = 0; i < arrayStudents.count; i++) {
                NSString *string = [[arrayStudents objectAtIndex:i] surname];
                if (filterString && [filterString length] > 0 && [string rangeOfString:filterString].location == NSNotFound) {
                    continue;
                }
                NSString *firstLetter = [string substringToIndex:1];
                Section *section = nil;
                if (![currentLetter isEqualToString:firstLetter]) {
                    section = [[Section alloc] init];
                    section.sectionName = firstLetter;
                    section.itemsArray = [NSMutableArray array];
                    currentLetter = firstLetter;
                    [sectionsArray addObject:section];
                } else {
                    section = [sectionsArray lastObject];
                }
                [section.itemsArray addObject:[arrayStudents objectAtIndex:i]];
            }
            break;
        default:
            break;
    }
    
    return sectionsArray;
}

- (Section *)getSectionForNumber:(NSInteger)number inSectionsArray:sectionsArray{
    for (Section *section in sectionsArray) {
        if (section.sectionNumber == number) {
            return section;
        }
    }
    
    return nil;
}

- (void)sortStudentsArrayByOption:(StudentSortOption)option {
    NSSortDescriptor *monthDescriptor = [NSSortDescriptor
                                         sortDescriptorWithKey:@"birthDate"
                                         ascending:YES
                                         comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                             NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:obj1 ];
                                             NSInteger currentMonth1 = [components month];
                                             components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:obj2];
                                             NSInteger currentMonth2 = [components month];
                                             return currentMonth1 - currentMonth2;
                                         }];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *surnameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"surname" ascending:YES];
    
    switch (option) {
        case StudentSortOptionBirthDate:
            [self.studentsArray sortUsingDescriptors:@[monthDescriptor, nameDescriptor, surnameDescriptor]];
            break;
        case StudentSortOptionName:
            [self.studentsArray sortUsingDescriptors:@[nameDescriptor, surnameDescriptor, monthDescriptor]];
            break;
        case StudentSortOptionSurbame:
            [self.studentsArray sortUsingDescriptors:@[surnameDescriptor, monthDescriptor, nameDescriptor]];
            break;
        default:
            break;
    }
    
}

- (void)generateSectionsInBackgroundFromArray:(NSArray<Student *> *)studentsArray withFilter:(NSString *)filterString byOption:(StudentSortOption)option completionBlock:(void (^)(void))completionBlock {
    [self.operationQueue cancelAllOperations];                  //Cancelling the operations is asynchronous since an in-progress op may take a little while to finish up.
    [self.operationQueue waitUntilAllOperationsAreFinished];    //Need to wait untill cancel will finish
    
    __weak ViewController* weakSelf = self;
    self.operation = [NSBlockOperation blockOperationWithBlock:^{
        [self sortStudentsArrayByOption:option];
        self.sectionsArray = [weakSelf generateSectionsFromArray:self.studentsArray withFilter:filterString byOption:option];
        completionBlock();
        self.operation = nil;
    }];
    
    [self.operationQueue addOperation:self.operation];
}

#pragma mark - Actions
- (IBAction)actionSearchControl:(UISegmentedControl *)sender {
    NSLog(@"%ld", (long)sender.selectedSegmentIndex);
    self.sortOption = sender.selectedSegmentIndex;
    [self sortStudentsArrayByOption:sender.selectedSegmentIndex];
    self.sectionsArray = [self generateSectionsFromArray:self.studentsArray withFilter:self.searchBar.text byOption:sender.selectedSegmentIndex];
    [self.tableView reloadData];
}

@end
