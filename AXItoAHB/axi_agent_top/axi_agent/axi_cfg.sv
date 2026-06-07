class axi_cfg extends uvm_object;
    `uvm_object_utils(axi_cfg)
     `NEW_OBJ
    virtual axi_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;


endclass
