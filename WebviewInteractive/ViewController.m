//
//  ViewController.m
//  WebviewInteractive
//
//  Created by 李金柱 on 16/4/18.
//  Copyright © 2016年 likeme. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIWebView *_webView;
    NSString  *_callback;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString*urlStr =[[NSBundle mainBundle]pathForResource:@"camera" ofType:@"html"];
    NSURL*url =[NSURL fileURLWithPath:urlStr];
    NSURLRequest*request  =[[NSURLRequest alloc]initWithURL:url];
    _webView =[[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate =self;
    [self.view addSubview:_webView];
    [_webView loadRequest:request];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView stringByEvaluatingJavaScriptFromString:jsString];

}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    
    NSString *requestString = [[request URL] absoluteString];
    NSString *protocol = @"js-call://"; //协议名称
    if ([requestString hasPrefix:protocol]) {
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if ([[vals objectAtIndex:0] isEqualToString:@"camera"]) { // 摄像头
            _callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypeCamera];
        } else if([[vals objectAtIndex:0] isEqualToString:@"photolibrary"]) { // 图库
            _callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypePhotoLibrary];
        } else if([[vals objectAtIndex:0] isEqualToString:@"album"]) { // 相册
            _callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }
        else {
            [webView stringByEvaluatingJavaScriptFromString:@"alert('未定义');"];
        }
        return NO;
    }
    return YES;
    
}
- (void)doAction:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        imagePicker.sourceType = sourceType;
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"照片获取失败" message:@"没有可用的照片来源" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    // iPad设备做额外处理
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        // 返回图片
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        // 设置并显示加载动画
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"正在处理图片..." message:@"\n\n"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:nil, nil];
        
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loading.center = CGPointMake(139.5, 75.5);
        [av addSubview:loading];
        [loading startAnimating];
        [av show];
        // 在后台线程处理图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // 这里可以对图片做一些处理，如调整大小等，否则图片过大显示在网页上时会造成内存警告
            NSString *base64 = [UIImagePNGRepresentation(originalImage) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]; // 图片转换成base64字符串
            [self performSelectorOnMainThread:@selector(doCallback:) withObject:base64 waitUntilDone:YES]; // 把结果显示在网页上
            [av dismissWithClickedButtonIndex:0 animated:YES]; // 关闭动画
        });
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)doCallback:(NSString *)data
{
    
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", _callback, data]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
