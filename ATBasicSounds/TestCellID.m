//
//  TestCellID.m
//  ATBasicSounds
//
//  Created by Gregory Young on 3/31/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

#import "TestCellID.h"

@interface TestCellID()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation TestCellID

- (void)configureWithName:(NSString *)name
{
    self.nameLabel.text = name;
}

@end
