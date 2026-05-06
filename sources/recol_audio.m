#include <recol_audio.h>

#include <cer0.h>

#include <clic3_memory.h>

#include <metil.h>
#include <metil_audio/metil_audio_io_proc.h>
#include <metil_audio/metil_audio_io_proc_data.h>

const unsigned char* scales[
  recol_length_scales
] = {
  cer0_scale_notes_octatonic_diminished,
  cer0_scale_notes_altered,
  cer0_scale_notes_hirajoshi,
  cer0_scale_notes_hungarian_gypsy,
  cer0_scale_notes_melodic_minor_descending
};

const unsigned char length_scales[
  recol_length_scales
] = {
  cer0_scale_length_octatonic_diminished,
  cer0_scale_length_altered,
  cer0_scale_length_hirajoshi,
  cer0_scale_length_hungarian_gypsy,
  cer0_scale_length_melodic_minor_descending
};

void recol_audio_initialize(
  struct metil* metil,
  struct recol_audio* recol_audio
) {
  recol_audio->note_table = (
    cer0_note_table_create(
      0x00,
      0x06,
      cer0_frequency_root_scientific
    )
  );
  
  recol_audio->length_note_table = (
    cer0_note_table_length(
      0x00,
      0x06
    )
  );
  
  recol_audio->scale = (
    scales[
      0x01
    ]
  );

  recol_audio->length_scale = (
    length_scales[
      0x01
    ]
  );

  recol_audio->registers[
    0x00
  ] = (
    0x0
  );
 
  recol_audio->registers[
    0x01
  ] = (
    0x0
  );

  recol_audio->registers[
    0x02
  ] = (
    0x0
  );

  recol_audio->registers[
    0x03
  ] = (
    0x0
  );

  recol_audio->registers[
    0x04
  ] = (
    recol_audio->note_table[
      0x0c
    ]
  );

  recol_audio->registers[
    0x05
  ] = (
    0x0
  );

  recol_audio->registers[
    0x06
  ] = (
    recol_audio->note_table[
      0x0f
    ]
  );

  recol_audio->registers[
    0x07
  ] = (
    0x0
  );

  recol_audio->registers[
    0x08
  ] = (
    0x0
  );

  recol_audio->registers[
    0x09
  ] = (
    0x0
  );
  
  cer0_phase_initialize(
    &recol_audio->phase,
    metil->audio.audio_output.sample_rate,
    recol_audio->registers[6]
  );
  
  cer0_phase_initialize(
    &recol_audio->phase_secondary,
    metil->audio.audio_output.sample_rate,
    recol_audio->registers[4]
  );
  
  recol_audio->registers[5] = (
    recol_audio->phase.value
  );
  
  recol_audio->registers[3] = (
    recol_audio->phase_secondary.value
  );

  recol_audio->buffer = (
    0x00
  );
}

metil_audio_io_proc_macro_definition(
  recol_audio_io_proc
) {
  metil_audio_io_proc_macro_definition_initializer;

  struct recol_audio* recol_audio = (
    metil_audio_io_proc_data->data
  );

  if (
    recol_audio->buffer ==
    0x00
  ) {      recol_audio->length_buffer = (
        output_data->mNumberBuffers
      );
      
      recol_audio->size_buffer = (
        length_frames
      );
      
      recol_audio->buffer = (
        clic3_memory_allocate_raw(
          sizeof(
            void*
          ) *
          recol_audio->length_buffer
        )
      );
        
        for (
          unsigned int index_buffer = (
            0x00
          );
          (
            index_buffer <
            recol_audio->length_buffer
          );
          ++index_buffer
        ) {
          recol_audio->buffer[
            index_buffer
          ] = (
            clic3_memory_allocate_raw(
              sizeof(
                float
              ) *
              recol_audio->size_buffer
            )
          );
          
          for (
            unsigned int index_frame = (
              0x00
            );
            (
              index_frame <
              length_frames
            );
            ++index_frame
          ) {
            recol_audio->buffer[
              index_buffer
            ][
              index_frame
            ] = (
              0x00
            );
          }
        }
      }
      
      for (
        unsigned int frame = (
          0x00
        );
        (
          frame <
          length_frames
        );
        ++frame
      ) {
        if (
          (int)
          recol_audio->registers[
            0x07
          ] %
          4222 ==
          0x00
        ) {
          recol_audio->registers[
            0x09
          ] = (
            recol_audio->registers[
              0x09
            ] +
            0x01
          );

          cer0_phase_frequency_set(
            &recol_audio->phase,
            recol_audio->note_table[
              recol_audio->scale[
                (int)
                recol_audio->registers[
                  0x09
                ] %
                recol_audio->length_scale
              ] +
              0x0c
            ]
          );
        }
        
        if (
          (int)
          recol_audio->registers[7] %
          6444 ==
          0x00
        ) {
          recol_audio->registers[0] = (
            recol_audio->registers[0] + ((float) recol_audio->length_scale * 4328.23489f)
          );

          cer0_phase_frequency_set(
            &recol_audio->phase_secondary,
            recol_audio->note_table[
              recol_audio->scale[
                (int)
                recol_audio->registers[
                  0x00
                ] %
                recol_audio->length_scale
              ] +
              24
            ]
          );
        }

        if (
          (int)
          recol_audio->registers[
            0x07
          ] %
          73289 ==
          0x00
        ) {
          recol_audio->scale = (
            scales[
              (int)
              recol_audio->registers[
                0x07
              ] %
              recol_length_scales
            ]
          );

          recol_audio->length_scale = (
            length_scales[
              (int)
              recol_audio->registers[7] %
              recol_length_scales
            ]
          );
        }

        for (
          unsigned int index_buffer = 0;
          index_buffer < output_data->mNumberBuffers;
          ++index_buffer
        ) {
          recol_audio->registers[6] = recol_audio->phase.frequency;
          recol_audio->registers[4] = recol_audio->phase.frequency;

          recol_audio->registers[5] = recol_audio->phase.value;
          recol_audio->registers[3] = recol_audio->phase_secondary.value;
          
          float value = (cer0_signal_triangle(
            recol_audio->registers[5]
          ) * 0.6f) + (cer0_signal_square(
            recol_audio->registers[3]
          ) * 0.4f);
  ((float*) output_data->mBuffers[index_buffer].mData)[frame] = value * 0.5f;
/*
          if (
            index_buffer < recol_audio->length_buffer &&
            frame < recol_audio->size_buffer
          ) {
            recol_audio->buffer[index_buffer][frame] = (
              (recol_audio->buffer[index_buffer][frame] * 0.9f) + 
              (value * 0.1f)
            );
          }

          ((float*) output_data->mBuffers[index_buffer].mData)[frame] = (
            (value * 0.1f) + (recol_audio->buffer[index_buffer][frame] * 0.9f)
          ) * recol_audio->amplitude;*/
   
          cer0_phase_poll(
            &recol_audio->phase
          );
          
          cer0_phase_poll(
            &recol_audio->phase_secondary
          );
        }

        recol_audio->registers[7] = (
          recol_audio->registers[7] + 1.0f
        );
      }
      
      return (
        0x00
      );
}

void recol_audio_destroy(
  struct recol_audio* audio
) {
  clic3_memory_free_raw(
    audio->note_table
  );
}
