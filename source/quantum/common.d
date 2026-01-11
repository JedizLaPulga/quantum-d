module quantum.common;

import std.complex;

/// Complex number type used throughout the quantum library
alias C = Complex!real;

/// Compute |z|² = re² + im² (squared absolute value)
real absSq(C z) pure @safe @nogc nothrow {
    return z.re * z.re + z.im * z.im;
}
