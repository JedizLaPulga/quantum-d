import quantum.qubit;
import quantum.register;
import quantum.qasm;
import quantum.teleport;
import quantum.common : C;

void main()
{
	Qubit myQubit = Qubit(C(0.6), C(0.8));
	QuantumTeleport.run(myQubit, true);
}
