module rsph_cpu.sph.config;

import rsph.config : Config;
import rsph_core.traits.model : isSphModel;
import rsph_cpu.device : CPU;
import rsph_cpu.sph.runtime : Runtime;

/// Allocates CPU storage for particleCount particles, with each field initialized to its type's .init.
Runtime!Model build(Model)(Config!(CPU, Model) config, size_t particleCount = 0)
    if (isSphModel!Model)
{
    return Runtime!Model(config.model, particleCount);
}
