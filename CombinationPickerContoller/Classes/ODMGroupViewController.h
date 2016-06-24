//
//  ODMGroupViewController.h
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 24..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ODMGroupViewControllerDelegate <NSObject>

- (void) changeGroup : (id)sender;

@end

@interface ODMGroupViewController : UIViewController



@property (nonatomic, strong) NSArray *groups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) id<ODMGroupViewControllerDelegate> delegate;

@end
