class test extends uvm_test;
        `uvm_component_utils(test)


         env envh;
        axi_rst_cfg  axi_rst_cfg_h[];
        axi_cfg axi_cfg_h[];
        ahb_rst_cfg ahb_rst_cfg_h[];
        ahb_cfg ahb_cfg_h[];
        env_cfg  env_cfg_h;

        bit has_axi_agent = 1;
        bit has_ahb_agent=1;
        bit has_ahb_rst_agent=1;
        bit has_axi_rst_agent = 1;

        int no_of_duts=1;

        bit has_scoreboard=1;

        rand int length[];
        int no_of_trans=1;

        constraint length_c {foreach(length[i])
                                 length[i] inside {[1:15]}; }


        `NEW_COMP

        function void config_create();
            if(has_axi_agent)
            begin
                axi_cfg_h = new[no_of_duts];
                env_cfg_h.axi_cfg_h = new[no_of_duts];
                foreach(axi_cfg_h[i])
                    axi_cfg_h[i] = axi_cfg::type_id::create($sformatf("axi_cfg_h[%0d]",i));
            end

            if(has_axi_rst_agent)
            begin
                axi_rst_cfg_h = new[no_of_duts];
                env_cfg_h.axi_rst_cfg_h = new[no_of_duts];
                foreach(axi_rst_cfg_h[i])
                    axi_rst_cfg_h[i] = axi_rst_cfg::type_id::create($sformatf("axi_rst_cfg_h[%0d]",i));
            end

            if(has_ahb_agent)
            begin
                ahb_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_cfg_h = new[no_of_duts];
                foreach(ahb_cfg_h[i])
                    ahb_cfg_h[i] = ahb_cfg::type_id::create($sformatf("ahb_cfg_h[%0d]",i));
            end

            if(has_ahb_rst_agent)
            begin
                ahb_rst_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_rst_cfg_h = new[no_of_duts];
                foreach(ahb_rst_cfg_h[i])
                    ahb_rst_cfg_h[i] = ahb_rst_cfg::type_id::create($sformatf("ahb_rst_cfg_h[%0d]",i));
            end
        endfunction


        function void config_set();
            if(has_axi_agent)
            begin
                foreach(axi_cfg_h[i])  begin
                    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif", axi_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi cfg")
                env_cfg_h.axi_cfg_h[i] = axi_cfg_h[i];
                end
            end

            if(has_axi_rst_agent)
            begin

                foreach(axi_rst_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual axi_rst_if)::get(this,"", "vif",axi_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi reset cfg")
                    env_cfg_h.axi_rst_cfg_h[i] = axi_rst_cfg_h[i];

                end
            end

            if(has_ahb_agent)
            begin
                foreach(ahb_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual ahb_if)::get(this,"", "vif",ahb_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb cfg")
                    env_cfg_h.ahb_cfg_h[i] = ahb_cfg_h[i];

                end
            end

            if(has_ahb_rst_agent)
            begin
                foreach(ahb_rst_cfg_h[i]) begin
                     if(!uvm_config_db#(virtual ahb_rst_if)::get(this,"", "vif",ahb_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb reset cfg")
                    env_cfg_h.ahb_rst_cfg_h[i]= ahb_rst_cfg_h[i];

                end
            end

            this.randomize() with {length.size == no_of_trans;}; // randomizing length for all transactions

            foreach(length[i]) begin
                env_cfg_h.axi_length.push_back(length[i]);  //pushing the randomized length values to env cfg variable length
                env_cfg_h.ahb_length.push_back(length[i]);  // both axi and ahb should have same length for given transaction
            end

            env_cfg_h.has_axi_agent = has_axi_agent;
            env_cfg_h.has_ahb_agent=has_ahb_agent;
            env_cfg_h.has_axi_rst_agent = has_axi_rst_agent;
            env_cfg_h.has_ahb_rst_agent=has_ahb_rst_agent;

            env_cfg_h.no_of_duts=no_of_duts;

            env_cfg_h.has_scoreboard=has_scoreboard;

            uvm_config_db#(env_cfg)::set(this,"*", "env_cfg", env_cfg_h);

        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env_cfg_h = env_cfg::type_id::create("env_cfg_h");

                config_create();
                config_set();
                envh = env::type_id::create("envh",this);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                uvm_top.print_topology();
        endfunction


endclass

class rd_wr_test extends test;
     `uvm_component_utils(rd_wr_test)
       `NEW_COMP
        axi_seq axi_seq_h;
        ahb_seq ahb_seq_h;
        axi_rst_seq axi_rst_seq_h;
        ahb_rst_seq ahb_rst_seq_h;

         function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                axi_seq_h = axi_seq :: type_id::create("axi_seq_h");
                ahb_seq_h = ahb_seq :: type_id::create("ahb_seq_h");
                axi_rst_seq_h = axi_rst_seq :: type_id::create("axi_rst_seq_h");
                ahb_rst_seq_h = ahb_rst_seq :: type_id::create("ahb_rst_seq_h");
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                foreach(envh.axi_agent_top_h[i]) begin
                axi_rst_seq_h.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);
                ahb_rst_seq_h.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);
                axi_seq_h.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);
                ahb_seq_h.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
                end
                phase.phase_done.set_drain_time(this,200000);

            phase.drop_objection(this);

        endtask
endclass

class write_test extends test;
     `uvm_component_utils(write_test)
       `NEW_COMP
        axi_write_seq axi_seq_h;
        ahb_seq ahb_seq_h;
        axi_rst_seq axi_rst_seq_h;
        ahb_rst_seq ahb_rst_seq_h;

         function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                axi_seq_h = axi_write_seq :: type_id::create("axi_seq_h");
                ahb_seq_h = ahb_seq :: type_id::create("ahb_seq_h");
                axi_rst_seq_h = axi_rst_seq :: type_id::create("axi_rst_seq_h");
                ahb_rst_seq_h = ahb_rst_seq :: type_id::create("ahb_rst_seq_h");
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                foreach(envh.axi_agent_top_h[i]) begin
                axi_rst_seq_h.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);
                ahb_rst_seq_h.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);
                axi_seq_h.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);
                ahb_seq_h.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
                end
                phase.phase_done.set_drain_time(this,200000);

            phase.drop_objection(this);

        endtask
endclass

class read_test extends test;
     `uvm_component_utils(read_test)
       `NEW_COMP
        axi_read_seq axi_seq_h;
        ahb_seq ahb_seq_h;
        axi_rst_seq axi_rst_seq_h;
        ahb_rst_seq ahb_rst_seq_h;

         function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                axi_seq_h = axi_read_seq :: type_id::create("axi_seq_h");
                ahb_seq_h = ahb_seq :: type_id::create("ahb_seq_h");
                axi_rst_seq_h = axi_rst_seq :: type_id::create("axi_rst_seq_h");
                ahb_rst_seq_h = ahb_rst_seq :: type_id::create("ahb_rst_seq_h");
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                foreach(envh.axi_agent_top_h[i]) begin
                axi_rst_seq_h.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);
                ahb_rst_seq_h.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);
                axi_seq_h.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);
                ahb_seq_h.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
                end
                phase.phase_done.set_drain_time(this,200000);

            phase.drop_objection(this);

        endtask
endclass

~
