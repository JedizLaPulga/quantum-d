/++
$(H2 Qubit Module)

Single-qubit representation and operations for quantum computing simulation.

A qubit is represented as |ψ⟩ = α|0⟩ + β|1⟩ where |α|² + |β|² = 1.

Example:
---
auto q = Qubit(C(0.6), C(0.8));  // Creates normalized qubit
q.applyH();                       // Apply Hadamard gate
q.print();                        // Display state
---
+/
module quantum.qubit;

import std.math;
import std.algorithm : swap;
import std.exception : enforce;

import quantum.common : C, absSq;

/++
Represents a single qubit in superposition state |ψ⟩ = α|0⟩ + β|1⟩.

The qubit is automatically normalized upon construction.
+/
public struct Qubit {
    /// Amplitude for |0⟩ basis state
    C alpha;
    /// Amplitude for |1⟩ basis state  
    C beta;

    /++
    Constructs a qubit from two complex amplitudes.
    
    The amplitudes are automatically normalized so that |α|² + |β|² = 1.
    
    Params:
        a = Complex amplitude for |0⟩
        b = Complex amplitude for |1⟩
    
    Throws:
        Exception if both amplitudes are zero (invalid quantum state)
    +/
    this(C a, C b) {
        real n = sqrt(absSq(a) + absSq(b));
        enforce(n > 0.0L, "Zero state");
        alpha = a / n;
        beta  = b / n;
    }

    /// Returns probability of measuring |0⟩
    real prob0() const pure @safe @nogc nothrow => absSq(alpha);
    
    /// Returns probability of measuring |1⟩
    real prob1() const pure @safe @nogc nothrow => absSq(beta);

    /// Applies Pauli-X (NOT) gate: |0⟩ ↔ |1⟩
    void applyX() pure @safe @nogc nothrow { swap(alpha, beta); }

    /++
    Applies Hadamard gate, creating superposition.
    
    H|0⟩ = (|0⟩ + |1⟩)/√2
    H|1⟩ = (|0⟩ - |1⟩)/√2
    +/
    void applyH() pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        real s = 1.0L / sqrt(2.0L);
        alpha = (a + b) * s;
        beta  = (a - b) * s;
    }

    /// Prints the qubit state in Dirac notation
    void print() const {
        import std.stdio : writefln;
        
        writefln!"|ψ⟩ = (%.6f%+fi)|0⟩ + (%.6f%+fi)|1⟩   (P0=%.6f, P1=%.6f)"(
            alpha.re, alpha.im, beta.re, beta.im, prob0, prob1);
    }
}
