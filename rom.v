module rom(rd_en, addr, data, cs);
input [2:0] addr;
input rd_en, cs;
output reg [15:0] data; // widened from 8 to 16 bits so every table
                        // entry (including 2005/2004) fits without
                        // truncation
always @(addr or rd_en or cs)
 if (cs && rd_en)
   case(addr)
    0: data = 22;
    1: data = 07;
    2: data = 2005;
    3: data = 08;
    4: data = 01;
    5: data = 2004;
    6: data = 03;
    7: data = 82;
   endcase
 else
   data = 16'bz; // not selected / read not enabled -> release the bus
endmodule
