//
//  ODMViewController.m
//  CombinationPickerContoller
//
//  Created by allfake on 7/31/14.
//  Copyright (c) 2014 Opendream. All rights reserved.
//

#import "ODMViewController.h"
#import <Photos/Photos.h>

@interface ODMViewController ()

@end

@implementation ODMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"pickerSegue"]) {
        
        ODMCombinationPickerViewController *vc = [segue destinationViewController];
        [vc setDelegate:self];
        
    }

}

#pragma mark - delegate

- (void)imagePickerControllerDidCancel:(ODMCombinationPickerViewController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerController:(ODMCombinationPickerViewController *)picker didFinishPickingAsset:(PHAsset *)phasset
{
    [self getImageForAsset:phasset andTargetSize:CGSizeMake(200, 200) andSuccessBlock:^(UIImage *photoObj) {
        self.selectedImageView.image = photoObj;
    }];
//    
//    ALAssetRepresentation *rep = [asset defaultRepresentation];
//    CGImageRef iref = [rep fullResolutionImage];
//    
//    self.selectedImageView.image = [UIImage imageWithCGImage:iref];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)click:(id)sender
{
    ODMCombinationPickerViewController *vc = [[ODMCombinationPickerViewController alloc] initWithCombinationPickerNib];
    [vc setDelegate:self];

    [self presentViewController:vc animated:YES completion:nil];
}

-(void) getImageForAsset: (PHAsset *) asset andTargetSize: (CGSize) targetSize andSuccessBlock:(void (^)(UIImage * photoObj))successBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *requestOptions;
        
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        requestOptions.synchronous = true;
        requestOptions.networkAccessAllowed = YES;
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



@end
