#ifndef __recol_h
#define __recol_h

#include <metil.h>

extern char* _Nonnull recol_executable_path;

int main(
  int,
  char* _Nonnull * _Nonnull
);

void recol_view_controller_on_view_did_load();

void recol_renderer_on_initialize(
  struct metil* _Nonnull,
  void* _Nullable
);

#endif
