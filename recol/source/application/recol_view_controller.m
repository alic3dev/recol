#include <application/recol_view_controller.h>

#include <application/recol_renderer.h>
#include <audio.h>
#include <termination.h>

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

static struct recol_audio audio;

@implementation recol_view_controller {
  MTKView* _view;
  recol_renderer* _renderer;
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
  
  termination_on_function_add(
    recol_view_controller_on_termination
  );

  _renderer = [[recol_renderer alloc] initWithMetalKitView:_view];
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

void recol_view_controller_on_termination(void) {
  recol_audio_destroy(
    &audio
  );
}
