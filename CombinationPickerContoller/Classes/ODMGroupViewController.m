//
//  ODMGroupViewController.m
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 24..
//  Copyright © 2016년 Opendream. All rights reserved.
//

static NSString *CellIdentifier = @"groupCell";

#import "ODMGroupViewController.h"
#import "ODMTableViewCell.h"

@interface ODMGroupViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ODMGroupViewController

- (id)init {
    self = [super initWithNibName:@"ODMGroupViewController" bundle:nil];
    
    
    if(!self) {
        return nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.estimatedRowHeight = 100;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_groups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ODMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ODMTableViewCell" owner:self options:nil][0];
    }
    [cell setCell:_groups[indexPath.row]];
    
    
    return cell;
}

#pragma mark - Table View Delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate changeGroup:_groups[indexPath.row]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
