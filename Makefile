TEST   ?= i2c_base_test
GUI    ?= 0
WAVE   ?= 0
COV    ?= 0
V 	   ?= UVM_LOW
SNAPSHOT = sim_snapshot
TOP_MODULE = tb_lib.top
LOG_DIR    = logs
COV_DIR     = cov
COV_REPORT  = $(COV_DIR)/report

ifeq ($(WAVE), 1)
    VLOG_FLAGS = -d DUMP_WAVES
endif

ifeq ($(GUI), 1)
    XSIM_FLAGS = -gui
else
    XSIM_FLAGS = -runall
endif

ifeq ($(COV), 1)
    COV_ELAB = -cc_type sbct
endif

all:
	@$(MAKE) --no-print-directory full QUIET="> /dev/null"
	@$(MAKE) --no-print-directory filter
	
full: prep comp_rtl comp_tb elab run report_cov
	@echo "Logs: $(LOG_DIR)/"

prep:
	@mkdir -p $(LOG_DIR)

comp_rtl:
	@echo -n "RTL COMPILATION (rtl_lib)... "
	@xvlog $(VLOG_FLAGS) -sv -work rtl_lib -f rtl/rtl.f -log $(LOG_DIR)/comp_rtl.log $(QUIET) \
        || (echo "ERROR! log:"; cat $(LOG_DIR)/comp_rtl.log; exit 1)
	@echo "OK"

comp_tb:
	@echo -n "TB COMPILATION(tb_lib)...  "
	@xvlog $(VLOG_FLAGS) -L uvm -sv -work tb_lib -L rtl_lib -f tb/tb.f -log $(LOG_DIR)/comp_tb.log $(QUIET) \
        || (echo "ERROR! log:"; cat $(LOG_DIR)/comp_tb.log; exit 1)
	@echo "OK"

elab:
	@echo -n "Elaboration...              "
	@xelab -debug typical $(COV_ELAB) -L uvm $(TOP_MODULE) -L rtl_lib -L tb_lib -timescale 1ns/1ps -s $(SNAPSHOT) -log $(LOG_DIR)/elab.log $(QUIET) \
        || (echo "ERROR! log:"; cat $(LOG_DIR)/elab.log; exit 1)
	@echo "OK"

report_cov:
ifeq ($(COV), 1)
	@echo -n "[5/5] Raport Coverage.... "
	@mkdir -p $(COV_REPORT)
	@xcrg -cc_db $(SNAPSHOT) -cc_report $(COV_REPORT) -log $(LOG_DIR)/xcrg.log $(QUIET) || true
	@echo "OK -> Report HTML: $(COV_REPORT)/dashboard.html"
else
	@echo "Coverage disabled (COV=0)"
endif

run:
	@echo -n "Simulation...               "
	@xsim $(SNAPSHOT) $(XSIM_FLAGS) -testplusarg UVM_VERBOSITY=$(V) -testplusarg UVM_TESTNAME=$(TEST) -cov_db_name $(SNAPSHOT) -log $(LOG_DIR)/xsim.log $(QUIET) \
        || (echo "ERROR! log:"; cat $(LOG_DIR)/xsim.log; exit 1)
	@echo "OK"

filter:
	@echo ""
	@echo "=== SIMULATION LOGS ==="
	@if [ -f $(LOG_DIR)/xsim.log ]; then \
		sed -n '/run -all/,/exit/p' $(LOG_DIR)/xsim.log | grep -v "run -all" | grep -v "xsim" | grep -v "exit"; \
	else \
		echo "Brak pliku logu!"; \
	fi
	@echo "==========================="
	@echo ""

clean:
	@rm -rf xsim.dir *.jou *.pb *.wdb *.str $(LOG_DIR) $(COV_DIR) .Xil xsim.codeCov
	@echo "Folder Cleaned."