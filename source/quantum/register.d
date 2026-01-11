module quantum.register;

import std.complex;
import std.math;
import std.algorithm : swap;
import std.exception : enforce;

alias C = Complex!real;

private real absSq(C z) pure @safe @nogc nothrow {
    return z.re * z.re + z.im * z.im;
}


struct QRegister(ulong N) {
    C[1 << N] state;

    this(C[] init) {
        assert(init.length == (1 << N));
        foreach (i, amp; init) state[i] = amp;
        normalize();
    }

    void normalize() {
        real sum = 0.0L;
        foreach (amp; state) sum += absSq(amp);
        real norm = sqrt(sum);
        if (norm > 0.0L) foreach (ref amp; state) amp /= norm;
    }

    real prob(size_t k) const => absSq(state[k]);

    void applyGate(size_t target, C[2][2] gate) {
        size_t stride = 1UL << target;
        size_t size   = 1UL << N;
        for (size_t base = 0; base < size; base += 2 * stride) {
            for (size_t i = 0; i < stride; ++i) {
                size_t i0 = base + i;
                size_t i1 = base + i + stride;
                C a = state[i0], b = state[i1];
                state[i0] = gate[0][0] * a + gate[0][1] * b;
                state[i1] = gate[1][0] * a + gate[1][1] * b;
            }
        }
    }

    void applyCNOT(size_t control, size_t target) {
        size_t cbit = 1UL << control;
        size_t tbit = 1UL << target;
        C[1 << N] temp;
        foreach (i; 0 .. (1 << N)) {
            temp[i] = (i & cbit) ? state[i ^ tbit] : state[i];
        }
        state = temp;
    }

    bool measure(size_t qubit) {
        real p0 = 0.0L;
        foreach (i; 0 .. (1 << N)) {
            if (((i >> qubit) & 1) == 0) p0 += prob(i);
        }
        import std.random : uniform01, rndGen;
        bool result = uniform01!real(rndGen) >= p0;  // true = |1⟩, false = |0⟩

        foreach (i; 0 .. (1 << N)) {
            if (((i >> qubit) & 1) != (result ? 1 : 0)) {
                state[i] = C(0.0L);
            }
        }
        normalize();
        return result;
    }

    void print() const {
        import std.stdio:writeln, writefln;
        
        writeln("State vector:");
        foreach (i; 0 .. (1 << N)) {
            real p = prob(i);
            if (p > 1e-10L) {
                writefln!"  |%0*b⟩ → %.6f%+fi  (P=%.6f)"(N, i, state[i].re, state[i].im, p);
            }
        }
    }
}

import quantum.qasm;
// At the end of QRegister struct in register.d


