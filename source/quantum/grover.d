module quantum.grover;

/++
Grover's Search Algorithm

Grover's algorithm provides quadratic speedup for unstructured search.
Given N items, it finds a marked item in O(sqrt(N)) queries instead of O(N).

The algorithm works by:
1. Initialize all qubits in superposition
2. Repeat sqrt(N) times:
   a. Apply oracle (marks the target state with phase -1)
   b. Apply diffusion operator (amplifies marked state amplitude)
3. Measure to find the target

Example:
---
// Search for item 5 in a 3-qubit (8 item) database
auto result = Grover!3.search(5);
writefln!"Found: %d"(result);
---
+/

import quantum.common : C, absSq;
import quantum.register;
import quantum.gates;
import std.math : sqrt, PI, round;
import std.stdio : writeln, writefln;

/++
Grover's quantum search algorithm implementation.

Params:
    N = Number of qubits (searches 2^N items)
+/
struct Grover(ulong N) {
    private enum size_t NUM_STATES = 1 << N;
    
    /++
    Run Grover's search to find a target value.
    
    Params:
        target = The value to search for (0 to 2^N - 1)
        verbose = Print intermediate steps
    
    Returns:
        The measured result (should be target with high probability)
    +/
    static size_t search(size_t target, bool verbose = false) {
        assert(target < NUM_STATES, "Target must be less than 2^N");
        
        if (verbose) {
            writeln("=== GROVER'S SEARCH ALGORITHM ===");
            writefln!"Searching for %d in %d items (%d qubits)"(target, NUM_STATES, N);
        }
        
        // Initialize register in |0...0> state
        C[NUM_STATES] init;
        foreach (ref amp; init) amp = C(0);
        init[0] = C(1);
        auto reg = QRegister!N(init[]);
        
        // Apply Hadamard to all qubits to create superposition
        foreach (q; 0 .. N) {
            reg.applyGate(q, Gates.H);
        }
        
        if (verbose) {
            writeln("\nInitial superposition created");
        }
        
        // Calculate optimal number of iterations
        size_t iterations = optimalIterations();
        if (verbose) {
            writefln!"Optimal iterations: %d"(iterations);
        }
        
        // Grover iterations
        foreach (iter; 0 .. iterations) {
            // Oracle: flip phase of target state
            applyOracle(reg, target);
            
            // Diffusion operator
            applyDiffusion(reg);
            
            if (verbose) {
                writefln!"\nIteration %d:"(iter + 1);
                writefln!"  Target amplitude: %.4f (P=%.4f)"(
                    reg.state[target].re, reg.prob(target));
            }
        }
        
        if (verbose) {
            writeln("\nFinal state probabilities:");
            foreach (i; 0 .. NUM_STATES) {
                real p = reg.prob(i);
                if (p > 0.01) {
                    writefln!"  |%d>: P=%.4f %s"(i, p, i == target ? "<-- TARGET" : "");
                }
            }
        }
        
        // Measure all qubits to get result
        size_t result = measureAll(reg);
        
        if (verbose) {
            writefln!"\nMeasured result: %d (target was %d)"(result, target);
            writeln(result == target ? "SUCCESS!" : "FAILED (try again)");
        }
        
        return result;
    }
    
    /++
    Calculate optimal number of Grover iterations.
    
    Returns:
        Optimal iteration count ~ (pi/4) * sqrt(N)
    +/
    static size_t optimalIterations() {
        // Optimal is approximately (pi/4) * sqrt(2^N)
        real optimal = (PI / 4.0L) * sqrt(cast(real)NUM_STATES);
        return cast(size_t)round(optimal);
    }
    
    /++
    Apply the oracle that marks the target state.
    Flips the phase of |target> to -|target>.
    +/
    private static void applyOracle(ref QRegister!N reg, size_t target) {
        // Oracle simply flips the sign of the target state
        reg.state[target] = reg.state[target] * C(-1);
    }
    
    /++
    Apply the diffusion operator (Grover's diffuser).
    Also known as the "inversion about the mean" operator.
    
    D = 2|s><s| - I, where |s> is the uniform superposition
    +/
    private static void applyDiffusion(ref QRegister!N reg) {
        // Apply H to all qubits
        foreach (q; 0 .. N) {
            reg.applyGate(q, Gates.H);
        }
        
        // Apply conditional phase flip (flip all except |0...0>)
        // This is equivalent to: 2|0><0| - I
        foreach (i; 1 .. NUM_STATES) {
            reg.state[i] = reg.state[i] * C(-1);
        }
        
        // Apply X to all qubits, multi-controlled Z, then X again
        // Simplified: we already did the phase flip above
        
        // Apply H to all qubits again
        foreach (q; 0 .. N) {
            reg.applyGate(q, Gates.H);
        }
    }
    
    /++
    Measure all qubits and return the result as an integer.
    +/
    private static size_t measureAll(ref QRegister!N reg) {
        size_t result = 0;
        foreach (q; 0 .. N) {
            if (reg.measure(q)) {
                result |= (1 << q);
            }
        }
        return result;
    }
    
    /++
    Run Grover's search multiple times and return statistics.
    
    Params:
        target = The value to search for
        runs = Number of times to run the search
    
    Returns:
        Success rate (fraction of runs that found target)
    +/
    static real benchmark(size_t target, size_t runs = 100) {
        size_t successes = 0;
        foreach (_; 0 .. runs) {
            if (search(target, false) == target) {
                successes++;
            }
        }
        return cast(real)successes / cast(real)runs;
    }
}

/++
Convenience function for Grover search with custom oracle.
Allows searching for items matching any predicate.
+/
struct GroverCustom(ulong N) {
    private enum size_t NUM_STATES = 1 << N;
    
    /++
    Search using a custom oracle function.
    
    Params:
        oracle = Function that returns true for target states
        verbose = Print intermediate steps
    
    Returns:
        A measured state that satisfies the oracle
    +/
    static size_t search(bool delegate(size_t) oracle, bool verbose = false) {
        // Count how many solutions exist
        size_t solutionCount = 0;
        foreach (i; 0 .. NUM_STATES) {
            if (oracle(i)) solutionCount++;
        }
        
        if (solutionCount == 0) {
            if (verbose) writeln("No solutions exist!");
            return size_t.max;
        }
        
        if (verbose) {
            writeln("=== GROVER'S SEARCH (Custom Oracle) ===");
            writefln!"Solutions: %d out of %d"(solutionCount, NUM_STATES);
        }
        
        // Initialize
        C[NUM_STATES] init;
        foreach (ref amp; init) amp = C(0);
        init[0] = C(1);
        auto reg = QRegister!N(init[]);
        
        // Superposition
        foreach (q; 0 .. N) {
            reg.applyGate(q, Gates.H);
        }
        
        // Iterations (adjusted for multiple solutions)
        real theta = 2.0L * sqrt(cast(real)solutionCount / cast(real)NUM_STATES);
        size_t iterations = cast(size_t)round((PI / 4.0L) / theta);
        if (iterations == 0) iterations = 1;
        
        if (verbose) writefln!"Iterations: %d"(iterations);
        
        foreach (_; 0 .. iterations) {
            // Oracle: flip phase of all solution states
            foreach (i; 0 .. NUM_STATES) {
                if (oracle(i)) {
                    reg.state[i] = reg.state[i] * C(-1);
                }
            }
            
            // Diffusion
            foreach (q; 0 .. N) reg.applyGate(q, Gates.H);
            foreach (i; 1 .. NUM_STATES) reg.state[i] = reg.state[i] * C(-1);
            foreach (q; 0 .. N) reg.applyGate(q, Gates.H);
        }
        
        // Measure
        size_t result = 0;
        foreach (q; 0 .. N) {
            if (reg.measure(q)) result |= (1 << q);
        }
        
        if (verbose) {
            writefln!"Result: %d (valid: %s)"(result, oracle(result));
        }
        
        return result;
    }
}
