//
//  ODMTableViewCell.h
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 23..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupModel.h"
#import <Photos/Photos.h>

@interface ODMTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *firstPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupPhotoCountLabel;

- (void)setCell : (GroupModel *)model;
- (void)setImageView : (PHAssetCollection *)collection;
@end
