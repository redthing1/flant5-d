#pragma once

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined __GNUC__
#define VIS_PUBLIC __attribute__((visibility("default")))
#else
#pragma message("Compiler does not support symbol visibility.")
#define VIS_PUBLIC
#endif

struct GenerationParams {
  size_t beam_size = 2;
  float patience = 1;
  float length_penalty = 1;
  float coverage_penalty = 0;
  float repetition_penalty = 1;
  size_t no_repeat_ngram_size = 0;
  bool disable_unk = false;
  bool return_end_token = false;
  size_t max_input_length = 1024;
  size_t max_decoding_length = 256;
  size_t min_decoding_length = 1;
  size_t sampling_topk = 1;
  float sampling_temperature = 1;
};

typedef void *CT2Generator;

// create a generator, loading the specified model and tokenizer
VIS_PUBLIC CT2Generator ct2_generator_create(const char *model_path,
                                             const char *tokenizer_path);
// close and free a generator
VIS_PUBLIC void ct2_generator_destroy(CT2Generator generator);

// execute generator to create one output sequence from one input sequence
VIS_PUBLIC void ct2_generator_generate_one_str(CT2Generator generator,
                                           const char *input, char *output,
                                           size_t max_output_length,
                                           size_t *output_length,
                                           const GenerationParams *params);

#ifdef __cplusplus
}
#endif