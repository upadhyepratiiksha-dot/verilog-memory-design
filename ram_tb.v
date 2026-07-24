module RAM_test;
reg [7:0] data_in;
reg [9:0] address;
wire [7:0] data_out;
reg write, select;
integer k, myseed;

ram_3 RAM (data_out, data_in, address, write, select);

initial
myseed = 35;

initial
begin
  // ---- Write phase: fill every location ----
  for (k = 0; k <= 1023; k = k+1)
  begin
    address = k;
    data_in = (k + k) % 256;   // set addr + data BEFORE pulsing write
    write = 1; select = 1;
    #2 write = 0; select = 0;  // NOW pulse write -> RAM captures data_in at addr
  end

  // ---- Read phase: check random locations ----
  write = 0; select = 1;
  repeat (20)
  begin
    address = $random(myseed) % 1024;
    #2 $display("Address: %5d, Data: %4d", address, data_out); // wait, then read data_out (not data_in!)
  end
end
endmodule
