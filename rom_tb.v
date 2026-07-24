`timescale 1ns/1ps

module rom_tb;

  reg  [2:0] addr;
  reg        rd_en, cs;
  wire [7:0] data;
  integer    i, errors;
  reg  [7:0] expected [0:7];

  rom ROM (.rd_en(rd_en), .addr(addr), .data(data), .cs(cs));

  initial begin
    // expected values, truncated to 8 bits the same way the ROM's
    // "output reg [7:0] data" truncates them at assignment
    expected[0] = 22;
    expected[1] = 7;
    expected[2] = 2005 % 256; // NOTE: 2005 doesn't fit in 8 bits -> truncates to 213
    expected[3] = 8;
    expected[4] = 1;
    expected[5] = 2004 % 256; // NOTE: 2004 doesn't fit in 8 bits -> truncates to 212
    expected[6] = 3;
    expected[7] = 82;

    errors = 0;
    rd_en  = 1;
    cs     = 1;

    for (i = 0; i < 8; i = i + 1) begin
      addr = i;
      #5;
      if (data !== expected[i]) begin
        errors = errors + 1;
        $display("MISMATCH addr=%0d expected=%0d got=%0d", i, expected[i], data);
      end else begin
        $display("OK addr=%0d data=%0d", i, data);
      end
    end

    if (errors == 0)
      $display("rom_tb: PASS, all 8 locations match (note: addr 2 and 5 are truncated 8-bit values, see source comment)");
    else
      $display("rom_tb: FAIL, %0d mismatches", errors);

    $finish;
  end

endmodule
