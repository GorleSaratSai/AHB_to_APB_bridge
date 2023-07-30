module top_tb();
reg hclk;
reg hresetn;

wire [31:0] hrdata;
wire [31:0] haddr;
wire [31:0] hwdata;
wire [31:0] prdata;
wire [31:0] paddr;
wire [31:0] pwdata;
wire [31:0] paddrout;
wire [31:0] pwdataout;
wire hwrite;
wire hreadyin;
wire [1:0] htrans;
wire [1:0]hresp;
wire penable;
wire pwrite;
wire hreadyout;
wire pwriteout;
wire penableout;
wire [2:0] pselx;
wire [2:0] pselxout;

ahb_master AHB(hclk,hresetn,hreadyout,hrdata,haddr,hwdata,hwrite,hreadyin,htrans);

bridge_top BRIDGE(hclk,hresetn,hwrite,hreadyin,htrans,hwdata,haddr,prdata,penable,pwrite,hreadyout,pselx,hresp,paddr,pwdata,hrdata);

apb_interface APB(pwrite,penable,pselx,paddr,pwdata,pwriteout,penableout,pselxout,paddrout,pwdataout,prdata);

initial
  begin
    hclk=1'b0;
    forever
    #10 hclk=~hclk;
  end

task reset;
  begin
    @(negedge hclk);//driving reset at negedge of hclk for sability & maintain setup ime violation.
      hresetn=1'b0;
    @(negedge hclk);
      hresetn=1'b1;
  end
endtask

initial
  begin
    reset;
      //AHB.single_write();
      //AHB.single_read();
      //AHB.burst_4_incr_write();
     //AHB.burst_inc4_read();
      AHB.back_2_back();
  end

initial
  #800 $finish;

endmodule
