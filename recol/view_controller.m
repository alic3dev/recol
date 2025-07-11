#import "view_controller.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <AVFAudio/AVFAudio.h>

#import "renderer.h"

@implementation view_controller {
  MTKView* _view;
  Renderer* _renderer;
  AVAudioEngine* engine_audio;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  _view = (MTKView*) self.view;
  
  _view.device = MTLCreateSystemDefaultDevice();
  _view.clearColor = MTLClearColorMake(
    0.0f,
    1.0f,
    0.0f,
    1.0f
  );

  _renderer = [[Renderer alloc] initWithMetalKitView:_view];
  [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
  _view.delegate = _renderer;
  
  AVAudioSession* session_audio_shared = [AVAudioSession sharedInstance];
  
  [session_audio_shared 
    setCategory:AVAudioSessionCategoryPlayAndRecord
    mode:AVAudioSessionModeDefault
    options:AVAudioSessionCategoryOptionMixWithOthers + AVAudioSessionCategoryOptionAllowBluetooth
    error:nil
  ];
  
  [session_audio_shared
    setActive:true
    error:nil
  ];
  
  engine_audio = [[AVAudioEngine alloc] init];
  
  AVAudioMixerNode* node_mixer = engine_audio.mainMixerNode;
  AVAudioOutputNode* node_output = engine_audio.outputNode;
  AVAudioFormat* format_output = [node_output inputFormatForBus:0];

  __block AVAudioFrameCount f = 0;
  __block const AudioBufferList* j = nil;
  
  AVAudioSinkNode* node_sink = [[AVAudioSinkNode alloc] initWithReceiverBlock:^OSStatus(const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, const AudioBufferList * _Nonnull inputData) {
    f = frameCount; // half of other frameCount
    j = inputData; // 1 buffer
    
    return noErr;
  }];
  __block unsigned int x = 672489;
  float* da = calloc(x, sizeof(float));
  __block unsigned int v = 0;
  __block unsigned int q = 0;
  
  AVAudioSourceNode* node_source = [[AVAudioSourceNode alloc] initWithFormat:format_output
    renderBlock:^OSStatus(BOOL * _Nonnull isSilence, const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, AudioBufferList* _Nonnull outputData) {
    
    unsigned int ff = 0;
    unsigned int fz = frameCount / f;
    
    for (
      unsigned int frame = 0;
      frame < frameCount;
      ++frame
    ) {
      for (
        unsigned int index_buffer = 0;
        index_buffer < outputData->mNumberBuffers;
        ++index_buffer
      ) {
        da[q] = (
          (da[q] * 0.9f) +
          ((float*) j->mBuffers[0].mData)[ff % f]
        );
        
        if (da[q] > 1.0f) {
          da[q] = da[q] - 1.0f;
        }
        
        if (da[q] < -1.0f) {
          da[q] = da[q] + 1.0f;
        }

        ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
          da[v]
        );

//        ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
//          buf_ptr[index_buf_read] * 10.0f
//        );
      }
      
      v = (v + 1) % (x - 1);
      q = (q + 1) % (x - 1);
      
//      index_buf_read = index_buf_read + 1;
//      
//      if (index_buf_read >= length_buf) {
//        index_buf_read = 0;
//      }
      
      if ((frame + 1) % fz == 0) {
        ff = ff + 1;
      }
    }
    
    return noErr;
  }];
  
//  [engine_audio attachNode:node_source];
//  [engine_audio connect:node_source to:node_mixer format:format_output];
//  
//  [engine_audio attachNode:node_sink];
//  [engine_audio connect:engine_audio.inputNode to:node_sink format:[engine_audio.inputNode outputFormatForBus:0]];
//  
////  [engine_audio.inputNode installTapOnBus: 0 bufferSize: 8192 format: [engine_audio.inputNode outputFormatForBus:0] block: ^(AVAudioPCMBuffer *buff, AVAudioTime *when) {
////    float *const  _Nonnull * _Nullable dat = [buff floatChannelData];
////    AVAudioFrameCount fc = [buff frameLength];
////    
////    for (unsigned int i = 0; i < fc; ++i) {
////      buf_ptr[index_buf_write] = dat[0][i];
////      index_buf_write = index_buf_write + 1;
////      if (index_buf_write >= length_buf) {
////        index_buf_write = 0;
////      }
////    }
////  }];
//
//  [engine_audio connect:node_mixer to:node_output format:format_output];
//  
//  [engine_audio startAndReturnError:nil];
  
  AVAudioUnitDelay* unit_delay = [[AVAudioUnitDelay alloc] init];
  unit_delay.delayTime = 2;
  unit_delay.feedback = 90;
  unit_delay.wetDryMix = 40;
  [engine_audio attachNode:unit_delay];
  
  [engine_audio attachNode:node_source];
  [engine_audio connect:node_source to:unit_delay format:format_output];
  [engine_audio connect:unit_delay to:node_output format:format_output];
  
  [engine_audio attachNode:node_sink];
  [engine_audio connect:engine_audio.inputNode to:node_mixer format:[engine_audio.inputNode outputFormatForBus:0]];

  [engine_audio connect:node_mixer to:unit_delay format:format_output];
  
  [engine_audio startAndReturnError:nil];
}

@end
