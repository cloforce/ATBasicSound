//
//  Network.m
//  ATBasicSounds
//
//  Created by Gregory Young on 4/6/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//
#define ARC4RANDOM_MAX      0x100000000
#import "Network.h"

@implementation Network

- (id)initWithData:(NSString*)videoID
{
    self = [super init];
    if(self)
    {
        _videoID = videoID;
    }
    return self;
}

-(void)main
{
    //Youtube Video ID string random number key and GET url
    NSString *videoID = @"6o5TpKpZsxY";
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    double randomVal = floor(val*3500000);
    NSString *videoKey = [NSString stringWithFormat:@"%f",randomVal];
    
    NSString *GETurl =[NSString stringWithFormat:@"http://www.video2mp3.at/settings.php?set=check&format=mp3&id=%@&video=%@",videoID,videoKey];
    
    //GET request to retrieve the response key to build the URL
    NSString *responeData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
    NSArray *responseDataList = [responeData componentsSeparatedByString:@"|"];
    
    //Build download URL
    NSString *mp3URL = [NSString stringWithFormat:@"http://s%@.video2mp3.at/dl.php?id=%@",[responseDataList objectAtIndex:1],[responseDataList objectAtIndex:2]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mp3URL]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    //Write to filepath
    //NSData *mp3File = [NSData dataWithContentsOfURL:[NSURL URLWithString:mp3URL]];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"sample.mp3"];
    [_responseData writeToFile:filePath atomically:YES];
    
    //TO-DO Send filePath back to audiocontroller
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
    
    _expectedBytes = (NSUInteger)response.expectedContentLength;
    _data = [NSMutableData dataWithCapacity:_expectedBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    [_data appendData:data];
    _receivedBytes = _data.length;
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
