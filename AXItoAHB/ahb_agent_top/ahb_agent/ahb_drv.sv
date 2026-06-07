class ahb_drv extends uvm_driver#(ahb_xtn);
     `uvm_component_utils(ahb_drv)
     `NEW_COMP
    ahb_cfg ahb_cfg_h;
    virtual ahb_if vif;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_drv")
        vif = ahb_cfg_h.vif;
    endfunction

    task send_to_dut(ahb_xtn xtn);
        $display("\n***************** send to dut : AHB DRV : time : %0t *************", $time);
      vif.ahb_drv_cb.hmaster <= 4'b0;  //master code : is this for multiple masters?

      if(xtn.resp == 0)   // okay transaction (hresp : 0 - okay)----> hready high for 2 cc (for the transfer to be done)
        begin
            
            if(vif.ahb_drv_cb.hwrite == 1'b1)         //write trans - no hrdata
                $display("\n---------------- OKAY RESPONSE : WRITE : TIME : %0t----------------------", $time);
                repeat(2) begin
                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                end

            else if(vif.ahb_drv_cb.hwrite == 1'b0)  //read trans - hrdata  // slave wont be sending hready in read trans so
                begin
                    $display("\n---------------- OKAY RESPONSE : READ : TIME : %0t----------------------", $time);
                    repeat(2) begin   // I ADDED THIS
                        vif.ahb_drv_cb.hready <= 1'b1; //no need right?
                        vif.ahb_drv_cb.hresp  <= 2'b0;
                        vif.ahb_drv_cb.hrdata <= xtn.hrdata;

                        @(vif.ahb_drv_cb);
                    end
                end
        end

    else if(xtn.resp == 1)  // okay with wait states (hresp : 0 -- its still okay state) --> after delay make hready 1
      begin

         if(vif.ahb_drv_cb.hwrite == 1'b1)  // write trans
            begin
                $display("\n---------------- OKAY RESPONSE WITH DELAY : WRITE : TIME : %0t----------------------", $time);
                vif.ahb_drv_cb.hready <= 1'b0;

                repeat(xtn.delay_cycles)    //delay
                @(vif.ahb_drv_cb);

                repeat(2) begin
                    vif.ahb_drv_cb.hready <= 1'b1;     //asserted after delay
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                end

                vif.ahb_drv_cb.hready <= 1'b0;
            end

        else if(vif.ahb_drv_cb.hwrite == 1'b0)   //read trans
            begin
                 $display("\n---------------- OKAY RESPONSE WITH DELAY : READ : TIME : %0t----------------------", $time);
                vif.ahb_drv_cb.hready <= 1'b0;

                repeat(xtn.delay_cycles)
                @(vif.ahb_drv_cb);

                repeat(2) begin
                vif.ahb_drv_cb.hready <= 1'b1;
                vif.ahb_drv_cb.hresp  <= 2'b0;
                vif.ahb_drv_cb.hrdata <= xtn.hrdata;

                @(vif.ahb_drv_cb);
                end

                vif.ahb_drv_cb.hready <= 1'b0;
            end
      end
    else if(xtn.resp == 2)
      begin

         if(vif.ahb_drv_cb.hwrite == 1'b1)
            begin
                @(vif.ahb_drv_cb);    /// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

                if(vif.ahb_drv_cb.htrans == (2'b10))
                    begin
                         $display("\n---------------- ERROR RESPONSE (HTRANS == NON SEQ) : WRITE : TIME : %0t----------------------", $time);
                        vif.ahb_drv_cb.hready <= 1'b0;    // first cc hready should be 0
                        vif.ahb_drv_cb.hresp  <= 2'b01;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b1;  // next cc hready should be 1
                        vif.ahb_drv_cb.hresp  <= 2'b01;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b0;
                    end

                else   // if htrans is not non seq then error response wont be sent
                    begin
                         $display("\n---------------- ERROR RESPONSE (HTRANS != NON SEQ) : WRITE : TIME : %0t----------------------", $time);
                        @(vif.ahb_drv_cb);
                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b1;
                        vif.ahb_drv_cb.hresp  <= 2'b0;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b0;
                    end

            end

        else if(vif.ahb_drv_cb.hwrite == 1'b0)
         begin
            @(vif.ahb_drv_cb);

            if(vif.ahb_drv_cb.htrans == (2'b10))
                begin
                     $display("\n---------------- ERROR RESPONSE (HTRANS == NON SEQ) : READ : TIME : %0t----------------------", $time);
                    vif.ahb_drv_cb.hready <= 1'b0;
                    vif.ahb_drv_cb.hresp  <= 2'b01;

                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b01;

                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b0;
                end

            else
                begin
                    @(vif.ahb_drv_cb);
                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b0;
                end

         end

      end

   endtask
task run_phase(uvm_phase phase);
      forever begin
           // $display("entered run phase : AHB DRIVER - waiting for trans from seq");
            seq_item_port.get_next_item(req);
          //  $display("got trans from seq in run phase : AHB DRIVER");
            send_to_dut(req);
            seq_item_port.item_done();
         //    $display(" trans is sent to dut(completed) : AHB DRIVER");
      end
    endtask
endclass

~
~
~
~
~
~
