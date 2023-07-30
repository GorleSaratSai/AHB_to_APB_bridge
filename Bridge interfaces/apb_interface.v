module apb_interface(pwrite,penable,pselx,paddr,pwdata,pwriteout,penableout,pselxout,paddrout,pwdataout,prdata);

input pwrite,penable;
input [2:0] pselx;
input [31:0] paddr;
input [31:0] pwdata;

output pwriteout;
output penableout;
output [2:0] pselxout;
output [31:0] paddrout;
output [31:0] pwdataout;
output reg [31:0] prdata;

assign pwriteout =pwrite;
assign paddrout =paddr;
assign pselxout =pselx;
assign pwdataout =pwdata;
assign penableout =penable;

always@(*)
  begin 
    if(!pwrite&&penable)
      prdata={$random}%256;
    else
      prdata=32'h0;
  end

endmodule
