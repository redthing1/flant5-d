#include <errno.h>
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>

#include "ct2wrap.h"

const std::string model_file_name = "model.bin";
const std::string tokenizer_file_name = "spiece.model";

bool file_exists(std::string filename) {
  FILE *file = fopen(filename.c_str(), "r");
  if (file) {
    fclose(file);
    return true;
  } else {
    return false;
  }
}

int main(int argc, char **argv) {
  // usage: $0 model_path
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " model_path" << std::endl;
    return 1;
  }
  std::string model_path = argv[1];
  std::string model_file_path = model_path + "/" + model_file_name;
  std::string tokenizer_file_path = model_path + "/" + tokenizer_file_name;

  // ensure that the model and tokenizer files exist
  if (!file_exists(model_file_path)) {
    std::cerr << "Model file not found: " << model_file_path << std::endl;
    return 1;
  }
  if (!file_exists(tokenizer_file_path)) {
    std::cerr << "Tokenizer file not found: " << tokenizer_file_path
              << std::endl;
    return 1;
  }

  std::cout << "ct2wrap_test: using model: " << model_path << std::endl;

  std::cout << "ct2wrap_test: creating generator" << std::endl;
  // create a generator
  auto generator =
      ct2_generator_create(model_path.c_str(), tokenizer_file_path.c_str());

  // generate one output sequence from one input sequence
  std::cout << "ct2wrap_test: generating one output" << std::endl;
  const char *input =
      "Summarize the following: A buffer overflow occurs when a program or "
      "process tries to store more data in a buffer (or some temporary data "
      "storage area) than that buffer was intended to hold. This extra data, "
      "which has to go somewhere, overflows adjacent memory regions, "
      "corrupting or overwriting the valid data stored there. If the buffer is "
      "stored on the stack, as it is the case for local variables in C, "
      "control information such as function return addresses can be altered. "
      "This allows the attacker to redirect the execution flow to arbitrary "
      "memory addresses. By injecting machine code into the process memory "
      "(e.g., as part of the data used to overflow the buffer, or in "
      "environment variables), the attacker can redirect the execution flow to "
      "this code and execute arbitrary machine instructions with the "
      "privileges of the running process. Thus, it is imperative that the "
      "length of the input data is checked before copied into buffers of fixed "
      "lengths. Unfortunately, a number of popular C functions (e.g., strcpy, "
      "strcat, sprintf, gets, or fgets) do not perform such length checks, "
      "making many applications vulnerable to this kind of attack.";
  size_t output_length;
  constexpr size_t max_output_length = 8192;
  char output[max_output_length];
  GenerationParams params = ct2_generator_default_params();
  params.sampling_temperature = 0.7;
  params.sampling_topk = 10;
  params.max_input_length = 1024;
  params.max_decoding_length = 150;
  params.repetition_penalty = 1.1;
  ct2_generator_generate_one_str(generator, input, output, max_output_length,
                                 &output_length, &params);
  std::cout << "ct2wrap_test: generated output: " << output << std::endl;

  // clean up
  std::cout << "ct2wrap_test: destroying generator" << std::endl;
  ct2_generator_destroy(generator);

  return 0;
}