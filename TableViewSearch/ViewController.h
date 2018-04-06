#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar            *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *sortingControl;

@end

