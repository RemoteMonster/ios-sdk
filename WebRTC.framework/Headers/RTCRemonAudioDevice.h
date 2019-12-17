//
//  RTCRemonAudioDevice.h
//  products
//
//  Created by Chance Kim on 2019/10/31.
//

#ifndef RTCRemonAudioDevice_h
#define RTCRemonAudioDevice_h

#import <Foundation/Foundation.h>
#include <AudioUnit/AudioUnit.h>
#import "RTCMacros.h"


@class AudioDeviceModule;
@class RTCRemonAudioDevice;

RTC_OBJC_EXPORT
@protocol RTCRemonAudioDeviceDelegate<NSObject>
-(void)setAudioDeviceModule:(void*)refptr;

@end

RTC_OBJC_EXPORT
@interface RTCRemonAudioDevice : NSObject<RTCRemonAudioDeviceDelegate>

-(bool)microphoneIsInitialized;

@end



#endif /* RTCRemonAudioDevice_h */
