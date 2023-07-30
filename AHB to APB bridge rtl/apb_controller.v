module apb_controller(hclk,hresetn,hwritereg,hwritereg1,hwritereg2,hwritereg3,hwrite,valid,haddr,hwdata,hwdata1,hwdata2,hwdata3,hwdata4,haddr1,haddr2,haddr3,haddr4,prdata,tempselx,penable,pwrite,hreadyout,pselx,paddr,pwdata);

input hclk;
input hresetn;
input [31:0] haddr;
input [31:0] haddr1;
input [31:0] haddr2;
input [31:0] haddr3;
input [31:0] haddr4;
input [31:0] hwdata;
input [31:0] hwdata1;
input [31:0] hwdata2;
input [31:0] hwdata3;
input [31:0] hwdata4;
input [31:0] prdata;
input [2:0] tempselx;
input valid;
input hwrite;
input hwritereg,hwritereg1,hwritereg2,hwritereg3;

output reg penable;
output reg pwrite;
output reg [2:0] pselx;
output reg [31:0] pwdata;
output reg [31:0] paddr;
output reg hreadyout;

// as there are 8 states we need register of width [2:0]  to complete all 8 states

reg [2:0] PRESENT_STATE,NEXT_STATE;



// giving resemblance to the states using parameters

parameter ST_IDLE = 3'b000,
          ST_WWAIT = 3'b001,
	  ST_READ = 3'b010,
	  ST_RENABLE = 3'b011,
	  ST_WRITE = 3'b100,
	  ST_WRITEP = 3'b101,
	  ST_WEENABLE = 3'b110,
	  ST_WENABLEP = 3'b111;
		  
 reg penable_temp;
 reg pwrite_temp;
 reg hreadyout_temp;
 reg [2:0] pselx_temp;
 reg [31:0] paddr_temp;
 reg [31:0] pwdata_temp;
		  


// present state logic 

always@(posedge hclk)
  begin
    if(!hresetn)
      PRESENT_STATE<=ST_IDLE;
   else
      PRESENT_STATE<=NEXT_STATE;
  end

// next state logic

 always@(*)
   begin
     NEXT_STATE=ST_IDLE;
	 
       case(PRESENT_STATE)
	  ST_IDLE: begin
		     if( valid == 1 && hwrite == 1)
		       NEXT_STATE = ST_WWAIT;
		     else if( valid == 1 && hwrite == 0)
		       NEXT_STATE = ST_READ;
		     else 
		       NEXT_STATE = ST_IDLE;
		   end
	 ST_READ : NEXT_STATE = ST_RENABLE;
		 
	 ST_RENABLE : begin 
		        if( valid == 1 && hwrite == 1)
			  NEXT_STATE = ST_WWAIT;
			else if( valid == 1 && hwrite == 0)
			  NEXT_STATE = ST_READ;
			else if(valid == 0)
			  NEXT_STATE = ST_IDLE;
		      end
	  ST_WWAIT :  begin
		        if( valid == 1)
	                  NEXT_STATE = ST_WRITEP;
			else if( valid == 0)
			  NEXT_STATE = ST_WRITE;
		      end
         
          ST_WRITEP : NEXT_STATE = ST_WENABLEP;
		 
	  ST_WRITE : begin
		       if( valid == 1)
		         NEXT_STATE = ST_WENABLEP;
		       else if( valid == 0)
			  NEXT_STATE = ST_WEENABLE;
		       end
					
         ST_WEENABLE : begin 
                         if( valid == 1 &&  hwrite == 1)
                           NEXT_STATE = ST_WWAIT;
                         else if( valid == 1 && hwrite == 0)
                           NEXT_STATE = ST_READ;
                         else if(valid == 0) 
                          NEXT_STATE = ST_IDLE;
                        end
		
          ST_WENABLEP : begin
                          if( hwritereg1 == 0)
                            NEXT_STATE = ST_READ; 
                         else if( valid == 1 && hwritereg == 1)
                            NEXT_STATE = ST_WRITEP;
                         else if( valid == 0 && hwritereg == 1)
                            NEXT_STATE = ST_WRITE;
                         end
						
	 default: NEXT_STATE = ST_IDLE;
                        
          
      endcase
  end

//temporary output logic

always@(*)
  begin
    case(PRESENT_STATE)
      ST_IDLE : if( valid == 1 && hwrite == 0 )
                  begin
	            paddr_temp = haddr;
                    pwdata_temp=hwdata;
	            pwrite_temp = hwrite;
	            pselx_temp = tempselx;
	            penable_temp = 0;
	            hreadyout_temp = 0;
	          end
		else if( valid == 1 && hwrite == 1 )
		  begin
                    paddr_temp=haddr1;
                    pwdata_temp=hwdata;
                    pwrite_temp=hwritereg;
		    pselx_temp = 0;
		    penable_temp = 0;
		    hreadyout_temp = 1;
                  end
		 else
	           begin
                     paddr_temp=haddr1;
                     pwdata_temp=hwdata;
                     pwrite_temp=hwritereg;
		     pselx_temp = 0;
		     penable_temp = 0; 
		     hreadyout_temp = 1;
		   end
      ST_READ :   if(hwritereg==0)
                    begin   
                      paddr_temp=haddr1;
                      pwdata_temp=hwdata;
                      pwrite_temp=0;
                      pselx_temp= tempselx;
                      penable_temp = 1;
		      hreadyout_temp = 1;
	            end
                 else
                   begin
                     paddr_temp=haddr3;
                     pwdata_temp=hwdata3;
                     pwrite_temp=0;
                     pselx_temp=tempselx;
                     penable_temp = 1;
	             hreadyout_temp = 1;
                   end
		   
     ST_RENABLE : if( valid == 1 && hwrite == 0)
                    begin
		      paddr_temp = haddr;
                      pwdata_temp=hwdata;
		      pwrite_temp = hwrite;
		      pselx_temp = tempselx;
		      penable_temp = 0;
		      hreadyout_temp = 0;
		    end
	          else if( valid == 1 && hwrite == 1 )
		    begin
                      paddr_temp=haddr4;
                      pwdata_temp=hwdata4;
                      pwrite_temp=0;
		      pselx_temp = 0;
		      penable_temp = 0;
		      hreadyout_temp = 1;
                   end
		  else
		    begin
                      paddr_temp=haddr4;
                      pwdata_temp=hwdata4;
                      pwrite_temp=0;
		      pselx_temp = 0;
		      penable_temp = 0;
		      hreadyout_temp = 1;
		    end

        ST_WWAIT :  if(valid)  
                      begin
                        paddr_temp = haddr1;
		        pwdata_temp = hwdata;
		        pwrite_temp = hwritereg;
		        pselx_temp = tempselx;
		        penable_temp = 0;
		        hreadyout_temp = 0;
		     end
	           else 
                     begin
                       paddr_temp = haddr1;
		       pwdata_temp = hwdata;
		       pwrite_temp = hwritereg;
		       pselx_temp = tempselx;
		       penable_temp = 0;
		       hreadyout_temp = 1;
                     end

       ST_WRITE :         
                  if(hwritereg1)
                    begin  
                      paddr_temp=haddr2;
                      pwdata_temp=hwdata1;
                      pwrite_temp=1;
                      pselx_temp=tempselx;
                      penable_temp = 1;
		      hreadyout_temp = 1;
		   end
                  else
                    begin  
                      paddr_temp=haddr3;
                      pwdata_temp=hwdata1;
                      pwrite_temp=1;
                      pselx_temp=tempselx;
                      penable_temp = 1;
		      hreadyout_temp = 1;
		   end
		   
     ST_WEENABLE : if( valid == 1 && hwrite == 0)
                     begin 
		       paddr_temp = haddr2;
                       pwdata_temp=hwdata;
		       pwrite_temp = hwritereg;
		       pselx_temp = tempselx;
		       penable_temp = 0;
		       hreadyout_temp = 0;
		     end
		    else if( valid == 1 && hwrite == 1)
		      begin
                        paddr_temp=haddr;
                        pwdata_temp=hwdata;
                        pwrite_temp= hwritereg;
		        pselx_temp = 0;
		        penable_temp = 0;
		        hreadyout_temp = 1;
                      end
		   else
		     begin
                       paddr_temp=haddr;
                       pwdata_temp=hwdata;
                       pwrite_temp=1;
		       pselx_temp = 0;
		       penable_temp = 0;
		       hreadyout_temp = 1;
		     end		   
		   
     ST_WRITEP :   if(hwritereg==0)
                     begin
                       paddr_temp=haddr2;
                       pwdata_temp= hwdata1;
                       pwrite_temp=1;
                       pselx_temp=tempselx;
                       penable_temp=1;
                       hreadyout_temp=0;
                     end
                  else if(hwritereg3)
                    begin
                      paddr_temp=haddr3;
                      pwdata_temp=hwdata1;
                      pwrite_temp=1;
                      pselx_temp=tempselx;
                      penable_temp = 1;
		      hreadyout_temp = 1;
		    end
                  else
                    begin
                      paddr_temp=haddr2;
                      pwdata_temp=hwdata1;
                      pwrite_temp=1;
                      pselx_temp=tempselx;
                      penable_temp = 1;
		      hreadyout_temp = 1;
		    end
           
    ST_WENABLEP : if(valid==0 && hwritereg==1)
                    begin
                      paddr_temp = haddr2;
                      pwdata_temp=hwdata;
		      pwrite_temp = hwritereg1;
		      pselx_temp = tempselx;
		      penable_temp = 0;
		      hreadyout_temp = 0;
                    end
                  else if(valid==1&&hwritereg==1)
                    begin
                      paddr_temp = haddr2;
	              pwdata_temp = hwdata;
		      pwrite_temp = hwritereg1;
		      pselx_temp = tempselx;
		      penable_temp = 0;
		      hreadyout_temp = 0;
		    end
		   else
                     begin
                       paddr_temp = haddr2;
	               pwdata_temp = hwdata1;
		       pwrite_temp = hwritereg1;
		       pselx_temp = tempselx;
		       penable_temp = 0;
		       hreadyout_temp = 1;
                      end
                       

			   
      endcase
  end

// actual output logic

always@(posedge hclk)
  begin
    if(!hresetn)
      begin
        paddr<= 0;
        penable<= 0;
        pselx<= 0;
        pwdata<= 0;
        pwrite<= 0;
        hreadyout<= 1;
     end
  else
    begin
      paddr<= paddr_temp;
      penable<= penable_temp;
      pselx<= pselx_temp;
      pwdata<= pwdata_temp;
      pwrite<= pwrite_temp;
      hreadyout<= hreadyout_temp;
   end
end
 
 endmodule
              
             
			 
			
        
	


