#pragma once

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

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
  size_t beam_size;
  float patience;
  float length_penalty;
  float coverage_penalty;
  float repetition_penalty;
  size_t no_repeat_ngram_size;
  bool disable_unk;
  bool return_end_token;
  size_t max_input_length;
  size_t max_decoding_length;
  size_t min_decoding_length;
  size_t sampling_topk;
  float sampling_temperature;
};
typedef struct GenerationParams GenerationParams;

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

// default generation parameters
VIS_PUBLIC GenerationParams ct2_generator_default_params();

#ifdef __cplusplus
}
#endif