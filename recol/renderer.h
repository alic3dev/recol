#ifndef __metal_kit_renderer_h
#define __metal_kit_renderer_h

#include "audio.h"

#import <AVFAudio/AVFAudio.h>
#include <MetalKit/MetalKit.h>

@interface metal_kit_renderer : NSObject<MTKViewDelegate>

- (nonnull instancetype) initWithMetalKitView: (nonnull MTKView*) mtkView;
- (void) data_set: (AVAudioFrameCount) frame_count input_data: (const AudioBufferList* _Nullable) input_data;
- (void) audio_set: (nonnull struct recol_audio*) audio;

@end

#endif
