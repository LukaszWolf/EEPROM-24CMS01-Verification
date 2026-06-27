# test_readback.py -- write random data to a random address, then read it back.

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# operation_t encoding (rtl/ctrl_operations_pkg.sv)
OP_READ_DATA  = 0b00
OP_WRITE_DATA = 0b11

CLK_PERIOD_NS = 10
TWC_MS        = 6     # EEPROM internal write cycle (tWC = 5 ms) + margin


async def reset_dut(dut):
    """Reset the controller and EEPROM, then wait out the controller power-up."""
    dut.start.value         = 0
    dut.op_sel.value        = 0
    dut.datacount.value     = 0
    dut.addr_in.value       = 0
    dut.write_data_in.value = 0

    dut.rst_n.value = 0
    await Timer(200, unit="ns")
    dut.rst_n.value = 1

    # The controller runs a ~1 ms power-up sequence before it reaches IDLE.
    await Timer(1200, unit="us")


async def drive(dut, op, addr, wdata=0, count=0):
    """Issue one transaction via the start/busy/done handshake; return read_data."""
    await RisingEdge(dut.clk)
    dut.addr_in.value       = addr
    dut.write_data_in.value = wdata
    dut.datacount.value     = count
    dut.op_sel.value        = op
    dut.start.value         = 1

    await RisingEdge(dut.busy)
    dut.start.value = 0
    await RisingEdge(dut.done)
    return int(dut.read_data.value)


@cocotb.test(timeout_time=50, timeout_unit="ms")
async def readback(dut):
    """Reset, write random data to a random address, read it back, compare."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start())

    await reset_dut(dut)

    addr  = random.randint(0, 0xFFFF)
    wdata = random.randint(0, 0xFF)
    dut._log.info("WRITE  data=0x%02x -> addr=0x%04x", wdata, addr)
    await drive(dut, OP_WRITE_DATA, addr, wdata=wdata, count=0)

    await Timer(TWC_MS, unit="ms")
    rdata = await drive(dut, OP_READ_DATA, addr, count=0)
    rbyte = rdata & 0xFF
    dut._log.info("READ   data=0x%02x <- addr=0x%04x", rbyte, addr)

    assert rbyte == wdata, \
        f"readback mismatch @0x{addr:04x}: wrote 0x{wdata:02x}, read 0x{rbyte:02x}"
    dut._log.info("READBACK OK: 0x%02x read back from 0x%04x", rbyte, addr)
