//
//  Network.m
//  ATBasicSounds
//
//  Created by Gregory Young on 4/6/15.
//
#define ARC4RANDOM_MAX      0x100000000
#import "Network.h"
#import "AFNetworking.h"

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

-(void)postGetRequest:(NSString*)url{
    
    //AFNetowrking
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self postGetRequest:url];
    }];
}

-(void)main
{
    //Youtube Video ID string random number key and GET url
    NSString *videoID = @"BU769XX_dIQ";
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    double randomVal = floor(val*3500000);
    NSString *videoKey = [NSString stringWithFormat:@"%.f",randomVal];
    
    NSString *GETurl =[NSString stringWithFormat:@"http://www.video2mp3.at/settings.php?set=check&format=mp3&id=%@&key=%@",videoID,videoKey];
    
    [self postGetRequest:GETurl];
    
    //GET request to retrieve the response key to build the URL
    NSString *responeData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
    NSArray *responseDataList = [responeData componentsSeparatedByString:@"|"];
    
    if([responseDataList[0] isEqualToString:@"ERROR"] && [responseDataList[1] isEqualToString:@"PENDING"] )
    {
        //Server has to download and convert the song.
        responeData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
        responseDataList = [responeData componentsSeparatedByString:@"|"];
    }
    
    if([responseDataList[0] isEqualToString:@"DOWNLOAD"])
    {
        NSString *testData = [NSString stringWithContentsOfURL:
                              [NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
        NSArray *responseDataList = [responeData componentsSeparatedByString:@"|"];
        NSString *percentString = @"000";
        int index = responseDataList.count-2;
        
        while(![percentString isEqualToString:@"100"])
        {
            testData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
            responseDataList = [testData componentsSeparatedByString:@"|"];
            percentString = [responseDataList[index] substringWithRange:NSMakeRange(0, 3)];
            NSLog(@"In the loop at percent %@\n",responseDataList[index]);
        }
        
        //Continuously ping the server, until object 0 is ok.
        
        videoKey = [NSString stringWithFormat:@"%.f",randomVal];
        randomVal = floor(val*3500000);
        GETurl =[NSString stringWithFormat:@"http://www.video2mp3.at/settings.php?set=check&format=mp3&id=%@&video=%@",videoID,videoKey];
        
        testData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
        responseDataList = [responeData componentsSeparatedByString:@"|"];
        
        while(![responseDataList[0] isEqualToString:@"OK"])
        {
            videoKey = [NSString stringWithFormat:@"%.f",randomVal];
            randomVal = floor(val*3500000);
            GETurl =[NSString stringWithFormat:@"http://www.video2mp3.at/settings.php?set=check&format=mp3&id=%@&video=%@",videoID,videoKey];
            
            testData = [NSString stringWithContentsOfURL:[NSURL URLWithString:GETurl] encoding:NSUTF8StringEncoding error:nil];
            responseDataList = [testData componentsSeparatedByString:@"|"];
            NSLog(@"Object 0 is %@\n",responseDataList[0]);
        }
        
    }
    
    if([responseDataList[0] isEqualToString:@"OK"])
    {
        //Build download URL
        NSString *mp3URL = [NSString stringWithFormat:@"http://dl%@.downloader.space/dl.php?id=%@",[responseDataList objectAtIndex:1],[responseDataList objectAtIndex:2]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mp3URL]];
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
    }
    
    
    //TO-DO Send filePath back to audiocontroller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadComplete" object:self userInfo:@{@"key" : @"value"}];
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
    
    //Write to filepath
    //NSData *mp3File = [NSData dataWithContentsOfURL:[NSURL URLWithString:mp3URL]];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"sample2.mp3"];
    [_responseData writeToFile:filePath atomically:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download"
                                                    message:@"Complete!"
                                                   delegate:self
                                          cancelButtonTitle:@"Lets dance!"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
