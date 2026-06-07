class env_cfg extends uvm_object;
    `uvm_object_utils(env_cfg)
     `NEW_OBJ

    ahb_rst_cfg ahb_rst_cfg_h[];
    axi_rst_cfg axi_rst_cfg_h[];
    ahb_cfg  ahb_cfg_h[];
    axi_cfg axi_cfg_h[];

    bit has_axi_agent = 1;
    bit has_ahb_agent=1;
    bit has_axi_rst_agent = 1;
    bit has_ahb_rst_agent=1;

    int no_of_duts=1;

    bit  has_scoreboard=1;

    int ahb_length[$];
    int axi_length[$];
endclass
