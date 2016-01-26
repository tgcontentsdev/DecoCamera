//
//  ImageViewController.h
//  DecoCamera
//
//  Created by tgaiacontentsdev on 2016/01/14.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "ViewController.h"

@interface ImageViewController : UIViewController<UIScrollViewDelegate>


@property(weak,nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak,nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) UIImage *editImage;


@end
