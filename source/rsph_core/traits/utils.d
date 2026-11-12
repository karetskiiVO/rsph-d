module rsph_core.traits.utils;

template hasGetter(ObjectType, string name, DataType) {
    enum hasGetter = is(typeof(mixin("lvalueOf!(const ObjectType)." ~ name)) == DataType);
}

template hasSetter(ObjectType, string name, DataType) {
    enum hasSetter = is(typeof({ ObjectType obj; mixin("obj." ~ name) = rvalueOf!DataType; }));
}

enum hasSetterAndGetter(ObjectType, string name, DataType) =
    hasGetter!(ObjectType, name, DataType) &&
    hasSetter!(ObjectType, name, DataType);
