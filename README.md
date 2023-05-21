# flant5-d

optimized inference of [FLAN-T5] models in D

+ can run any huggingface [T5](https://huggingface.co/transformers/model_doc/t5.html) family model (including FlanT5, T0, etc.)

powered by [CTranslate2](https://github.com/OpenNMT/CTranslate2) and [sentencepiece](https://github.com/google/sentencepiece)

⚠️ currently there is an [issue](https://github.com/OpenNMT/CTranslate2/issues/1196) with the static library build of CTranslate2, so you will need to copy `$PACKAGE_DIR/libctranslate2.so` from this project when built to `libctranslate2.so.3` next to your binary. this will be fixed when the issue is resolved.

## usage

### models

obtain a model that is in the CTranslate2 (ct2) format. see the [ctranslate2 model conversion](https://opennmt.net/CTranslate2/conversion.html) documentation for specific instructions.

for cpu reference, `int8` quantization is recommended for best performance and memory usage.

assuming you have a model in the ct2 format, you can use it like so:

```d
auto gen = FlanT5Generator();

// load model
gen.load_model(model_path);

// generation params
auto gen_params = gen.default_gen_params;
gen_params.beam_size = 5;
gen_params.sampling_temperature = cli_options.temp;
gen_params.sampling_topk = 10;
gen_params.max_input_length = 1024;
gen_params.max_decoding_length = 150;
gen_params.repetition_penalty = 1.1;

// generate
auto test_output = gen.generate(test_input);
```
