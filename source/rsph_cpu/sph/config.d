module rsph_cpu.sph.config;

import rsph.config;
import rsph_cpu.device : CPU;
import rsph_cpu.sph.runtime;

// TODO: make Model sphModel
Runtime build(Model)(Config!(CPU, Model) config) {
    return Runtime();
}
