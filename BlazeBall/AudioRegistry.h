//  Created by Jens Riemschneider on 9/30/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenAL/al.h>
#include <OpenAL/alc.h>

@interface AudioRegistry : NSObject {
    NSMutableDictionary* _sources;
    NSMutableDictionary* _buffers;

    ALCcontext* _audioContext;
    ALCdevice* _audioDevice;
}

- (void)play:(NSString *)soundId;

@end
