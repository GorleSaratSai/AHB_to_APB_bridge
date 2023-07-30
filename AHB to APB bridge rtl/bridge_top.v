module bridge_top(hclk,hresetn,hwrite,hreadyin,htrans,hwdata,haddr,prdata,penable,pwrite,hreadyout,pselx,hresp,paddr,pwdata,hrdata);

  input hclk,hwrite,hreadyin;
  input hresetn;
  input [1:0]htrans;
  input [31:0]haddr;
  input [31:0]hwdata;
  input [31:0]prdata;
  
  output  penable;
  output  pwrite;
  output  [1:0] hresp;
  output  [2:0] pselx;
  output  [31:0] pwdata;
  output  [31:0] paddr;
  output  [31:0] hrdata;
  output  hreadyout;
  
  wire [31:0] hwdata1;
  wire [31:0] hwdata2;
  wire [31:0] hwdata3;
  wire [31:0] hwdata4;
  wire [31:0] haddr1;
  wire [31:0] haddr2;
  wire [31:0] haddr3;
  wire [31:0] haddr4;
  wire [2:0] tempselx;
  wire hwritereg,hwritereg1,hwritereg2,hwritereg3;
  wire valid;
  
    ahb_slave_interface A1(hclk,hresetn,hwrite,hreadyin,htrans,hwdata,haddr,prdata,hwritereg,hwritereg1,hwritereg3,hwritereg2,valid,hwdata1,hwdata2,hwdata3,hwdata4,haddr1,haddr2,haddr3,haddr4,hrdata,hresp,tempselx);
  
    apb_controller A2(hclk,hresetn,hwritereg,hwritereg1,hwritereg2,hwritereg3,hwrite,valid,haddr,hwdata,hwdata1,hwdata2,hwdata3,hwdata4,haddr1,haddr2,haddr3,haddr4,prdata,tempselx,penable,pwrite,hreadyout,pselx,paddr,pwdata);
  
  endmodule
