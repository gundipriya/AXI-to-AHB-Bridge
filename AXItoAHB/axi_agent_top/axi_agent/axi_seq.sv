class axi_seq_base extends uvm_sequence#(axi_xtn);
    `uvm_object_utils(axi_seq_base)
    `NEW_OBJ
    env_cfg env_cfg_h;
    int temp;
endclass

class axi_seq extends axi_seq_base;
    `uvm_object_utils(axi_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==1; awvalid==1; wvalid==1; awburst inside{[0:1]};});
        finish_item(req);
    endtask
endclass

class axi_write_seq extends axi_seq_base;
    `uvm_object_utils(axi_write_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi burst sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==0; awvalid==1; wvalid==1; awburst ==2;});
        finish_item(req);
    endtask
endclass

class axi_read_seq extends axi_seq_base;
    `uvm_object_utils(axi_read_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi burst sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==1; awvalid==0; wvalid==0; arsize inside {0,1,2,3};
                arburst inside {0,1,2};});
        finish_item(req);
    endtask
endclass
