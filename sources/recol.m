#include <recol.h>

#include <recol_scene.h>

#include <clic3_memory.h>

#include <metil_application/metil_application.h>
#include <metil_application/metil_application_delegate.h>
#include <metil_application/metil_view_controller.h>
#include <metil_initialize.h>
#include <metil_library.h>
#include <metil_scenes/metil_scene_controller.h>

#include <UIKit/UIKit.h>

char* recol_executable_path;

int main(
  int length_parameters,
  char** parameters
) {
  recol_executable_path = (
    parameters[
      0x00
    ]
  );

  metil_view_controller_on_view_did_load = (
    recol_view_controller_on_view_did_load
  );

  return UIApplicationMain(
    length_parameters,
    parameters,
    NSStringFromClass(
      [
        metil_application
        class
      ]
    ),
    NSStringFromClass(
      [
        metil_application_delegate
        class
      ]
    )
  );
}

void recol_view_controller_on_view_did_load() {
  metil_initialize(
    0x01,
    &recol_executable_path,
    "recol",
    recol_renderer_on_initialize
  );
}

void recol_renderer_on_initialize(
  struct metil* metil,
  void* data
) {
  metil_library_initialize(
    &metil->library,
    metil->renderer_interface.metal_device,
    @"recol_fragment",
    @"recol_vertex"
  );

  struct metil_scene_controller* metil_scene_controller = (
    metil->scene_controller
  );

  recol_scene_initialize(
    metil,
    &metil_scene_controller->scene
  );
}
