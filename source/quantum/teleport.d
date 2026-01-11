module quantum.teleport;

import quantum.register;
import quantum.qasm;
import quantum.qubit;
import quantum.common : C, absSq;

import std.file;

class QuantumTeleport {
    QRegister!3 reg;
    GateOp[] circuit;

    private this(QRegister!3 r) { reg = r; }

    private void log(GateType t, size_t tgt, size_t ctrl = size_t.max) {
        circuit ~= GateOp(t, tgt, ctrl);
    }

    // -------------------------------------------------------------
    // STATIC RUN — TAKES YOUR QUBIT
    // -------------------------------------------------------------
    static void run(Qubit psi, bool exportQASM = true) {
        import std.math;
        import std.stdio : writeln, writefln;
        writeln("=== QUANTUM TELEPORTATION (with your Qubit) ===");
        psi.print();

        // Build |ψ⟩|00⟩ = α|000⟩ + β|001⟩
        // Qubit ordering: q0 = Alice's qubit (to teleport), q1 = ancilla, q2 = Bob's qubit
        // Index bit 0 (value 1) = q0, bit 1 (value 2) = q1, bit 2 (value 4) = q2
        C[8] init = [C(0), C(0), C(0), C(0), C(0), C(0), C(0), C(0)];
        init[0] = psi.alpha;  // |000⟩ (q0=0)
        init[1] = psi.beta;   // |001⟩ (q0=1)

        auto tele = new QuantumTeleport(QRegister!3(init));

        // 1. Bell pair: H(1), CX(1→2)
        C[2][2] H = [
            
            [C(1.0L/sqrt(2.0L)), C(1.0L/sqrt(2.0L))],
            [C(1.0L/sqrt(2.0L)), C(-1.0L/sqrt(2.0L))]
        ];
        tele.reg.applyGate(1, H); tele.log(GateType.H, 1);
        tele.reg.applyCNOT(1, 2); tele.log(GateType.CX, 2, 1);

        // 2. Alice's Bell measurement
        tele.reg.applyCNOT(0, 1); tele.log(GateType.CX, 1, 0);
        tele.reg.applyGate(0, H); tele.log(GateType.H, 0);

        bool c0 = tele.reg.measure(0);
        bool c1 = tele.reg.measure(1);
        writefln!"\nAlice measures → c0=%d, c1=%d\n"(c0, c1);

        // 3. Bob's corrections (based on Alice's measurement results)
        // Standard teleportation: if c1=1, apply X; if c0=1, apply Z
        if (c1) { tele.reg.applyGate(2, [[C(0), C(1)], [C(1), C(0)]]); tele.log(GateType.X, 2); }
        if (c0) { tele.reg.applyGate(2, [[C(1), C(0)], [C(0), C(-1)]]); tele.log(GateType.Z, 2); }

        // 4. Extract Bob's qubit (3 qubits = 8 basis states)
        enum NUM_STATES = 1 << 3;  // 2^3 = 8
        enum QUBIT2_MASK = 1 << 2; // Bit mask for qubit 2
        C bob0 = C(0), bob1 = C(0);
        foreach (i; 0 .. NUM_STATES) {
            if ((i & QUBIT2_MASK) == 0) bob0 += tele.reg.state[i];
            else                        bob1 += tele.reg.state[i];
        }
        real n = sqrt(absSq(bob0) + absSq(bob1));
        bob0 /= n; bob1 /= n;

        writeln("TELEPORTED:");
        writefln!"  %.6f|0⟩ + (%.6f%+fi)|1⟩"(bob0.re, bob1.re, bob1.im);
        writeln("ORIGINAL:");
        psi.print();

        // 5. Export QASM
        if (exportQASM) {
            string qasm = tele.toQASM(c0, c1);
            writeln("\n=== OpenQASM 2.0 ===");
            writeln(qasm);
            std.file.write("teleport.qasm", qasm);
            writeln("Saved to: teleport.qasm");
        }
    }

    string toQASM(bool c0, bool c1) const {
        import std.array : appender;
        import std.string : join;
        auto lines = appender!(string[]);
        lines ~= "OPENQASM 2.0;";
        lines ~= "include \"qelib1.inc\";";
        lines ~= "qreg q[3];";
        lines ~= "creg c[2];";

        foreach (op; circuit) {
            with (GateType) final switch (op.type) {
                import std.format;
                
                case H:  lines ~= format!"h q[%d];"(op.target); break;
                case CX: lines ~= format!"cx q[%d],q[%d];"(op.control, op.target); break;
                case X:  lines ~= format!"x q[%d];"(op.target); break;
                case Z:  lines ~= format!"z q[%d];"(op.target); break;
            }
        }

        lines ~= "measure q[0] -> c[0];";
        lines ~= "measure q[1] -> c[1];";

        int val = (c1 ? 2 : 0) + (c0 ? 1 : 0);
        if (val == 1) lines ~= "if(c==1) x q[2];";
        if (val == 2) lines ~= "if(c==2) z q[2];";
        if (val == 3) lines ~= "if(c==3) x q[2]; z q[2];";

        return lines.data.join("\n") ~ "\n";
    }
}
