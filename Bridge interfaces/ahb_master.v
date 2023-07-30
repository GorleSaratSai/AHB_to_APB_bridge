module ahb_master(hclk,hresetn,hreadyout,hrdata,haddr,hwdata,hwrite,hreadyin,htrans);

input hclk,hresetn,hreadyout;
input [31:0] hrdata;

output reg [31:0] haddr;
output reg [31:0] hwdata;
output reg hwrite,hreadyin;
output reg [1:0] htrans;
  
 //not menioned in the diagram and porlist but then also we have to write for our requirement.
 reg [2:0] hburst; //single,4,16.....
 reg [2:0] hsize; //size 8,16bit.....
 integer i=0;
 
 //all  the values to the signals in the below tasks are asiigned from observation from the graph..
 
 task single_write();
   begin
     @(posedge hclk)
     #1;
       begin
         hwrite=1;
	 htrans=2'd2; // non sequential transfer because single write 
	 hsize=0; // 0 because here we are doing only transfer of 8 bits
	 hburst=0; // single transfer
	 hreadyin=1;
	 haddr= 32'h8000_0000;
      end
     @(posedge hclk)
     #1;
       begin
         hwdata=32'h24;
	 htrans=2'd0; //after the non sequential since it's single transfer it goes to idle state
       end
   end
endtask
	
task single_read();
  begin
    @(posedge hclk)
    #1;
      begin
        hwrite=0;
	htrans=2'd2;
	hsize=0;
	hburst=0;
	hreadyin=1;
	haddr=32'h8000_0000;
     end
   @(posedge hclk)
   #1;
     begin
       htrans=2'd0;
     end
  end
endtask
	
task burst_4_incr_write();
  begin
    @(posedge hclk);
    #1;
      begin 
	hwrite=1;
	htrans=2'd2; // non sequential because 1st transfer is always n.sequential
	hsize=0;
	hburst=3'd1; // 4 transfer
	hreadyin=1;
	haddr=32'h8000_0000;
      end
    @(posedge hclk)
    #1;
      begin
        haddr=haddr+1;// because 8 bits
	hwdata={$random}%256; //%256 because i want a 8 bit data(random numbers between 0 o 255 will be generated).
	htrans=2'd3; // after n.sequential it is a sequential transfer.
      end
	
     for(i=0;i<2;i=i+1)
       begin
         @(posedge hclk)
	 #1;
	   begin
	     haddr=haddr+1;
	     hwdata={$random}%256;
	     htrans=2'd3;
	   end
        @(posedge hclk); // it's written once again because while this operation address is extended for2 clk cycles.
     end
	
     wait (hreadyout);
       @(posedge hclk)
       #1;
         begin
	   hwdata={$random}%256;
	   htrans=2'd0;
	 end
  end
endtask
	
task burst_inc4_read();
  begin
    @(posedge hclk);
    #1;
      begin
        hwrite=0;
        htrans=2'd2;
        hsize=0;
        hburst=3'd1;
        hreadyin=1;
        haddr=32'h8000_0000;
      end
   
     for(i=0;i<3;i=i+1)
       begin
         @(posedge hclk);
         #1;
           begin
             haddr=haddr+1;
             htrans=2'd3;
           end
        @(posedge hclk);
      end
   
       @(posedge hclk);
       #1;
         begin
           htrans=0;
         end
    end
endtask

task back_2_back();
  begin
    @(posedge hclk)
    #1;
      begin
        hwrite=1;
        htrans=2'd2;
        hsize=0;
        hburst=3'd1;
        hreadyin=1;
        haddr=32'h8000_0000;
     end
   @(posedge hclk)
   #1;
     begin
       hwrite=0;
       haddr=haddr+1;
       hwdata={$random}%256; 
       htrans=2'd2; 
     end
   @(posedge hclk)
   #1;
     begin
       hwrite=1;
       haddr=haddr+1;
       htrans=2'd2;
       @(posedge hclk);
       @(posedge hclk);
       @(posedge hclk);
     end
   @(posedge hclk)
   #1;
     begin
	hwrite=0;
	haddr=haddr+1;
	hwdata={$random}%256; 
	htrans=2'd2;
    end	
  wait(hreadyout);
    @(posedge hclk);
    #1;
      begin
       hwrite=1'bx;
       htrans=2'b0;
      end
  end
endtask
	
 endmodule
	
 
