module rsph_core.traits.utils;

import std.traits : lvalueOf, rvalueOf;

template hasGetter(ObjectType, string name, DataType) {
    enum member = "lvalueOf!(const ObjectType)." ~ name;
    enum hasGetter = is(typeof(mixin(member)) == DataType) ||
        is(typeof(mixin(member)) == const(DataType));
}

template hasSetter(ObjectType, string name, DataType) {
    enum hasSetter = is(typeof({ ObjectType obj; mixin("obj." ~ name) = rvalueOf!DataType; }));
}

enum hasSetterAndGetter(ObjectType, string name, DataType) =
    hasGetter!(ObjectType, name, DataType) &&
    hasSetter!(ObjectType, name, DataType);
