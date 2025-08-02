#import "view_controller.h"

#include "audio.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <AVFAudio/AVFAudio.h>

#import "renderer.h"

@implementation view_controller {
  MTKView* _view;
  metal_kit_renderer* _renderer;
  struct recol_audio audio;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  
  _view = (MTKView*) self.view;
  
  _view.device = MTLCreateSystemDefaultDevice();
  _view.clearColor = MTLClearColorMake(
    0.0f,
    0.0f,
    0.0f,
    1.0f
  );
  
  recol_audio_initialize(
    &audio
  );

  _renderer = [[metal_kit_renderer alloc] initWithMetalKitView:_view];
  [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
  [_renderer audio_set: &audio];
  _view.delegate = _renderer;
}

- (void) drawInMTKView: (nonnull MTKView*) _metal_kit_view {
  [_renderer
    drawInMTKView: _metal_kit_view
  ];
}

@end
