import std.stdio;
import std.getopt;
import std.string;
import std.conv;
import std.file;

import flant5;

struct Options {
	string model;
	string prompt_file;
	float temp = 0.7;
}

int main(string[] args) {
	Options cli_options;

	auto help_info = getopt(args,
		"m", &cli_options.model,
		"p", &cli_options.prompt_file,
		"t", &cli_options.temp
	);
	if (help_info.helpWanted) {
		defaultGetoptPrinter("flant5-d example", help_info.options);
		return 0;
	}

	if (cli_options.model.empty) {
		writeln("model file is required");
		return 1;
	}
	if (cli_options.prompt_file.empty) {
		writeln("prompt file is required");
		return 1;
	}

	auto gen = FlanT5Generator();

	writefln("loading model: %s", cli_options.model);
	gen.load_model(cli_options.model);

	string test_input = std.file.readText(cli_options.prompt_file);

	writefln("input: %s", test_input);
	writefln("generating...");
	auto gen_params = gen.default_gen_params;
	gen_params.beam_size = 5;
	gen_params.sampling_temperature = cli_options.temp;
	gen_params.sampling_topk = 10;
	gen_params.max_input_length = 1024;
	gen_params.max_decoding_length = 150;
	gen_params.repetition_penalty = 1.1;
	writefln("gen_params: %s", gen_params);
	auto test_output = gen.generate(test_input);

	writefln("output: %s", test_output);

	return 0;
}
