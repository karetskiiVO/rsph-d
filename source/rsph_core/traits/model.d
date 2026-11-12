module rsph_core.traits.model;

enum isModel(M) =
    is(M.PhysicsDomain) &&
    isPhysicsDomain!(M.PhysicsDomain);
    // TODO: kernel



