//
//  CBPViewController.m
//  CBPWordPressExample
//
//  Created by Karl Monaghan on 29/03/2014.
//  Copyright (c) 2014 Crayons and Brown Paper. All rights reserved.
//

#import "NSString+HTML.h"

#import "CBPViewController.h"
#import "CBPPostViewController.h"

#import "CBPWordPressDataSource.h"

#import "CBPLargePostPreviewTableViewCell.h"

@interface CBPViewController () <UITableViewDelegate>
@property (nonatomic) CBPLargePostPreviewTableViewCell *heightMeasuringCell;
@property (strong, nonatomic) CBPWordPressDataSource *dataSource;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation CBPViewController

- (void)loadView
{
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                  style:UITableViewStylePlain];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.dataSource = [CBPWordPressDataSource new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = CBPLargePostPreviewTableViewCellHeight;
    self.tableView.estimatedRowHeight = CBPLargePostPreviewTableViewCellHeight;
    
    [self.tableView registerClass:[CBPLargePostPreviewTableViewCell class] forCellReuseIdentifier:CBPLargePostPreviewTableViewCellIdentifier];
    
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)load
{
    __weak typeof(self) blockSelf = self;
    
    [self.dataSource loadWithBlock:^(BOOL result, NSError *error){
        if (result) {
            [blockSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
/**
 * Adapted from https://github.com/smileyborg/TableViewCellWithAutoLayout/blob/master/TableViewCellWithAutoLayout/TableViewController/RJTableViewController.m
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.heightMeasuringCell) {
        self.heightMeasuringCell = [CBPLargePostPreviewTableViewCell new];
    
        // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        [self.heightMeasuringCell setNeedsUpdateConstraints];
        [self.heightMeasuringCell updateConstraintsIfNeeded];
    }
    
    CBPWordPressPost *post = self.dataSource.posts[indexPath.row];
    
    self.heightMeasuringCell.postTitle = [post.title kv_decodeHTMLCharacterEntities];
    self.heightMeasuringCell.imageURI = post.thumbnail;
    self.heightMeasuringCell.postDate = post.date;
    self.heightMeasuringCell.commentCount = post.commentCount;
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    self.heightMeasuringCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.heightMeasuringCell.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [self.heightMeasuringCell setNeedsLayout];
    [self.heightMeasuringCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [self.heightMeasuringCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    if (height < CBPLargePostPreviewTableViewCellHeight) {
        height = CBPLargePostPreviewTableViewCellHeight;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPPostViewController *vc = [[CBPPostViewController alloc] initWithPost:self.dataSource.posts[indexPath.row]];
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
