//
//  AudioPlayer.m
//  auidoUnitPlayLocalAudioSimple
//
//  Created by zengbailiang on 2018/12/13.
//  Copyright © 2018年 zengbailiang. All rights reserved.
//

#import "AudioPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ELAudioSession.h"

@interface  AudioPlayer ()
@property (nonatomic, strong) NSURL *playPath;
@end

@implementation AudioPlayer
{
    AUGraph mPlayerGraph;
    
    //输入
    AUNode mPlayerNode;
    AudioUnit mPlayerUnit;
    
    //输出
    AUNode mPlayerIONode;
    AudioUnit mPlayerIOUnit;
}



- (instancetype)initWithFilePath:(NSString*)path
{
    self = [super init];
    if(self)
    {
        [[ELAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord];
        [[ELAudioSession sharedInstance] setPreferredSampleRate:441000];
        [[ELAudioSession sharedInstance] setActive:YES];
        [[ELAudioSession sharedInstance] addRouteChangeListener];
//        [self addAudioSessionInterruptedObserver];
        _playPath = [NSURL URLWithString:path];
        [self initializePlayGraph];
    }
    return self;
}

#pragma mark -
- (BOOL)play
{
    OSStatus status = AUGraphStart(mPlayerGraph);
    CheckStatus(status, @"Could not start AUGraph", YES);
    return YES;
}

- (void)stop
{
    Boolean isRunning = false;
    OSStatus status = AUGraphIsRunning(mPlayerGraph, &isRunning);
    
    if (isRunning) {
        status = AUGraphStop(mPlayerGraph);
        CheckStatus(status, @"Could not stop AUGraph", YES);
    }
}

#pragma mark -
/*
 CF_ENUM(UInt32) {
 kAudioUnitType_Output                    = 'auou',
 kAudioUnitType_MusicDevice                = 'aumu',
 kAudioUnitType_MusicEffect                = 'aumf',
 kAudioUnitType_FormatConverter            = 'aufc',
 kAudioUnitType_Effect                    = 'aufx',
 kAudioUnitType_Mixer                    = 'aumx',
 kAudioUnitType_Panner                    = 'aupn',
 kAudioUnitType_Generator                = 'augn',
 kAudioUnitType_OfflineEffect            = 'auol',
 kAudioUnitType_MIDIProcessor            = 'aumi'
 };
 */

- (void)initializePlayGraph
{
    OSStatus status = noErr;
    //init graph
    status = NewAUGraph(&mPlayerGraph);
    CheckStatus(status, @"could not create a new AUGraph", YES);
    
    //init node
    AudioComponentDescription ioDescription;
    bzero(&ioDescription, sizeof(ioDescription));
    ioDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioDescription.componentType = kAudioUnitType_Output;
    ioDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    status = AUGraphAddNode(mPlayerGraph, &ioDescription, &mPlayerIONode);
    CheckStatus(status, @"Could not add I/O node to AUGraph", YES);
    
    AudioComponentDescription playDescription;
    bzero(&playDescription, sizeof(playDescription));
    playDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    playDescription.componentType = kAudioUnitType_Generator;
    playDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;//file
    status = AUGraphAddNode(mPlayerGraph, &playDescription, &mPlayerNode);
    CheckStatus(status, @"Could not add Player node to AUGraph", YES);
    
    //打开graph 并实例化nodes
    status = AUGraphOpen(mPlayerGraph);
    CheckStatus(status, @"Could not open AUGraph", YES);
    
    status = AUGraphNodeInfo(mPlayerGraph, mPlayerIONode, NULL, &mPlayerIOUnit);
    CheckStatus(status, @"Could not retrieve node info for I/O node", YES);
    status = AUGraphNodeInfo(mPlayerGraph, mPlayerNode, NULL, &mPlayerUnit);
    CheckStatus(status, @"Could not retrieve node info for Player node", YES);
    
    //给unit 设置参数
    AudioStreamBasicDescription stereoStreamFormat;
    UInt32 bytesPerSample = sizeof(Float32);
    bzero(&stereoStreamFormat, sizeof(stereoStreamFormat));
    stereoStreamFormat.mFormatID = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked |
    kAudioFormatFlagIsNonInterleaved;
    stereoStreamFormat.mBytesPerPacket = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket = 1;
    stereoStreamFormat.mBytesPerFrame = bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame = 2;
    stereoStreamFormat.mBitsPerChannel = 8 * bytesPerSample;
    stereoStreamFormat.mSampleRate = 48000;
    
    status = AudioUnitSetProperty(mPlayerIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &stereoStreamFormat, sizeof(stereoStreamFormat));
    CheckStatus(status, @"set remote IO output element stream format ", YES);
    status = AudioUnitSetProperty(
                                  mPlayerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &stereoStreamFormat,
                                  sizeof (stereoStreamFormat)
                                  );
     CheckStatus(status, @"Could not Set StreamFormat for Player Unit", YES);
    
    //连接node
    AUGraphConnectNodeInput(mPlayerGraph, mPlayerNode, 0, mPlayerIONode, 0);
    
    //初始化graph
    status = AUGraphInitialize(mPlayerGraph);
    CheckStatus(status, @"Couldn't Initialize the graph", YES);
    CAShow(mPlayerGraph);//print info
    
    [self setUpFilePlayer];
}

- (void) setUpFilePlayer
{
    //获取文件信息，并配置mplayUnit读取策略
    OSStatus status = noErr;
    AudioFileID musicFile;
    CFURLRef songURL = (__bridge  CFURLRef) _playPath;
    // open the input audio file
    status = AudioFileOpenURL(songURL, kAudioFileReadPermission, 0, &musicFile);
    CheckStatus(status, @"Open AudioFile... ", YES);
    
    
    // tell the file player unit to load the file we want to play
    status = AudioUnitSetProperty(mPlayerUnit, kAudioUnitProperty_ScheduledFileIDs,
                                  kAudioUnitScope_Global, 0, &musicFile, sizeof(musicFile));
    CheckStatus(status, @"Tell AudioFile Player Unit Load Which File... ", YES);
    
    
    
    AudioStreamBasicDescription fileASBD;
    // get the audio data format from the file
    UInt32 propSize = sizeof(fileASBD);
    status = AudioFileGetProperty(musicFile, kAudioFilePropertyDataFormat,
                                  &propSize, &fileASBD);
    CheckStatus(status, @"get the audio data format from the file... ", YES);
    UInt64 nPackets;
    UInt32 propsize = sizeof(nPackets);
    AudioFileGetProperty(musicFile, kAudioFilePropertyAudioDataPacketCount,
                         &propsize, &nPackets);
    // tell the file player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = musicFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32)nPackets * fileASBD.mFramesPerPacket;
    status = AudioUnitSetProperty(mPlayerUnit, kAudioUnitProperty_ScheduledFileRegion,
                                  kAudioUnitScope_Global, 0,&rgn, sizeof(rgn));
    CheckStatus(status, @"Set Region... ", YES);
    
    
    // prime the file player AU with default values
    UInt32 defaultVal = 0;
    status = AudioUnitSetProperty(mPlayerUnit, kAudioUnitProperty_ScheduledFilePrime,
                                  kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
    CheckStatus(status, @"Prime Player Unit With Default Value... ", YES);
    
    
    // tell the file player AU when to start playing (-1 sample time means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    status = AudioUnitSetProperty(mPlayerUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
                                  kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
    CheckStatus(status, @"set Player Unit Start Time... ", YES);
}


#pragma mark -
static void CheckStatus(OSStatus status, NSString *message, BOOL fatal)
{
    if(status != noErr)
    {
        char fourCC[16];
        *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        
        if(isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3]))
            NSLog(@"%@: %s", message, fourCC);
        else
            NSLog(@"%@: %d", message, (int)status);
        
        if(fatal)
            exit(-1);
    }
}


// AudioSession 被打断的通知
- (void)addAudioSessionInterruptedObserver
{
    [self removeAudioSessionInterruptedObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationAudioInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
}

- (void)removeAudioSessionInterruptedObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:nil];
}

- (void)onNotificationAudioInterrupted:(NSNotification *)sender {
    AVAudioSessionInterruptionType interruptionType = [[[sender userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            [self stop];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            [self play];
            break;
        default:
            break;
    }
}

@end
