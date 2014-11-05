//
//  TencentLoginView.m
//  TencentOAuthDemo
//
//  Created by cloudxu on 11-8-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "TencentLoginView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString* kDefaultTitle = @"QQ登录";

//static CGFloat kTencentBlue[4] = {0.42578125, 0.515625, 0.703125, 1.0};
//static CGFloat kTencentBlue[4] = {1, 1, 0, 1.0};
//static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
//static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
//static CGFloat kBorderBlue[4] = {0.23, 0.35, 0.6, 1.0};

static CGFloat kTransitionDuration = 0.3;

static CGFloat kTitleMarginX = 8;
static CGFloat kTitleMarginY = 4;
static CGFloat kPadding = 0;
static CGFloat kBorderWidth = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////

BOOL TencentIsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
	return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TencentLoginView

@synthesize delegate = _delegate,
params   = _params;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
		CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	if (fillColors) {
		CGContextSaveGState(context);
		CGContextSetFillColor(context, fillColors);
		if (radius) {
			[self addRoundedRectToPath:context rect:rect radius:radius];
			CGContextFillPath(context);
		} else {
			CGContextFillRect(context, rect);
		}
		CGContextRestoreGState(context);
	}
	
	CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(context);
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColor(context, strokeColor);
	CGContextSetLineWidth(context, 1.0);
	
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y-0.5},
			{rect.origin.x+rect.size.width, rect.origin.y-0.5}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5},
			{rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+rect.size.width-0.5, rect.origin.y},
			{rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y},
			{rect.origin.x+0.5, rect.origin.y+rect.size.height}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
	if (orientation == _orientation) {
		return NO;
	} else {
		return orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight
		|| orientation == UIDeviceOrientationPortrait
		|| orientation == UIDeviceOrientationPortraitUpsideDown;
	}
}

- (CGAffineTransform)transformForOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}

- (void)sizeToFitOrientation:(BOOL)transform {
	if (transform) {
		self.transform = CGAffineTransformIdentity;
	}
	
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	CGPoint center = CGPointMake(
								 frame.origin.x + ceil(frame.size.width/2),
								 frame.origin.y + ceil(frame.size.height/2));
	
	CGFloat scale_factor = 1.0f;
	if (TencentIsDeviceIPad()) {
		// On the iPad the dialog's dimensions should only be 60% of the screen's
		//scale_factor = 0.6f;
	}
	
	CGFloat width = floor(scale_factor * frame.size.width) - kPadding * 2;
	CGFloat height = floor(scale_factor * frame.size.height) - kPadding * 2;
	
	_orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(_orientation)) {
		self.frame = CGRectMake(kPadding, kPadding, height, width);
	} else {
		self.frame = CGRectMake(kPadding, kPadding, width, height);
	}
	self.center = center;
	
	if (transform) {
		self.transform = [self transformForOrientation];
	}
}

- (void)updateWebOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.setAttribute('orientation', 90);"];
	} else {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.removeAttribute('orientation');"];
	}
 
}

- (void)bounce1AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
//	self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	self.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	self.transform = [self transformForOrientation];
	[UIView commitAnimations];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8);
			
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			[escaped_value release];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];

		
		return [NSURL URLWithString:url];
	} 
	else {
		return [NSURL URLWithString:baseURL];
	}
}

- (void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)postDismissCleanup {
	[self removeObservers];
	[self removeFromSuperview];
}

- (void)dismiss:(BOOL)animated {
	[self dialogWillDisappear];
	
	[_loadingURL release];
	_loadingURL = nil;
	
	if (animated) {
        [UIView animateWithDuration:.30f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect tmpFrame = self.frame;
            tmpFrame.origin.y = self.superview.frame.size.height;
            self.frame = tmpFrame;
        } completion:^(BOOL completed){
            [self postDismissCleanup];
            if (self.didDismiss) {
                self.didDismiss();
            }
        }];
	} else {
		[self postDismissCleanup];
	}
	 
}

- (void)cancel {
	[self dialogDidCancel:nil];
	if ([_delegate respondsToSelector:@selector(tencentDialogNotLogin:)]) {
		[_delegate tencentDialogNotLogin:YES];
	}	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super initWithFrame:CGRectZero]) {
		_delegate = nil;
		_loadingURL = nil;
		_orientation = UIDeviceOrientationUnknown;
		_showingKeyboard = NO;
		
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;
		
		_closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeButton setTitle:@"返回" forState:UIControlStateNormal];
        [_closeButton setBackgroundColor:[UIColor redColor]];
		[_closeButton addTarget:self action:@selector(cancel)
			   forControlEvents:UIControlEventTouchUpInside];
		
		// To be compatible with OS 2.x
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_2_2
		_closeButton.font = [UIFont boldSystemFontOfSize:12];
#else
		_closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
#endif
		
		_closeButton.showsTouchWhenHighlighted = YES;
		_closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
		| UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_closeButton];
		
		CGFloat titleLabelFontSize = (TencentIsDeviceIPad() ? 18 : 14);
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.text = kDefaultTitle;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
		_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
		| UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_titleLabel];
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(kPadding, kPadding, 480, 480)];
		_webView.delegate = self;
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_webView];
		
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
					UIActivityIndicatorViewStyleGray];
		_spinner.autoresizingMask =
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
		| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_spinner];
        
        UINavigationBar *navigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)] autorelease];
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:navigationBar];
        
        UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:@"QQ登录"] autorelease];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
	}
	return self;
}

- (void)dealloc {
	_webView.delegate = nil;
	[_webView release];
	[_params release];
	[_serverURL release];
	[_spinner release];
	[_titleLabel release];
	[_closeButton release];
	[_loadingURL release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
	
	CGRect headerRect = CGRectMake(
								   ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth),
								   rect.size.width - kBorderWidth*2, _titleLabel.frame.size.height);
	

	UIImage* titleImage =[UIImage imageNamed:@"title_btn.png"];

	CGImageRef imageRef=titleImage.CGImage;
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, headerRect, imageRef);

}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	NSURL* url = request.URL;
//	NSLog([NSString stringWithFormat:@"absolute url : %@", [url absoluteURL]]);
	
	NSRange start = [[url absoluteString] rangeOfString:@"access_token="];
	if (start.location != NSNotFound)
	{
		NSString * token = [self getStringFromUrl:[url absoluteString] needle:@"access_token="];
		NSString * expireTime = [self getStringFromUrl:[url absoluteString] needle:@"expires_in="];
        NSString *openId = [self getStringFromUrl:[url absoluteString] needle:@"openid="];
		NSDate *expirationDate =nil;
		
		if (expireTime != nil) {
			int expVal = [expireTime intValue];
			if (expVal == 0) {
				expirationDate = [NSDate distantFuture];
			} else {
				expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
			} 
		} 
		
		if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
			[self dialogDidCancel:url];
			if ([_delegate respondsToSelector:@selector(tencentDialogNotLogin:)]) {
				[_delegate tencentDialogNotLogin:NO];
			}
		} else {
			if ([_delegate respondsToSelector:@selector(tencentDialogLogin:openId:expirationDate:)]) {
				[_delegate tencentDialogLogin:token openId:openId expirationDate:expirationDate];
			}
		}
		return NO;
	}
	else
	{
		return YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[_spinner stopAnimating];
	_spinner.hidden = YES;
	
	self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self updateWebOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
	if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
//		[self dismissWithError:error animated:YES];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
	UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
	if ([self shouldRotateToOrientation:orientation]) {
	//	if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
		[self updateWebOrientation];
		
		CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
		[self sizeToFitOrientation:YES];
		[UIView commitAnimations];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
	
	_showingKeyboard = YES;
	
	if (TencentIsDeviceIPad()) {
		// On the iPad the screen is large enough that we don't need to
		// resize the dialog to accomodate the keyboard popping up
		return;
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_webView.frame = CGRectInset(_webView.frame,
									 -(kPadding + kBorderWidth),
									 -(kPadding + kBorderWidth) - _titleLabel.frame.size.height);
	}
	 
}

- (void)keyboardWillHide:(NSNotification*)notification {
	
	_showingKeyboard = NO;
	
	if (TencentIsDeviceIPad()) {
		return;
	}
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_webView.frame = CGRectInset(_webView.frame,
									 kPadding + kBorderWidth,
									 kPadding + kBorderWidth + _titleLabel.frame.size.height);
	}
	 
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

/**
 * Find a specific parameter from the url
 */
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return str;
}

- (id)initWithURL: (NSString *) serverURL
           params: (NSMutableDictionary *) params
         delegate: (id <TencentLoginViewDelegate>) delegate {
	
	self = [self init];
	_serverURL = [serverURL retain];
	_params = [params retain];
	_delegate = delegate;
	
	return self;
}

- (NSString*)title {
	return _titleLabel.text;
}

- (void)setTitle:(NSString*)title {
	_titleLabel.text = title;
}

- (void)load {
	[self loadURL:_serverURL get:_params];
}

- (void)loadURL:(NSString*)url get:(NSDictionary*)getParams {
	
	[_loadingURL release];
	_loadingURL = [[self generateURL:url params:getParams] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
	
	[_webView loadRequest:request];
}

- (void)show {
	[self load];
	[self sizeToFitOrientation:NO];
	
	CGFloat innerWidth = self.frame.size.width - (kBorderWidth)*2;
	[_titleLabel sizeToFit];
	[_closeButton sizeToFit];
	
	
	_titleLabel.frame = CGRectMake(
								   kBorderWidth + kTitleMarginX + kTitleMarginX,
								   kBorderWidth,
								   innerWidth - (_titleLabel.frame.size.height  + kTitleMarginX*2),
								   _titleLabel.frame.size.height + kTitleMarginY*2+4);

	
	_closeButton.frame = CGRectMake(
									self.frame.size.width - 60,
									10,
									50,
									_titleLabel.frame.size.height-4);
    _closeButton.hidden = YES;

	
	_webView.frame = CGRectMake(
								kBorderWidth,
								45,
								innerWidth+2,
								self.frame.size.height - 45);
	
	[_spinner sizeToFit];
	[_spinner startAnimating];
	_spinner.center = _webView.center;
	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	
	[window addSubview:self];
	
	[self dialogWillAppear];
    CGRect originalFrame = self.frame;
    
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.y = self.superview.frame.size.height;
    self.frame = tmpFrame;
    [UIView animateWithDuration:.30f delay:.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = originalFrame;
    } completion:nil];
	
	[self addObservers];
}

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated {
	if (success) {
		if ([_delegate respondsToSelector:@selector(dialogDidComplete:)]) {
			[_delegate dialogDidComplete:self];
		}
	} else {
		if ([_delegate respondsToSelector:@selector(dialogDidNotComplete:)]) {
			[_delegate dialogDidNotComplete:self];
		}
	}
	
	[self dismiss:animated];
}

- (void)dismissWithError:(NSError*)error animated:(BOOL)animated {
	if ([_delegate respondsToSelector:@selector(dialog:didFailWithError:)]) {
		[_delegate dialog:self didFailWithError:error];
	}
	
	[self dismiss:animated];
}

- (void)dialogWillAppear {
}

- (void)dialogWillDisappear {
}

- (void)dialogDidSucceed:(NSURL *)url {
	
	if ([_delegate respondsToSelector:@selector(dialogCompleteWithUrl:)]) {
		[_delegate dialogCompleteWithUrl:url];
	}
	[self dismissWithSuccess:YES animated:YES];
}

- (void)dialogDidCancel:(NSURL *)url {
	if ([_delegate respondsToSelector:@selector(dialogDidNotCompleteWithUrl:)]) {
		[_delegate dialogDidNotCompleteWithUrl:url];
	}
	[self dismissWithSuccess:NO animated:YES];
}

@end
