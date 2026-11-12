import std.stdio;

import rsph.config;
import rsph_cpu.sph.config;
import rsph_cpu.device;

void main() {
	auto device = CPU();

	auto runtime = Config!(CPU, int)(device, 1).build();
}
