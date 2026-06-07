class axi_rst_agent extends uvm_agent;
     `uvm_component_utils(axi_rst_agent)
     `NEW_COMP
     axi_rst_drv axi_rst_drv_h;
     axi_rst_mon axi_rst_mon_h;
     axi_rst_seqr axi_rst_seqr_h;
    axi_rst_cfg axi_rst_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db#(axi_rst_cfg)::get(this,"*","axi_rst_cfg",axi_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi reset agent")
        axi_rst_mon_h = axi_rst_mon ::type_id::create("axi_rst_mon_h",this);

         if(axi_rst_cfg_h.is_active==UVM_ACTIVE) begin
        axi_rst_drv_h = axi_rst_drv ::type_id::create("axi_rst_drv_h",this);
        axi_rst_seqr_h = axi_rst_seqr ::type_id::create("axi_rst_seqr_h",this);
         end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(axi_rst_cfg_h.is_active == UVM_ACTIVE)
        axi_rst_drv_h.seq_item_port.connect(axi_rst_seqr_h.seq_item_export);
    endfunction
endclass
