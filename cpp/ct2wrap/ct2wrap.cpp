#include <iostream>
#include <stdexcept>
#include <vector>

#include "ct2wrap.h"
#include "ctranslate2/translator.h"
#include <sentencepiece_processor.h>

class cxxCT2Generator {
private:
  sentencepiece::SentencePieceProcessor _sp_processor;
  ctranslate2::Translator *_translator;

public:
  cxxCT2Generator(const std::string &model_path,
                  const std::string &tokenizer_path) {
    // load tokenizer
    const auto tokenizer_load_status = _sp_processor.Load(tokenizer_path);
    if (!tokenizer_load_status.ok()) {
      throw std::runtime_error("Failed to load tokenizer: " +
                               tokenizer_load_status.ToString());
    }
    // load model
    _translator =
        new ctranslate2::Translator(model_path, ctranslate2::Device::CPU);
  }
  ~cxxCT2Generator() { delete _translator; }

  std::vector<std::string> tokenize_str(const std::string &input) {
    std::vector<std::string> tokens;
    _sp_processor.Encode(input, &tokens);
    return tokens;
  }

  std::vector<int> tokenize_ids(const std::string &input) {
    std::vector<int> tokens;
    _sp_processor.Encode(input, &tokens);
    return tokens;
  }

  std::string detokenize_str(const std::vector<std::string> &tokens) {
    std::string output;
    _sp_processor.Decode(tokens, &output);
    return output;
  }

  std::string detokenize_ids(const std::vector<int> &tokens) {
    std::string output;
    _sp_processor.Decode(tokens, &output);
    return output;
  }

  std::vector<std::string>
  translate_one(const std::vector<std::string> &input_tokens,
                ctranslate2::TranslationOptions options) {
    std::vector<std::vector<std::string>> batch_inputs;
    batch_inputs.push_back(input_tokens);
    // auto results = _translator->translate_batch(batch_inputs);
    auto results = _translator->translate_batch(batch_inputs, options);
    // get output tokens from results
    auto batch_outputs = results[0].output();
    return batch_outputs;
  }
};

CT2Generator ct2_generator_create(const char *model_path,
                                  const char *tokenizer_path) {
  auto cxx_generator = new cxxCT2Generator(model_path, tokenizer_path);
  return reinterpret_cast<CT2Generator>(cxx_generator);
}

void ct2_generator_destroy(CT2Generator generator) {
  auto cxx_generator = reinterpret_cast<cxxCT2Generator *>(generator);
  delete cxx_generator;
}

void ct2_generator_generate_one_str(CT2Generator generator, const char *input,
                                    char *output, size_t max_output_length,
                                    size_t *output_length,
                                    const GenerationParams *params) {
  // 1. convert generation params to ctranslate2::TranslationOptions
  ctranslate2::TranslationOptions ct2_options;
  ct2_options.beam_size = params->beam_size;
  ct2_options.patience = params->patience;
  ct2_options.length_penalty = params->length_penalty;
  ct2_options.coverage_penalty = params->coverage_penalty;
  ct2_options.repetition_penalty = params->repetition_penalty;
  ct2_options.no_repeat_ngram_size = params->no_repeat_ngram_size;
  ct2_options.disable_unk = params->disable_unk;
  ct2_options.return_end_token = params->return_end_token;
  ct2_options.max_input_length = params->max_input_length;
  ct2_options.max_decoding_length = params->max_decoding_length;
  ct2_options.min_decoding_length = params->min_decoding_length;
  ct2_options.sampling_topk = params->sampling_topk;
  ct2_options.sampling_temperature = params->sampling_temperature;

  auto cxx_generator = reinterpret_cast<cxxCT2Generator *>(generator);

  // 2. tokenize input
  //   std::cout << "input str: " << input << std::endl;
  auto input_tokens = cxx_generator->tokenize_str(input);
  //   std::cout << "input tokens: ";
  //   for (auto token : input_tokens) {
  //     std::cout << token << ", ";
  //   }
  //   std::cout << std::endl;

  // 3. translate
  auto output_tokens = cxx_generator->translate_one(input_tokens, ct2_options);
  //   std::cout << "output tokens: ";
  //   for (auto token : output_tokens) {
  //     std::cout << token << ", ";
  //   }
  //   std::cout << std::endl;

  // 4. detokenize output
  auto output_str = cxx_generator->detokenize_str(output_tokens);
  //   std::cout << "output str: " << output_str << std::endl;

  // 5. copy output to output buffer
  // ensure output buffer is large enough
  //   std::cout << "output str size: " << output_str.size() << std::endl;
  //   std::cout << "output buffer size: " << max_output_length << std::endl;
  if (output_str.size() >= max_output_length) {
    throw std::runtime_error("output buffer too small: buffer size is " +
                             std::to_string(max_output_length) +
                             " but output size is " +
                             std::to_string(output_str.size()));
  }

  // copy output to output buffer
  std::copy(output_str.begin(), output_str.end(), output);

  *output_length = output_str.size();
}

GenerationParams ct2_generator_default_params() {
  GenerationParams params;
  params.beam_size = 2;
  params.patience = 1;
  params.length_penalty = 1;
  params.coverage_penalty = 0;
  params.repetition_penalty = 1;
  params.no_repeat_ngram_size = 0;
  params.disable_unk = false;
  params.return_end_token = false;
  params.max_input_length = 1024;
  params.max_decoding_length = 256;
  params.min_decoding_length = 1;
  params.sampling_topk = 1;
  params.sampling_temperature = 1;
  return params;
}
