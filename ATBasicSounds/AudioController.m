//
//  AudioController.m
//  ATBasicSounds
//
//  Created by Audrey M Tam on 22/03/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//
#define ARC4RANDOM_MAX      0x100000000

#import "AudioController.h"
#import "TFHpple.h"
@import AVFoundation;

@interface AudioController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
//Test
@property (strong, nonatomic) AVPlayer      *audioPlayer;
@property (strong, nonatomic) AVPlayerItem  *playerItem;
@property (strong, nonatomic) AVURLAsset    *avAsset;

@property (assign) BOOL backgroundMusicPlaying;
@property (assign) BOOL backgroundMusicInterrupted;
@property (assign) SystemSoundID pewPewSound;

@end

@implementation AudioController

#pragma mark - Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureAudioSession];
        [self configureAudioPlayer];
        [self configureSystemSound];
    }
    return self;
}

- (void)tryPlayMusic {
	// If background music or other music is already playing, nothing more to do here
	//if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
    //    return;
    //}
    
    // Play background music if no other music is playing and we aren't playing already
    //Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
    //call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
    //It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
    //delay when playing a sound later on.
    //[self.backgroundMusicPlayer prepareToPlay];
    
    //[self.audioPlayer play];
    //self.backgroundMusicPlaying = YES;
}

- (void)playSystemSound {
    AudioServicesPlaySystemSound(self.pewPewSound);
}

- (void)playTapped
{
    [self.audioPlayer play];
}

- (void)pauseTapped
{
    [self.audioPlayer pause];
}

- (void)doubleTapped
{
    [self.audioPlayer setRate:2];
}

- (void)singleTapped
{
    [self.audioPlayer setRate:1];
    NSLog(@"singleTapped fired");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification1" object:self userInfo:@{@"key" : @"value"}];
}

#pragma mark - Private

- (void) configureAudioSession {
    // Implicit initialization of audio session
    self.audioSession = [AVAudioSession sharedInstance];
    
    // Set category of audio session
	// See handy chart on pg. 46 of the Audio Session Programming Guide for what the categories mean
	// Not absolutely required in this example, but good to get into the habit of doing
	// See pg. 10 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
	
    NSError *setCategoryError = nil;
    if ([self.audioSession isOtherAudioPlaying]) { // mix sound effects with music already playing
        [self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&setCategoryError];
        self.backgroundMusicPlaying = NO;
    } else {
        [self.audioSession setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
    }
    if (setCategoryError) {
        NSLog(@"Error setting category! %ld", (long)[setCategoryError code]);
    }
}

- (void)configureAudioPlayer {
    // Create audio player with background music
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"background-music-aac" ofType:@"caf"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
    self.backgroundMusicPlayer.delegate = self;  // We need this so we can restart after interruptions
    self.backgroundMusicPlayer.numberOfLoops = -1;	// Negative number means loop forever
    
    
    //YOUTUBE MP3 Testing
     
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
    
    //Write to filepath
    //This works, need to move off the main thread.
    NSData *mp3File = [NSData dataWithContentsOfURL:[NSURL URLWithString:mp3URL]];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"sample.mp3"];
    [mp3File writeToFile:filePath atomically:YES];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
    self.audioPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    
    
    //Working Example
    /*
    NSURL *url = [NSURL URLWithString:mp3URL];
    self.avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_avAsset];
    self.audioPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
     */
    //[self.audioPlayer play];
     

}

- (void)configureSystemSound {
    // This is the simplest way to play a sound.
	// But note with System Sound services you can only use:
	// File Formats (a.k.a. audio containers or extensions): CAF, AIF, WAV
	// Data Formats (a.k.a. audio encoding): linear PCM (such as LEI16) or IMA4
	// Sounds must be 30 sec or less
	// And only one sound plays at a time!
	NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"pew-pew-lei" ofType:@"caf"];
	NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    //It is often not necessary to implement this method since by the time
    //this method is called, the sound has already stopped. You don't need to
    //stop it yourself.
    //In this case the backgroundMusicPlaying flag could be used in any
    //other portion of the code that needs to know if your music is playing.
    
	self.backgroundMusicInterrupted = YES;
	self.backgroundMusicPlaying = NO;
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags{
    //Since this method is only called if music was previously interrupted
    //you know that the music has stopped playing and can now be resumed.
      [self tryPlayMusic];
      self.backgroundMusicInterrupted = NO;
}

@end
