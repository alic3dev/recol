#import "view_controller.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <AVFAudio/AVFAudio.h>

#import "renderer.h"

@implementation view_controller {
  MTKView* _view;
  metal_kit_renderer* _renderer;
  AVAudioEngine* engine_audio;
  __block AVAudioFrameCount frame_count;
  __block const AudioBufferList* input_data;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  frame_count = 0;
  input_data = (void*)0;
  
  _view = (MTKView*) self.view;
  
  _view.device = MTLCreateSystemDefaultDevice();
  _view.clearColor = MTLClearColorMake(
    0.0f,
    1.0f,
    0.0f,
    1.0f
  );

  _renderer = [[metal_kit_renderer alloc] initWithMetalKitView:_view];
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
  
  AVAudioOutputNode* node_output = engine_audio.outputNode;
  AVAudioFormat* format_output = [node_output inputFormatForBus:0];
  
  AVAudioSinkNode* node_sink = [[AVAudioSinkNode alloc] initWithReceiverBlock:^OSStatus(const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount _frame_count, const AudioBufferList * _Nonnull _input_data) {
    self->frame_count = _frame_count;
    self->input_data = _input_data;
    
    [self->_renderer
      data_set: self->frame_count
      input_data: self->input_data
    ];
    
    return noErr;
  }];
  
  __block unsigned int x = 672489;
  float* da = calloc(x, sizeof(float));
  __block unsigned int v = 0;
  __block unsigned int q = 0;
  
  AVAudioSourceNode* node_source = [[AVAudioSourceNode alloc] initWithFormat:format_output
    renderBlock:^OSStatus(BOOL * _Nonnull isSilence, const AudioTimeStamp * _Nonnull timestamp, AVAudioFrameCount frameCount, AudioBufferList* _Nonnull outputData) {
    
    unsigned int ff = 0;
    unsigned int fz = frameCount / self->frame_count;
    
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
          ((float*) self->input_data->mBuffers[0].mData)[ff % self->frame_count]
        );
        
        if (da[q] > 1.0f) {
          da[q] = da[q] - 1.0f;
        }
        
        if (da[q] < -1.0f) {
          da[q] = da[q] + 1.0f;
        }

        ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
          da[v] > 0.0f ? 0.25f : -0.25f 
        );
      }
      
      v = (v + 1) % (x - 1);
      q = (q + 1) % (x - 1);
      
      if ((frame + 1) % fz == 0) {
        ff = ff + 1;
      }
    }
    
    return noErr;
  }];
  
  AVAudioUnitDelay* unit_delay = [[AVAudioUnitDelay alloc] init];
  unit_delay.delayTime = 0;
  unit_delay.feedback = 0;
  unit_delay.wetDryMix = 0;
  [engine_audio attachNode:unit_delay];
  
  [engine_audio attachNode:node_source];
  [engine_audio connect:node_source to:unit_delay format:format_output];
  [engine_audio connect:unit_delay to:node_output format:format_output];
  
  [engine_audio attachNode:node_sink];
  [engine_audio connect:engine_audio.inputNode to:node_sink format:[engine_audio.inputNode outputFormatForBus:0]];
  
  [engine_audio startAndReturnError:nil];
}

- (void) drawInMTKView: (nonnull MTKView*) _metal_kit_view {
  [_renderer
    drawInMTKView: _metal_kit_view
  ];
}

@end
