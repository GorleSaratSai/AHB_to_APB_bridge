module ahb_slave_interface(hclk,hresetn,hwrite,hreadyin,htrans,hwdata,haddr,prdata,hwritereg,hwritereg1,hwritereg2,hwritereg3,valid,hwdata1,hwdata2,hwdata3,hwdata4,haddr1,haddr2,haddr3,haddr4,hrdata,hresp,tempselx);
 
  input hclk,hwrite,hreadyin;
  input hresetn;
  input [1:0]htrans;
  input [31:0]haddr;
  input [31:0]hwdata;
  input [31:0]prdata;
  
  output reg [31:0]haddr1;
  output reg [31:0]haddr2;
  output reg [31:0]haddr3;
  output reg [31:0]haddr4;
  output reg [31:0]hwdata1;
  output reg [31:0]hwdata2;
  output reg [31:0]hwdata3;
  output reg [31:0]hwdata4;
  output reg [2:0]tempselx;
  output reg valid;
  output reg hwritereg;
  output reg hwritereg1;
  output reg hwritereg2;
  output reg hwritereg3;
  output [1:0] hresp;
  output [31:0]hrdata;
  
  //pipelining of haddress
  always@(posedge hclk)
    begin
      if(!hresetn)
        begin
	  haddr1<=0;
	  haddr2<=0;
          haddr3<=0;
          haddr4<=0;
	end
     else
       begin
	 haddr1<=haddr;
	 haddr2<=haddr1;
         haddr3<=haddr2;
         haddr4<=haddr3;
       end
     end
  //pipelining of hwdata
  always@(posedge hclk)
    begin
      if(!hresetn)
        begin
	  hwdata1<=0;
	  hwdata2<=0;
          hwdata3<=0;
          hwdata4<=0;
        end
      else
        begin
	  hwdata1<=hwdata;
	  hwdata2<=hwdata1;
          hwdata3<=hwdata2;
          hwdata4<=hwdata3;
	end
     end
  //pipelining of hwrite
  always@(posedge hclk)
    begin
      if(!hresetn)
        begin
	  hwritereg<=0;
	  hwritereg1<=0;
          hwritereg2<=0;
          hwritereg3<=0;
	 end
     else
       begin
         hwritereg<=hwrite;
	 hwritereg1<=hwritereg;
         hwritereg2<=hwritereg1;
         hwritereg3<=hwritereg2;
       end
    end
  
  always@(*)
    begin
      if(hreadyin==1 && (haddr >=32'h8000_0000 && haddr<32'h8c00_0000) && (htrans==2'b10||htrans==2'b11))
        begin 
	  valid=1;
	end
      else
        begin
          valid=0;
        end
    end
  
  always@(*)
    begin 
      if( (haddr>=32'h8000_0000 && haddr<32'h8400_0000) )
        tempselx=3'b001;
      else if((haddr>=32'h8400_0000 && haddr<32'h8800_0000) )
        tempselx=3'b010;
      else if( (haddr>=32'h8800_0000 && haddr<32'h8c00_0000) )
        tempselx=3'b100;
      else
        tempselx=3'b000;
    end
  
  assign hrdata=prdata;
  assign hresp=2'b00;
  
endmodule
	 
