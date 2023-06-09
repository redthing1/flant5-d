module flant5.ct2wrap;

import core.stdc.config;

extern (C):
@nogc:

struct GenerationParams {
    // create a generator, loading the specified model and tokenizer

    // close and free a generator

    // execute generator to create one output sequence from one input sequence

    // default generation parameters
    alias size_t = c_ulong;
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

    string toString() const {
        import std.format;

        return format(
            "GenerationParams("
            ~ "beam_size: %s, "
            ~ "patience: %s, "
            ~ "length_penalty: %s, "
            ~ "coverage_penalty: %s, "
            ~ "repetition_penalty: %s, "
            ~ "no_repeat_ngram_size: %s, "
            ~ "disable_unk: %s, "
            ~ "return_end_token: %s, "
            ~ "max_input_length: %s, "
            ~ "max_decoding_length: %s, "
            ~ "min_decoding_length: %s, "
            ~ "sampling_topk: %s, "
            ~ "sampling_temperature: %s)"
            ~ ")",
            beam_size,
            patience,
            length_penalty,
            coverage_penalty,
            repetition_penalty,
            no_repeat_ngram_size,
            disable_unk,
            return_end_token,
            max_input_length,
            max_decoding_length,
            min_decoding_length,
            sampling_topk,
            sampling_temperature
        );
    }
}

alias CT2Generator = void*;
CT2Generator ct2_generator_create(
    const(char)* model_path,
    const(char)* tokenizer_path);
void ct2_generator_destroy(CT2Generator generator);
void ct2_generator_generate_one_str(
    CT2Generator generator,
    const(char)* input,
    char* output,
    size_t max_output_length,
    size_t* output_length,
    const(GenerationParams)* params,
    bool add_sequence_end_token);
GenerationParams ct2_generator_default_params();
