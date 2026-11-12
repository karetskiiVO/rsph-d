module rsph_core.generic.sph;

import rsph_core.traits.model;
import rsph_core.traits.particle;
import rsph_core.traits.physics_domain;

/// Adds m_j * W(r_i - r_j, h) to density using the model's fixed smoothing length.
void update_density(D, Particle, Model)(ref const Model model, ref Particle particle, ref const Particle neighbour)
    if (isSphParticle!Particle && isSphDensityModel!Model
        && is(Particle.PhysicsDomain == Model.PhysicsDomain))
{
    auto weight = model.kernel().value(particle.position - neighbour.position, model.h());

    particle.density = particle.density + neighbour.restMass * weight;
}

/// Updates pressure using the model's equation of state and the particle's rest-frame properties.
void calc_presure(D, Particle, Model)(ref const Model model, ref Particle particle)
    if (isSphParticle!Particle && isSphModel!Model
        && is(Particle.PhysicsDomain == Model.PhysicsDomain))
{
    particle.pressure = model.equation_of_state().pressure(particle.restMassDensity, particle.specificInternalEnergy);
}

/// Adds the Newtonian pressure contribution from one neighbour to particle acceleration.
/// Uses the sum of each particle's pressure divided by its squared density. Densities must be positive.
void calc_internal_acceleration(D, Particle, Model)(ref const Model model, ref Particle particle, ref const Particle neighbour)
    if (isSphParticle!Particle && isSphModel!Model
        && is(Particle.PhysicsDomain == Model.PhysicsDomain))
{
    auto particleFactor = particle.pressure / particle.density / particle.density;
    auto neighbourFactor = neighbour.pressure / neighbour.density / neighbour.density;
    auto pressureFactor = particleFactor + neighbourFactor;

    auto gradient = model.kernel().gradient(particle.position - neighbour.position, model.h());

    particle.acceleration = particle.acceleration - gradient * (neighbour.restMass * pressureFactor);
}

/// Adds mu * m_j/(rho_i*rho_j) * (v_j-v_i) * viscosity_laplacian to acceleration.
/// Dynamic viscosity must be nonnegative. Densities and smoothing length must be positive.
void calc_viscosity_acceleration(D, P, M, V)(ref const M model, ref P particle, ref const P neighbour, V dynamicViscosity)
    if (isSphParticle!(P) && isModel!(M) && isViscosityKernel!(D, M.Kernel))
{
    auto laplacian = model.kernel().viscosity_laplacian(particle.position - neighbour.position, model.h());
    auto viscosityFactor = dynamicViscosity / particle.density / neighbour.density;

    particle.acceleration = particle.acceleration + laplacian * neighbour.restMass * viscosityFactor * (neighbour.velocity - particle.velocity);
}

/// Returns min(max_dt, C_cfl*h/(c+v), C_a*sqrt(h/a), C_nu*h^2/nu).
/// Inputs must be finite. Smoothing length and configuration values must be positive.
/// State values must be nonnegative. Zero rates add no limit.
D.Time calc_dt(D)(D.Length h, TimeStepState!(D.Length) state, TimeStepConfig!(D.Length, D.Time) config)
    if (isPhysicsDomain!D)
{
    auto dt = config.max_dt;
    auto signal_speed = state.max_sound_speed + state.max_speed;
    const no_rate = zero!(D.Length);

    if (signal_speed > no_rate) {
        auto acoustic_dt = quantityFrom!(D.Time)(config.cfl * (h / signal_speed));
        if (acoustic_dt < dt) dt = acoustic_dt;
    }

    if (state.max_acceleration > no_rate) {
        auto acceleration_dt = quantityFrom!(D.Time)(config.acceleration_factor * squareRoot(h / state.max_acceleration));
        if (acceleration_dt < dt) dt = acceleration_dt;
    }

    if (state.max_kinematic_viscosity > no_rate) {
        auto viscous_dt = quantityFrom!(D.Time)(config.viscosity_factor * h * (h / state.max_kinematic_viscosity));
        if (viscous_dt < dt) dt = viscous_dt;
    }

    return dt;
}
