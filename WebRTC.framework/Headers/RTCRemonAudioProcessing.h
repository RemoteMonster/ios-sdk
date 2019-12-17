//
//  RTCRemonAudioProcessing.h
//  products
//
//  Created by Chance Kim on 2019/11/07.
//

#ifndef RTCRemonAudioProcessing_h
#define RTCRemonAudioProcessing_h

#import <AudioUnit/AudioUnit.h>
#import "RTCMacros.h"

typedef NS_ENUM(NSInteger, RTCRemonAudioProcessingState) {
  kInitRequired,
  kUninitialized,
  kInitialized,
  kStarted
};

typedef OSStatus (^NotifyGetPlayoutData)(AudioUnitRenderActionFlags*, const AudioTimeStamp*, uint32_t, uint32_t, AudioBufferList*);
typedef OSStatus (^NotifyDeliverRecoredData)(AudioUnitRenderActionFlags*, const AudioTimeStamp*, uint32_t, uint32_t, AudioBufferList*);

RTC_OBJC_EXPORT
@protocol RTCRemonAudioProcessingDelegate <NSObject>
-(bool)initAudioProcessing;
-(RTCRemonAudioProcessingState)getState;
-(bool)initialize:(double)sample_rate;
-(bool)start;
-(bool)stop;
-(bool)uninitialize;
-(AudioStreamBasicDescription)getFormat:(double)sample_rate;
-(void)disposeAudioUnit;
-(OSStatus)render:(AudioUnitRenderActionFlags*)flags
   inTimeStamp:(const AudioTimeStamp*)time_stamp
   inBusNumber:(uint32_t)output_bus_number
inNumberFrames:(uint32_t)num_frames
        ioData:(AudioBufferList*)io_data;
@end

RTC_OBJC_EXPORT
@interface RTCRemonAudioProcessing:NSObject<RTCRemonAudioProcessingDelegate>

-(void)setObserver:(void*) observer;
-(OSStatus)notifyGetPlayoutData:(AudioUnitRenderActionFlags*)flags
                    inTimeStamp:(const AudioTimeStamp*)time_stamp
                    inBusNumber:(uint32_t)bus_number
                 inNumberFrames:(uint32_t)num_frames
                         ioData:(AudioBufferList*)io_data;

-(OSStatus)notifyDeliverRecordedData:(AudioUnitRenderActionFlags*)flags
                         inTimeStamp:(const AudioTimeStamp*)time_stamp
                         inBusNumber:(uint32_t)bus_number
                      inNumberFrames:(uint32_t)num_frames
                              ioData:(AudioBufferList*)io_data;

@end

#endif /* RTCRemonAudioProcessing_h */
