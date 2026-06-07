class ahb_agent extends uvm_agent;
     `uvm_component_utils(ahb_agent)
     `NEW_COMP

    ahb_drv ahb_drv_h;
    ahb_mon ahb_mon_h;
    ahb_seqr ahb_seqr_h;
    ahb_cfg ahb_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_agent")

        ahb_mon_h = ahb_mon ::type_id::create("ahb_mon_h",this);

        if(ahb_cfg_h.is_active==UVM_ACTIVE) begin
        ahb_drv_h = ahb_drv ::type_id::create("ahb_drv_h",this);
        ahb_seqr_h = ahb_seqr ::type_id::create("ahb_seqr_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(ahb_cfg_h.is_active == UVM_ACTIVE)
        ahb_drv_h.seq_item_port.connect(ahb_seqr_h.seq_item_export);
    endfunction
endclass
