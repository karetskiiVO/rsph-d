module result.result;

public import std.sumtype : match, tryMatch;

struct Ok(R) {
    static if (!is(R == void)) R value;
}

struct Error(E) {
    static if (!is(E == void)) E error;
}

alias Result(T, E) = SumType!(Ok!T, Error!E);
