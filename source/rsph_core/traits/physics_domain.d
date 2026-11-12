module rsph_core.traits.physics_domain;

import std.meta : allSatisfy;
import std.traits : lvalueOf, rvalueOf;

enum isPhysicsDomain(D) = __traits(compiles, {
    alias Time         = D.Time;
    alias Length       = D.Length;
    alias Force        = D.Force;
    alias Position     = D.Position;
    alias Displacement = D.Displacement;
    alias Velocity     = D.Velocity;
    alias Acceleration = D.Acceleration;

    // TODO: type assertions
});

enum isSphDomain(D) = isPhysicsDomain!D && __traits(compiles, {
    alias Pressure               = D.Pressure;
    alias SpecificInternalEnergy = D.SpecificInternalEnergy; // TODO: rename or remove
});
