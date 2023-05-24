import std.stdio;
import std.getopt;
import std.string;
import std.conv;
import std.file;

import flant5;

struct Options {
	string model;
	string prompt_str;
	string prompt_file;
	int num_beams = 5;
	float temp = 1.0;
	int topk = 1;
}

int main(string[] args) {
	Options cli_options;

	auto help_info = getopt(args,
		"m", &cli_options.model,
		"p", &cli_options.prompt_str,
		"f", &cli_options.prompt_file,
		"num-beams", &cli_options.num_beams,
		"temp", &cli_options.temp,
		"topk", &cli_options.topk,
	);
	if (help_info.helpWanted) {
		defaultGetoptPrinter("flant5-d example", help_info.options);
		return 0;
	}

	if (cli_options.model.empty) {
		writeln("model file is required");
		return 1;
	}
	if (cli_options.prompt_str.empty && cli_options.prompt_file.empty) {
		writeln("either prompt_str or prompt_file is required");
		return 1;
	}

	auto gen = FlanT5Generator();

	writefln("loading model: %s", cli_options.model);
	gen.load_model(cli_options.model);

	string prompt;
	if (!cli_options.prompt_str.empty) {
		prompt = cli_options.prompt_str;
	} else {
		prompt = std.file.readText(cli_options.prompt_file);
	}

	writefln("input: %s", prompt);

	auto gen_params = gen.default_gen_params;
	gen_params.beam_size = cli_options.num_beams;
	gen_params.sampling_temperature = cli_options.temp;
	gen_params.sampling_topk = cli_options.topk;
	writefln("gen_params: %s", gen_params);

	writefln("generating...");
	auto test_output = gen.generate(prompt).replace("▁", " ");

	writefln("output: %s", test_output);

	return 0;
}
