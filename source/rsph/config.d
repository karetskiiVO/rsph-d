module rsph.config;

import rsph.device : isDevice;

struct Config(Device, Model)
    if (isDevice!(Device) /* && isModel(Model) */)
{
    Device device;
    Model  model;

    this(Device device, Model model) {
        this.device = device;
        this.model  = model;
    }
}
