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
#import <Photos/Photos.h>


@interface ODMCombinationPickerViewController ()<ODMGroupViewControllerDelegate>

@property (nonatomic, strong) ODMGroupViewController *groupViewController;
@property (nonatomic) BOOL showOrHide; //show :1 hide : 0
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

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
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serialQueue = dispatch_queue_create("sessionUploadQueue", NULL);
    });
    
    _images = [NSMutableArray new];
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
    
    [self getCameraRollPhoto];
    
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
    userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
    
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [self viewForAuthorizationStatus];
        if(idx == 0) {
            [self.groups addObject:@"Camera Roll"];
        }
        [self.groups addObject:collection];
    }];
    
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
    return [_photos count];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ODMCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionBorderWidth = self.selectionBorderWidth ? self.selectionBorderWidth : cell.selectionBorderWidth;
    cell.selectionHighlightColor = self.selectionHighlightColor ? self.selectionHighlightColor :cell.selectionHighlightColor;
    
    if([_images count] > indexPath.row) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isSelected = [indexPath isEqual:currentSelectedIndex];
            BOOL isDeselectedShouldAnimate = currentSelectedIndex == nil && [indexPath isEqual:previousSelectedIndex];
            
            [cell setHightlightBackground:isSelected withAimate:isDeselectedShouldAnimate];
        });
//        cell.imageView.image=_images[indexPath.row];
        int k =0;
        for(NSDictionary *dic in _images) {
            if([[[dic allKeys] firstObject] longValue] == indexPath.row) {
               cell.imageView.image = [[dic allValues] firstObject];
                break;
            }
            k++;
        }
        
    }
    else {
        [self getImageForAsset:_photos[indexPath.row] andTargetSize:CGSizeMake(300, 300) andSuccessBlock:^(UIImage *photoObj)
        {
            
            [_images addObject:@{[NSNumber numberWithLong:indexPath.row]:photoObj}];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image=photoObj;
                BOOL isSelected = [indexPath isEqual:currentSelectedIndex];
                BOOL isDeselectedShouldAnimate = currentSelectedIndex == nil && [indexPath isEqual:previousSelectedIndex];
                
                [cell setHightlightBackground:isSelected withAimate:isDeselectedShouldAnimate];
            });
        }];
    }
    
    
    
    
    
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
    
    if(previousSelectedIndex) {
        [self.collectionView reloadItemsAtIndexPaths:@[previousSelectedIndex]];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    
    
    
    [self checkDoneButton];
}

- (void)changeGroup:(id)sender {
    
    //    GroupModel *model = (GroupModel *)sender;
    if([sender isKindOfClass:[PHAssetCollection class]]) {
        [self getPhotosWithCollection:sender];
        PHAssetCollection *collection = sender;
        [self setNavigationTitle:collection.localizedTitle];
        currentSelectedIndex = nil;
        [self showGroupView];
    }
    else {
        [self getCameraRollPhoto];
        [self.collectionView reloadData];
        [self setNavigationTitle:@"Camera Roll"];
        currentSelectedIndex = nil;
        [self showGroupView];
    }
    
}


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
    
    
    if(!self.groupViewController) {
        self.groupViewController = [[ODMGroupViewController alloc] init];
        self.groupViewController.delegate = self;
        [self.view addSubview:self.groupViewController.view];
        [self.view bringSubviewToFront:self.navigationView];
    }
    [self showGroupView];
    
    self.groupViewController.groups = _groups;
    [self.groupViewController.tableView reloadData];
    
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
        self.didFinishPickingAsset(self, self.photos[currentSelectedIndex.row]);
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAsset:)]) {
        
        [self.delegate imagePickerController:self didFinishPickingAsset:self.photos[currentSelectedIndex.row]];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    PHAsset *asset =  _photos[currentSelectedIndex.row];
    if(self.didFinishPickingAsset) {
        self.didFinishPickingAsset(self, asset);
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAsset:)]) {
        [self.delegate imagePickerController:self didFinishPickingAsset:asset];
    }
    
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

-(void) getImageForAsset: (PHAsset *) asset andTargetSize: (CGSize) targetSize andSuccessBlock:(void (^)(UIImage * photoObj))successBlock {
    

    
    dispatch_async(_serialQueue, ^{
        
        PHImageRequestOptions *requestOptions;
        
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        requestOptions.synchronous = true;
        requestOptions.networkAccessAllowed = YES;
        NSLog(@"슈발바랍라발바랍ㄹ");
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset
                           targetSize:targetSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            @autoreleasepool {
                                if(image!=nil){
                                    successBlock(image);
                                }
                            }
                        }];
    });
    
}

- (CGRect)view:(UIView *)view setYPostion :(CGFloat)postion {
    CGRect frame = view.frame;
    frame.origin.y = postion;
    
    return frame;
}

- (void)getCameraRollPhoto {
    _photos = [NSMutableArray new];
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    if(_nextDate) {
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i AND creationDate > %@", PHAssetMediaTypeImage, _nextDate];
    }
    else {
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    }
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *photo = obj;
        if(_havePlaceData) {
            if(photo.location) {
                [_photos addObject:photo];
            }
        }
        else {
            [_photos addObject:photo];
        }
        if(idx == [result count]-1) {
            [self.collectionView reloadData];
            [MBProgressHUD dismissGlobalHUD];
        }

    }];
}

- (void)getPhotosWithCollection : (PHAssetCollection *)collection {
    _photos = [NSMutableArray new];
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    if(_nextDate) {
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i AND creationDate > %@", PHAssetMediaTypeImage, _nextDate];
    }
    else {
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    }

    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:allPhotosOptions];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *photo = obj;
        if(_havePlaceData) {
            if(photo.location) {
                [_photos addObject:photo];
            }
        }
        else {
            [_photos addObject:photo];
        }
        if(idx == [result count]-1) {
            [self.collectionView reloadData];
            [MBProgressHUD dismissGlobalHUD];
        }
    }];
}


@end
