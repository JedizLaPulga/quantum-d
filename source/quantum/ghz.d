module quantum.ghz;

import quantum.common : C;
import quantum.register;

/// GHZ (Greenberger–Horne–Zeilinger) state generator
/// Creates maximally entangled states: |GHZ⟩ = (|00...0⟩ + |11...1⟩) / √2
struct GHZState(ulong N) if (N >= 2) {
    QRegister!N reg;

    /// Initialize a GHZ state with N qubits
    static GHZState create() {
        import std.math : sqrt;
        
        GHZState ghz;
        // |GHZ⟩ = (|00...0⟩ + |11...1⟩) / √2
        ghz.reg.state[0] = C(1.0L / sqrt(2.0L));           // |00...0⟩
        ghz.reg.state[(1 << N) - 1] = C(1.0L / sqrt(2.0L)); // |11...1⟩
        return ghz;
    }

    void print() const {
        reg.print();
    }
}
