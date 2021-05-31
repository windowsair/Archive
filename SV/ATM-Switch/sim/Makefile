RTL= ../src/rtl/hec_cal.v ../src/rtl/LookupTable.v ../src/rtl/utopia1_atm_rx.v ../src/rtl/utopia1_atm_tx.v ../src/rtl/FwdLkp.v ../src/rtl/arbitor.v ../src/rtl/squat.v ../src/rtl/fifo.v
SVTB = ../src/tb/top.sv ../src/tb/cpu_ifc.svh ../src/tb/Utopia.svh
SVCM_NORMAL = ../src/tb/test.sv ../src/tb/environment.sv ../src/tb/config.sv ../src/tb/generator.sv ../src/tb/driver.sv ../src/tb/monitor.sv ../src/tb/scoreboard.sv ../src/tb/coverage.sv ../src/tb/generator_stats.sv
SVCM_ARBITOR = ../src/tb/test_arbitor.sv ../src/tb/environment_arbitor.sv ../src/tb/config.sv ../src/tb/generator.sv ../src/tb/driver.sv ../src/tb/monitor.sv ../src/tb/scoreboard.sv ../src/tb/coverage.sv ../src/tb/generator_stats.sv
# seed = 123456
# use system timestamp

default: test

test: compile_normal run

test_arbitor: compile_arbitor run

run:
	./simv -l simv.log +ntb_random_seed=`date +%s`

compile_normal:
	vcs -full64 -l vcs.log -sverilog -kdb +lint=TFIPC-L -debug_access+all $(SVTB) $(RTL) $(SVCM_NORMAL) +vcs+vcdpluson -lca +incdir+../src/tb

compile_arbitor:
	vcs -full64 -l vcs.log -sverilog -kdb +lint=TFIPC-L -debug_access+all $(SVTB) $(RTL) $(SVCM_ARBITOR) +vcs+vcdpluson -lca +incdir+../src/tb

verdi:
	verdi -ssf novas.fsdb -undockWin -nologo &

dve:
	dve -vpd vcdplus.vpd &

verdi_debug:
	./simv -l simv.log -gui=verdi +ntb_random_seed=$(seed)

debug:
	./simv -l simv.log -gui=dve +ntb_random_seed=$(seed)

solution: clean

clean:
	rm -rf simv* csrc* *.tmp *.vpd *.key *.log *hdrs.h *.fsdb verdiLog elabcomLog novas.* *.dat DVEfiles

nuke: clean
	rm -rf *.v* *.sv include .*.lock .*.old DVE* *.tcl *.h *.rc *.ses *.ses.* *.dat

help:
	@echo ==========================================================================
	@echo  " 								       "
	@echo  " USAGE: make target <seed=xxx>                                         "
	@echo  " 								       "
	@echo  " ------------------------- Test TARGETS ------------------------------ "
	@echo  " test       => Compile TB and DUT files, runs the simulation.          "
	@echo  " compile    => Compile the TB and DUT. Generates dve and verdi output  "
	@echo  " run        => Run the simulation.                                     "
	@echo  " dve        => Run dve in post-processing mode.          "
	@echo  "                                                                       "
	@echo  " verdi      => Run verdi in post-processing mode.          "
	@echo  " verdi_gui  => Run simulation interactively with verdi                  "
	@echo  "               All verdi targets must have Verdi installed.          "
	@echo  "                                                                       "
	@echo  " debug      => Runs simulation interactively with dve.                  "
	@echo  " clean      => Remove all intermediate simv and log files.             "
	@echo  "                                                                       "
	@echo  " -------------------- ADMINISTRATIVE TARGETS ------------------------- "
	@echo  " help       => Displays this message.                                  "
	@echo  " solution   => Copies all files from solutions directory.               "
	@echo  " nuke       => Erase all files except Makefile. Put directory back to original state. "
	@echo  "								       "
	@echo ==========================================================================

#.PHONY: run
