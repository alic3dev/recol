#include "audio.h"

void recol_audio_initialize(
  struct recol_audio* audio
) {
  audio->frame_count = 0;
  audio->input_data = (void*)0;
  
  AVAudioSession* session_audio_shared = [AVAudioSession sharedInstance];
  
  [session_audio_shared 
    setCategory:AVAudioSessionCategoryPlayAndRecord
    mode:AVAudioSessionModeDefault
    options:AVAudioSessionCategoryOptionMixWithOthers + AVAudioSessionCategoryOptionAllowBluetooth
    error:nil
  ];
  
  [session_audio_shared
    setActive:true
    error:nil
  ];
  
  audio->engine_audio = [[AVAudioEngine alloc] init];
  
  float amplitude = 1.0f;
  float amplitude_2 = 0.1f;
  
  AVAudioMixerNode* node_output = audio->engine_audio.mainMixerNode;
  AVAudioFormat* format_output = [node_output inputFormatForBus:0];
  
  audio->registers[0] = 345.6786786898788687f; 
  audio->registers[1] = 845.6786786898788687f;
  audio->registers[2] = 145.6786786898788687f;
  audio->registers[3] = 245.6786786898788687f;
  audio->registers[4] = 945.6786786898788687f;
  audio->registers[5] = 545.6786786898788687f;
  audio->registers[6] = 365.6786786898788687f;
  audio->registers[7] = 255.6786786898788687f;
  audio->registers[8] = 575.6786786898788687f;
  audio->registers[9] = 915.6786786898788687f;
  
  audio->ff = 0;
  
  __block AVAudioUnitTimePitch* utp = [[AVAudioUnitTimePitch alloc] init];
  utp.pitch = 100.0f;
  utp.rate =  1.0f / 32.0f;
  utp.overlap = 3.0f;
  
  __block AVAudioUnitTimePitch* utp_2 = [[AVAudioUnitTimePitch alloc] init];
  utp.pitch = -34278.23478f;
  utp.rate =  1.0f / 32.0f;;
  utp.overlap = 3.0f;
  
  __block AVAudioUnitTimePitch* utp_3 = [[AVAudioUnitTimePitch alloc] init];
  utp.pitch = -0.0f;
  utp.rate =  1.0f / 32.0f;;
  utp.overlap = 3.0f;
  
  AVAudioSourceNode* node_source = [[AVAudioSourceNode alloc]
    initWithFormat:format_output
    renderBlock: ^OSStatus(
      BOOL * _Nonnull isSilence,
      const AudioTimeStamp * _Nonnull timestamp,
      AVAudioFrameCount frameCount,
      AudioBufferList* _Nonnull outputData
    ) {
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
          audio->registers[0] = audio->registers[0] + (
            audio->registers[0] * 0.89860878f
          );
          
          while (
            audio->registers[0] > 14833928.375892f
          ) {
            audio->registers[0] = audio->registers[0] - 122333.384f;
          }
          while (
            audio->registers[0] > 193324.23482f
          ) {
            audio->registers[0] = audio->registers[0] / 13.73248f;
          }

          while (
            audio->registers[0] < 124.453f
          ) {
            audio->registers[0] = (
              audio->registers[0] * 2.54736f
            );
          };
          
          audio->registers[9] = audio->registers[0];
          
          while (
            audio->registers[9] > 1374839.48239f
          ) {
            audio->registers[9] = (
              audio->registers[9] - 10258.23748f
            );
          }
          while (
            audio->registers[9] > 15489.32847f
          ) {
            audio->registers[9] = (
              audio->registers[9] / 25.42738f
            );
          }
          while (
            audio->registers[9] > 1028.23478f
          ) {
            audio->registers[9] = (
              audio->registers[9] - 133.32478f
            );
          }
          while (
            audio->registers[9] > 489.23478f
          ) {
            audio->registers[9] = (
              audio->registers[9] / 3.2347f
            );
          }
          while (
            audio->registers[9] > 10
          ) {
            audio->registers[9] = (
              audio->registers[9] - 3.23748f
            );
          }
          while (
            audio->registers[9] > 2
          ) {
            audio->registers[9] = audio->registers[9] - 2.0f;
          }
          
          if (audio->ff % 440 == 0) {
            utp.pitch = (int)audio->registers[0] % 12 * -1230.34728f;
          }
    
          if ((int)audio->registers[0] % 21 == 0) {
            audio->registers[4] = (
              (audio->registers[9] - 1.0f) > 0.0f
              ? 1.0f
              : -1.0f
            );
          }
          if (audio->ff % 19 == 0) {
            audio->registers[1] = -(
              (audio->registers[9] - 1.0f) > 0.0f
              ? -1.0f
              : 1.0f
            );
          }
          if (audio->ff % 18 == 0) {
            audio->registers[2] = (
              (audio->registers[9] - 1.0f) > 0.0f
              ? 1.0f
              : -1.0f
            );
          }
          if (audio->ff % 15 == 0) {
            audio->registers[3] = -(
              (audio->registers[9] - 1.0f) > 0.0f
              ? 1.0f
              : -1.0f
            );
          }
          
          audio->registers[5] = (
            audio->registers[4] - 
            (audio->registers[2] / 32.7348f) -
            ((audio->registers[9] - 1.0f) / 56.34728f) -
            (audio->registers[3] / 33.2378f) -
            (audio->registers[1] / 25.34758f)
          );
          
          while (
            audio->registers[5] > 1.0f
          ) {
            audio->registers[5] = (
              audio->registers[5] - 1.0f
            );
          }
          
          while (
            audio->registers[5] < -1.0f
          ) {
            audio->registers[5] = (
              audio->registers[5] - -1.0f
            );
          }
          
          ((float*) outputData->mBuffers[index_buffer].mData)[frame] = (
            audio->registers[5] > 1.0f
            ? audio->registers[5] - 1.0f
            : audio->registers[5] < -1.0f
            ? audio->registers[5] + 1.0f
            : audio->registers[5]
          ) * amplitude;
        }

        audio->ff = audio->ff + 1;
      }
      
      return noErr;
    }
  ];
  
  audio->increment = (
    M_PI * 2 / 44100.0f
  ) * 440;
  
  audio->phase = audio->increment;
  
  AVAudioSourceNode* node_source_2 = [[AVAudioSourceNode alloc]
    initWithFormat:format_output
    renderBlock: ^OSStatus(
      BOOL * _Nonnull isSilence,
      const AudioTimeStamp * _Nonnull timestamp,
      AVAudioFrameCount frameCount,
      AudioBufferList* _Nonnull outputData
    ) {
      if ((int)timestamp->mSampleTime % 2 == 0) {
        audio->registers[6] = ((int)(timestamp->mSampleTime / 152) % 100) + 666.666f;
      }
      if ((int)timestamp->mSampleTime % 5 == 0) {
        audio->registers[7] = ((int)(timestamp->mSampleTime / 291) % 152) + 128.291f;
      }
      if ((int)timestamp->mSampleTime % 151 == 0) {
        audio->registers[8] = ((int)(timestamp->mSampleTime / 291) % 120) / 100;
      }
      
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
        
          audio->increment = (
            M_PI * 2.0f / 44100
          ) * (audio->registers[6] + audio->registers[5] + audio->registers[4] + audio->registers[3] + audio->registers[2] + audio->registers[1]);
          
          audio->increment_2 = (
            M_PI * 2.0f / 44100
          ) * (audio->registers[7] - audio->registers[5] - audio->registers[4] + audio->registers[3] - audio->registers[2] + audio->registers[1]);
          
          audio->increment_3 = (
            M_PI * 2.0f / 44100
          ) * (audio->registers[8] - audio->registers[5] + audio->registers[4] - audio->registers[3] - audio->registers[2] - audio->registers[1]);
        
        
          float value_1 = (2.0f * (audio->phase * (1.0f / (M_PI * 2.0f)))) - 1.0f;
          float value_2 = (2.0f * (audio->phase_2 * (1.0f / M_PI * 2.0f))) - 1.0f;
//          float value_3 = (2.0f * (audio->phase_3 * (1.0f / M_PI * 2.0f))) - 1.0f;
          
          float value = (value_1 / 1.2f) + (value_2 / 2.8f);// + (value_3 / 4);

          ((float*) outputData->mBuffers[index_buffer].mData)[frame] = value * amplitude_2;
          
          audio->phase += audio->increment;

          if (audio->phase >= M_PI * 2.0f) {
            audio->phase -= M_PI * 2.0f;
          }

          if (audio->phase < 0.0f) {
            audio->phase += M_PI * 2.0f;
          }
          
          audio->phase_2 += audio->increment_2;

          if (audio->phase_2 >= M_PI * 2.0f) {
            audio->phase_2 -= M_PI * 2.0f;
          }

          if (audio->phase_2 < 0.0f) {
            audio->phase_2 += M_PI * 2.0f;
          }
          
          audio->phase_3 += audio->increment_3;

          if (audio->phase_3 >= M_PI * 2.0f) {
            audio->phase_3 -= M_PI * 2.0f;
          }

          if (audio->phase_3 < 0.0f) {
            audio->phase_3 += M_PI * 2.0f;
          }
        }

        audio->ff = audio->ff + 1;
      }
      
      return noErr;
    }
  ];
  
  AVAudioUnitDelay* unit_delay = [[AVAudioUnitDelay alloc] init];
  unit_delay.delayTime = 0.35283f;
  unit_delay.feedback = 0.3257328f;
  unit_delay.wetDryMix = 0.483498f;
  [audio->engine_audio attachNode:unit_delay];
  
  AVAudioUnitDelay* unit_delay_2 = [[AVAudioUnitDelay alloc] init];
  unit_delay.delayTime = 0.25283f;
  unit_delay.feedback = 0.4257328f;
  unit_delay.wetDryMix = 0.383498f;
  [audio->engine_audio attachNode:unit_delay];
  
  AVAudioUnitDelay* unit_delay_3 = [[AVAudioUnitDelay alloc] init];
  unit_delay.delayTime = 0.05283f;
  unit_delay.feedback = 0.8257328f;
  unit_delay.wetDryMix = 0.283498f;
  
  AVAudioUnitDistortion* dist = [[AVAudioUnitDistortion alloc] init];
  [dist loadFactoryPreset:AVAudioUnitDistortionPresetSpeechWaves];
  dist.preGain = 20.0f;
  dist.wetDryMix = 1.0f;
  
  [audio->engine_audio attachNode:node_source];
  [audio->engine_audio attachNode:node_source_2];
  [audio->engine_audio attachNode:dist];
  [audio->engine_audio attachNode:unit_delay];
  [audio->engine_audio attachNode:unit_delay_2];
  [audio->engine_audio attachNode:unit_delay_3];
  [audio->engine_audio attachNode:utp];
  [audio->engine_audio attachNode:utp_2];
  [audio->engine_audio attachNode:utp_3];
  
  [audio->engine_audio connect:node_source to:unit_delay format:format_output];
  [audio->engine_audio connect:node_source_2 to:node_output format:format_output];
  
  [audio->engine_audio connect:unit_delay to:unit_delay_2 format:format_output];
  [audio->engine_audio connect:unit_delay_2 to:unit_delay_3 format:format_output];

  [audio->engine_audio connect:unit_delay_3 to:utp format:format_output];
  [audio->engine_audio connect:utp to:dist format:format_output];
  [audio->engine_audio connect:dist to:utp_2 format:format_output];
  [audio->engine_audio connect:utp_2 to:utp_3 format:format_output];
  
  AVAudioMixerNode* mix = [[AVAudioMixerNode alloc] init];
  mix.volume = 0.666f;
  
  [audio->engine_audio attachNode:mix];
  [audio->engine_audio connect:utp_3 to:mix format:format_output];
  [audio->engine_audio connect:mix to:node_output format:format_output];

  [audio->engine_audio startAndReturnError:nil];
}
