#include "shader_types.h"

struct metal_kit_rasterizer_data {
  float4 position [[position]];
  float4 color;
};

vertex metal_kit_rasterizer_data metal_kit_vertex_shader(
  uint id_vertex [[vertex_id]],
  constant vector_float2* vertices [[buffer(metal_kit_vertex_input_index_vertices)]],
  constant vector_uint2* pointer_size_viewport [[buffer(metal_kit_vertex_input_index_viewport_size)]],
  constant float* registers [[buffer(metal_kit_vertex_input_index_registers)]]
) {
  metal_kit_rasterizer_data data_out;

  float2 position_space_pixel = vertices[id_vertex].xy;

  data_out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
  data_out.position.x = position_space_pixel.x - 1.0f;
  data_out.position.y = 2.0f * position_space_pixel.y - 1.0f;
  
  unsigned char offset_register = (int)(((position_space_pixel.x * position_space_pixel.y)) * 23874.23874f) % 8;

  data_out.color = vector_float4(
    ((float)((int)registers[offset_register] % 1000)) / 1000.0f,
    registers[offset_register + 1],
    registers[offset_register + 2],
    1.0f
  );

  return data_out;
}

fragment float4 metal_kit_fragment_shader(
  metal_kit_rasterizer_data data_in [[stage_in]]
) {
  return data_in.color;
}
