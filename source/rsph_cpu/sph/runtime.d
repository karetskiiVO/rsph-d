module rsph_cpu.sph.runtime;

import rsph_core.traits.model : isSphModel;

struct Runtime(Model)
    if (isSphModel!Model)
{
    private alias D = Model.PhysicsDomain;

    private Model model;
    private ParticleStorage particles;

    @disable this(this);

    package this(Model model, size_t particleCount) {
        this.model = model;
        this.particles = ParticleStorage(particleCount);
    }

    @property size_t particleCount() const {
        return particles.length;
    }

    private static struct ParticleStorage {
        D.Position[] positions;
        D.Velocity[] velocities;
        D.Acceleration[] accelerations;
        D.Mass[] restMasses;
        D.Density[] restMassDensities;
        D.Density[] densities;
        D.Pressure[] pressures;
        D.SpecificInternalEnergy[] specificInternalEnergies;

        this(size_t count) {
            positions = new D.Position[count];
            velocities = new D.Velocity[count];
            accelerations = new D.Acceleration[count];
            restMasses = new D.Mass[count];
            restMassDensities = new D.Density[count];
            densities = new D.Density[count];
            pressures = new D.Pressure[count];
            specificInternalEnergies = new D.SpecificInternalEnergy[count];
        }

        @property size_t length() const {
            return positions.length;
        }

        ParticleView opIndex(size_t index) {
            assert(index < length);
            return ParticleView(&this, index);
        }
    }

    // Views are local to a computation while the runtime stays at the same address.
    private static struct ParticleView {
        alias PhysicsDomain = D;

        private ParticleStorage* storage;
        private size_t index;

        @property {
            const(D.Position) position() const { return storage.positions[index]; }
            void position(D.Position value) { storage.positions[index] = value; }

            const(D.Velocity) velocity() const { return storage.velocities[index]; }
            void velocity(D.Velocity value) { storage.velocities[index] = value; }

            const(D.Acceleration) acceleration() const { return storage.accelerations[index]; }
            void acceleration(D.Acceleration value) { storage.accelerations[index] = value; }

            const(D.Mass) restMass() const { return storage.restMasses[index]; }
            const(D.Density) restMassDensity() const { return storage.restMassDensities[index]; }

            const(D.Density) density() const { return storage.densities[index]; }
            void density(D.Density value) { storage.densities[index] = value; }

            const(D.Pressure) pressure() const { return storage.pressures[index]; }
            void pressure(D.Pressure value) { storage.pressures[index] = value; }

            const(D.SpecificInternalEnergy) specificInternalEnergy() const {
                return storage.specificInternalEnergies[index];
            }
            void specificInternalEnergy(D.SpecificInternalEnergy value) {
                storage.specificInternalEnergies[index] = value;
            }
        }
    }
}

unittest {
    import rsph.config : Config;
    import rsph_core.generic.sph : calc_internal_acceleration, calc_presure, update_density;
    import rsph_core.traits.particle : isSphParticle;
    import rsph_cpu.device : CPU;
    import rsph_cpu.sph.config : build;
    import std.math : isClose;

    struct Domain {
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

    struct Kernel {
        double value(double displacement, double smoothingLength) const {
            return smoothingLength + displacement;
        }

        double gradient(double displacement, double smoothingLength) const {
            return 1.0;
        }
    }

    struct EquationOfState {
        double pressure(double density, double specificInternalEnergy) const {
            return density * specificInternalEnergy;
        }
    }

    struct Model {
        alias PhysicsDomain = Domain;
        double smoothingLength;

        double h() const { return smoothingLength; }
        Kernel kernel() const { return Kernel(); }
        EquationOfState equation_of_state() const { return EquationOfState(); }
    }

    struct DensityModel {
        alias PhysicsDomain = Domain;
        double h() const { return 3.0; }
        Kernel kernel() const { return Kernel(); }
    }

    struct MutableModel {
        alias PhysicsDomain = Domain;
        double h() { return 3.0; }
        Kernel kernel() const { return Kernel(); }
        EquationOfState equation_of_state() const { return EquationOfState(); }
    }

    struct ReferenceEquationOfState {
        double pressure(ref const double density, ref const double energy) const {
            return density * energy;
        }
    }

    struct ReferenceModel {
        alias PhysicsDomain = Domain;
        double h() const { return 3.0; }
        Kernel kernel() const { return Kernel(); }
        ReferenceEquationOfState equation_of_state() const { return ReferenceEquationOfState(); }
    }

    static assert(isSphModel!Model);
    static assert(!isSphModel!DensityModel);
    static assert(!isSphModel!MutableModel);
    static assert(!isSphModel!ReferenceModel);
    static assert(!isSphModel!int);
    static assert(!__traits(compiles, Config!(CPU, DensityModel)(CPU(), DensityModel()).build()));

    auto config = Config!(CPU, Model)(CPU(), Model(3.0));
    auto runtime = config.build(2);
    auto emptyRuntime = config.build();
    assert(runtime.particleCount == 2);
    assert(emptyRuntime.particleCount == 0);

    runtime.particles.positions[] = [1.0, 2.0];
    runtime.particles.restMasses[] = [2.0, 4.0];
    runtime.particles.restMassDensities[] = [2.0, 3.0];
    runtime.particles.densities[] = [5.0, 7.0];
    runtime.particles.specificInternalEnergies[] = [4.0, 1.0];
    runtime.particles.accelerations[] = [0.0, 0.0];
    auto particle = runtime.particles[0];
    auto neighbour = runtime.particles[1];
    static assert(isSphParticle!(typeof(particle)));

    auto densityModel = DensityModel();
    update_density!Domain(densityModel, particle, neighbour);
    assert(runtime.particles.densities == [13.0, 7.0]);

    calc_presure!Domain(runtime.model, particle);
    calc_presure!Domain(runtime.model, neighbour);
    assert(runtime.particles.pressures == [8.0, 3.0]);

    calc_internal_acceleration!Domain(runtime.model, particle, neighbour);
    assert(isClose(particle.acceleration, -3596.0 / 8281.0));
    assert(neighbour.acceleration == 0.0);
}
