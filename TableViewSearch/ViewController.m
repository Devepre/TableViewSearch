#import "ViewController.h"
#import "NSString+Random.h"
#import "NSString+DateString.h"
#import "Student.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *studentsArray;

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"studentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
   
    Student *student = [self.studentsArray objectAtIndex:indexPath.row];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", [student fullName], [NSString dateWithString:student.birthDate]];
    cell.textLabel.text = text;
    
    return cell;
}

@end
