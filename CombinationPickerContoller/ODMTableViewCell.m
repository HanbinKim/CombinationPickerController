//
//  ODMTableViewCell.m
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 23..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import "ODMTableViewCell.h"
#import <AssetsLibrary/ALAsset.h>

@implementation ODMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell : (GroupModel *)model {
    [_firstPhotoImageView setImage:model.asset];
    _groupNameLabel.text = model.title;
    _groupPhotoCountLabel.text = [NSString stringWithFormat:@"%ld",model.photoCount];
}

@end
