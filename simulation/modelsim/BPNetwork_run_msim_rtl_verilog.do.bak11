transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/src {D:/IntelFPGA/BPNetwork/src/lay1_mod.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/src {D:/IntelFPGA/BPNetwork/src/lay2_mod.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/src {D:/IntelFPGA/BPNetwork/src/bpnetwork.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/ip_core {D:/IntelFPGA/BPNetwork/ip_core/bpparams.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/ip_core {D:/IntelFPGA/BPNetwork/ip_core/sigmoid_lut.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/db {D:/IntelFPGA/BPNetwork/db/ADD.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/db {D:/IntelFPGA/BPNetwork/db/MULT.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/src {D:/IntelFPGA/BPNetwork/src/top.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/src {D:/IntelFPGA/BPNetwork/src/seg_display.v}
vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/db {D:/IntelFPGA/BPNetwork/db/mult_ncs.v}

vlog -vlog01compat -work work +incdir+D:/IntelFPGA/BPNetwork/sim {D:/IntelFPGA/BPNetwork/sim/top_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  top_tb

add wave *
view structure
view signals
run 1 ms
