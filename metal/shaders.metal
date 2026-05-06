#include <metil_rendering/metil_renderer_vertex_index_parameter.h>

struct recol_data_vertex {  float4 position [[position]];
  float point_size [[point_size]];
  float4 colour;
};

vertex struct recol_data_vertex recol_vertex(
  constant float4* vertices [[
    buffer(
      metil_renderer_vertex_index_parameter_vertices
    )
  ]],
  constant struct metil_renderer_data_frame* data_frame [[
    buffer(
      metil_renderer_vertex_index_parameter_data_frame
    )
  ]],
  constant struct metil_renderer_data_object* data_object [[
    buffer(
      metil_renderer_vertex_index_parameter_data_object
    )
  ]],
  constant float* registers [[
    buffer(
      metil_renderer_vertex_index_parameter_data_object +
      0x01
    )
  ]],
  unsigned int index_vertex [[vertex_id]]
) {
  struct recol_data_vertex recol_data_vertex;

  float4 position_space_pixel = (
    vertices[
      index_vertex
    ]
  );

  recol_data_vertex.position = vector_float4(0.0, 0.0, 0.0, 1.0);

  recol_data_vertex.position.x = (position_space_pixel.x - 0.5f) * 1.95f;

  recol_data_vertex.position.y = (position_space_pixel.y - 0.5f) * 1.75f;

  unsigned char offset_register = (int)(((position_space_pixel.x + position_space_pixel.y) * registers[9])) % 8;

  recol_data_vertex.colour = vector_float4(
    ((float) ((int) registers[offset_register] % 10)) / 10.0f,
    ((float) ((int) registers[offset_register + 1] % 10)) / 10.0f,
    ((float) ((int) registers[offset_register + 2] % 10)) / 10.0f,
    0x01
  );
  
  recol_data_vertex.point_size = (
    0x0e
  );

  return (
    recol_data_vertex  );
}

fragment float4 recol_fragment(
  struct recol_data_vertex data_in [[stage_in]]
) {
  return (
    data_in.colour
  );
}
