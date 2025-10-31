module quantum.qasm;

enum GateType { H, CX, X, Z }

struct GateOp {
    GateType type;
    size_t target;
    size_t control = size_t.max;
}