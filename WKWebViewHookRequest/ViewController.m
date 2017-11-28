//
//  ViewController.m
//  WKWebViewHookRequest
//
//  Created by 梁宪松 on 2017/11/27.
//  Copyright © 2017年 madao. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "Constant.h"


@interface ViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong, readwrite) WKWebView *wkWebView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak, readwrite)IBOutlet UILabel *urlIndicatorLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect frame = self.view.frame;
    frame.origin.y += 64;
    frame.size.height -= frame.origin.y + 20;
    [self.wkWebView setFrame:frame];
    [self.view addSubview:self.wkWebView];
    
    self.navigationItem.titleView = self.indicatorView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:URLLoadingNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadURL:[NSURL URLWithString:@"http://www.jianshu.com/u/00be556128d1"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EventHandler

- (IBAction)goBack:(id)sender {
    if(self.wkWebView.canGoBack){
        [self.wkWebView goBack];
    }else
    {
        [self.wkWebView reload];
    }
}

- (IBAction)goFoward:(id)sender {
    if(self.wkWebView.canGoForward){
        [self.wkWebView goForward];
    }
}

- (IBAction)refresh:(id)sender {
     [self.wkWebView reload];
}

- (void)notificationHandler:(NSNotification *)notification
{
    NSString *obj = (NSString *)notification.object;
    if (obj && obj.length == 0){
        self.urlIndicatorLabel.text == @"";
    }else if(obj)
    {
        self.urlIndicatorLabel.text = [NSString stringWithFormat:@"URL : %@", obj];
    }
}

#pragma mark - Public Methods
- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    
    //若需要限制只允许某些前缀的scheme通过请求，则取消下述注释，并在数组内添加自己需要放行的前缀
    //    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https",@"file"]];
    //    return ![validSchemes containsObject:URL.scheme];
    
    return !URL;
}

- (void)loadURL:(NSURL *)URL {
    
    [self.wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:URL]];
}

- (void)alertInfo: (NSString *)info{
    if (nil == info){
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"来自madao的通知" message:info delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Getter
- (WKWebView *)wkWebView
{
    if (!_wkWebView){
        _wkWebView = [[WKWebView alloc] init];
        _wkWebView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [_wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_wkWebView setNavigationDelegate:self];
        [_wkWebView setUIDelegate:self];
        [_wkWebView setMultipleTouchEnabled:YES];
        [_wkWebView setAutoresizesSubviews:YES];
        [_wkWebView setAllowsBackForwardNavigationGestures:YES];
        [_wkWebView.scrollView setAlwaysBounceVertical:YES];
    }
    return _wkWebView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView setHidesWhenStopped:YES];
    }
    return _indicatorView;
}


@end


@implementation ViewController(WKUIDelegate)
#pragma mark - WKUIDelegate

///
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
@end


@implementation ViewController(WKNavigationDelegate)
#pragma mark - WKNavigationDelegate
/// 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [self.indicatorView startAnimating];
}

/// 页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self.indicatorView stopAnimating];
}

/// 加载错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    
    [self alertInfo:error.localizedDescription];
    [self.indicatorView stopAnimating];
}

/// 导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    
    [self alertInfo:error.localizedDescription];
    [self.indicatorView stopAnimating];
}

/// 收到响应后是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 接收到服务器跳转请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if(webView == self.wkWebView) {
        NSURL *URL = navigationAction.request.URL;
        if(![self externalAppRequiredToOpenURL:URL]) {
            if(!navigationAction.targetFrame) {
                [self loadURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
            [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
        }else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType {
    
    // 自定义拦截跳转请求
    return YES;
}

@end

