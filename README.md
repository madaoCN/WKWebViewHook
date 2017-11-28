# WKWebViewHook
hook WKWebViewHook request with NSURLProtocol

hook every loading URL request with use `NSURLProtocol`

```swift
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:HttpProtocolKey] == NSOrderedSame ||
        [scheme caseInsensitiveCompare:HttpsProtocolKey] == NSOrderedSame)
    {
        // avoid endless loop
        if ([NSURLProtocol propertyForKey:kURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
    }
    
    return YES;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}
```

__screenshot__

![pic](https://github.com/madaoCN/WKWebViewHook/blob/master/pic.png)
