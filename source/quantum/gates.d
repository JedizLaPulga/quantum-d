module quantum.gates;

/++
Quantum Gates Module

Standard quantum gates for quantum circuit simulation.
This module provides all common single-qubit gates as 2x2 unitary matrices.
+/

import quantum.common : C;
import std.math : sqrt, cos, sin, PI;

/// Collection of standard quantum gates as 2x2 unitary matrices
struct Gates {
    /// 1/sqrt(2) constant used in many gates
    private static immutable real SQRT2_INV = 1.0L / sqrt(2.0L);

    // =========================================================================
    // PAULI GATES
    // =========================================================================

    /++
    Pauli-X gate (NOT gate / bit-flip).
    Matrix: [0 1; 1 0]
    +/
    static immutable C[2][2] X = [
        [C(0), C(1)],
        [C(1), C(0)]
    ];

    /++
    Pauli-Y gate.
    Matrix: [0 -i; i 0]
    +/
    static immutable C[2][2] Y = [
        [C(0), C(0, -1)],
        [C(0, 1), C(0)]
    ];

    /++
    Pauli-Z gate (phase-flip).
    Matrix: [1 0; 0 -1]
    +/
    static immutable C[2][2] Z = [
        [C(1), C(0)],
        [C(0), C(-1)]
    ];

    // =========================================================================
    // HADAMARD GATE
    // =========================================================================

    /++
    Hadamard gate - creates superposition.
    Matrix: [1 1; 1 -1] / sqrt(2)
    +/
    static immutable C[2][2] H = [
        [C(SQRT2_INV), C(SQRT2_INV)],
        [C(SQRT2_INV), C(-SQRT2_INV)]
    ];

    // =========================================================================
    // PHASE GATES
    // =========================================================================

    /++
    S gate (sqrt(Z) gate, phase gate).
    Matrix: [1 0; 0 i]
    +/
    static immutable C[2][2] S = [
        [C(1), C(0)],
        [C(0), C(0, 1)]
    ];

    /++
    S-dagger gate (inverse of S).
    Matrix: [1 0; 0 -i]
    +/
    static immutable C[2][2] Sdag = [
        [C(1), C(0)],
        [C(0), C(0, -1)]
    ];

    /++
    T gate (sqrt(S) gate, pi/8 gate).
    Matrix: [1 0; 0 e^(i*pi/4)]
    +/
    static C[2][2] T() {
        immutable real angle = PI / 4.0L;
        return [
            [C(1), C(0)],
            [C(0), C(cos(angle), sin(angle))]
        ];
    }

    /++
    T-dagger gate (inverse of T).
    Matrix: [1 0; 0 e^(-i*pi/4)]
    +/
    static C[2][2] Tdag() {
        immutable real angle = -PI / 4.0L;
        return [
            [C(1), C(0)],
            [C(0), C(cos(angle), sin(angle))]
        ];
    }

    // =========================================================================
    // ROTATION GATES
    // =========================================================================

    /++
    Rx gate - rotation around X-axis by angle theta.
    Matrix: [cos(t/2) -i*sin(t/2); -i*sin(t/2) cos(t/2)]
    +/
    static C[2][2] Rx(real theta) {
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        return [
            [C(c), C(0, -s)],
            [C(0, -s), C(c)]
        ];
    }

    /++
    Ry gate - rotation around Y-axis by angle theta.
    Matrix: [cos(t/2) -sin(t/2); sin(t/2) cos(t/2)]
    +/
    static C[2][2] Ry(real theta) {
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        return [
            [C(c), C(-s)],
            [C(s), C(c)]
        ];
    }

    /++
    Rz gate - rotation around Z-axis by angle theta.
    Matrix: [e^(-i*t/2) 0; 0 e^(i*t/2)]
    +/
    static C[2][2] Rz(real theta) {
        real c = cos(theta / 2.0L);
        real s = sin(theta / 2.0L);
        return [
            [C(c, -s), C(0)],
            [C(0), C(c, s)]
        ];
    }

    /++
    General phase gate P(phi).
    Matrix: [1 0; 0 e^(i*phi)]
    +/
    static C[2][2] P(real phi) {
        return [
            [C(1), C(0)],
            [C(0), C(cos(phi), sin(phi))]
        ];
    }

    // =========================================================================
    // IDENTITY
    // =========================================================================

    /++
    Identity gate (no operation).
    Matrix: [1 0; 0 1]
    +/
    static immutable C[2][2] I = [
        [C(1), C(0)],
        [C(0), C(1)]
    ];

    // =========================================================================
    // SQRT GATES
    // =========================================================================

    /++
    sqrt(X) gate (square root of X).
    Applying twice gives X gate.
    +/
    static C[2][2] SqrtX() {
        return [
            [C(0.5L, 0.5L), C(0.5L, -0.5L)],
            [C(0.5L, -0.5L), C(0.5L, 0.5L)]
        ];
    }

    /++
    sqrt(Y) gate (square root of Y).
    +/
    static C[2][2] SqrtY() {
        return [
            [C(0.5L, 0.5L), C(-0.5L, -0.5L)],
            [C(0.5L, 0.5L), C(0.5L, 0.5L)]
        ];
    }
}
