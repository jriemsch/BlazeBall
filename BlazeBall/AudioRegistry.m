//  Created by Jens Riemschneider on 9/30/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "AudioRegistry.h"
#import "AudioToolbox/AudioToolbox.h"

@implementation AudioRegistry

- (AudioFileID)openAudioFile:(NSString *)filePath {
	AudioFileID audioFileId;
	NSURL *url = [NSURL fileURLWithPath:filePath];
	OSStatus result = AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0, &audioFileId);
	if (result != 0) {
        NSLog(@"Cannot open audio file: %@:result was: %x", filePath, result);
        exit(1);
    }
	return audioFileId;
}

- (UInt32)audioFileSize:(AudioFileID)audioFileId {
	UInt64 size = 0;
	UInt32 propSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(audioFileId, kAudioFilePropertyAudioDataByteCount, &propSize, &size);
	if (result != 0) {
        NSLog(@"Cannot find file size of audio file");
        exit(1);
    }
	return (UInt32)size;
}

- (void)loadAudioFile:(NSString *)filePath withId:(NSString *)soundId {
    AudioFileID fileID = [self openAudioFile:filePath];
    
    UInt32 fileSize = [self audioFileSize:fileID];
    unsigned char *audioData = malloc(fileSize);
    OSStatus result = AudioFileReadBytes(fileID, false, 0, &fileSize, audioData);
    AudioFileClose(fileID);
    
    if (result != 0) {
        NSLog(@"cannot load audio: %@", filePath);
        exit(1);
    }
    
    NSUInteger bufferId;
    alGenBuffers(1, &bufferId);
    
    alBufferData(bufferId, AL_FORMAT_MONO16, audioData, fileSize, 44100);
    free(audioData);
    
    NSUInteger sourceId;
    alGenSources(1, &sourceId); 
    alSourcei(sourceId, AL_BUFFER, bufferId);
    alSourcef(sourceId, AL_PITCH, 1.0f);
    alSourcef(sourceId, AL_GAIN, 1.0f);
    
    [_buffers setObject:[NSNumber numberWithUnsignedInt:bufferId] forKey:soundId];
    [_sources setObject:[NSNumber numberWithUnsignedInt:sourceId] forKey:soundId];
}

- (void)setupAudio {
    _audioDevice = alcOpenDevice(NULL);
    if (_audioDevice) {
        _audioContext = alcCreateContext(_audioDevice, NULL);
        alcMakeContextCurrent(_audioContext);
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _sources = [[NSMutableDictionary alloc] init];
        _buffers = [[NSMutableDictionary alloc] init];
        [self setupAudio];

        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"jump" ofType:@"caf"] withId:@"jump"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"block" ofType:@"caf"] withId:@"block"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"hole" ofType:@"caf"] withId:@"hole"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"restart" ofType:@"caf"] withId:@"restart"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"slow" ofType:@"caf"] withId:@"slow"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"speed" ofType:@"caf"] withId:@"speed"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"warp" ofType:@"caf"] withId:@"warp"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"click" ofType:@"caf"] withId:@"click"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"caf"] withId:@"highscore"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"gameover" ofType:@"caf"] withId:@"gameover"];
        [self loadAudioFile:[[NSBundle mainBundle] pathForResource:@"leveldone" ofType:@"caf"] withId:@"leveldone"];
    }
    
    return self;
}

- (void)dealloc {
	for (NSNumber *source in [_sources allValues]) {
		NSUInteger sourceID = [source unsignedIntegerValue];
		alDeleteSources(1, &sourceID);
	}
    
	for (NSNumber *buffer in [_buffers allValues]) {
		NSUInteger bufferID = [buffer unsignedIntegerValue];
		alDeleteBuffers(1, &bufferID);
	}
    
    [_sources dealloc];
    [_buffers dealloc];

	alcDestroyContext(_audioContext);
	alcCloseDevice(_audioDevice);
    
    [super dealloc];
}

- (void)play:(NSString *)soundId {
    NSNumber *numVal = [_sources objectForKey:soundId];
	NSUInteger sourceID = [numVal unsignedIntValue];
    ALenum state;        
    alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_PLAYING) {
        alSourcePlay(sourceID);
    }
}

@end
