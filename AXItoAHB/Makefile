SIMULATOR = Questa

RTL = ../RTL/*
work = work

SVTB1 = ../tb/top.sv
PKG = ../test/test_pkg.sv

INC = +incdir+../tb \
      +incdir+../test \
      +incdir+../axi_master_agent_top \
      +incdir+../axi_master_agent_top/axi_agent \
      +incdir+../axi_master_agent_top/axi_rst_agent \
      +incdir+../ahb_slave_agent_top \
      +incdir+../ahb_slave_agent_top/ahb_agent \
      +incdir+../ahb_slave_agent_top/ahb_rst_agent \
      +incdir+../RTL

VSIMOPT = -vopt -voptargs=+acc
VSIMCOV = -coverage -sva

VSIMBATCH1 = -c -do "log -r /* ;coverage save -onexit axi2ahb_cov1;run -all; exit"
VSIMBATCH2 = -c -do "log -r /* ;coverage save -onexit axi2ahb_cov2;run -all; exit"
VSIMBATCH3 = -c -do "log -r /* ;coverage save -onexit axi2ahb_cov3;run -all; exit"
VSIMBATCH4 = -c -do "log -r /* ;coverage save -onexit axi2ahb_cov4;run -all; exit"

help:
	@echo "=============================================================================================="
	@echo "! USAGE          --  make target                                                            !"
	@echo "! clean          =>  clean earlier log and intermediate files                               !"
	@echo "! sv_cmp         =>  Create library and compile the code                                    !"
	@echo "! run_test       =>  compile & run base_test                                                !"
	@echo "! run_test1      =>  compile & run write_test                                               !"
	@echo "! run_test2      =>  compile & run read_test                                                !"
	@echo "! run_test3      =>  compile & run reset_test                                               !"
	@echo "! view_wave1     =>  view waveform of base_test                                             !"
	@echo "! view_wave2     =>  view waveform of write_test                                            !"
	@echo "! view_wave3     =>  view waveform of read_test                                             !"
	@echo "! view_wave4     =>  view waveform of reset_test                                            !"
	@echo "! regress        =>  clean, compile and run all testcases                                   !"
	@echo "! report         =>  merge coverage reports and convert to html                             !"
	@echo "! cov            =>  open merged coverage report in browser                                 !"
	@echo "=============================================================================================="

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
run_test1 : run_test1_$(SIMULATOR)
run_test2 : run_test2_$(SIMULATOR)
run_test3 : run_test3_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)
regress : regress_$(SIMULATOR)
report : report_$(SIMULATOR)
cov : cov_$(SIMULATOR)

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(PKG) $(SVTB1)

run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1) \
	-wlf wave_file1.wlf \
	-l test1.log \
	-sv_seed random \
	work.top +UVM_TESTNAME=test

	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi2ahb_cov1

run_test1_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2) \
	-wlf wave_file2.wlf \
	-l test2.log \
	-sv_seed random \
	work.top +UVM_TESTNAME=write_test

	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi2ahb_cov2

run_test2_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3) \
	-wlf wave_file3.wlf \
	-l test3.log \
	-sv_seed random \
	work.top +UVM_TESTNAME=read_test

	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi2ahb_cov3

run_test3_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4) \
	-wlf wave_file4.wlf \
	-l test4.log \
	-sv_seed random \
	work.top +UVM_TESTNAME=reset_test

	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi2ahb_cov4

view_wave1_Questa:
	vsim -view wave_file1.wlf

view_wave2_Questa:
	vsim -view wave_file2.wlf

view_wave3_Questa:
	vsim -view wave_file3.wlf

view_wave4_Questa:
	vsim -view wave_file4.wlf

report_Questa:
	vcover merge axi2ahb_cov \
	axi2ahb_cov1 \
	axi2ahb_cov2 \
	axi2ahb_cov3 \
	axi2ahb_cov4

	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi2ahb_cov

cov_Questa:
	firefox covhtmlreport/index.html &

regress_Questa: clean_Questa \
	run_test_Questa \
	run_test1_Questa \
	run_test2_Questa \
	run_test3_Questa \
	report_Questa \
	cov_Questa

clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* axi2ahb_cov* *.wlf modelsim.ini work
	clear