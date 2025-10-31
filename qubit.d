module quantum.qubit;


import std.complex;
import std.math;
import std.algorithm : swap;
import std.exception : enforce;

alias C = Complex!real;

private real absSq(C z) pure @safe @nogc nothrow {
    return z.re * z.re + z.im * z.im;
}

public struct Qubit {
    C alpha, beta;

    this(C a, C b) {
        real n = sqrt(absSq(a) + absSq(b));
        enforce(n > 0.0L, "Zero state");
        alpha = a / n;
        beta  = b / n;
    }

    real prob0() const pure @safe @nogc nothrow => absSq(alpha);
    real prob1() const pure @safe @nogc nothrow => absSq(beta);

    void applyX() pure @safe @nogc nothrow { swap(alpha, beta); }

    void applyH() pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        real s = 1.0L / sqrt(2.0L);
        alpha = (a + b) * s;
        beta  = (a - b) * s;
    }

    void print() const {
        import  std.stdio:writefln;
        
        writefln!"|ψ⟩ = %.6f|0⟩ + %.6f%+fi|1⟩   (P0=%.6f, P1=%.6f)"(
            alpha.re, beta.re, beta.im, prob0, prob1);
    }
}