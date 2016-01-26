//
//  ImageViewController.m
//  DecoCamera
//
//  Created by tgaiacontentsdev on 2016/01/14.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "ImageViewController.h"
#import <CoreImage/CoreImage.h>

@interface ImageViewController ()


@property(weak,nonatomic) IBOutlet UISlider *sl;
@property(weak,nonatomic) IBOutlet UIButton *grayButton;
@property(assign,nonatomic) BOOL isGray;
@property(nonatomic)NSNumber *number;

-(IBAction)saveButtonAction:(id)sender;
-(IBAction)grayButtonAction:(id)sender;
-(IBAction)backButtonaction:(id)sender;
-(IBAction)sliderAction:(id)sender;

@end

@implementation ImageViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
//ここから拡大縮小
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.5f;    // 最小拡大率
    _scrollView.maximumZoomScale = 3.0f;    // 最大拡大率
    _scrollView.zoomScale = 1.0f;

  
    _imageView.image = self.editImage; //"self.imageView.image="を書き換え
    self.isGray = NO;
    
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateImageCenter];
}

/**
 * ScrollViewの拡大縮小終了時に呼び出される
 */
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale
{
    [self updateImageCenter];
}

- (void)updateImageCenter
{
    // 画像の表示サイズを取得
    CGSize imageSize = self.imageView.image.size;
    imageSize.width *= self.scrollView.zoomScale;
    imageSize.height *= self.scrollView.zoomScale;
    
    // サブスクロールビューのサイズを取得
    CGRect  bounds = self.scrollView.bounds;
    
    // イメージビューの中央の座標を計算
    CGPoint point;
    point.x = imageSize.width / 2;
    if (imageSize.width < bounds.size.width) {
        point.x += (bounds.size.width - imageSize.width) / 2;
    }
    point.y = imageSize.height / 2;
    if (imageSize.height < bounds.size.height) {
        point.y += (bounds.size.height - imageSize.height) / 2;
    }
    self.imageView.center = point;
}

//ここまで拡大縮小



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveButtonAction:(id)sender{
   
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    
    //ここから
   
    UIGraphicsBeginImageContextWithOptions(_scrollView.bounds.size,YES,[UIScreen mainScreen].scale);
    
    CGPoint offset=_scrollView.contentOffset;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
    
    [_scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *scrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
   // self.imageView.image = scrollViewImage;

    //ここまで
    
    UIImageWriteToSavedPhotosAlbum(scrollViewImage, self, selector, NULL);
    
}

-(void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存終了" message:@"画像を保存しました" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)grayButtonAction:(id)sender{

    self.isGray = !self.isGray;
    self.imageView.image = [self glayfilter];
    
}

-(UIImage *)glayfilter{
    
    
    if (self.isGray) {
        [self.grayButton setTitle:@"Reset" forState:UIControlStateNormal];
        
        UIImage *image = self.editImage;
        CGRect imageRect = (CGRect){0.0,0.0,image.size.width,image.size.height};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        
        CGContextDrawImage(context, imageRect, [image CGImage]);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        UIImage *grayScaleImage = [UIImage imageWithCGImage:imageRef];
        
        //メモリ解放
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CFRelease(imageRef);
        
        return  grayScaleImage;
        
    }else{
        
        self.grayButton.titleLabel.text = @"Gray";
        [self.grayButton setTitle:@"Gray" forState:UIControlStateNormal];
        
        return  self.editImage;
    }
    
}

-(IBAction)backButtonaction:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)sliderAction:(UISlider*)sender{

     _number =[NSNumber numberWithFloat:sender.value];
   
    
  //  NSLog(@"%@",_number);
    
   
    self.imageView.image = [self brightFilter];
    
}

-(UIImage *)brightFilter{
    
    
     //UIImageViewからUIImageを取得
    UIImage *image = [self glayfilter];

    //UIImageをCIImageに
    CIImage *ciImage =[[CIImage alloc]initWithImage:image];
    
    
    //フィルター
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputBrightnessKey,_number,kCIInputImageKey,ciImage, nil ];
    
    
   // [filter setDefaults];
    
    
    
    ciImage = filter.outputImage;
    
    //CIimageをUIImageに
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:[ciImage extent]];
    
    
   // UIImage *finalImage = [UIImage imageWithCIImage:ciImage];
  /*  UIImage *finalImage = [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(ciImage) scale:1.0f orientation:UIImageOrientationUp];*/
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    
    return finalImage;
    
    //self.imageView.image = finalImage;
    
    
    
    
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
