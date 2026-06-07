class ahb_rst_cfg extends uvm_object;
    `uvm_object_utils(ahb_rst_cfg)
     `NEW_OBJ

    virtual ahb_rst_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass
