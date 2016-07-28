//
//  MBProgressHUD+ODM.m
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 7. 28..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import "MBProgressHUD+ODM.h"

@implementation MBProgressHUD (ODM)
+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.labelText = title;
    return hud;
}

+ (void)dismissGlobalHUD {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
}
@end
