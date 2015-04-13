//
//  ATBViewController.m
//  ATBasicSounds
//
//  Created by Audrey M Tam on 20/03/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

#import "ATBViewController.h"
#import "AudioController.h"
#import "TestCellID.h"

@interface ATBViewController ()


@property (strong, nonatomic) AudioController *audioController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ATBViewController
{
    NSMutableArray *sampleData;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sampleData = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"Play"],
                  [NSString stringWithFormat:@"Pause"],[NSString stringWithFormat:@"Double Rate"],
                  [NSString stringWithFormat:@"Single Rate"],[NSString stringWithFormat:@"Download Song"], nil];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    self.audioController = [[AudioController alloc] init];
    [self.audioController tryPlayMusic];
    
    //NSNotificationCenter Testing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifTest:) name:@"Notification1" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction


- (void)notifTest:(NSNotification *)notif
{
    NSLog(@"notifTest fired with data %@",[[notif userInfo]valueForKey:@"key"]);
}


- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIImageView *bullets = (__bridge UIImageView *)context;
	[bullets removeFromSuperview];
}

#pragma mark - TableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Placeholder
    static NSString *kTestCellID = @"TestCellID";
    TestCellID *cell = (TestCellID*)[tableView dequeueReusableCellWithIdentifier:kTestCellID forIndexPath:indexPath];
    [cell configureWithName:[sampleData objectAtIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Placeholder
    return sampleData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        [self.audioController playTapped];
    
    if(indexPath.row == 1)
        [self.audioController pauseTapped];
    
    if(indexPath.row == 2)
        [self.audioController doubleTapped];
    
    if(indexPath.row == 3)
        [self.audioController singleTapped];
    
    if(indexPath.row == 4)
        [self.audioController downloadTapped];
}

@end
