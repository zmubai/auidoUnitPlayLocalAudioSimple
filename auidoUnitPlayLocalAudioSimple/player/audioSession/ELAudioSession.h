//
//  ELAudioSession.h
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSTimeInterval AUSAudioSessionLatency_Background;
extern const NSTimeInterval AUSAudioSessionLatency_Default;
extern const NSTimeInterval AUSAudioSessionLatency_LowLatency;

@interface ELAudioSession : NSObject
+ (ELAudioSession *)sharedInstance;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, assign) Float64 preferredSampleRate;
@property (nonatomic, assign, readonly) Float64 currentSampleRate;
@property (nonatomic, assign) NSTimeInterval preferredLatency;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSString *category;

- (void)addRouteChangeListener;
@end

NS_ASSUME_NONNULL_END
