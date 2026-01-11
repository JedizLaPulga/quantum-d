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
