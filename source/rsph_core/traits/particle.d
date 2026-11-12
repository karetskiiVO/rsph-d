module rsph_core.traits.particle;

// TODO: check thats PhysicsDomain is same
enum isParticle(P) =
    is(P.PhysicsDomain) &&
    isPhysicsDomain!(P.PhysicsDomain) &&
    hasSetterAndGetter!(P, "position",     P.PhysicsDomain.Position) &&
    hasSetterAndGetter!(P, "velocity",     P.PhysicsDomain.Velocity) &&
    hasSetterAndGetter!(P, "acceleration", P.PhysicsDomain.Acceleration);

enum isSphParticle(P) = isParticle!P &&
    is(isSphDomain!(P.PhysicsDomain)) &&
    hasGetter!(P, "restMass",        P.PhysicsDomain.Mass) &&
    hasGetter!(P, "restMassDensity", P.PhysicsDomain.Density) &&
    hasSetterAndGetter!(P, "density",                P.PhysicsDomain.Density) &&
    hasSetterAndGetter!(P, "pressure",               P.PhysicsDomain.Pressure) &&
    hasSetterAndGetter!(P, "specificInternalEnergy", P.PhysicsDomain.SpecificInternalEnergy);
