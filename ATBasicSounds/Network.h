//
//  Network.h
//  ATBasicSounds
//
//  Created by Gregory Young on 4/6/15.
//

#import <Foundation/Foundation.h>

@interface Network : NSOperation <NSURLConnectionDelegate>

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSUInteger expectedBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property (nonatomic) NSString *videoID;

- (id)initWithData:(NSString*)videoID;

@end
