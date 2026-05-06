#include <recol_scene.h>

#include <recol_audio.h>

#include <clic3_memory.h>

#include <math_c_vector.h>

#include <metil.h>
#include <metil_audio/metil_audio_io_proc.h>
#include <metil_object/metil_object.h>
#include <metil_object/metil_object_buffer.h>
#include <metil_rendering/metil_renderable_type.h>
#include <metil_scenes/metil_scene.h>

void recol_scene_initialize(
  struct metil* metil,
  struct metil_scene* metil_scene
) {
  metil_scene_initialize_with_renderables(
    metil,
    metil_scene,
    0x01
  );

  metil_renderable_initialize_at_index(
    metil_scene->renderables,
    0x00,
    metil_renderable_type_object
  );

  struct math_c_vector2_unsigned_char size = {
    .x = (
      55
    ),
    .y = (
      65
    )
  };

  struct metil_object* metil_object = (
    metil_scene->renderables[
      0x00
    ].renderable
  );

  metil_mesh_initialize_with_lengths(
    &metil_object->mesh,
    (
      size.x *
      size.y
    ),
    (
      size.x *
      size.y
    )
  );  

  unsigned short int index_vertex = (
    0x00
  );  for (
    unsigned short int index_y = (
      0x00
    );
    (
      index_y <
      size.y
    );
    ++index_y
  ) {
    for (
      unsigned short int index_x = (
        0x00
      );
      (
        index_x <
        size.x
      );
      ++index_x
    ) {
      metil_object->mesh.vertices[
        index_vertex
      ].x = (
        (float)
        index_x /
        (float)
        (
          size.x -
          0x01
        )
      );

      metil_object->mesh.vertices[
        index_vertex
      ].y = (
        (float) index_y /
        (float)
        (
          size.y -
          0x01
        )
      );

      metil_object->mesh.vertices[
        index_vertex
      ].z = (
        0x00
      );

      metil_object->mesh.vertices[
        index_vertex
      ].w = (
        0x01
      );


      metil_object->mesh.indices[
        index_vertex
      ] = (
        index_vertex
      );

      index_vertex = (
        index_vertex +
        0x01
      );
    }
  }

  metil_object_buffers_initialize(
    metil_object,
    metil->renderer_interface.metal_device
  );

  metil_object_buffers_add(
    metil_object,
    metil->renderer_interface.metal_device,
    metil_object_buffer_type_vertex
  );

  metil_object->buffers_vertex[
    metil_object->length_buffers_vertex -
    0x01
  ].buffer = [
    metil->renderer_interface.metal_device
    newBufferWithLength: (
      sizeof(
        float
      ) *
      0x0a
    )
    options: MTLResourceStorageModeShared
  ];

  metil_object->type_primitive = (
    MTLPrimitiveTypePoint
  );

  metil_scene->data = (
    clic3_memory_allocate_raw(
      sizeof(
        struct recol_audio
      )
    )
  );

  recol_audio_initialize(
    metil,
    metil_scene->data
  );

  metil_audio_io_proc_add_with_data(
    &metil->audio,
    recol_audio_io_proc,
    metil_scene->data
  );

  metil_scene->poll = (
    recol_scene_poll
  );

  metil_scene->destroy = (
    recol_scene_destroy
  );
}

void recol_scene_poll(
  struct metil* metil,
  struct metil_scene* metil_scene
) {
  struct recol_audio* recol_audio = (
    metil_scene->data
  );

  struct metil_object* metil_object = (
    metil_scene->renderables[
      0x00
    ].renderable
  );

  float* registers = (
    metil_object->buffers_vertex[
      metil_object->length_buffers_vertex -
      0x01
    ].buffer.contents
  );

  for (
    unsigned char index_register = (
      0x00
    );
    (
      index_register <
      0x0a
    );
    ++index_register
  ) {
    registers[
      index_register
    ] = (
      recol_audio->registers[
        index_register
      ]
    );
  }  }

void recol_scene_destroy(
  struct metil* metil,
  struct metil_scene* metil_scene
) {
  metil_audio_io_proc_remove(
    &metil->audio,
    recol_audio_io_proc
  );

  recol_audio_destroy(
    metil_scene->data
  );
}
