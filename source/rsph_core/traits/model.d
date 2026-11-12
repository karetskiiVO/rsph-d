module rsph_core.traits.model;

import rsph_core.traits.physics_domain : isPhysicsDomain, isSphDomain;
import std.traits : rvalueOf;

enum isModel(M) =
    is(M.PhysicsDomain) &&
    isPhysicsDomain!(M.PhysicsDomain);

/// Model operations required by the fixed smoothing-length density sum.
enum isSphDensityModel(M) = isModel!M
    && isSphDomain!(M.PhysicsDomain)
    && __traits(compiles, (ref const M model) {
        alias D = M.PhysicsDomain;
        D.Length smoothingLength = model.h();
        D.Displacement separation = rvalueOf!(const D.Position) - rvalueOf!(const D.Position);
        auto weight = model.kernel().value(
            rvalueOf!(const D.Position) - rvalueOf!(const D.Position), model.h());
        D.Density contribution = rvalueOf!(const D.Mass) * weight;
        D.Density updatedDensity = rvalueOf!(const D.Density)
            + rvalueOf!(const D.Mass) * weight;
    });

/// Model contract for density, pressure and pressure acceleration in Newtonian SPH.
enum isSphModel(M) = isSphDensityModel!M
    && __traits(compiles, (ref const M model) {
        alias D = M.PhysicsDomain;
        D.Pressure computedPressure = model.equation_of_state().pressure(
            rvalueOf!(const D.Density), rvalueOf!(const D.SpecificInternalEnergy));
        auto pressureFactor = rvalueOf!(const D.Pressure)
            / rvalueOf!(const D.Density) / rvalueOf!(const D.Density);
        auto gradient = model.kernel().gradient(
            rvalueOf!(const D.Position) - rvalueOf!(const D.Position), model.h());
        auto combinedFactor = pressureFactor + pressureFactor;
        D.Acceleration updatedAcceleration = rvalueOf!(const D.Acceleration)
            - gradient * (rvalueOf!(const D.Mass) * combinedFactor);
    });
