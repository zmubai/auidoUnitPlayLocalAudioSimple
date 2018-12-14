//
//  AudioPlayer.h
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayer : NSObject
- (instancetype) initWithFilePath:(NSString*) path;

- (BOOL)play;

- (void)stop;
@end

NS_ASSUME_NONNULL_END
