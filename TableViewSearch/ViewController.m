#import "ViewController.h"
#import "NSString+Random.h"
#import "NSString+DateString.h"
#import "Student.h"
#import "Section.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray        *studentsArray;
@property (strong, nonatomic) NSArray<Section *>    *sectionsArray;
@property (strong, nonatomic) NSOperation           *operation;
@property (strong, nonatomic) NSOperationQueue      *operationQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSInteger sizeArray = 50000;
    self.studentsArray = [[NSMutableArray alloc] initWithCapacity:sizeArray];
    for (int i = 0; i < sizeArray; i++) {
        [self.studentsArray addObject:[[Student alloc] init]];
    }
    
    [self sortStudentsArray];
    self.sectionsArray = [self generateSectionsFromArray:self.studentsArray withFilter:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [NSString stringWithFormat:@"%ld", (long)[[self.sectionsArray objectAtIndex:section] sectionNumber]];
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:self.sectionsArray.count];
    for (int i = 0; i < self.sectionsArray.count; i++) {
        NSInteger intNum = [[self.sectionsArray objectAtIndex:i] sectionNumber];
        [temp addObject: [NSString stringWithFormat:@"%ld", intNum]];
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
                                completionBlock:^{
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.tableView reloadData];
                                    });
                                }];
}

#pragma mark - Additional Methods
- (NSArray*) generateSectionsFromArray:(NSArray<Student *> *)arrayStudents withFilter:filterString{
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
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
            [currentSection.itemsArray addObject:student];
            [sectionsArray addObject:currentSection];
        }
        
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

- (void)sortStudentsArray {
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
    [self.studentsArray sortUsingDescriptors:@[monthDescriptor, nameDescriptor, surnameDescriptor]];
}

- (void)generateSectionsInBackgroundFromArray:studentsArray withFilter:filterString completionBlock:(void (^)(void))completionBlock {
    [self.operationQueue cancelAllOperations];                  //Cancelling the operations is asynchronous since an in-progress op may take a little while to finish up.
    [self.operationQueue waitUntilAllOperationsAreFinished];    //Need to wait untill cancel will finish
    
    __weak ViewController* weakSelf = self;
    self.operation = [NSBlockOperation blockOperationWithBlock:^{
        [self sortStudentsArray];
        self.sectionsArray = [weakSelf generateSectionsFromArray:self.studentsArray withFilter:filterString];
        completionBlock();
        self.operation = nil;
    }];
    
    [self.operationQueue addOperation:self.operation];
}

@end
