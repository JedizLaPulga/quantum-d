import quantum.qubit;
import quantum.register;
import quantum.qasm;
import quantum.teleport;
import quantum.ghz;
import quantum.gates;
import quantum.common : C, absSq;
import std.math;
import std.stdio;

void main()
{
    writeln("========================================");
    writeln("     QUANTUM-D EXTENSIVE TEST SUITE    ");
    writeln("========================================\n");
    
    int passed = 0;
    int total = 0;
    
    // Core tests
    total++; if (testQubitNormalization()) passed++;
    total++; if (testHadamardGate()) passed++;
    total++; if (testPauliXGate()) passed++;
    total++; if (testRegisterNormalization()) passed++;
    total++; if (testCNOTEntanglement()) passed++;
    total++; if (testGHZState()) passed++;
    total++; if (testMeasurementCollapse()) passed++;
    total++; if (testComplexAmplitudes()) passed++;
    
    // New gate tests
    total++; if (testPauliYGate()) passed++;
    total++; if (testPauliZGate()) passed++;
    total++; if (testSGate()) passed++;
    total++; if (testTGate()) passed++;
    total++; if (testRotationGates()) passed++;
    total++; if (testSWAPGate()) passed++;
    total++; if (testCZGate()) passed++;
    total++; if (testToffoliGate()) passed++;
    total++; if (testGatesModule()) passed++;
    
    writeln("\n========================================");
    writefln!"  RESULTS: %d/%d tests passed"(passed, total);
    writeln("========================================");
    
    if (passed == total) {
        writeln("  ALL TESTS PASSED!");
    } else {
        writefln!"  %d tests FAILED"(total - passed);
    }
    
    writeln("\n\n========================================");
    writeln("     TELEPORTATION DEMO");
    writeln("========================================\n");
    
    Qubit myQubit = Qubit(C(0.6), C(0.8));
    QuantumTeleport.run(myQubit, true);
}

/// Test that probabilities sum to 1
bool testQubitNormalization() {
    auto q = Qubit(C(3.0), C(4.0));  // Should normalize to 0.6, 0.8
    real sum = q.prob0 + q.prob1;
    bool pass = abs(sum - 1.0L) < 1e-10L;
    writefln!"[%s] Qubit normalization: P0+P1 = %.10f (expected 1.0)"(pass ? "PASS" : "FAIL", sum);
    return pass;
}

/// Test Hadamard gate creates superposition
bool testHadamardGate() {
    auto q = Qubit(C(1.0), C(0.0));  // |0⟩
    q.applyH();
    // Should be (|0⟩ + |1⟩)/√2, so both probs should be 0.5
    bool pass = abs(q.prob0 - 0.5L) < 1e-10L && abs(q.prob1 - 0.5L) < 1e-10L;
    writefln!"[%s] Hadamard on |0⟩: P0=%.6f, P1=%.6f (expected 0.5, 0.5)"(
        pass ? "PASS" : "FAIL", q.prob0, q.prob1);
    return pass;
}

/// Test Pauli-X gate flips qubit
bool testPauliXGate() {
    auto q = Qubit(C(1.0), C(0.0));  // |0⟩
    q.applyX();
    // Should now be |1⟩
    bool pass = abs(q.prob0) < 1e-10L && abs(q.prob1 - 1.0L) < 1e-10L;
    writefln!"[%s] Pauli-X on |0⟩: P0=%.6f, P1=%.6f (expected 0.0, 1.0)"(
        pass ? "PASS" : "FAIL", q.prob0, q.prob1);
    return pass;
}

/// Test QRegister initialization and normalization
bool testRegisterNormalization() {
    auto reg = QRegister!2([C(1), C(1), C(1), C(1)]);  // Equal superposition
    real sum = 0;
    foreach (i; 0..4) sum += reg.prob(i);
    bool pass = abs(sum - 1.0L) < 1e-10L;
    writefln!"[%s] QRegister normalization: sum(P) = %.10f (expected 1.0)"(pass ? "PASS" : "FAIL", sum);
    return pass;
}

/// Test CNOT creates entanglement
bool testCNOTEntanglement() {
    // Start with |00⟩, apply H to qubit 0, then CNOT
    auto reg = QRegister!2([C(1), C(0), C(0), C(0)]);
    
    // Apply H to qubit 0
    C[2][2] H = [
        [C(1.0L/sqrt(2.0L)), C(1.0L/sqrt(2.0L))],
        [C(1.0L/sqrt(2.0L)), C(-1.0L/sqrt(2.0L))]
    ];
    reg.applyGate(0, H);
    
    // Apply CNOT(0→1)
    reg.applyCNOT(0, 1);
    
    // Should be Bell state: (|00⟩ + |11⟩)/√2
    // |00⟩ = index 0, |11⟩ = index 3
    bool pass = abs(reg.prob(0) - 0.5L) < 1e-10L && 
                abs(reg.prob(3) - 0.5L) < 1e-10L &&
                abs(reg.prob(1)) < 1e-10L &&
                abs(reg.prob(2)) < 1e-10L;
    writefln!"[%s] CNOT entanglement (Bell state): P(00)=%.4f, P(01)=%.4f, P(10)=%.4f, P(11)=%.4f"(
        pass ? "PASS" : "FAIL", reg.prob(0), reg.prob(1), reg.prob(2), reg.prob(3));
    return pass;
}

/// Test GHZ state creation
bool testGHZState() {
    auto ghz = GHZState!3.create();
    // Should be (|000⟩ + |111⟩)/√2
    bool pass = abs(ghz.reg.prob(0) - 0.5L) < 1e-10L && 
                abs(ghz.reg.prob(7) - 0.5L) < 1e-10L;
    
    // All other states should have zero probability
    real otherSum = 0;
    foreach (i; 1..7) otherSum += ghz.reg.prob(i);
    pass = pass && (otherSum < 1e-10L);
    
    writefln!"[%s] GHZ state: P(000)=%.4f, P(111)=%.4f, P(others)=%.6f"(
        pass ? "PASS" : "FAIL", ghz.reg.prob(0), ghz.reg.prob(7), otherSum);
    return pass;
}

/// Test measurement collapses state
bool testMeasurementCollapse() {
    // Create |+⟩ state on 1 qubit (via 1-qubit register)
    auto reg = QRegister!1([C(1.0L/sqrt(2.0L)), C(1.0L/sqrt(2.0L))]);
    
    bool result = reg.measure(0);
    
    // After measurement, should be in definite state
    real p0 = reg.prob(0);
    real p1 = reg.prob(1);
    bool pass = (abs(p0 - 1.0L) < 1e-10L && abs(p1) < 1e-10L) ||
                (abs(p0) < 1e-10L && abs(p1 - 1.0L) < 1e-10L);
    writefln!"[%s] Measurement collapse: result=%d, P0=%.4f, P1=%.4f"(
        pass ? "PASS" : "FAIL", result, p0, p1);
    return pass;
}

/// Test complex amplitudes
bool testComplexAmplitudes() {
    // Create qubit with complex phase: (|0⟩ + i|1⟩)/√2
    auto q = Qubit(C(1.0L), C(0.0L, 1.0L));
    bool pass = abs(q.prob0 - 0.5L) < 1e-10L && abs(q.prob1 - 0.5L) < 1e-10L;
    writefln!"[%s] Complex amplitudes: alpha=%.4f%+.4fi, beta=%.4f%+.4fi"(
        pass ? "PASS" : "FAIL", q.alpha.re, q.alpha.im, q.beta.re, q.beta.im);
    return pass;
}

// =========================================================================
// NEW GATE TESTS
// =========================================================================

/// Test Pauli-Y gate
bool testPauliYGate() {
    auto q = Qubit(C(1.0), C(0.0));  // |0⟩
    q.applyY();
    // Y|0⟩ = i|1⟩, so alpha=0, beta=i
    bool pass = abs(q.alpha.re) < 1e-10L && abs(q.alpha.im) < 1e-10L &&
                abs(q.beta.re) < 1e-10L && abs(q.beta.im - 1.0L) < 1e-10L;
    writefln!"[%s] Pauli-Y on |0⟩: beta = %.4f%+.4fi (expected 0+1i)"(
        pass ? "PASS" : "FAIL", q.beta.re, q.beta.im);
    return pass;
}

/// Test Pauli-Z gate
bool testPauliZGate() {
    auto q = Qubit(C(1.0), C(1.0));  // Normalized: (|0⟩ + |1⟩)/√2
    q.applyZ();
    // Z flips phase of |1⟩: (|0⟩ - |1⟩)/√2
    bool pass = abs(q.alpha.re - 1.0L/sqrt(2.0L)) < 1e-10L &&
                abs(q.beta.re + 1.0L/sqrt(2.0L)) < 1e-10L;
    writefln!"[%s] Pauli-Z on |+⟩: alpha=%.4f, beta=%.4f (expected +0.707, -0.707)"(
        pass ? "PASS" : "FAIL", q.alpha.re, q.beta.re);
    return pass;
}

/// Test S gate
bool testSGate() {
    auto q = Qubit(C(0.0), C(1.0));  // |1⟩
    q.applyS();
    // S|1⟩ = i|1⟩
    bool pass = abs(q.beta.re) < 1e-10L && abs(q.beta.im - 1.0L) < 1e-10L;
    writefln!"[%s] S gate on |1⟩: beta = %.4f%+.4fi (expected 0+1i)"(
        pass ? "PASS" : "FAIL", q.beta.re, q.beta.im);
    return pass;
}

/// Test T gate
bool testTGate() {
    auto q = Qubit(C(0.0), C(1.0));  // |1⟩
    q.applyT();
    // T|1⟩ = e^(iπ/4)|1⟩ = (1+i)/√2 |1⟩
    real expected_re = cos(PI/4.0L);
    real expected_im = sin(PI/4.0L);
    bool pass = abs(q.beta.re - expected_re) < 1e-10L && 
                abs(q.beta.im - expected_im) < 1e-10L;
    writefln!"[%s] T gate on |1⟩: beta = %.4f%+.4fi (expected %.4f%+.4fi)"(
        pass ? "PASS" : "FAIL", q.beta.re, q.beta.im, expected_re, expected_im);
    return pass;
}

/// Test rotation gates Rx, Ry, Rz
bool testRotationGates() {
    // Test Rx(π) = -iX (up to global phase, should swap |0⟩ and |1⟩)
    auto q1 = Qubit(C(1.0), C(0.0));  // |0⟩
    q1.applyRx(PI);
    bool pass1 = abs(q1.prob0) < 1e-10L && abs(q1.prob1 - 1.0L) < 1e-10L;
    
    // Test Ry(π) should also swap |0⟩ and |1⟩
    auto q2 = Qubit(C(1.0), C(0.0));  // |0⟩
    q2.applyRy(PI);
    bool pass2 = abs(q2.prob0) < 1e-10L && abs(q2.prob1 - 1.0L) < 1e-10L;
    
    // Test Rz(π) = Z (up to global phase)
    auto q3 = Qubit(C(1.0), C(1.0));  // |+⟩
    q3.applyRz(PI);
    // Should flip phase of |1⟩ component
    bool pass3 = abs(q3.prob0 - 0.5L) < 1e-10L && abs(q3.prob1 - 0.5L) < 1e-10L;
    
    bool pass = pass1 && pass2 && pass3;
    writefln!"[%s] Rotation gates: Rx(π)=%s, Ry(π)=%s, Rz(π)=%s"(
        pass ? "PASS" : "FAIL",
        pass1 ? "ok" : "FAIL",
        pass2 ? "ok" : "FAIL",
        pass3 ? "ok" : "FAIL");
    return pass;
}

/// Test SWAP gate
bool testSWAPGate() {
    // Start with |01⟩
    auto reg = QRegister!2([C(0), C(1), C(0), C(0)]);  // |01⟩
    reg.applySWAP(0, 1);
    // Should become |10⟩
    bool pass = abs(reg.prob(0)) < 1e-10L &&   // |00⟩
                abs(reg.prob(1)) < 1e-10L &&   // |01⟩
                abs(reg.prob(2) - 1.0L) < 1e-10L &&  // |10⟩
                abs(reg.prob(3)) < 1e-10L;     // |11⟩
    writefln!"[%s] SWAP gate: |01⟩ → P(10)=%.4f (expected 1.0)"(
        pass ? "PASS" : "FAIL", reg.prob(2));
    return pass;
}

/// Test CZ gate
bool testCZGate() {
    // Start with |11⟩
    auto reg = QRegister!2([C(0), C(0), C(0), C(1)]);  // |11⟩
    reg.applyCZ(0, 1);
    // CZ|11⟩ = -|11⟩
    bool pass = abs(reg.state[3].re + 1.0L) < 1e-10L;
    writefln!"[%s] CZ gate: |11⟩ amplitude = %.4f (expected -1.0)"(
        pass ? "PASS" : "FAIL", reg.state[3].re);
    return pass;
}

/// Test Toffoli gate
bool testToffoliGate() {
    // Start with |110⟩ (controls both 1)
    auto reg = QRegister!3([C(0), C(0), C(0), C(1), C(0), C(0), C(0), C(0)]);
    // Index 3 = binary 011 = |110⟩ in our ordering (q0=1, q1=1, q2=0)
    reg.applyToffoli(0, 1, 2);
    // Should flip qubit 2: |110⟩ → |111⟩
    // |111⟩ = index 7
    bool pass = abs(reg.prob(7) - 1.0L) < 1e-10L;
    writefln!"[%s] Toffoli gate: |110⟩ → P(111)=%.4f (expected 1.0)"(
        pass ? "PASS" : "FAIL", reg.prob(7));
    return pass;
}

/// Test Gates module
bool testGatesModule() {
    // Test that Gates.H matches manual Hadamard
    auto reg = QRegister!1([C(1), C(0)]);
    reg.applyGate(0, Gates.H);
    bool pass = abs(reg.prob(0) - 0.5L) < 1e-10L && abs(reg.prob(1) - 0.5L) < 1e-10L;
    
    // Test rotation gate from module
    auto q = Qubit(C(1.0), C(0.0));
    q.applyGate(Gates.Rx(PI));
    pass = pass && abs(q.prob1 - 1.0L) < 1e-10L;
    
    writefln!"[%s] Gates module: H and Rx(π) work correctly"(pass ? "PASS" : "FAIL");
    return pass;
}