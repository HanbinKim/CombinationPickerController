//
//  MBProgressHUD+ODM.h
//  CombinationPickerContoller
//
//  Created by Han-binkim on 2016. 7. 28..
//  Copyright © 2016년 Opendream. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (ODM)

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title;
+ (void)dismissGlobalHUD;

@end
