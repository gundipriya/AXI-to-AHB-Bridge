class axi_rst_cfg extends uvm_object;
    `uvm_object_utils(axi_rst_cfg)
     `NEW_OBJ
    virtual axi_rst_if vif;
    //if
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass
