<div align="center">

```
     ◇───────────────────────────────────────────────────────◇
     │  ╭─────╮   ╭─────╮   ╭─────╮   ╭─────╮   ╭─────╮      │
     │  │  H  │───│CNOT │───│  X  │───│  Z  │───│ RY  │      │
     │  ╰──┬──╯   ╰──┬──╯   ╰──┬──╯   ╰──┬──╯   ╰──┬──╯      │
     │     │        │╲        │         │         │         │
     │  ───●────────●─●───────●─────────●─────────●───  ⟩   │
     │     ║          ║       ║         ║         ║         │
     │  |ψ⟩ ════════════════════════════════════════ |φ⟩    │
     ◇───────────────────────────────────────────────────────◇
```

# ⚛️ Quantum-D

### *The D Language Quantum Computing Simulator*

<img src="https://img.shields.io/badge/D-CC342D?style=for-the-badge&logo=d&logoColor=white" alt="D Language"/>
<img src="https://img.shields.io/badge/Quantum-Computing-blueviolet?style=for-the-badge" alt="Quantum Computing"/>
<img src="https://img.shields.io/badge/OpenQASM-2.0-00ADD8?style=for-the-badge" alt="OpenQASM 2.0"/>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-19%2F19%20Passing-success?style=flat-square)](source/app.d)
[![D Language](https://img.shields.io/badge/D-2.109+-red?style=flat-square)](https://dlang.org)

---

**🚀 Fast** · **🔬 Accurate** · **📤 OpenQASM Export** · **🎯 Zero Dependencies**

*Simulate quantum circuits, run Grover's search, model realistic NISQ noise — all in pure D.*

</div>

---

## ✨ Features at a Glance

```
    ╔════════════════════════════════════════════════════════════════╗
    ║                                                                ║
    ║   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ║
    ║   │   QUBITS     │    │  REGISTERS   │    │    GATES     │    ║
    ║   │  ─────────   │    │  ─────────   │    │  ─────────   │    ║
    ║   │  |0⟩, |1⟩    │    │  N-qubit     │    │  H,X,Y,Z     │    ║
    ║   │  α|0⟩+β|1⟩   │    │  entangled   │    │  S,T,Rx,Ry   │    ║
    ║   │  Bloch sphere│    │  2^N states  │    │  Rz,CNOT,CZ  │    ║
    ║   └──────────────┘    └──────────────┘    └──────────────┘    ║
    ║                                                                ║
    ║   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ║
    ║   │   GROVER     │    │    NOISE     │    │   TELEPORT   │    ║
    ║   │  ─────────   │    │  ─────────   │    │  ─────────   │    ║
    ║   │  O(√N)       │    │  Depolar     │    │  Bell pairs  │    ║
    ║   │  search      │    │  T1/T2 decay │    │  EPR state   │    ║
    ║   │  algorithm   │    │  Readout err │    │  QASM export │    ║
    ║   └──────────────┘    └──────────────┘    └──────────────┘    ║
    ║                                                                ║
    ╚════════════════════════════════════════════════════════════════╝
```

| Module | Description |
|--------|-------------|
| **`quantum.qubit`** | Single qubit with all standard gates (H, X, Y, Z, S, T, Rx, Ry, Rz, P) |
| **`quantum.register`** | N-qubit register with CNOT, CZ, SWAP, Toffoli, Fredkin gates |
| **`quantum.gates`** | Static gate matrices for direct manipulation |
| **`quantum.grover`** | Grover's quantum search algorithm with O(√N) speedup |
| **`quantum.noise`** | NISQ noise models: depolarizing, amplitude/phase damping, readout errors |
| **`quantum.teleport`** | Quantum teleportation with OpenQASM 2.0 export |
| **`quantum.ghz`** | GHZ entangled state generation |
| **`quantum.qasm`** | OpenQASM 2.0 code generation |

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/quantum-d.git
cd quantum-d

# Build and run tests
dub build
dub run
```

### Hello Quantum World

```d
import quantum.qubit;
import quantum.common : C;

void main() {
    // Create |0⟩ state
    auto q = Qubit(C(1), C(0));
    
    // Apply Hadamard → |+⟩ = (|0⟩ + |1⟩)/√2
    q.H();
    
    // Measure: 50% chance of 0 or 1
    bool result = q.measure();
    
    q.print();  // |ψ⟩ = 0.7071|0⟩ + 0.7071|1⟩
}
```

---

## 🔬 Examples

### 🌀 Create a Bell State (Entanglement)

```d
import quantum.register;
import quantum.gates;
import quantum.common : C;

void main() {
    // Start with |00⟩
    auto reg = QRegister!2([C(1), C(0), C(0), C(0)]);
    
    // Apply H to qubit 0, then CNOT
    reg.applyGate(0, Gates.H);
    reg.applyCNOT(0, 1);
    
    // Now in Bell state: (|00⟩ + |11⟩)/√2
    reg.print();
    // Output:
    //   |00⟩: 0.5000
    //   |11⟩: 0.5000
}
```

### 🔍 Grover's Search Algorithm

```d
import quantum.grover;

void main() {
    // Search for item 5 in a database of 8 items (3 qubits)
    auto result = Grover!3.search(5);
    
    // With ~94% probability, result == 5
    // Quadratic speedup: O(√8) ≈ 3 iterations vs O(8) classical
}
```

```
    ╭─────────────────────────────────────────────────────────╮
    │           GROVER'S ALGORITHM VISUALIZATION              │
    ├─────────────────────────────────────────────────────────┤
    │                                                         │
    │  Iteration 0:  ████ (12.5% - uniform)                   │
    │  Iteration 1:  ██████████████████ (78.1%)               │
    │  Iteration 2:  ████████████████████████ (94.5%) ← peak  │
    │                                                         │
    │  Target |5⟩ amplified from 0.35 → 0.97                  │
    ╰─────────────────────────────────────────────────────────╯
```

### 📡 Quantum Teleportation

```d
import quantum.qubit;
import quantum.teleport;
import quantum.common : C;

void main() {
    // Create arbitrary quantum state to teleport
    auto psi = Qubit(C(0.6), C(0.8));
    
    // Teleport! Generates OpenQASM file
    QuantumTeleport.run(psi);
    
    // Output: teleport.qasm (IBM Quantum compatible)
}
```

**Generated OpenQASM 2.0:**
```qasm
OPENQASM 2.0;
include "qelib1.inc";
qreg q[3];
creg c[2];
h q[1];
cx q[1],q[2];
cx q[0],q[1];
h q[0];
measure q[0] -> c[0];
measure q[1] -> c[1];
```

### 🌡️ Realistic Noise Simulation

```d
import quantum.register;
import quantum.noise;
import quantum.gates;
import quantum.common : C;

void main() {
    // Simulate IBM Quantum-like noise
    auto config = NoiseConfig.ibmQuantum();
    
    auto reg = QRegister!2([C(1), C(0), C(0), C(0)]);
    
    // Noisy Bell state preparation
    C[2][2] h = Gates.H;
    NoiseModel.applyNoisyGate(reg, 0, h, config.singleQubitError);
    NoiseModel.applyNoisyCNOT(reg, 0, 1, config.twoQubitError);
    
    // Measure with readout errors
    bool q0 = reg.measure(0);
    q0 = NoiseModel.applyReadoutError(q0, config.readoutError);
    
    // Fidelity drops from 100% to ~97% due to noise
}
```

---

## 🧮 Supported Quantum Gates

### Single-Qubit Gates

| Gate | Matrix | Description |
|------|--------|-------------|
| **H** | $\frac{1}{\sqrt{2}}\begin{pmatrix}1 & 1\\1 & -1\end{pmatrix}$ | Hadamard - creates superposition |
| **X** | $\begin{pmatrix}0 & 1\\1 & 0\end{pmatrix}$ | Pauli-X (NOT gate) |
| **Y** | $\begin{pmatrix}0 & -i\\i & 0\end{pmatrix}$ | Pauli-Y |
| **Z** | $\begin{pmatrix}1 & 0\\0 & -1\end{pmatrix}$ | Pauli-Z (phase flip) |
| **S** | $\begin{pmatrix}1 & 0\\0 & i\end{pmatrix}$ | Phase gate (√Z) |
| **T** | $\begin{pmatrix}1 & 0\\0 & e^{i\pi/4}\end{pmatrix}$ | π/8 gate (√S) |
| **Rx(θ)** | Rotation around X-axis | Parameterized |
| **Ry(θ)** | Rotation around Y-axis | Parameterized |
| **Rz(θ)** | Rotation around Z-axis | Parameterized |

### Multi-Qubit Gates

| Gate | Description |
|------|-------------|
| **CNOT** | Controlled-NOT (entangling gate) |
| **CZ** | Controlled-Z |
| **CY** | Controlled-Y |
| **SWAP** | Swaps two qubits |
| **Toffoli** | 3-qubit AND gate (CCNOT) |
| **Fredkin** | Controlled-SWAP (CSWAP) |

---

## 🌡️ Noise Models

Simulate real quantum hardware imperfections:

```
    ╭──────────────────────────────────────────────────────────╮
    │                   NOISE CHANNELS                         │
    ├──────────────────────────────────────────────────────────┤
    │                                                          │
    │  DEPOLARIZING        │  AMPLITUDE DAMPING (T1)           │
    │  ───────────────     │  ──────────────────────           │
    │  Random X,Y,Z error  │  |1⟩ decays to |0⟩ over time      │
    │                      │                                   │
    │  PHASE DAMPING (T2)  │  READOUT ERROR                    │
    │  ───────────────     │  ─────────────                    │
    │  Coherence loss      │  Measurement bit-flips            │
    │                      │                                   │
    ╰──────────────────────────────────────────────────────────╯
```

| Preset | 1Q Error | 2Q Error | Readout | T1/T2 |
|--------|----------|----------|---------|-------|
| `ibmQuantum()` | 0.1% | 1% | 1% | ~100μs |
| `googleSycamore()` | 0.15% | 0.6% | 0.4% | ~15μs |
| `ideal()` | 0% | 0% | 0% | ∞ |
| `noisy()` | 5% | 10% | 5% | Short |

---

## 📊 Test Results

```
========================================
     QUANTUM-D EXTENSIVE TEST SUITE
========================================

[PASS] Qubit normalization
[PASS] Hadamard gate
[PASS] Pauli-X gate
[PASS] QRegister normalization
[PASS] CNOT entanglement (Bell state)
[PASS] GHZ state
[PASS] Measurement collapse
[PASS] Complex amplitudes
[PASS] Pauli-Y gate
[PASS] Pauli-Z gate
[PASS] S gate
[PASS] T gate
[PASS] Rotation gates (Rx, Ry, Rz)
[PASS] SWAP gate
[PASS] CZ gate
[PASS] Toffoli gate
[PASS] Gates module
[PASS] Grover's search (90%+ success)
[PASS] Noise models

========================================
  RESULTS: 19/19 tests passed ✓
========================================
```

---

## 📁 Project Structure

```
quantum-d/
├── source/
│   ├── app.d                 # Test suite & demos
│   └── quantum/
│       ├── common.d          # Shared types (Complex!real alias)
│       ├── qubit.d           # Single qubit operations
│       ├── register.d        # N-qubit quantum register
│       ├── gates.d           # Gate matrices
│       ├── grover.d          # Grover's search algorithm
│       ├── noise.d           # NISQ noise models
│       ├── teleport.d        # Quantum teleportation
│       ├── ghz.d             # GHZ state generation
│       └── qasm.d            # OpenQASM 2.0 export
├── dub.json                  # DUB package configuration
├── LICENSE                   # MIT License
├── CONTRIBUTING.md           # Contribution guidelines
├── SECURITY.md               # Security policy
└── README.md                 # You are here!
```

---

## 🔮 Roadmap

- [ ] Quantum error correction codes (Shor, Steane)
- [ ] Variational Quantum Eigensolver (VQE)
- [ ] Quantum Approximate Optimization (QAOA)
- [ ] Density matrix simulation
- [ ] GPU acceleration
- [ ] OpenQASM 3.0 support
- [ ] Qiskit/Cirq integration

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

```
    ╭────────────────────────────────────────╮
    │  🐛 Found a bug? Open an issue!        │
    │  💡 Have an idea? Start a discussion!  │
    │  🔧 Want to help? Submit a PR!         │
    ╰────────────────────────────────────────╯
```

---

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

```
        ╭──────────────────────────────────────────╮
        │                                          │
        │      |ψ⟩ = α|0⟩ + β|1⟩                   │
        │                                          │
        │   Where the magic of superposition       │
        │   meets the power of D                   │
        │                                          │
        ╰──────────────────────────────────────────╯
```

**Made with ❤️ and quantum entanglement**

*Copyright © 2025-2026 jedizlapulga*

</div>
