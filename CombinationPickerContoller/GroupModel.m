//
//  Group.m
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 24..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel

- (id)initForTitle : (NSString *)title
      firstAlasset : (UIImage *) asset
        photoCount : (NSInteger) count {
    self = [super init];
    if(self) {
        _title = title;
        _asset = asset;
        _photoCount = count;
    }
    return self;
}


@end
