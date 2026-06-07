class ahb_agent_top extends uvm_env;
     `uvm_component_utils(ahb_agent_top)
     `NEW_COMP

    ahb_rst_agent ahb_rst_agent_h;
    ahb_agent ahb_agent_h;
    env_cfg env_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_agent_h = ahb_agent::type_id::create("ahb_agent_h",this);
        ahb_rst_agent_h= ahb_rst_agent::type_id::create("ahb_rst_agent_h",this);
    endfunction

endclass
