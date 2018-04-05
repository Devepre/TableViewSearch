#import "ViewController.h"
#import "NSString+Random.h"
#import "NSString+DateString.h"
#import "Student.h"
#import "Section.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray        *studentsArray;
@property (strong, nonatomic) NSArray<Section *>    *sectionsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSInteger sizeArray = 50;
    self.studentsArray = [[NSMutableArray alloc] initWithCapacity:sizeArray];
    for (int i = 0; i < sizeArray; i++) {
        [self.studentsArray addObject:[[Student alloc] init]];
    }
    
    [self sortStudentsArray];
    self.sectionsArray = [self generateSectionsFromArray:self.studentsArray];
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

#pragma mark - Additional Methods
- (NSArray*) generateSectionsFromArray:(NSArray<Student *> *)arrayStudents {
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    for (Student *student in arrayStudents) {
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
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *surnameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"surname" ascending:YES];
    [self.studentsArray sortUsingDescriptors:@[nameDescriptor, surnameDescriptor]];
}

@end
