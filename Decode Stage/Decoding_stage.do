vsim work.alldecoder
add wave -position insertpoint sim:/alldecoder/*
force -freeze sim:/alldecoder/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/alldecoder/IF_ID 000000000000000000000000000000001010011100000000000 0
force -freeze sim:/alldecoder/RegWriteinput 1 0
force -freeze sim:/alldecoder/Swapinput 0 0
run 100
force -freeze sim:/alldecoder/IF_ID 000000000000000000000000000000001000011100000000000 0
force -freeze sim:/alldecoder/RegWriteinput 1 0
force -freeze sim:/alldecoder/Swapinput 0 0
run 100

force -freeze sim:/alldecoder/IF_ID 000000000000000000000000000000010000011100000000000 0
force -freeze sim:/alldecoder/Mem_Wb_Rd 001 0
force -freeze sim:/alldecoder/value1 00000000000000001111111111111111 0
run 100
force -freeze sim:/alldecoder/RegWriteinput 0 0
force -freeze sim:/alldecoder/Swapinput 0 0
run 100

