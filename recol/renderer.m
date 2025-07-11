#import <simd/simd.h>
#import <ModelIO/ModelIO.h>

#import "renderer.h"
#import "shader_types.h"

@implementation Renderer {
  id<MTLDevice> metal_kit_device;
  id<MTLCommandQueue> command_queue;
  id<MTLRenderPipelineState> state_pipeline;
  vector_uint2 size_viewport;
  
  int frame;
  char direction_frame;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView*) metal_kit_view {
  self = [super init];
  
  if (!self) {
    return self;
  }
  
  frame = 0;
  direction_frame = 1;

  metal_kit_device = metal_kit_view.device;

  id<MTLLibrary> metal_kit_library = [metal_kit_device
    newDefaultLibrary
  ];
  
  id<MTLFunction> metal_kit_vertex_shader = [metal_kit_library
    newFunctionWithName: @"metal_kit_vertex_shader"
  ];
  
  id<MTLFunction> metal_kit_fragment_shader = [metal_kit_library
    newFunctionWithName: @"metal_kit_fragment_shader"
  ];

  MTLRenderPipelineDescriptor* state_descriptor_pipeline = [
    [MTLRenderPipelineDescriptor alloc]
    init
  ];

  state_descriptor_pipeline.label = @"metal_kit_pipeline";
  state_descriptor_pipeline.vertexFunction = metal_kit_vertex_shader;
  state_descriptor_pipeline.fragmentFunction = metal_kit_fragment_shader;
  state_descriptor_pipeline.colorAttachments[0].pixelFormat = metal_kit_view.colorPixelFormat;

  NSError* error_state_pipeline;
  state_pipeline = [metal_kit_device
    newRenderPipelineStateWithDescriptor: state_descriptor_pipeline
    error: &error_state_pipeline
  ];

  if (!state_pipeline) {
    fprintf(
      stderr,
      "Failed to create pipeline state[%li]: %s",
      error_state_pipeline.code,
      [error_state_pipeline.localizedDescription
        cStringUsingEncoding: NSUTF8StringEncoding
      ]
    );
  }

  command_queue = [metal_kit_device
    newCommandQueue
  ];

  return self;
}

- (void) _loadMetalWithView:(nonnull MTKView*)view; {
  view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
  view.sampleCount = 1;
}

- (void) drawInMTKView:(nonnull MTKView*) metal_kit_view {
  const metal_kit_vertex vertices_square[] = {
    {{ 250 + frame, -250 - frame }, { 1, 0, 0, 1 }},
    {{ -250 - frame, -250 - frame }, { 0, 0, 1, 1 }},
    {{ -250 - frame, 250 + frame }, { 1, 0, 1, 1 }},
    {{ -250 - frame, 250 + frame }, { 1, 0, 1, 1 }},
    {{ 250 + frame, 250 + frame }, { 0, 0, 1, 1 }},
    {{ 250 + frame, -250 - frame }, { 1, 0, 0, 1 }}
  };

  frame = (
    frame + direction_frame
  );

  if (frame == 100 || frame == 0) {
    direction_frame = -direction_frame;
  }

  id<MTLCommandBuffer> command_buffer = [command_queue
    commandBuffer
  ];
  command_buffer.label = @"metal_kit_renderer_command_buffer";

  MTLRenderPassDescriptor* metal_kit_render_pass_descriptor = metal_kit_view.currentRenderPassDescriptor;

  if (metal_kit_render_pass_descriptor != nil) {
    id<MTLRenderCommandEncoder> metal_kit_render_encoder = [command_buffer
      renderCommandEncoderWithDescriptor: metal_kit_render_pass_descriptor
    ];

    metal_kit_render_encoder.label = @"metal_kit_renderer_encoder";

    [metal_kit_render_encoder
      setViewport: (MTLViewport) {
      0.0,
      0.0,
      size_viewport.x,
      size_viewport.y,
      0.0,
      1.0
    }];
    
    [metal_kit_render_encoder
      setRenderPipelineState:state_pipeline
    ];

    [metal_kit_render_encoder
      setVertexBytes: vertices_square
      length: sizeof(vertices_square)
      atIndex: metal_kit_vertex_input_index_vertices
    ];
    
    [metal_kit_render_encoder 
      setVertexBytes: &size_viewport
      length: sizeof(size_viewport)
      atIndex: metal_kit_vertex_input_index_viewport_size
    ];

    [metal_kit_render_encoder
      drawPrimitives: MTLPrimitiveTypeTriangle
      vertexStart: 0
      vertexCount: 6
    ];

    [metal_kit_render_encoder 
      endEncoding
    ];

    [command_buffer
      presentDrawable: metal_kit_view.currentDrawable
    ];
  }

  [command_buffer
    commit
  ];
}

- (void)mtkView:(nonnull MTKView*) metal_kit_view drawableSizeWillChange:(CGSize) size {
  size_viewport.x = size.width;
  size_viewport.y = size.height;

  float size_combined = size.width + size.height;

  metal_kit_view.clearColor = MTLClearColorMake(
    fmod(size_combined, 100.0f) / 100.0f,
    fmod(size_combined + 33.33f, 100.0f) / 100.0f,
    fmod(size_combined + 66.66f, 100.0f) / 100.0f,
    1.0f
  );
}

@end
