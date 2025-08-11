#include <audio.h>

#include <cer0.h>

const unsigned char count_scales = 5;

const unsigned char* scales[count_scales] = {
  cer0_scale_notes_octatonic_diminished,
  cer0_scale_notes_altered,
  cer0_scale_notes_hirajoshi,
  cer0_scale_notes_hungarian_gypsy,
  cer0_scale_notes_melodic_minor_descending
};

const unsigned char length_scales[count_scales] = {
  cer0_scale_length_octatonic_diminished,
  cer0_scale_length_altered,
  cer0_scale_length_hirajoshi,
  cer0_scale_length_hungarian_gypsy,
  cer0_scale_length_melodic_minor_descending
};

void recol_audio_initialize(
  struct recol_audio* audio
) {
  audio->note_table = cer0_note_table_create(
    0,
    6,
    cer0_frequency_root_scientific
  );
  
  audio->length_note_table = cer0_note_table_length(
    0,
    6
  );
  
  audio->scale = scales[1];
  audio->length_scale = length_scales[1];
  
  AVAudioSession* session_audio_shared = [AVAudioSession sharedInstance];
  
  [session_audio_shared 
    setCategory: AVAudioSessionCategoryPlayback
    mode:AVAudioSessionModeDefault
    options:AVAudioSessionCategoryOptionMixWithOthers
    error:nil
  ];
  
  [session_audio_shared
    setActive:true
    error:nil
  ];
  
  audio->engine_audio = [[AVAudioEngine alloc] init];
  
  audio->amplitude = 1.0f;
  
  AVAudioMixerNode* node_output = audio->engine_audio.mainMixerNode;
  AVAudioFormat* format_output = [node_output inputFormatForBus:0];
  
  audio->registers[0] = 0.0f; 
  audio->registers[1] = 0.0f;
  audio->registers[2] = 0.0f;
  audio->registers[3] = 0.0f;
  audio->registers[4] = audio->note_table[12];
  audio->registers[5] = 0.0f;
  audio->registers[6] = audio->note_table[15];
  audio->registers[7] = 0.0f;
  audio->registers[8] = 0.0f;
  audio->registers[9] = 0.0f;
  
  __block unsigned int buffer_length = 0;
  __block unsigned int buffer_size = 0;
  __block float** buffer = (void*)0;
  
  __block struct cer0_phase phase;
  __block struct cer0_phase phase_secondary;
  
  cer0_phase_initialize(
    &phase,
    format_output.sampleRate,
    audio->registers[6]
  );
  
  cer0_phase_initialize(
    &phase_secondary,
    format_output.sampleRate,
    audio->registers[4]
  );
  
  audio->registers[5] = phase.value;
  audio->registers[3] = phase_secondary.value;
  
  AVAudioSourceNode* node_source = [[AVAudioSourceNode alloc]
    initWithFormat:format_output
    renderBlock: ^OSStatus(
      BOOL * _Nonnull isSilence,
      const AudioTimeStamp * _Nonnull timestamp,
      AVAudioFrameCount frameCount,
      AudioBufferList* _Nonnull outputData
    ) {
      if (buffer == (void*)0) {
        buffer_length = outputData->mNumberBuffers;
        buffer_size = frameCount;
        buffer = malloc(
          sizeof(float*) * buffer_length
        );
        
        for (
          unsigned int index_buffer = 0;
          index_buffer < buffer_length;
          ++index_buffer
        ) {
          buffer[
            index_buffer
          ] = malloc(
            sizeof(float) * buffer_size
          );
          
          for (
            unsigned int index_frame = 0;
            index_frame < frameCount;
            ++index_frame
          ) {
            buffer[
              index_buffer
            ][
              index_frame
            ] = 0.0f;
          }
        }
      }
      
      for (
        unsigned int frame = 0;
        frame < frameCount;
        ++frame
      ) {
        if ((int) audio->registers[7] % 4222 == 0) {
          audio->registers[9] = (
            audio->registers[9] + 1.0f
          );

          cer0_phase_frequency_set(
            &phase,
            audio->note_table[
              audio->scale[
                (int) audio->registers[9] % audio->length_scale
              ] + 12
            ]
          );
        }
        
        if ((int) audio->registers[7] % 6444 == 0) {
          audio->registers[0] = (
            audio->registers[0] + ((float) audio->length_scale * 4328.23489f)
          );

          cer0_phase_frequency_set(
            &phase_secondary,
            audio->note_table[
              audio->scale[
                (int) audio->registers[0] % audio->length_scale
              ] + 24
            ]
          );
        }

        if ((int) audio->registers[7] % 73289 == 0) {
          audio->scale = scales[(int) audio->registers[7] % count_scales];
          audio->length_scale = length_scales[(int) audio->registers[7] % count_scales];
        }

        for (
          unsigned int index_buffer = 0;
          index_buffer < outputData->mNumberBuffers;
          ++index_buffer
        ) {
          audio->registers[6] = phase.frequency;
          audio->registers[4] = phase.frequency;

          audio->registers[5] = phase.value;
          audio->registers[3] = phase_secondary.value;
          
          float value = (cer0_signal_triangle(
            audio->registers[5]
          ) * 0.6f) + (cer0_signal_square(
            audio->registers[3]
          ) * 0.4f);
          
          if (
            index_buffer < buffer_length &&
            frame < buffer_size
          ) {
            buffer[index_buffer][frame] = (
              (buffer[index_buffer][frame] * 0.9f) + 
              (value * 0.1f)
            );
          }

          ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
            (value * 0.1f) + (buffer[index_buffer][frame] * 0.9f)
          ) * audio->amplitude;
          
          cer0_phase_poll(
            &phase
          );
          
          cer0_phase_poll(
            &phase_secondary
          );
        }

        audio->registers[7] = (
          audio->registers[7] + 1.0f
        );
      }
      
      return noErr;
    }
  ];
  
  [audio->engine_audio attachNode:node_source];

  [audio->engine_audio connect:node_source to:node_output format:format_output];
  
  [audio->engine_audio startAndReturnError:nil];
}

void recol_audio_destroy(
  struct recol_audio* audio
) {
  free(audio->note_table);

  [audio->engine_audio stop];
}
