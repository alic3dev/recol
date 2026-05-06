#ifndef __recol_scene_h
#define __recol_scene_h

#include <metil.h>
#include <metil_scenes/metil_scene.h>

void recol_scene_initialize(
  struct metil* _Nonnull,
  struct metil_scene* _Nonnull
);

void recol_scene_poll(
  struct metil* _Nonnull,
  struct metil_scene* _Nonnull
);

void recol_scene_destroy(
  struct metil* _Nonnull,
  struct metil_scene* _Nonnull
);

#endif
