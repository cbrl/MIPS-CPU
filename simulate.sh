verilator -Isrc/ -Wall -Wno-fatal --trace-fst --trace-structs --trace-max-array 512  src/cpu.sv --exe --cc -CFLAGS "-std=c++2a" test/testbench.cpp
make -j -C obj_dir -f Vcpu.mk
./obj_dir/Vcpu &
Vcpu_PID=$!
echo "Starting simulation (pid $Vcpu_PID)"
sleep 1
kill $Vcpu_PID
echo "Ending simulation (pid $Vcpu_PID)"
