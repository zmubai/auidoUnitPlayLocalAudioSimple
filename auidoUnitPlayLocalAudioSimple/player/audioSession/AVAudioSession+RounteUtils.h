//
//  AVAudioSession+RounteUtils.h
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioSession (RounteUtils)
- (BOOL)usingBlueTooth;

- (BOOL)usingWiredMicrophone;

- (BOOL)shouldShowEarphoneAlert;

@end

NS_ASSUME_NONNULL_END
