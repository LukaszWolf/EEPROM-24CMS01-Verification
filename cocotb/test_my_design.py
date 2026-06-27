# test_my_design.py -- drives clock and toggles reset on the I2C controller

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def clk_and_reset(dut):
    """Drive a 10 ns clock on `clk` and toggle the active-low reset `rst_n`."""

    # Initialise inputs so the DUT doesn't start from X.
    dut.rst_n.value         = 0
    dut.start.value         = 0
    dut.op_sel.value        = 0
    dut.datacount.value     = 0
    dut.addr_in.value       = 0
    dut.write_data_in.value = 0

    # Free-running 10 ns clock on dut.clk.
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # Hold reset asserted (active-low) for a few clocks.
    await ClockCycles(dut.clk, 5)
    dut._log.info("reset asserted: rst_n=%s busy=%s done=%s",
                  dut.rst_n.value, dut.busy.value, dut.done.value)

    # Release reset and let the clock keep running.
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut._log.info("reset released: rst_n=%s busy=%s done=%s",
                  dut.rst_n.value, dut.busy.value, dut.done.value)

    assert dut.rst_n.value == 1, "rst_n did not deassert"
