//
//  Group.h
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 24..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>

@interface GroupModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *asset;
@property (nonatomic) NSInteger photoCount;

- (id)initForTitle : (NSString *)title
      firstAlasset : (UIImage *) asset
        photoCount : (NSInteger) count;

@end
