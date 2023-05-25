module flant5.flant5;

import std.stdio;
import std.string;
import std.conv;
import std.exception : enforce;
import flant5.ct2wrap;

alias FlanT5GenerationParams = flant5.ct2wrap.GenerationParams;

struct FlanT5Generator {
    private CT2Generator _generator = null;

    static FlanT5GenerationParams default_gen_params;

    static this() {
        default_gen_params = ct2_generator_default_params();
    }

    void load_model(string model_path, string model_file_name = "model.bin", string tokenizer_file_name = "spiece.model") {
        import std.file : exists;

        auto model_file_path = model_path ~ "/" ~ model_file_name;
        enforce(exists(model_file_path), "model file not found: " ~ model_file_path);
        auto tokenizer_file_path = model_path ~ "/" ~ tokenizer_file_name;
        enforce(exists(tokenizer_file_path), "tokenizer file not found: " ~ tokenizer_file_path);
        _generator = ct2_generator_create(model_path.toStringz, tokenizer_file_path.toStringz);
    }

    string generate(string prompt, FlanT5GenerationParams params = default_gen_params, bool add_sequence_end_token = true) {
        enforce(_generator !is null, "model not loaded");

        char[] output_buffer;
        enum size_t max_output_length = 4 * 2048;
        output_buffer.length = max_output_length;
        size_t output_length;
        ct2_generator_generate_one_str(
            _generator,
            prompt.toStringz,
            output_buffer.ptr,
            max_output_length,
            &output_length,
            &params,
            add_sequence_end_token
        );
        output_buffer.length = output_length;

        return output_buffer.to!string;
    }

    bool destroy() {
        if (_generator !is null) {
            ct2_generator_destroy(_generator);
            return true;
        }
        return false;
    }

    ~this() {
        destroy();
    }
}
