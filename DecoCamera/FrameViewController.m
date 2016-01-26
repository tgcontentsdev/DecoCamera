//
//  FrameViewController.m
//  DecoCamera
//
//  Created by tgaiacontentsdev on 2016/01/14.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "FrameViewController.h"
#import "ImageViewController.h"


@interface FrameViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(weak,nonatomic)IBOutlet UICollectionView *frameCollectionView;

@property(strong,nonatomic)NSArray *frameArray;
@property(strong,nonatomic)UIImage *editImage;

@end

@implementation FrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.frameArray = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.frameArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    NSString *imgName = [NSString stringWithFormat:@"frame_%02ld.png",(long)[self.frameArray[indexPath.row]integerValue]];
    
    UIImage *image = [UIImage imageNamed:imgName];
    imageView.image = image;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //カメラ判定
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //生成
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        imagePickerController.delegate = self;
        
        
        //写真モードに
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;

        
        //ずれ防止
        imagePickerController.cameraViewTransform = CGAffineTransformTranslate(imagePickerController.cameraViewTransform, 0, 50);
        
        
        
        //正方形に
        CGRect rect = imagePickerController.view.bounds;
        rect.size.height -= imagePickerController.navigationBar.bounds.size.height;
        CGFloat barHeight = (rect.size.height - rect.size.width) / 2;
        UIGraphicsBeginImageContext(rect.size);
        [[UIColor colorWithWhite:0 alpha:1]set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, rect.size.width, barHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, rect.size.height - barHeight, rect.size.width, barHeight / 1.48), kCGBlendModeNormal);
        UIImage *rimImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //土台作成
        UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        
        //画面を隠す準備
        UIImageView *rimView = [[UIImageView alloc]initWithFrame:rect];
        rimView.image = rimImage;
        [baseView addSubview:rimView];
        
        //フレーム準備
        NSString *imgName = [NSString stringWithFormat:@"frame_%02ld.png",(long)[self.frameArray[indexPath.row]integerValue]];
        UIImageView *frameView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imgName]];
        frameView.frame = (CGRect){0,barHeight,rect.size.width,rect.size.width};
        
        [baseView addSubview:frameView];
        
        //フレーム置く
        [imagePickerController setCameraOverlayView:baseView];
        
        //カメラ呼び出し
         [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //キャプチャ対象をWindowに
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //キャプチャの作業場所を生成
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //windowの表示内容を作業場所へ
    for (UIWindow *aWindow in [UIApplication sharedApplication].windows) {
        [aWindow.layer renderInContext:context];
    }
    
    //描画内容受取
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //描画終了
    UIGraphicsEndImageContext();
    
    //写真部分の切り取り
    CGRect rect = picker.view.bounds;
    rect.size.height -= picker.navigationBar.bounds.size.height;
    CGFloat barHeight = (rect.size.height - rect.size.width) /2;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    
    //画像描画
    [capturedImage drawAtPoint:CGPointMake(0, -barHeight)];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.editImage = capturedImage;
    [self performSegueWithIdentifier:@"ImageView" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ImageView"]) {
        ImageViewController *nextViewController = [segue destinationViewController];
        
        nextViewController.editImage = self.editImage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
