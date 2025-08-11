#ifndef __metal_kit_shader_types_h
#define __metal_kit_shader_types_h

#include <simd/simd.h>

typedef enum metal_kit_vertex_input_index {
    metal_kit_vertex_input_index_vertices = 0,
    metal_kit_vertex_input_index_viewport_size = 1,
    metal_kit_vertex_input_index_frame_count = 2,
    metal_kit_vertex_input_index_buffer_count = 3,
    metal_kit_vertex_input_index_buffer = 4,
    metal_kit_vertex_input_index_registers = 5
} metal_kit_vertex_input_index;

typedef struct {
    vector_float2 position;
    vector_float4 color;
} metal_kit_vertex;

#endif
