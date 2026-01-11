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

import std.math : sqrt, cos, sin, PI;
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

    // =========================================================================
    // PAULI GATES
    // =========================================================================

    /// Applies Pauli-X (NOT) gate: |0⟩ ↔ |1⟩
    void applyX() pure @safe @nogc nothrow { swap(alpha, beta); }

    /// Applies Pauli-Y gate: Y|0⟩ = i|1⟩, Y|1⟩ = -i|0⟩
    void applyY() pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        alpha = b * C(0, -1);  // -i * beta
        beta = a * C(0, 1);    // i * alpha
    }

    /// Applies Pauli-Z gate: Z|0⟩ = |0⟩, Z|1⟩ = -|1⟩
    void applyZ() pure @safe @nogc nothrow {
        beta = beta * C(-1);
    }

    // =========================================================================
    // HADAMARD
    // =========================================================================

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

    // =========================================================================
    // PHASE GATES
    // =========================================================================

    /// Applies S gate (√Z): S|0⟩ = |0⟩, S|1⟩ = i|1⟩
    void applyS() pure @safe @nogc nothrow {
        beta = beta * C(0, 1);
    }

    /// Applies S† gate (inverse of S): S†|1⟩ = -i|1⟩
    void applySdag() pure @safe @nogc nothrow {
        beta = beta * C(0, -1);
    }

    /// Applies T gate (√S, π/8 gate)
    void applyT() pure @safe @nogc nothrow {
        immutable real angle = PI / 4.0L;
        beta = beta * C(cos(angle), sin(angle));
    }

    /// Applies T† gate (inverse of T)
    void applyTdag() pure @safe @nogc nothrow {
        immutable real angle = -PI / 4.0L;
        beta = beta * C(cos(angle), sin(angle));
    }

    // =========================================================================
    // ROTATION GATES
    // =========================================================================

    /++
    Applies rotation around X-axis.
    
    Params:
        theta = Rotation angle in radians
    +/
    void applyRx(real theta) pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        alpha = a * C(c) + b * C(0, -s);
        beta = a * C(0, -s) + b * C(c);
    }

    /++
    Applies rotation around Y-axis.
    
    Params:
        theta = Rotation angle in radians
    +/
    void applyRy(real theta) pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        alpha = a * C(c) + b * C(-s);
        beta = a * C(s) + b * C(c);
    }

    /++
    Applies rotation around Z-axis.
    
    Params:
        theta = Rotation angle in radians
    +/
    void applyRz(real theta) pure @safe @nogc nothrow {
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        alpha = alpha * C(c, -s);
        beta = beta * C(c, s);
    }

    /++
    Applies a general phase gate P(φ).
    
    P(φ)|0⟩ = |0⟩, P(φ)|1⟩ = e^(iφ)|1⟩
    
    Params:
        phi = Phase angle in radians
    +/
    void applyP(real phi) pure @safe @nogc nothrow {
        beta = beta * C(cos(phi), sin(phi));
    }

    /++
    Applies an arbitrary 2x2 unitary gate.
    
    Params:
        gate = 2x2 unitary matrix
    +/
    void applyGate(C[2][2] gate) pure @safe @nogc nothrow {
        C a = alpha, b = beta;
        alpha = gate[0][0] * a + gate[0][1] * b;
        beta = gate[1][0] * a + gate[1][1] * b;
    }

    /// Prints the qubit state in Dirac notation
    void print() const {
        import std.stdio : writefln;
        
        writefln!"|ψ⟩ = (%.6f%+fi)|0⟩ + (%.6f%+fi)|1⟩   (P0=%.6f, P1=%.6f)"(
            alpha.re, alpha.im, beta.re, beta.im, prob0, prob1);
    }
}
