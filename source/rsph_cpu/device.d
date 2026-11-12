module rsph_cpu.device;

import rsph.device;

struct CPU {
    static assert(isDevice!CPU);
}
