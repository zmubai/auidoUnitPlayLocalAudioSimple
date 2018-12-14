//
//  ViewController.m
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import "ViewController.h"
#import "AudioPlayer.h"
#import "CommonUtil.h"

@interface ViewController ()
@property (nonatomic,strong) AudioPlayer *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* filePath = [CommonUtil bundlePath:@"hongri.mp3"];
    //    NSString* filePath = [CommonUtil bundlePath:@"0fe2a7e9c51012210eaaa1e2b103b1b1.m4a"];
    
    self.audioPlayer = [[AudioPlayer alloc] initWithFilePath:filePath];
}

- (IBAction)playAction:(id)sender {
    [self.audioPlayer stop];
    [self.audioPlayer play];
}

- (IBAction)stopAction:(id)sender {
    [self.audioPlayer stop];
}

@end
