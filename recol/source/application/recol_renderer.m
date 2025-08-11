#include <application/recol_renderer.h>

#include <audio.h>
#include <shader_types.h>

#include <MetalKit/MetalKit.h>
#include <simd/simd.h>

@implementation recol_renderer {
  id<MTLDevice> metal_kit_device;
  id<MTLCommandQueue> command_queue;
  id<MTLRenderPipelineState> state_pipeline;
  vector_uint2 size_viewport;
  
  AVAudioFrameCount frame_count;
  const AudioBufferList* input_data; 

  int frame;
  char direction_frame;
  
  struct recol_audio* audio;
  
  vector_uint2 size;
  unsigned short int length_vertices;
}

- (nonnull instancetype) initWithMetalKitView: (nonnull MTKView*) metal_kit_view {
  self = [super init];
  
  if (!self) {
    return self;
  }
  
  size.x = 52;
  size.y = 78;
  
  length_vertices = size.x * size.y;

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

- (void) audio_set: (struct recol_audio*) audio {
  self->audio = audio;
}

- (void) data_set: (AVAudioFrameCount) frame_count input_data: (const AudioBufferList*) input_data {
  self->frame_count = frame_count;
  self->input_data = input_data;
} 

- (void)drawInMTKView: (nonnull MTKView*) metal_kit_view {
  size.x = 55;
  size.y = 65;
  
  length_vertices = size.x * size.y;
  
  vector_float2 vertices_square[length_vertices];
  
  for (
    unsigned short int index_y = 0;
    index_y < size.y;
    ++index_y
  ) {
    for (
      unsigned short int index_x = 0;
      index_x < size.x;
      ++index_x
    ) {
      unsigned short int offset_index = index_y * size.x;
      
      vertices_square[index_x + offset_index].x = (float)index_x / (float)(size.x - 1);
      vertices_square[index_x + offset_index].y = (float)index_y / (float)(size.y - 1);
    }
  }

  frame = (
    frame + direction_frame
  );

  if (frame == 100 || frame == 0) {
    direction_frame = -direction_frame;
  }

  id<MTLCommandBuffer> command_buffer = [command_queue
    commandBuffer
  ];
  command_buffer.label = @"recol_renderer_command_buffer";

  MTLRenderPassDescriptor* metal_kit_render_pass_descriptor = metal_kit_view.currentRenderPassDescriptor;

  if (metal_kit_render_pass_descriptor != nil) {
    id<MTLRenderCommandEncoder> metal_kit_render_encoder = [command_buffer
      renderCommandEncoderWithDescriptor: metal_kit_render_pass_descriptor
    ];

    metal_kit_render_encoder.label = @"recol_renderer_encoder";

    [metal_kit_render_encoder
      setViewport: (MTLViewport) {
      0.0f,
      0.0f,
      size_viewport.x,
      size_viewport.y,
      0.0f,
      1000000.0f
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
      setVertexBytes: audio->registers
      length: sizeof(float) * 10
      atIndex: metal_kit_vertex_input_index_registers
    ];

    [metal_kit_render_encoder 
      setVertexBytes: &size_viewport
      length: sizeof(size_viewport)
      atIndex: metal_kit_vertex_input_index_viewport_size
    ];

    [metal_kit_render_encoder
      drawPrimitives: MTLPrimitiveTypePoint
      vertexStart: 0
      vertexCount: length_vertices
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

- (void) mtkView: (nonnull MTKView*) metal_kit_view drawableSizeWillChange: (CGSize) size {
  size_viewport.x = size.width;
  size_viewport.y = size.height;
}

@end
