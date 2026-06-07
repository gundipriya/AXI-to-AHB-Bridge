class ahb_cfg extends uvm_object;
    `uvm_object_utils(ahb_cfg)
     `NEW_OBJ

    virtual ahb_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass
