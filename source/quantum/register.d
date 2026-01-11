/++
$(H2 Quantum Register Module)

Multi-qubit quantum register for simulating quantum circuits.

A quantum register of N qubits has 2^N basis states, each with a complex amplitude.

Example:
---
auto reg = QRegister!2([C(1), C(0), C(0), C(0)]);  // |00⟩ state
reg.applyGate(0, H_GATE);                          // Apply H to qubit 0
reg.applyCNOT(0, 1);                               // CNOT with control=0, target=1
bool result = reg.measure(0);                       // Measure qubit 0
---
+/
module quantum.register;

import std.math;
import std.algorithm : swap;
import std.exception : enforce;

import quantum.common : C, absSq;


private enum : real {
    PROB_DISPLAY_THRESHOLD = 1e-10L  /// Minimum probability to display in print()
}

/++
Quantum register holding N entangled qubits.

Params:
    N = Number of qubits (register has 2^N basis states)
+/
struct QRegister(ulong N) {
    private enum size_t NUM_STATES = 1 << N;  /// Total number of basis states (2^N)
    
    /// State vector: complex amplitudes for all 2^N basis states
    C[NUM_STATES] state;

    /++
    Constructs a quantum register from initial amplitudes.
    
    Params:
        init = Array of 2^N complex amplitudes (will be normalized)
    
    Throws:
        Exception if init.length != 2^N
    +/
    this(C[] init) {
        enforce(init.length == NUM_STATES, "Initial state must have 2^N amplitudes");
        foreach (i, amp; init) state[i] = amp;
        normalize();
    }

    /// Normalizes the state vector so that total probability = 1
    void normalize() {
        real sum = 0.0L;
        foreach (amp; state) sum += absSq(amp);
        real norm = sqrt(sum);
        if (norm > 0.0L) foreach (ref amp; state) amp /= norm;
    }

    /// Returns probability of measuring basis state k
    real prob(size_t k) const => absSq(state[k]);

    /++
    Applies a single-qubit gate to the specified target qubit.
    
    Params:
        target = Index of qubit to apply gate to (0-indexed)
        gate = 2x2 unitary matrix representing the gate
    +/
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

    /++
    Applies a CNOT (controlled-NOT) gate.
    
    Flips the target qubit if and only if the control qubit is |1⟩.
    
    Params:
        control = Index of control qubit
        target = Index of target qubit
    +/
    void applyCNOT(size_t control, size_t target) {
        size_t cbit = 1UL << control;
        size_t tbit = 1UL << target;
        C[NUM_STATES] temp;
        foreach (i; 0 .. NUM_STATES) {
            temp[i] = (i & cbit) ? state[i ^ tbit] : state[i];
        }
        state = temp;
    }

    /++
    Applies a Controlled-Z (CZ) gate.
    
    Applies a phase of -1 when both qubits are |1⟩.
    
    Params:
        control = Index of control qubit
        target = Index of target qubit
    +/
    void applyCZ(size_t control, size_t target) {
        size_t cbit = 1UL << control;
        size_t tbit = 1UL << target;
        foreach (i; 0 .. NUM_STATES) {
            if ((i & cbit) && (i & tbit)) {
                state[i] = state[i] * C(-1);
            }
        }
    }

    /++
    Applies a Controlled-Y (CY) gate.
    
    Applies Y gate to target when control is |1⟩.
    
    Params:
        control = Index of control qubit
        target = Index of target qubit
    +/
    void applyCY(size_t control, size_t target) {
        size_t cbit = 1UL << control;
        size_t tbit = 1UL << target;
        C[NUM_STATES] temp = state;
        foreach (i; 0 .. NUM_STATES) {
            if (i & cbit) {
                size_t j = i ^ tbit;
                if (i & tbit) {
                    // |1⟩ -> -i|0⟩
                    temp[i] = state[j] * C(0, -1);
                } else {
                    // |0⟩ -> i|1⟩
                    temp[i] = state[j] * C(0, 1);
                }
            }
        }
        state = temp;
    }

    /++
    Applies a SWAP gate - exchanges the states of two qubits.
    
    Params:
        qubit1 = Index of first qubit
        qubit2 = Index of second qubit
    +/
    void applySWAP(size_t qubit1, size_t qubit2) {
        size_t bit1 = 1UL << qubit1;
        size_t bit2 = 1UL << qubit2;
        C[NUM_STATES] temp;
        foreach (i; 0 .. NUM_STATES) {
            bool b1 = (i & bit1) != 0;
            bool b2 = (i & bit2) != 0;
            if (b1 != b2) {
                // Swap the bits
                temp[i] = state[i ^ bit1 ^ bit2];
            } else {
                temp[i] = state[i];
            }
        }
        state = temp;
    }

    /++
    Applies a Toffoli (CCNOT) gate - controlled-controlled-NOT.
    
    Flips target qubit only when both control qubits are |1⟩.
    
    Params:
        control1 = Index of first control qubit
        control2 = Index of second control qubit
        target = Index of target qubit
    +/
    void applyToffoli(size_t control1, size_t control2, size_t target) {
        size_t c1bit = 1UL << control1;
        size_t c2bit = 1UL << control2;
        size_t tbit = 1UL << target;
        C[NUM_STATES] temp;
        foreach (i; 0 .. NUM_STATES) {
            if ((i & c1bit) && (i & c2bit)) {
                temp[i] = state[i ^ tbit];
            } else {
                temp[i] = state[i];
            }
        }
        state = temp;
    }

    /++
    Applies a Fredkin (CSWAP) gate - controlled-SWAP.
    
    Swaps qubit1 and qubit2 only when control is |1⟩.
    
    Params:
        control = Index of control qubit
        target1 = Index of first target qubit
        target2 = Index of second target qubit
    +/
    void applyFredkin(size_t control, size_t target1, size_t target2) {
        size_t cbit = 1UL << control;
        size_t t1bit = 1UL << target1;
        size_t t2bit = 1UL << target2;
        C[NUM_STATES] temp;
        foreach (i; 0 .. NUM_STATES) {
            if (i & cbit) {
                bool b1 = (i & t1bit) != 0;
                bool b2 = (i & t2bit) != 0;
                if (b1 != b2) {
                    temp[i] = state[i ^ t1bit ^ t2bit];
                } else {
                    temp[i] = state[i];
                }
            } else {
                temp[i] = state[i];
            }
        }
        state = temp;
    }

    /++
    Applies a controlled single-qubit gate.
    
    Applies the given gate to target only when control is |1⟩.
    
    Params:
        control = Index of control qubit
        target = Index of target qubit
        gate = 2x2 unitary matrix representing the gate
    +/
    void applyControlled(size_t control, size_t target, C[2][2] gate) {
        size_t cbit = 1UL << control;
        size_t tbit = 1UL << target;
        
        foreach (i; 0 .. NUM_STATES) {
            if ((i & cbit) && !(i & tbit)) {
                size_t i0 = i;
                size_t i1 = i | tbit;
                C a = state[i0], b = state[i1];
                state[i0] = gate[0][0] * a + gate[0][1] * b;
                state[i1] = gate[1][0] * a + gate[1][1] * b;
            }
        }
    }

    /++
    Performs a measurement on a single qubit, collapsing the state.
    
    Params:
        qubit = Index of qubit to measure
    
    Returns:
        true if measured |1⟩, false if measured |0⟩
    +/
    bool measure(size_t qubit) {
        real p0 = 0.0L;
        foreach (i; 0 .. NUM_STATES) {
            if (((i >> qubit) & 1) == 0) p0 += prob(i);
        }
        import std.random : uniform01, rndGen;
        bool result = uniform01!real(rndGen) >= p0;  // true = |1⟩, false = |0⟩

        foreach (i; 0 .. NUM_STATES) {
            if (((i >> qubit) & 1) != (result ? 1 : 0)) {
                state[i] = C(0.0L);
            }
        }
        normalize();
        return result;
    }

    void print() const {
        import std.stdio : writeln, writefln;
        
        writeln("State vector:");
        foreach (i; 0 .. NUM_STATES) {
            real p = prob(i);
            if (p > PROB_DISPLAY_THRESHOLD) {
                writefln!"  |%0*b⟩ → %.6f%+fi  (P=%.6f)"(N, i, state[i].re, state[i].im, p);
            }
        }
    }
}
