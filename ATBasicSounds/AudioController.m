//
//  AudioController.m
//  ATBasicSounds
//
//  Created by Audrey M Tam on 22/03/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

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
    
    
    //NSURL *url = [NSURL URLWithString:@"https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3"];
    
    //This works but the service is to slow
    //NSURL *url = [NSURL URLWithString:@"http:\/\/w3.youtubeinmp3.com\/download\/grabber\/?mp3=Electro_House_2015_Best_of_Party_Charts_Dance_Mix_140.mp3&id=QuTGjAI6iSc&t=Electro+%26+House+2015+Best+of+Party+Charts+Dance++Mix+%23140&s=10"];
    
    //The QuTGjAI6iSc is the video ID
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://api.video2mp3.cc/api/QuTGjAI6iSc/"] encoding:NSUTF8StringEncoding error:nil];
    
    NSData *testData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://api.video2mp3.cc/api/QuTGjAI6iSc/"]];
    TFHpple *scraper = [TFHpple hppleWithHTMLData:testData];
    NSString *tutorialsXpathQueryString = @"//*[@id='dlsrc']";
    NSArray *tutorialsNodes = [scraper searchWithXPathQuery:tutorialsXpathQueryString];
    
    NSString *finalURL;
    for (TFHppleElement *element in tutorialsNodes)
    {
        NSString *scraperURL = [NSString stringWithString:[element objectForKey:@"href"]];
        finalURL = [NSString stringWithFormat:@"%@",scraperURL];
    }
    
    NSURL *newURL = [NSURL URLWithString:finalURL];
    
    
    self.avAsset = [AVURLAsset URLAssetWithURL:newURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_avAsset];
    self.audioPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    //[self.audioPlayer play];
    
    //Youtube MP3 Conversion Test
    static NSString *baseUrl = @"http://youtubeinmp3.com/fetch/?api=advanced&format=JSON&video=";
    static NSString *videoUrl = @"https://www.youtube.com/watch?v=QuTGjAI6iSc";
    
    
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
