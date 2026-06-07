class axi_drv extends uvm_driver#(axi_xtn);

     `uvm_component_utils(axi_drv)
     `NEW_COMP

    axi_xtn axi_xtn_h;
    axi_xtn q_aw[$], q_w[$], q_b[$], q_rw[$], q_r[$];

    semaphore sem_aw=new(1);
    semaphore sem_w=new();
    semaphore sem_b = new();
    semaphore sem_ar=new(1);
    semaphore sem_r=new();

    semaphore sem_aw_w = new(1);
    semaphore sem_ar_r = new(1);
    semaphore sem_w_b= new();

    axi_cfg axi_cfg_h;
    virtual axi_if.AXI_DRV_MP vif;
    ///virtual axi_rst_if.AXI_DRV_MP vif;
    task write_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb);
        begin
           vif.axi_drv_cb.awvalid <= xtn.awvalid;
           vif.axi_drv_cb.awid    <= xtn.awid;
           vif.axi_drv_cb.awaddr  <= xtn.awaddr;
           vif.axi_drv_cb.awlen   <= xtn.awlen;
           vif.axi_drv_cb.awsize  <= xtn.awsize;
           vif.axi_drv_cb.awburst <= xtn.awburst;
           //$display("\n write address channel : AXI  DRIVER - waiting from awready");
           wait(vif.axi_drv_cb.awready)
           @(vif.axi_drv_cb);
          // $display(" write address channel :AXI  DRIVER - received awready");
           vif.axi_drv_cb.awvalid <= 1'b0;
           $display("\n--------- WRITE ADDRESS CHANNEL : TIME : %0t ----------", $time);
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
        end
    endtask

    task read_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb);
        begin
           vif.axi_drv_cb.arvalid <= xtn.arvalid;
           vif.axi_drv_cb.arid    <= xtn.arid;
           vif.axi_drv_cb.araddr  <= xtn.araddr;
           vif.axi_drv_cb.arlen   <= xtn.arlen;
           vif.axi_drv_cb.arsize  <= xtn.arsize;
           vif.axi_drv_cb.arburst <= xtn.arburst;
           vif.axi_drv_cb.aresetn <= xtn.aresetn;

          // $display("\n read address channel : AXI  DRIVER - waiting from arready");
           wait(vif.axi_drv_cb.arready)
           @(vif.axi_drv_cb);
          // $display(" read address channel :AXI  DRIVER - received arready");
           $display("\n--------- READ ADDRESS CHANNEL : TIME : %0t ----------", $time);
           vif.axi_drv_cb.arvalid <= 1'b0;
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
        end
    endtask

    task write_response_channel(axi_xtn xtn);
        begin

           vif.axi_drv_cb.bready <= 1'b1;

          // $display("\n write response channel : AXI  DRIVER - waiting from bready");
           wait(vif.axi_drv_cb.bvalid)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.bready <= 1'b0;

         //  $display(" write response channel :AXI  DRIVER - received bready");
           $display("\n--------- WRITE RESPONSE CHANNEL : TIME : %0t ----------", $time);
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end

    endtask

    task write_data_channel(axi_xtn xtn);
        begin
            foreach(xtn.wdata[i]) begin
           vif.axi_drv_cb.wvalid <= xtn.wvalid;
           vif.axi_drv_cb.wid    <= xtn.wid;
           vif.axi_drv_cb.wdata  <= xtn.wdata[i];
           vif.axi_drv_cb.wstrb   <= xtn.wstrb[i];

           if(i==xtn.awlen) vif.axi_drv_cb.wlast<=1'b1;
           else vif.axi_drv_cb.wlast<=1'b0;

          // $display("\n write data channel : AXI  DRIVER - waiting from wready");
           wait(vif.axi_drv_cb.wready)
           @(vif.axi_drv_cb);
         //  $display(" write data channel :AXI  DRIVER - received wready");
           vif.axi_drv_cb.wvalid <= 1'b0;
           vif.axi_drv_cb.wlast <= 1'b0;
           $display("\n--------- WRITE DATA CHANNEL : TIME : %0t ----------", $time);
           @(vif.axi_drv_cb);
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end
        end
    endtask



    task read_data_channel(axi_xtn xtn);
        begin
           repeat(vif.axi_drv_cb.arlen + 1'b1) begin
           // @(vif.axi_drv_cb); i want to remove here and 
           vif.axi_drv_cb.rready <= 1'b1;

          // $display("\n read data channel : AXI  DRIVER - waiting from rready");
           wait(vif.axi_drv_cb.rvalid)
           
           @(vif.axi_drv_cb);
         //  $display(" read data channel :AXI  DRIVER - received rready");
           vif.axi_drv_cb.rready <= 1'b0;
            $display("\n--------- READ DATA CHANNEL : TIME : %0t ----------", $time);
            //@(vif.axi_drv_cb);        i wanna keep it here
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end
        end
    endtask


    task send_to_dut(axi_xtn xtn);
        $display("\n ********************* entered send to dut task : AXI DRIVER  : time : %0t**********************",$time);

        q_aw.push_back(xtn);
        q_w.push_back(xtn);
        q_b.push_back(xtn);
        q_rw.push_back(xtn);
        q_r.push_back(xtn);
        fork
            begin

               sem_aw.get(1);                           // get the key
               write_address_channel(q_aw.pop_front());
               sem_aw.put(1);    // putting it back as it supports outstanding transactions
               sem_w.put(1);
            end

            begin
               sem_aw_w.get(1);
               sem_w.get(1);
               write_data_channel(q_w.pop_front()); //running
               sem_b.put(1);
               sem_aw_w.put(1);
            end

            begin
                sem_b.get(1);
               write_response_channel(q_b.pop_front());

            end

             begin
                sem_ar.get(1);
                read_address_channel(q_rw.pop_front());
               sem_r.put(1);
               sem_ar.put(1);
            end

             begin
               sem_ar_r.get(1);
               sem_r.get(1);
               read_data_channel(q_r.pop_front());
               sem_ar_r.put(1);
            end
        join_any
    endtask

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_drv")
        vif = axi_cfg_h.vif;

    endfunction


    task run_phase(uvm_phase phase);
        forever begin
           // $display("entered run phase : AXI DRIVER");
            seq_item_port.get_next_item(req);
           // $display("\n******************* received xtn from seq : AXI DRIVER ****************");
            send_to_dut(req);
            seq_item_port.item_done();
            $display("sent req to dut : AXI DRIVER");
        end
    endtask


endclass
~
~
~
~
