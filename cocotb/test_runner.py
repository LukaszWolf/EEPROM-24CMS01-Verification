import os
from pathlib import Path

from cocotb_tools.runner import get_runner


def test_my_design_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent
    rtl = proj_path / ".." / "rtl"

    # Package first; EEPROM model + controller + top wrapper (module `dut`).
    sources = [
        rtl / "ctrl_operations_pkg.sv",
        rtl / "24CSM01.v",
        rtl / "ctrl.sv",
        rtl / "dut.sv",
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="dut",
        build_args=["-g2012"],   # Icarus needs SystemVerilog support
        always=True,
        waves=True,              # always rebuild with waveform dump enabled
    )

    runner.test(hdl_toplevel="dut", test_module="test_readback", waves=True)


if __name__ == "__main__":
    test_my_design_runner()
