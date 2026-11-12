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

template hasGetter(ObjectType, string name, DataType) {
    enum hasGetter = is(typeof(mixin("lvalueOf!(const ObjectType)." ~ name)) == DataType);
}

template hasSetter(ObjectType, string name, DataType) {
    enum hasSetter = is(typeof({ ObjectType obj; mixin("obj." ~ name) = rvalueOf!DataType; }));
}

enum hasSetterAndGetter(ObjectType, string name, DataType) =
    hasGetter!(ObjectType, name, DataType) &&
    hasSetter!(ObjectType, name, DataType);

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
