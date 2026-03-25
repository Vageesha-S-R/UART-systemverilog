.PHONY: build run wave clean

TOP = uart_tb

OUT = a.out

VCD = uart_tb.vcd

RTL = rtl/baud_gen.sv \
      rtl/fifo.sv \
      rtl/uart_tx.sv \
      rtl/uart_rx.sv \
      rtl/uart_regs.sv \
      rtl/uart_top.sv \
      rtl/uart_wb.sv

TB = tb/uart_tb.sv

IVERILOG = iverilog
VVP = vvp

build:
	$(IVERILOG) -g2012 $(RTL) $(TB) -o $(OUT)

run: build
	$(VVP) $(OUT)

wave: run
	gtkwave $(VCD)

clean:
	rm -f $(OUT) $(VCD)