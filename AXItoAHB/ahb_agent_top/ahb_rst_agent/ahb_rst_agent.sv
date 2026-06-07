class ahb_rst_agent extends uvm_agent;
     `uvm_component_utils(ahb_rst_agent)
    ahb_rst_drv ahb_rst_drv_h;
    ahb_rst_mon ahb_rst_mon_h;
    ahb_rst_seqr ahb_rst_seqr_h;
    ahb_rst_cfg ahb_rst_cfg_h;

     `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         if(!uvm_config_db#(ahb_rst_cfg)::get(this,"*","ahb_rst_cfg",ahb_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_rst_agent")

        ahb_rst_mon_h = ahb_rst_mon ::type_id::create("ahb_rst_mon_h",this);

        if(ahb_rst_cfg_h.is_active==UVM_ACTIVE) begin
        ahb_rst_drv_h = ahb_rst_drv ::type_id::create("ahb_rst_drv_h",this);
        ahb_rst_seqr_h = ahb_rst_seqr ::type_id::create("ahb_rst_seqr_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(ahb_rst_cfg_h.is_active == UVM_ACTIVE)
        ahb_rst_drv_h.seq_item_port.connect(ahb_rst_seqr_h.seq_item_export);
    endfunction
endclass
