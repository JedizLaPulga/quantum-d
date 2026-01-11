module quantum.noise;

/++
Quantum Noise Models

Simulates realistic noise in NISQ (Noisy Intermediate-Scale Quantum) devices.
These models help understand how real quantum computers behave.

Supported noise channels:
- Depolarizing: Random Pauli errors (X, Y, Z)
- Amplitude damping: Energy loss (T1 decay)
- Phase damping: Phase randomization (T2 decay)
- Bit-flip: Random X errors
- Phase-flip: Random Z errors

Example:
---
auto reg = QRegister!2([C(1), C(0), C(0), C(0)]);
NoiseModel.applyDepolarizing(reg, 0, 0.01);  // 1% error rate
---
+/

import quantum.common : C, absSq;
import quantum.register;
import quantum.gates;
import std.math : sqrt, exp;
import std.random : uniform01, uniform, rndGen;

/++
Collection of quantum noise channels for realistic simulation.
+/
struct NoiseModel {
    
    // =========================================================================
    // DEPOLARIZING CHANNEL
    // =========================================================================
    
    /++
    Apply depolarizing noise to a single qubit.
    
    With probability p, applies a random Pauli error (X, Y, or Z).
    This models general decoherence in quantum systems.
    
    Params:
        reg = Quantum register
        qubit = Target qubit index
        p = Error probability (0 to 1)
    +/
    static void applyDepolarizing(ulong N)(ref QRegister!N reg, size_t qubit, real p) {
        if (uniform01!real(rndGen) < p) {
            // Apply random Pauli error
            int error = uniform(0, 3, rndGen);
            final switch (error) {
                case 0: reg.applyGate(qubit, Gates.X); break;
                case 1: reg.applyGate(qubit, Gates.Y); break;
                case 2: reg.applyGate(qubit, Gates.Z); break;
            }
        }
    }
    
    /++
    Apply depolarizing noise to all qubits in a register.
    
    Params:
        reg = Quantum register
        p = Error probability per qubit
    +/
    static void applyDepolarizingAll(ulong N)(ref QRegister!N reg, real p) {
        foreach (q; 0 .. N) {
            applyDepolarizing(reg, q, p);
        }
    }
    
    // =========================================================================
    // BIT-FLIP CHANNEL
    // =========================================================================
    
    /++
    Apply bit-flip noise to a single qubit.
    
    With probability p, applies X gate (flips |0> to |1> and vice versa).
    
    Params:
        reg = Quantum register
        qubit = Target qubit index
        p = Flip probability
    +/
    static void applyBitFlip(ulong N)(ref QRegister!N reg, size_t qubit, real p) {
        if (uniform01!real(rndGen) < p) {
            reg.applyGate(qubit, Gates.X);
        }
    }
    
    // =========================================================================
    // PHASE-FLIP CHANNEL
    // =========================================================================
    
    /++
    Apply phase-flip noise to a single qubit.
    
    With probability p, applies Z gate (flips phase of |1>).
    
    Params:
        reg = Quantum register
        qubit = Target qubit index
        p = Flip probability
    +/
    static void applyPhaseFlip(ulong N)(ref QRegister!N reg, size_t qubit, real p) {
        if (uniform01!real(rndGen) < p) {
            reg.applyGate(qubit, Gates.Z);
        }
    }
    
    // =========================================================================
    // AMPLITUDE DAMPING (T1 DECAY)
    // =========================================================================
    
    /++
    Apply amplitude damping noise (T1 relaxation).
    
    Models energy loss where |1> decays to |0> over time.
    This is the dominant error in superconducting qubits.
    
    The damping parameter gamma = 1 - exp(-t/T1) where t is gate time
    and T1 is the relaxation time.
    
    Params:
        reg = Quantum register
        qubit = Target qubit index
        gamma = Damping parameter (0 to 1)
    +/
    static void applyAmplitudeDamping(ulong N)(ref QRegister!N reg, size_t qubit, real gamma) {
        enum size_t NUM_STATES = 1 << N;
        size_t qbit = 1UL << qubit;
        
        real sqrtGamma = sqrt(gamma);
        real sqrt1mGamma = sqrt(1.0L - gamma);
        
        C[NUM_STATES] newState;
        foreach (ref s; newState) s = C(0);
        
        foreach (i; 0 .. NUM_STATES) {
            if ((i & qbit) == 0) {
                // |0> component
                // Kraus operator E0: |0><0| + sqrt(1-gamma)|1><1|
                newState[i] = newState[i] + reg.state[i];
                
                // Contribution from |1> -> |0> decay
                size_t j = i | qbit;  // corresponding |1> state
                newState[i] = newState[i] + reg.state[j] * C(sqrtGamma);
            } else {
                // |1> component survives with probability sqrt(1-gamma)
                newState[i] = newState[i] + reg.state[i] * C(sqrt1mGamma);
            }
        }
        
        // Normalize
        real norm = 0;
        foreach (s; newState) norm += absSq(s);
        norm = sqrt(norm);
        if (norm > 0) {
            foreach (ref s; newState) s = s / C(norm);
        }
        
        reg.state = newState;
    }
    
    // =========================================================================
    // PHASE DAMPING (T2 DECAY)
    // =========================================================================
    
    /++
    Apply phase damping noise (T2 dephasing).
    
    Models loss of quantum coherence without energy loss.
    Reduces off-diagonal elements of the density matrix.
    
    Params:
        reg = Quantum register
        qubit = Target qubit index
        gamma = Dephasing parameter (0 to 1)
    +/
    static void applyPhaseDamping(ulong N)(ref QRegister!N reg, size_t qubit, real gamma) {
        // Phase damping reduces coherence between |0> and |1>
        // Implemented as random phase kick
        if (uniform01!real(rndGen) < gamma) {
            reg.applyGate(qubit, Gates.Z);
        }
    }
    
    // =========================================================================
    // READOUT ERROR
    // =========================================================================
    
    /++
    Simulate measurement readout error.
    
    With probability p, flips the classical measurement result.
    This models detector errors in real quantum computers.
    
    Params:
        result = Original measurement result
        p = Error probability
    
    Returns:
        Potentially flipped result
    +/
    static bool applyReadoutError(bool result, real p) {
        if (uniform01!real(rndGen) < p) {
            return !result;
        }
        return result;
    }
    
    // =========================================================================
    // GATE ERROR
    // =========================================================================
    
    /++
    Apply a noisy gate (gate followed by depolarizing noise).
    
    Params:
        reg = Quantum register
        qubit = Target qubit
        gate = Gate to apply
        errorRate = Probability of error after gate
    +/
    static void applyNoisyGate(ulong N)(ref QRegister!N reg, size_t qubit, 
                                   C[2][2] gate, real errorRate) {
        reg.applyGate(qubit, gate);
        applyDepolarizing(reg, qubit, errorRate);
    }
    
    /++
    Apply a noisy CNOT gate.
    
    Params:
        reg = Quantum register
        control = Control qubit
        target = Target qubit
        errorRate = Probability of error after gate
    +/
    static void applyNoisyCNOT(ulong N)(ref QRegister!N reg, size_t control, 
                                   size_t target, real errorRate) {
        reg.applyCNOT(control, target);
        applyDepolarizing(reg, control, errorRate);
        applyDepolarizing(reg, target, errorRate);
    }
}

/++
Noise configuration for simulating specific quantum hardware.
+/
struct NoiseConfig {
    /// Single-qubit gate error rate
    real singleQubitError = 0.001;  // 0.1%
    
    /// Two-qubit gate error rate
    real twoQubitError = 0.01;      // 1%
    
    /// Measurement readout error rate
    real readoutError = 0.01;       // 1%
    
    /// T1 relaxation time (microseconds)
    real t1 = 100.0;
    
    /// T2 coherence time (microseconds)
    real t2 = 50.0;
    
    /// Typical gate time (microseconds)
    real gateTime = 0.1;
    
    /++
    Get damping parameter for amplitude damping based on T1.
    +/
    real amplitudeDampingGamma() const {
        return 1.0L - exp(-gateTime / t1);
    }
    
    /++
    Get dephasing parameter based on T2.
    +/
    real phaseDampingGamma() const {
        return 1.0L - exp(-gateTime / t2);
    }
    
    /++
    Preset for IBM Quantum (approximate 2024 values).
    +/
    static NoiseConfig ibmQuantum() {
        NoiseConfig config;
        config.singleQubitError = 0.0003;
        config.twoQubitError = 0.008;
        config.readoutError = 0.01;
        config.t1 = 150.0;
        config.t2 = 80.0;
        return config;
    }
    
    /++
    Preset for Google Sycamore (approximate values).
    +/
    static NoiseConfig googleSycamore() {
        NoiseConfig config;
        config.singleQubitError = 0.0015;
        config.twoQubitError = 0.005;
        config.readoutError = 0.03;
        config.t1 = 20.0;
        config.t2 = 15.0;
        return config;
    }
    
    /++
    Preset for noisy simulation (high error rates for testing).
    +/
    static NoiseConfig noisy() {
        NoiseConfig config;
        config.singleQubitError = 0.05;
        config.twoQubitError = 0.10;
        config.readoutError = 0.05;
        return config;
    }
    
    /++
    Preset for ideal (noiseless) simulation.
    +/
    static NoiseConfig ideal() {
        NoiseConfig config;
        config.singleQubitError = 0.0;
        config.twoQubitError = 0.0;
        config.readoutError = 0.0;
        config.t1 = real.infinity;
        config.t2 = real.infinity;
        return config;
    }
}
