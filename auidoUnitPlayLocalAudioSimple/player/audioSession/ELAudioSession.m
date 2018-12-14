//
//  ELAudioSession.m
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import "ELAudioSession.h"
#import "AVAudioSession+RounteUtils.h"

@implementation ELAudioSession
+ (ELAudioSession*)sharedInstance
{
    static ELAudioSession *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ELAudioSession alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preferredSampleRate = _currentSampleRate = 44100.0;
        _audioSession = [AVAudioSession sharedInstance];
    }
    return self;
}

- (void)setCategory:(NSString *)category
{
    _category = category;
    
    NSError *error = nil;
    if(![self.audioSession setCategory:_category error:&error])
        NSLog(@"Could note set category on audio session: %@", error.localizedDescription);
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    NSError *error = nil;
    
    if(![self.audioSession setPreferredSampleRate:self.preferredSampleRate error:&error])
        NSLog(@"Error when setting sample rate on audio session: %@", error.localizedDescription);
    
    if(![self.audioSession setActive:_active error:&error])
        NSLog(@"Error when setting active state of audio session: %@", error.localizedDescription);
    
    _currentSampleRate = [self.audioSession sampleRate];
}

- (void)setPreferredLatency:(NSTimeInterval)preferredLatency
{
    _preferredLatency = preferredLatency;
    
    NSError *error = nil;
    if(![self.audioSession setPreferredIOBufferDuration:_preferredLatency error:&error])
        NSLog(@"Error when setting preferred I/O buffer duration");
}

- (void)addRouteChangeListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationAudioRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [self adjustOnRouteChange];
}

#pragma mark - notification observer

- (void)onNotificationAudioRouteChange:(NSNotification *)sender {
    [self adjustOnRouteChange];
}

- (void)adjustOnRouteChange
{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    if (currentRoute) {
        if ([[AVAudioSession sharedInstance] usingWiredMicrophone]) {
        } else {
            if (![[AVAudioSession sharedInstance] usingBlueTooth]) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        }
    }
}

@end
