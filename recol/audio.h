#ifndef __recol_audio_h
#define __recol_audio_h

#import <AVFAudio/AVFAudio.h>

struct recol_audio {
  AVAudioEngine* engine_audio;
  AVAudioFrameCount frame_count;
  const AudioBufferList* input_data;
  AVAudioSourceNodeRenderBlock render_block;

  float registers[10];
};

void recol_audio_initialize(
  struct recol_audio*
);

#endif
