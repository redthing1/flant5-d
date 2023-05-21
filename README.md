# flant5-d

FLAN-T5 bindings for D via CTranslate2 + sentencepiece

## usage

### models

obtain a model that is in the CTranslate2 (ct2) format. see the [model conversion](https://opennmt.net/CTranslate2/conversion.html) documentation for specific instructions.

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
