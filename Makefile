SNAPSHOT   = sim_snapshot
TOP_MODULE = tb_lib.top_tb
LOG_DIR    = logs

all:
	@$(MAKE) full QUIET="> /dev/null"
	@$(MAKE) filter
	@$(MAKE) clean

full: prep comp_rtl comp_tb elab run
	@echo "Logs: $(LOG_DIR)/"

prep:
	@mkdir -p $(LOG_DIR)

comp_rtl:
	@echo -n "RTL COMPILATION (rtl_lib)... "
	@xvlog -sv -work rtl_lib -f rtl/rtl.f -log $(LOG_DIR)/comp_rtl.log $(QUIET) \
		|| (echo "ERROR! log:"; cat $(LOG_DIR)/comp_rtl.log; exit 1)
	@echo "OK"

comp_tb:
	@echo -n "TB COMPILATION(tb_lib)...  "
	@xvlog -sv -work tb_lib -L rtl_lib -f tb/tb.f -log $(LOG_DIR)/comp_tb.log $(QUIET) \
		|| (echo "ERROR! log:"; cat $(LOG_DIR)/comp_tb.log; exit 1)
	@echo "OK"

elab:
	@echo -n "Elaboration...              "
	@xelab -debug typical $(TOP_MODULE) -L rtl_lib -L tb_lib -s $(SNAPSHOT) -log $(LOG_DIR)/elab.log $(QUIET) \
		|| (echo "ERROR! Slog:"; cat $(LOG_DIR)/elab.log; exit 1)
	@echo "OK"

run:
	@echo -n "Simulation...               "
	@xsim $(SNAPSHOT) -runall -log $(LOG_DIR)/xsim.log $(QUIET) \
		|| (echo "ERROR! log:"; cat $(LOG_DIR)/xsim.log; exit 1)
	@echo "OK"

filter:
	@echo ""
	@echo "=== TESTBENCH LOGS ==="
	@if [ -f $(LOG_DIR)/xsim.log ]; then \
		grep -E "\[[0-9]+\]" $(LOG_DIR)/xsim.log || echo "No logs available."; \
	fi
	@echo "========================="
	@echo ""

clean:
	@rm -rf xsim.dir *.jou *.pb *.wdb *.str $(LOG_DIR)
	@echo "Folder Cleaned."

gui:
	xsim $(SNAPSHOT) -gui
