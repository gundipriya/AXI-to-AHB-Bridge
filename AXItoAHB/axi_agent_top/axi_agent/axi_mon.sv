class axi_mon extends uvm_monitor;
     `uvm_component_utils(axi_mon)
    axi_cfg axi_cfg_h;
    virtual axi_if.AXI_MON_MP vif;

    uvm_analysis_port#(axi_xtn) axi_mon_port;
    uvm_analysis_port#(axi_xtn) axi_wr_mon_port;
    uvm_analysis_port#(axi_xtn) axi_rd_mon_port;

    axi_xtn xtn_aw,xtn_ar, xtn_r, xtn_w, xtn_b;
    axi_xtn q_w[$], q_r[$];                  //how does this queues work? why do we need this? bz we are pushing xtn in address as well as in data...// when we say pop
    axi_xtn axi_write_data, axi_read_data;
    semaphore sem_aw=new(1);
    semaphore sem_w=new();
    semaphore sem_b = new();
    semaphore sem_ar=new(1);
    semaphore sem_r=new();

    semaphore sem_aw_w = new(1);
    semaphore sem_ar_r = new(1);
    semaphore sem_w_b= new();

   function new(string name = "",uvm_component parent);
      super.new(name,parent);
      axi_mon_port = new("axi_mon_port",this);
      axi_wr_mon_port = new("axi_wr_mon_port",this);
      axi_rd_mon_port = new("axi_rd_mon_port",this);
   endfunction

    task write_address_channel();
        xtn_aw = axi_xtn::type_id::create("xtn_aw");
        wait((vif.axi_mon_cb.awvalid) && (vif.axi_mon_cb.awready))
           xtn_aw.awvalid  = vif.axi_mon_cb.awvalid;
           xtn_aw.awid     = vif.axi_mon_cb.awid;
           xtn_aw.awaddr   = vif.axi_mon_cb.awaddr;
           xtn_aw.awlen    = vif.axi_mon_cb.awlen;
           xtn_aw.awsize   = vif.axi_mon_cb.awsize;
           xtn_aw.awburst  = vif.axi_mon_cb.awburst;
           xtn_aw.awready  = vif.axi_mon_cb.awready;
                $display("\n +++++++++++++++++++ write address channel : AXI MONITOR : time :%0t ++++++++++++++++", $time);
          q_w.push_back(xtn_aw);   //we need queue for oustanding requests
          @(vif.axi_mon_cb);
    endtask


    task read_address_channel();
        xtn_ar = axi_xtn::type_id::create("xtn_ar");

        wait((vif.axi_mon_cb.arvalid) && (vif.axi_mon_cb.arready))

           xtn_ar.arvalid  = vif.axi_mon_cb.arvalid;
           xtn_ar.arid     = vif.axi_mon_cb.arid;
           xtn_ar.araddr   = vif.axi_mon_cb.araddr;
           xtn_ar.arlen    = vif.axi_mon_cb.arlen;
           xtn_ar.arsize   = vif.axi_mon_cb.arsize;
           xtn_ar.arburst  = vif.axi_mon_cb.arburst;
           xtn_ar.arready  = vif.axi_mon_cb.arready;

                 $display("\n +++++++++++++++++++ read address channel : AXI MONITOR : time :%0t ++++++++++++++++", $time);
          q_r.push_back(xtn_ar);
          @(vif.axi_mon_cb);
    endtask


    task write_data_channel(axi_xtn xtn);
        xtn_w = axi_xtn::type_id::create("xtn_w");

        xtn_w = xtn;  //  xtn has all write addr and control signals

        xtn_w.wdata=new[xtn_w.awlen+1];
        xtn_w.wstrb=new[xtn_w.awlen+1];

        foreach(xtn_w.wdata[i])
        begin
            wait((vif.axi_mon_cb.wvalid==1'b1)&&((vif.axi_mon_cb.wready==1'b1)))

            axi_write_data = axi_xtn::type_id::create("axi_write_data");

            xtn.wready   = vif.axi_mon_cb.wready;
            xtn.wvalid   = vif.axi_mon_cb.wvalid;
            xtn_w.wid      = vif.axi_mon_cb.wid;
            xtn_w.wdata[i] = vif.axi_mon_cb.wdata;

            axi_write_data.temp_wdata[7:0]=vif.axi_mon_cb.wstrb[0]?vif.axi_mon_cb.wdata[7:0]:8'b00000000;  // here wstrb in vif is not dynamic so wstrb[0] indicates the first bit in wstrb variable and according to the bit we decide it is valid byte or not
            axi_write_data.temp_wdata[15:8]=vif.axi_mon_cb.wstrb[1]?vif.axi_mon_cb.wdata[15:8]:8'b00000000;
            axi_write_data.temp_wdata[23:16]=vif.axi_mon_cb.wstrb[2]?vif.axi_mon_cb.wdata[23:16]:8'b00000000;
            axi_write_data.temp_wdata[31:24]=vif.axi_mon_cb.wstrb[3]?vif.axi_mon_cb.wdata[31:24]:8'b00000000;
            axi_write_data.temp_wdata[39:32]=vif.axi_mon_cb.wstrb[4]?vif.axi_mon_cb.wdata[39:32]:8'b00000000;
            axi_write_data.temp_wdata[47:40]=vif.axi_mon_cb.wstrb[5]?vif.axi_mon_cb.wdata[47:40]:8'b00000000;
            axi_write_data.temp_wdata[55:48]=vif.axi_mon_cb.wstrb[6]?vif.axi_mon_cb.wdata[55:48]:8'b00000000;
            axi_write_data.temp_wdata[63:56]=vif.axi_mon_cb.wstrb[7]?vif.axi_mon_cb.wdata[63:56]:8'b00000000;

            xtn_w.wstrb[i] = vif.axi_mon_cb.wstrb;  //in trans strb is dynamic. so if we have 4 transfers the size will be 4. each element in wstrb that is wstrb[0] is 8 bit data corresponding to one transfer

            if(i==(xtn_w.wdata.size-1))           // 4 bytes ---> 0123 till 3  or we can even using awlen isnt it?
                xtn_w.wlast = vif.axi_mon_cb.wlast;

            @(vif.axi_mon_cb);
            axi_wr_mon_port.write(axi_write_data); // we will send wdata to sb for every transfer
        end
             $display("\n +++++++++++++++++++ write data channel : AXI MONITOR : time :%0t ++++++++++++++++", $time);
                $display("\n write data channel data sampled : AXI MONITOR");
        `uvm_info(get_type_name(),$sformatf("axi_xtn :\n %p",xtn_w.sprint()),UVM_LOW)
         q_w.push_back(xtn_w);      // pushing the transaction
    endtask


    task read_data_channel(axi_xtn xtn);
    bit a;

    xtn_r = axi_xtn::type_id::create("xtn_r");
    xtn_r= xtn;
    xtn_r.rdata=new[xtn_r.arlen+1];
    xtn_r.rresp=new[xtn_r.arlen+1];

    foreach(xtn_r.rdata[i])
    begin
//      $display("@@@@@@@@@@@@@@@@@@@@  WAITING FOR RVALID AND RREADY TO BE ASSERTED @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        wait((vif.axi_mon_cb.rvalid)&&((vif.axi_mon_cb.rready)))
//      $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
//      $display("received rvalid and rready: axi monitor");
//      $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        axi_read_data=axi_xtn::type_id::create("axi_read_data");

        xtn_r.rid = vif.axi_mon_cb.rid;
        xtn_r.rvalid = vif.axi_mon_cb.rvalid;
        xtn_r.rready = vif.axi_mon_cb.rready;
        xtn_r.rdata[i] = vif.axi_mon_cb.rdata;
        xtn_r.rresp[i] = vif.axi_mon_cb.rresp;

        axi_read_data.temp_rdata=vif.axi_mon_cb.rdata;   // because for every transfer we will send the data to sb so we cant send the dynamic array of data


        if(i==(xtn_r.rdata.size-1))
        begin
            xtn_r.rlast = vif.axi_mon_cb.rlast;
            a= vif.axi_mon_cb.rlast;
        end

        @(vif.axi_mon_cb);

        axi_rd_mon_port.write(axi_read_data);  // sending every transfer in transaction to sb
    end

    axi_mon_port.write(xtn_r);
     $display("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
     $display("\n +++++++++++++++++++ read data channel : AXI MONITOR : time :%0t ++++++++++++++++", $time);
                $display("\n read data channel data sampled : AXI MONITOR");
    `uvm_info(get_type_name(),$sformatf("axi_xtn :\n %p",xtn_r.sprint()),UVM_LOW)
     $display("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    endtask

    task write_response_channel(axi_xtn xtn);
        xtn_b = axi_xtn::type_id::create("xtn_b");
        xtn_b = xtn;

        wait((vif.axi_mon_cb.bvalid)&&((vif.axi_mon_cb.bready)))

        xtn.bvalid  = vif.axi_mon_cb.bvalid;
        xtn.bready  = vif.axi_mon_cb.bready;
        xtn_b.bid    = vif.axi_mon_cb.bid;
        xtn_b.bresp  = vif.axi_mon_cb.bresp;
        xtn_b.bvalid = vif.axi_mon_cb.bvalid;

        axi_mon_port.write(xtn_b);
             $display("\n +++++++++++++++++++ write response channel : AXI MONITOR : time :%0t ++++++++++++++++", $time);

                $display("\n write response channel data sampled : AXI MONITOR");
        `uvm_info(get_type_name(),$sformatf("axi_xtn:\n %p",xtn.sprint()),UVM_LOW)

        @(vif.axi_mon_cb);
    endtask

    // we are sending write xtn and read xtn in data channels insider foreach loop(for every transfer)
    // we are sending xtn to mon port at the end of transaction i.e, in write response (last stage of write transaction - contains all write related info)
    // and in read data channel( last of read trans - contains all read related signals)


    task collect();
        $display("\n ********* COLLECT PHASE : AXI MONITOR : TIME-%0t **********", $time);
        fork
            begin

               sem_aw.get(1);                           // get the key
               write_address_channel();
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
               write_response_channel(q_w.pop_front());

            end

             begin
                sem_ar.get(1);
                read_address_channel();
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUTTING SEM_R ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
               sem_r.put(1);
               sem_ar.put(1);
            end

             begin
               sem_ar_r.get(1);
               sem_r.get(1);
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~ GETTING SEM_R ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
               $display("~~~~~~~~~~~~~~~~~~~~~~ CALLING READ_DATA_CHANNEL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                read_data_channel(q_r.pop_front());
               sem_ar_r.put(1);
            end
        join_any
    endtask

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_mon")
         vif = axi_cfg_h.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
           collect();
        end
    endtask
endclass
                                                                                                                                                        