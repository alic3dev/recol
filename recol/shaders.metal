#include "shader_types.h"

struct metal_kit_rasterizer_data {
  float4 position [[position]];
  float4 color;
};

vertex metal_kit_rasterizer_data metal_kit_vertex_shader(
  uint id_vertex [[vertex_id]],
  constant metal_kit_vertex* vertices [[buffer(metal_kit_vertex_input_index_vertices)]],
  constant vector_uint2* pointer_size_viewport [[buffer(metal_kit_vertex_input_index_viewport_size)]]
) {
  metal_kit_rasterizer_data data_out;

  float2 position_space_pixel = vertices[id_vertex].position.xy;

  vector_float2 size_viewport = vector_float2(*pointer_size_viewport);

  data_out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
  data_out.position.xy = position_space_pixel / (size_viewport / 2.0);

  data_out.color = vertices[id_vertex].color;

  return data_out;
}

fragment float4 metal_kit_fragment_shader(
  metal_kit_rasterizer_data data_in [[stage_in]]
) {
  return data_in.color;
}
