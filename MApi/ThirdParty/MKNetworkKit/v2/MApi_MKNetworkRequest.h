//
//  MKNetworkRequest.h
//  MKNetworkKit
//
//  Created by Mugunth Kumar (@mugunthkumar) on 23/06/14.
//  Copyright (C) 2011-2020 by Steinlogic Consulting and Training Pte Ltd

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

typedef enum {
  
  MApi_MKNKParameterEncodingURL = 0, // default
  MApi_MKNKParameterEncodingJSON,
  MApi_MKNKParameterEncodingPlist
} MApi_MKNKParameterEncoding;


typedef enum {
  
  MApi_MKNKRequestStateReady = 0,
  MApi_MKNKRequestStateStarted,
  MApi_MKNKRequestStateResponseAvailableFromCache,
  MApi_MKNKRequestStateStaleResponseAvailableFromCache,
  MApi_MKNKRequestStateCancelled,
  MApi_MKNKRequestStateCompleted,
  MApi_MKNKRequestStateError
} MApi_MKNKRequestState;

@interface MApi_MKNetworkRequest : NSObject {
  
  MApi_MKNKRequestState _state;
}

@property (readonly) NSMutableURLRequest *request;
@property (readonly) NSHTTPURLResponse *response;

@property MApi_MKNKParameterEncoding parameterEncoding;
@property (readonly) MApi_MKNKRequestState state;

// if the resource require authentication
@property NSString *username;
@property NSString *password;

@property NSString *clientCertificate;
@property NSString *clientCertificatePassword;

@property NSString *downloadPath;

@property (readonly) BOOL requiresAuthentication;
@property (readonly) BOOL isSSL;

@property BOOL doNotCache;
@property BOOL alwaysCache;

@property BOOL ignoreCache;
@property BOOL alwaysLoad;

@property NSString *httpMethod;

@property (readonly) BOOL isCachedResponse;
@property (readonly) BOOL responseAvailable;

@property (readonly) NSData *multipartFormData;
@property (readonly) NSData *responseData;
@property (readonly) NSError *error;
@property (readonly) NSURLSessionTask *task;
@property (readonly) CGFloat progress;
@property (readonly) id responseAsJSON;
@property NSTimeInterval timeoutInterval;

#if TARGET_OS_IPHONE
-(UIImage*) decompressedResponseImageOfSize:(CGSize) size;
@property (readonly) UIImage *responseAsImage;
#else
@property (readonly) NSImage *responseAsImage;
#endif

@property (readonly) NSString *responseAsString;

@property (readonly) BOOL cacheable;

- (instancetype)initWithURLString:(NSString *)aURLString
                           params:(NSDictionary *)params
                         bodyData:(NSData *)bodyData
                       httpMethod:(NSString *)method;

typedef void (^MKNKHandler)(MApi_MKNetworkRequest* completedRequest);

-(void) addParameters:(NSDictionary*) paramsDictionary;
-(void) addHeaders:(NSDictionary*) headersDictionary;
-(void) setAuthorizationHeaderValue:(NSString*) token forAuthType:(NSString*) authType;

-(void) attachFile:(NSString*) filePath forKey:(NSString*) key mimeType:(NSString*) mimeType;
-(void) attachData:(NSData*) data forKey:(NSString*) key mimeType:(NSString*) mimeType suggestedFileName:(NSString*) fileName;

-(void) addCompletionHandler:(MKNKHandler) completionHandler;
-(void) addUploadProgressChangedHandler:(MKNKHandler) uploadProgressChangedHandler;
-(void) addDownloadProgressChangedHandler:(MKNKHandler) downloadProgressChangedHandler;
-(void) cancel;
@end
