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
                  [NSString stringWithFormat:@"Single Rate"], nil];

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

- (IBAction)spaceshipTapped:(id)sender {
    //The call below uses AudioServicesPlaySystemSound to play
    //the short pew-pew sound.
	[self.audioController playSystemSound];
	[self fireBullet];
}

- (void)notifTest:(NSNotification *)notif
{
    NSLog(@"notifTest fired with data %@",[[notif userInfo]valueForKey:@"key"]);
}


- (void)fireBullet {
    // In IB, the button to top layout guide constraint is set to 229, so
    // the bullets appear in the correct place, on both 3.5" and 4" screens
	UIImageView *bullets = [[UIImageView alloc] initWithFrame:CGRectMake(84, 256, 147, 29)];
	bullets.image = [UIImage imageNamed:@"bullets.png"];
	[self.view addSubview:bullets];
	[self.view sendSubviewToBack:bullets];
	[UIView beginAnimations:@"shoot" context:(__bridge void *)(bullets)];
	CGRect frame = bullets.frame;
	frame.origin.y = -29;
	bullets.frame = frame;
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
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
}

@end
