# cocotb + Icarus Verilog testbench for the I2C controller + EEPROM (module `dut`).
# Run from this directory with the cocotb venv active:  make

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# RTL sources (package first; EEPROM model + controller + top wrapper).
VERILOG_SOURCES += $(CURDIR)/../rtl/ctrl_operations_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../rtl/24CSM01.v
VERILOG_SOURCES += $(CURDIR)/../rtl/ctrl.sv
VERILOG_SOURCES += $(CURDIR)/../rtl/dut.sv

# Top-level RTL module (controller + EEPROM) and the Python test module.
COCOTB_TOPLEVEL = dut
COCOTB_TEST_MODULES = test_readback

# Icarus needs SystemVerilog support (-g2012) for logic/always_ff/enum/package.
COMPILE_ARGS += -g2012

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
