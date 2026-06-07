class axi_agent extends uvm_agent;
     `uvm_component_utils(axi_agent)
     `NEW_COMP

    axi_drv axi_drv_h;
    axi_mon axi_mon_h;
    axi_seqr axi_seqr_h;
    axi_cfg axi_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi  agent")

         axi_mon_h = axi_mon ::type_id::create("axi_mon_h",this);

         if(axi_cfg_h.is_active==UVM_ACTIVE) begin
            axi_drv_h = axi_drv ::type_id::create("axi_drv_h",this);
            axi_seqr_h = axi_seqr ::type_id::create("axi_seqr_h",this);
         end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(axi_cfg_h.is_active == UVM_ACTIVE)
        axi_drv_h.seq_item_port.connect(axi_seqr_h.seq_item_export);
    endfunction
endclass
