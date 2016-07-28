//
//  ODMViewController.m
//  CombinationPickerContoller
//
//  Created by allfake on 7/30/14.
//  Copyright (c) 2014 Opendream. All rights reserved.
//

#import "ODMCombinationPickerViewController.h"
#import "ODMCollectionViewCell.h"
#import "KxMenu.h"
#import "ODMGroupViewController.h"
#import "GroupModel.h"
#import "MBProgressHUD+ODM.h"


@interface ODMCombinationPickerViewController ()<ODMGroupViewControllerDelegate>

@property (nonatomic, strong) ODMGroupViewController *groupViewController;
@property (nonatomic) BOOL showOrHide; //show :1 hide : 0

@end

@implementation ODMCombinationPickerViewController

- (id)initWithCombinationPickerNib
{
    self = [super initWithNibName:@"ODMCombinationPickerViewController" bundle:nil];
    self.showCameraButton = YES;
    return self;
}

- (id)initWithCombinationPickerNibShowingCameraButton:(BOOL)showCameraButton
{
    self = [super initWithNibName:@"ODMCombinationPickerViewController" bundle:nil];
    self.showCameraButton = showCameraButton;
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [MBProgressHUD showGlobalProgressHUDWithTitle:nil];
    if (self.cameraImage == nil) {
        self.cameraImage = [UIImage imageNamed:@"camera-icon"];
    }
    
    UINib *cellNib = [UINib nibWithNibName:
                      NSStringFromClass([ODMCollectionViewCell class])
                                    bundle:nil];
    
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:CellIdentifier];
    
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [self.assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            if(_nextDate != nil) {
                if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
                    NSDateFormatter *dateFormatter = [NSDateFormatter new];
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                    NSDate *compareDate = [result valueForProperty:ALAssetPropertyDate];
                    
                    
                    if([[dateFormatter stringFromDate:_nextDate] integerValue] < [[dateFormatter
                                                                                   stringFromDate:compareDate] integerValue]) {
                        [self.assets insertObject:result atIndex:0];
                    }
                }
            }
            else if(_havePlaceData) {
                if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
                    [self.assets insertObject:result atIndex:0];
                }
            }
            else {
                if([result valueForProperty:ALAssetTypePhoto]) {
                    [self.assets insertObject:result atIndex:0];
                }
            }
        }
        
        if ([self.assetsGroup numberOfAssets] - 1 == index) {
            
            [self.collectionView reloadData];
            if(_nextDate) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.assets count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }
            [MBProgressHUD dismissGlobalHUD];
            
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        [self viewForAuthorizationStatus];
        
        NSLog(@"%@",group);
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                
                self.assetsGroup = group;
                
                if (self.assets.count == 0) {
                    
                    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
                    
                    [self addImageFirstRow];
                    
                }
                
                [self setNavigationTitle:[group valueForProperty:ALAssetsGroupPropertyName]];
                
                [self.groups insertObject:group atIndex:0];
                
            }
//            else if([[group valueForProperty:ALAssetsGroupPropertyType] intValue] != ALAssetsGroupPhotoStream){
                [self.groups addObject:group];
//            }
        }
        
        
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;
    
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        [self viewForAuthorizationStatus];
    }];
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    
    [self checkDoneButton];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!previousBarStyle) {
        previousBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    }
    
    isHideNavigationbar = self.navigationController.isNavigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self fadeStatusBar];
    [self setLightStatusBar];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self reStoreNavigationBar];
    [self fadeStatusBar];
    [self setBackStatusBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewForAuthorizationStatus
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status == ALAuthorizationStatusAuthorized || status == ALAuthorizationStatusNotDetermined) {
        [self.requestPermisstionView setHidden:YES];
    } else {
        [self.requestPermisstionView setHidden:NO];
    }
    
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = (CGRectGetWidth([[UIScreen mainScreen] bounds]) - 10)/3;
    CGSize cellSize = CGSizeMake(width, width);
    return cellSize;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ODMCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionBorderWidth = self.selectionBorderWidth ? self.selectionBorderWidth : cell.selectionBorderWidth;
    cell.selectionHighlightColor = self.selectionHighlightColor ? self.selectionHighlightColor :cell.selectionHighlightColor;
    
    ALAsset *asset;
    CGImageRef thumbnailImageRef;
    UIImage *thumbnail;
    
    if ([self.assets[indexPath.row] isKindOfClass:[UIImage class]]) {
        
        thumbnail = self.assets[indexPath.row];
        
    } else {
        
        asset = self.assets[indexPath.row];
        thumbnailImageRef = [asset aspectRatioThumbnail];
        if (thumbnailImageRef == nil) {
            thumbnailImageRef = [asset thumbnail];
        }
        thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        
    }
    
    cell.imageView.image = thumbnail;
    
    BOOL isSelected = [indexPath isEqual:currentSelectedIndex];
    BOOL isDeselectedShouldAnimate = currentSelectedIndex == nil && [indexPath isEqual:previousSelectedIndex];
    
    [cell setHightlightBackground:isSelected withAimate:isDeselectedShouldAnimate];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && self.showCameraButton == YES) {
        
        previousSelectedIndex = nil;
        currentSelectedIndex = nil;
        
        if (self.cameraController != nil) {
            
            id delegate;
            if ([self.cameraController valueForKey:@"delegate"]) {
                delegate = [self.cameraController valueForKey:@"delegate"];
            }
            
            NSData *tempArchiveViewController = [NSKeyedArchiver archivedDataWithRootObject:self.cameraController];
            UIViewController *cameraVC = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchiveViewController];
            
            if (delegate && delegate != nil) {
                [cameraVC setValue:delegate forKey:@"delegate"];
            }
            
            [self presentViewController:cameraVC animated:YES completion:NULL];
        } else {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
        
    } else {
        
        previousSelectedIndex = currentSelectedIndex;
        
        if ([currentSelectedIndex isEqual:indexPath] ) {
            
            currentSelectedIndex = nil;
            
        } else {
            
            currentSelectedIndex = indexPath;
            
        }
        
    }
    
    [self.collectionView reloadData];

    [self checkDoneButton];
}

- (void)changeGroup:(id)sender {
    GroupModel *model = (GroupModel *)sender;
        for (ALAssetsGroup *group in self.groups) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[model title]]) {
                self.assetsGroup = group;
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
    
                    if (result) {
                        if(_nextDate != nil) {
                            if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
                                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                [dateFormatter setDateFormat:@"yyyyMMdd"];
                                NSDate *compareDate = [result valueForProperty:ALAssetPropertyDate];
    
                                if([[dateFormatter stringFromDate:_nextDate] integerValue] < [[dateFormatter
                                    stringFromDate:compareDate] integerValue]) {
                                    [self.assets insertObject:result atIndex:0];
                                }
                            }
                        }
                        else if(_havePlaceData) {
                            if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
                                [self.assets insertObject:result atIndex:0];
                            }
                        }
                        else {
                            if([result valueForProperty:ALAssetTypePhoto]) {
                                [self.assets insertObject:result atIndex:0];
                            }
                        }
                    }
                };
    
                if (!self.assets) {
                    _assets = [[NSMutableArray alloc] init];
                } else {
                    [self.assets removeAllObjects];
                }
    
                [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
                [self addImageFirstRow];
    
                [self.collectionView reloadData];
                if(_nextDate) {
                    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.assets count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }
                
                
                [self setNavigationTitle:[model title]];
            }
        }
        
        currentSelectedIndex = nil;
    [self showGroupView];
}

//- (void)changeGroup:(KxMenuItem *)menu
//{
//    for (ALAssetsGroup *group in self.groups) {
//        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[menu title]]) {
//            self.assetsGroup = group;
//            
//            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                
//                if (result) {
//                    if(_nextDate != nil) {
//                        if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
//                            NSDateFormatter *dateFormatter = [NSDateFormatter new];
//                            [dateFormatter setDateFormat:@"yyyyMMdd"];
//                            NSDate *compareDate = [result valueForProperty:ALAssetPropertyDate];
//                            
//                            
//                            if([[dateFormatter stringFromDate:_nextDate] integerValue] < [[dateFormatter
//                                stringFromDate:compareDate] integerValue]) {
//                                [self.assets insertObject:result atIndex:0];
//                            }
//                        }
//                    }
//                    else if(_havePlaceData) {
//                        if([result valueForProperty:ALAssetTypePhoto] && [result valueForProperty:ALAssetPropertyLocation] != nil) {
//                            [self.assets insertObject:result atIndex:0];
//                        }
//                    }
//                    else {
//                        if([result valueForProperty:ALAssetTypePhoto]) {
//                            [self.assets insertObject:result atIndex:0];
//                        }
//                    }
//                }
//            };
//            
//            if (!self.assets) {
//                _assets = [[NSMutableArray alloc] init];
//            } else {
//                [self.assets removeAllObjects];
//            }
//            
//            [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
//            
//            [self addImageFirstRow];
//            
//            [self.collectionView reloadData];
//            
//            [self setNavigationTitle:[menu title]];
//        }
//    }
//    
//    currentSelectedIndex = nil;
//}
//

- (void)addImageFirstRow
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && self.showCameraButton == YES) {
        
        [self.assets insertObject:self.cameraImage atIndex:0];
        
    }
}

- (void)setNavigationTitle:(NSString *)title
{
    [self.navagationTitleButton setTitle:[NSString stringWithFormat:@"%@ ▾", title] forState:UIControlStateNormal];
    
}

- (void)checkDoneButton
{
    if (currentSelectedIndex != nil) {
        
        [self.doneButton setEnabled:YES];
        
    } else {
        
        [self.doneButton setEnabled:NO];
        
    }
}

#pragma mark - action

- (IBAction)showMenu:(UIView *)sender
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    
    if(!self.groupViewController) {
        self.groupViewController = [[ODMGroupViewController alloc] init];
        self.groupViewController.delegate = self;
        [self.view addSubview:self.groupViewController.view];
        [self.view bringSubviewToFront:self.navigationView];
    }
    [self showGroupView];
    

    __block ALAsset *asset;
    for (ALAssetsGroup *group in self.groups) {
        
//        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
////            if(!asset) {
//                asset = result;
////            }
//            if(index == 1) {
//                *stop = YES;
//            }
//            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
//            NSLog(@"%@ggggg@",image);
//
//        }];
        NSLog(@"%@",[UIImage imageWithCGImage:[group posterImage]]);
        GroupModel *model = [[GroupModel alloc] initForTitle:[group valueForProperty:ALAssetsGroupPropertyName] firstAlasset:[UIImage imageWithCGImage:[group posterImage]] photoCount:group.numberOfAssets];
        [menuItems addObject:model];
    }
    //
    //        [menuItems addObject:[KxMenuItem menuItem:[group valueForProperty:ALAssetsGroupPropertyName]
    //                                            image:nil
    //                                           target:self
    //                                           action:@selector(changeGroup:)]];
    
    self.groupViewController.groups = menuItems;
    [self.groupViewController.tableView reloadData];
    
//
//    if (menuItems.count) {
//        [KxMenu showMenuInView:self.view
//                      fromRect:sender.frame
//                     menuItems:menuItems];
//    }
}

- (void)showGroupView {
    
    if(_showOrHide) {
        self.groupViewController.view.frame = [self view:self.groupViewController.view setYPostion:64];
        [UIView animateWithDuration:0.5 animations:^{
            self.groupViewController.view.frame = [self view:self.groupViewController.view setYPostion:-660];
        }];
    }
    else {
        self.groupViewController.view.frame = [self view:self.groupViewController.view setYPostion:-660];
        [UIView animateWithDuration:0.5 animations:^{
            self.groupViewController.view.frame = [self view:self.groupViewController.view setYPostion:64];
        }];
        
    }
    _showOrHide = !_showOrHide;
}


- (IBAction)done:(id)sender
{
    if(self.didFinishPickingAsset) {
        self.didFinishPickingAsset(self, self.assets[currentSelectedIndex.row]);
    }

    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAsset:)]) {
        
        [self.delegate imagePickerController:self didFinishPickingAsset:self.assets[currentSelectedIndex.row]];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:originImage.CGImage
                                 metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              
                              [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {

                                  if(self.didFinishPickingAsset) {
                                      self.didFinishPickingAsset(self, asset);
                                  }

                                  if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAsset:)]) {
                                      [self.delegate imagePickerController:self didFinishPickingAsset:asset];
                                  }
                                  
                              } failureBlock:^(NSError *error) {
                                  
                                  NSLog(@"error couldn't get photo");
                                  
                              }];
                              
                          }];
}

- (IBAction)cancel:(id)sender
{
    if(self.didCancel) {
        self.didCancel(self);
    }

    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

#pragma mark - Status bar

- (void)fadeStatusBar
{
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        previousStatusBarIsHidden = YES;
        // need to animate
        //        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)setLightStatusBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setBackStatusBar
{
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        
        if(previousStatusBarIsHidden) [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [[UIApplication sharedApplication] setStatusBarStyle:previousBarStyle];
        [self setNeedsStatusBarAppearanceUpdate];
        
    }
}

- (void)reStoreNavigationBar
{
    [self.navigationController setNavigationBarHidden:isHideNavigationbar animated:NO];
}

#pragma mark - Fuction

- (CGRect)view:(UIView *)view setYPostion :(CGFloat)postion {
    CGRect frame = view.frame;
    frame.origin.y = postion;
    
    return frame;
}


@end
