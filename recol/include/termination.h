#ifndef __termination_h
#define __termination_h

typedef void(*termination_on_function)(void);

extern termination_on_function* termination_on_functions;
extern unsigned short int termination_length_on_functions;

void termination_initialize(void);

void termination_on_function_add(
  termination_on_function
);

void termination_on_function_remove(
  termination_on_function
);

void termination_terminate(void);

#endif
