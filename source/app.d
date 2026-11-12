import rsph.config : Config;
import rsph_cpu.device : CPU;
import rsph_cpu.sph.config : build;

struct ExampleDomain {
    alias Time = double;
    alias Length = double;
    alias Force = double;
    alias Position = double;
    alias Displacement = double;
    alias Velocity = double;
    alias Acceleration = double;
    alias Mass = double;
    alias Density = double;
    alias Pressure = double;
    alias SpecificInternalEnergy = double;
}

struct ExampleKernel {
    // Normalized in one dimension with support |displacement| < h.
    double value(ExampleDomain.Displacement displacement, ExampleDomain.Length h) const {
        auto scaledDisplacement = displacement / h;
        auto shape = 1.0 - scaledDisplacement * scaledDisplacement;
        if (shape <= 0.0) {
            return 0.0;
        }
        return 15.0 * shape * shape / (16.0 * h);
    }

    ExampleDomain.Displacement gradient(
        ExampleDomain.Displacement displacement, ExampleDomain.Length h
    ) const {
        auto scaledDisplacement = displacement / h;
        auto shape = 1.0 - scaledDisplacement * scaledDisplacement;
        if (shape <= 0.0) {
            return 0.0;
        }
        return -15.0 * scaledDisplacement * shape / (4.0 * h * h);
    }
}

struct ExampleEquationOfState {
    ExampleDomain.Pressure pressure(
        ExampleDomain.Density density, ExampleDomain.SpecificInternalEnergy internalEnergy
    ) const {
        enum gamma = 1.4;
        return (gamma - 1.0) * density * internalEnergy;
    }
}

struct ExampleModel {
    alias PhysicsDomain = ExampleDomain;

    ExampleDomain.Length h() const {
        return 1.0;
    }

    ExampleKernel kernel() const {
        return ExampleKernel();
    }

    ExampleEquationOfState equation_of_state() const {
        return ExampleEquationOfState();
    }
}

void main() {
    auto runtime = Config!(CPU, ExampleModel)(CPU(), ExampleModel()).build(2);
    assert(runtime.particleCount == 2);
}
