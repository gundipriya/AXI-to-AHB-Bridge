class ahb_sequence_base extends uvm_sequence#(ahb_xtn);
    `uvm_object_utils(ahb_sequence_base)

    env_cfg env_cfg_h;

    function new(string name="ahb_sequence_base");
        super.new(name);
    endfunction

endclass


class ahb_seq extends ahb_sequence_base;
    `uvm_object_utils(ahb_seq);

    function new(string name="ahb_seq");
        super.new(name);
    endfunction

    task body();

        req=ahb_xtn::type_id::create("req");

        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"configuration fail in ahb_sequence")

        $display("-------- entered sequence : AHB SEQUENCE BODY------");
        repeat((2*(env_cfg_h.ahb_length.pop_front())))
        begin
            start_item(req);
            assert(req.randomize() with {delay_cycles==2;});
            finish_item(req);
        $display("-------- finished ahb sequence : AHB SEQUENCE BODY------");
        end

    endtask

endclass
