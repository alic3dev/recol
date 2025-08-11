#ifndef __recol_audio_h
#define __recol_audio_h

#import <AVFAudio/AVFAudio.h>

struct recol_audio {
  AVAudioEngine* engine_audio;
  AVAudioSourceNodeRenderBlock render_block;

  float registers[10];
  
  float* note_table;
  unsigned int length_note_table;
  
  const unsigned char* scale;
  unsigned char length_scale;
  
  float amplitude;
};

void recol_audio_initialize(
  struct recol_audio*
);

void recol_audio_destroy(
  struct recol_audio*
);

#endif
