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
        //看看是否已经处理过了，防止无限循环
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
