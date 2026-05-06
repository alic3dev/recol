#ifndef __recol_audio_h
#define __recol_audio_h

#include <cer0_phase.h>

#include <metil.h>

#define recol_length_scales 0x05
#define recol_length_registers 0x0a

struct recol_audio {
  float registers[
    0x0a
  ];
  
  float* _Nonnull note_table;
  unsigned int length_note_table;
  
  const unsigned char* _Nonnull scale;
  unsigned char length_scale;
  
  float amplitude;

  float* _Nonnull * _Nonnull buffer;
  unsigned int length_buffer;
  unsigned int size_buffer;

  struct cer0_phase phase;
  struct cer0_phase phase_secondary;
};

void recol_audio_initialize(
  struct metil* _Nonnull,
  struct recol_audio* _Nonnull
);

metil_audio_io_proc_macro_type(
  recol_audio_io_proc
);

void recol_audio_destroy(
  struct recol_audio* _Nonnull
);

#endif
