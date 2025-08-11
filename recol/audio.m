#include "audio.h"

#include "cer0.h"

void recol_audio_initialize(
  struct recol_audio* audio
) {
  audio->frame_count = 0;
  audio->input_data = (void*)0;
  
  float* note_table = cer0_note_table_create(
    0,
    6,
    cer0_frequency_root_scientific
  );
  
  unsigned int length_note_table = cer0_note_table_length(
    0,
    6
  );
  
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
  
  float amplitude = 1.0f;
  
  AVAudioMixerNode* node_output = audio->engine_audio.mainMixerNode;
  AVAudioFormat* format_output = [node_output inputFormatForBus:0];
  
  audio->registers[0] = 0.0f; 
  audio->registers[1] = 0.0f;
  audio->registers[2] = 0.0f;
  audio->registers[3] = 0.0f;
  audio->registers[4] = 0.0f;
  audio->registers[5] = 0.0f;
  audio->registers[6] = note_table[15];
  audio->registers[7] = 0.0f;
  audio->registers[8] = 0.0f;
  audio->registers[9] = 0.0f;
  
  __block unsigned int buffer_length = 0;
  __block unsigned int buffer_size = 0;
  __block float** buffer = (void*)0;
  
  __block struct cer0_phase phase;
  
  cer0_phase_initialize(
    &phase,
    format_output.sampleRate,
    audio->registers[6]
  );
  
  audio->registers[5] = phase.value;
  
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
      
      if ((int) audio->registers[7] % 16 == 0) {
        audio->registers[9] = (
          audio->registers[9] + 1
        );

        cer0_phase_frequency_set(
          &phase,
          note_table[
            cer0_scale_notes_octatonic_diminished[
              (int) audio->registers[9] % cer0_scale_length_octatonic_diminished
            ] + 36
          ]
        );
      }
      
      audio->registers[6] = phase.frequency;
      
      for (
        unsigned int frame = 0;
        frame < frameCount;
        ++frame
      ) {
        for (
          unsigned int index_buffer = 0;
          index_buffer < outputData->mNumberBuffers;
          ++index_buffer
        ) {
          audio->registers[5] = phase.value;
          
          float value = cer0_signal_triangle(
            audio->registers[5]
          );
          
          if (
            index_buffer < buffer_length &&
            frame < buffer_size
          ) {
            buffer[index_buffer][frame] = (
              (buffer[index_buffer][frame] * 0.7f) + 
              (value * 0.3f)
            );
          }

          ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
            (value * 0.3f) + (buffer[index_buffer][frame] * 0.7f)
          ) * amplitude;
          
          cer0_phase_poll(
            &phase
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
