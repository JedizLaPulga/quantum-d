<div align="center">

# Quantum D  
![Quantum D Logo](https://img.shields.io/badge/Quantum%20D-Quantum%20in%20D-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48cGF0aCBkPSJNMTIgMmg3LjVjMS4zIDAgMi41LjcgMy4zIDEuOGwuNyAxLjFjLjYuOC41IDEuOS0uMSAyLjUtLjYgMS40LTEuMiAyLjEtMi4zIDIuMWgtM2MwLTEuMS0uOS0yLTItMi0xLjEgMC0yIC45LTIgMkg1Yy0xLjEgMC0yIC45LTIgMnYtM2MwLTEuMS45LTItMi0yaC43Yy4zIDAgLjUuMS43LjFsMS0uN2MuNi0uOCAxLjYtMS4zIDIuNy0xLjN6Ij48L3BhdGg+PHBhdGggZD0iTTEyIDIyaC03LjVjLTEuMyAwLTIuNS0uNy0zLjMtMS44bC0uNy0xLjFjLS42LS44LS41LTEuOS4xLTIuNS42LTEuNCAxLjItMi4xIDIuMy0yLjFoM2MwIDEuMS45IDIgMiAyaDhjMS4xIDAgMi0uOSAyLTJoLTNjMC0xLjEuOS0yIDItMmgxLjRjLjMgMCAuNS0uMS43LS4xbDEtLjZjLjYtLjggMS42LTEuMyAyLjctMS4zeiI+PC9wYXRoPjwvc3ZnPg==&style=for-the-badge)

**Quantum computing. In D. Fast. Clean. OpenQASM-ready.**

[![DUB Version](https://img.shields.io/dub/v/quantum-d?color=blue&style=flat-square)](https://code.dlang.org/packages/quantum-d)
[![DUB Downloads](https://img.shields.io/dub/dt/quantum-d?color=success&style=flat-square)](https://code.dlang.org/packages/quantum-d)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Build](https://img.shields.io/github/actions/workflow/status/yourname/quantum-d/ci.yml?branch=main&style=flat-square)](https://github.com/jedizlapulga/quantum-d/actions)

</div>

---

## Features

| Feature | Description |
|-------|-----------|
| **Qubit** | Normalized, with `H`, `X`, `print()` |
| **QRegister!N** | Full state-vector simulation |
| **QuantumTeleport** | Real quantum teleportation |
| **OpenQASM 2.0 Export** | Ready for IBM Quantum, Qiskit, Cirq |
| **Zero Dependencies** | Pure D |
| **Blazing Fast** | Optimized for CPU |

---

## Quick Start

```bash
dub add quantum-d

import quantum.qubit;
import quantum.teleport;



qasm file output
qreg q[3];
h q[1];
cx q[1],q[2];
cx q[0],q[1];
h q[0];
measure q[0] -> c[0];
measure q[1] -> c[1];
if(c==2) z q[2];

void main() {
    auto psi = Qubit(C(0.6), C(0.8));
    QuantumTeleport.run(psi);  // teleport.qasm
}

