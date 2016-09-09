//
//  ODMTableViewCell.m
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 6. 23..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import "ODMTableViewCell.h"
#import <Photos/Photos.h>

@implementation ODMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell : (PHAssetCollection *)collection {
    _groupNameLabel.text = collection.localizedTitle;
    if(collection) {
        [self setImageView:collection];
    }
}

- (void)setImageView : (PHAssetCollection *)collection{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *fetchResult;
    if(collection == nil) {
        fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    }
    else {
        fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions];
    }
    
    PHAsset *asset = [fetchResult firstObject];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        PHImageRequestOptions *requestOptions;
        
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        requestOptions.synchronous = true;
        requestOptions.networkAccessAllowed = YES;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset
                           targetSize:CGSizeMake(40, 40)
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            @autoreleasepool {
                                if(image!=nil){
                                    _firstPhotoImageView.image = image;
                                }
                            }
                        }];
    });
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.resizeMode = PHImageRequestOptionsResizeModeExact;
//    
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGFloat dimension = 78.0f;
//    CGSize size = CGSizeMake(dimension*scale, dimension*scale);
//    
//    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
//        _firstPhotoImageView.image = result;
//    }];
}



@end
