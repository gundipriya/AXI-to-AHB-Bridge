class sb extends uvm_scoreboard;
  `uvm_component_utils(sb)

  uvm_tlm_analysis_fifo#(axi_rst_xtn) fifo_axi_rst_h;
  uvm_tlm_analysis_fifo#(ahb_rst_xtn) fifo_ahb_rst_h;
  uvm_tlm_analysis_fifo#(axi_xtn) fifo_axi_h;
  uvm_tlm_analysis_fifo#(ahb_xtn) fifo_ahb_h;
  uvm_tlm_analysis_fifo#(axi_xtn) fifo_axi_wdata_h;
  uvm_tlm_analysis_fifo#(axi_xtn) fifo_axi_rdata_h;

  axi_xtn wdata[$], rdata[$];

  axi_rst_xtn axi_rst_xtn_h;
  axi_rst_xtn axi_rst_cov_data;
  ahb_rst_xtn ahb_rst_xtn_h;
  ahb_rst_xtn ahb_rst_cov_data;

  axi_xtn axi_xtn_h, axi_wdata, axi_rdata;
  axi_xtn axi_cov_data;

  ahb_xtn ahb_cov_data;
  ahb_xtn ahb_xtn_h;

  env_cfg env_cfg_h;

    covergroup axi_rst_cg;
        option.per_instance = 1;

        CP_A_RESETN : coverpoint axi_rst_cov_data.aresetn {
            bins RST[] = {0,1};
        }
    endgroup


    covergroup ahb_rst_cg;
        option.per_instance = 1;

        CP_H_RESETN : coverpoint ahb_rst_cov_data.hresetn {
            bins RST[] = {0,1};
        }

    endgroup


    covergroup axi_cg;
            option.per_instance = 1;

            CP_AW_ID : coverpoint axi_cov_data.awid {
                bins low = {[0:$]};
            }

            CP_AW_ADDR : coverpoint axi_cov_data.awaddr {
                bins first_slave  = {[32'h0000_0000 : 32'h4444_4444]};
                bins second_slave = {[32'h4444_4445 : 32'h8888_8888]};
                bins third_slave  = {[32'h8888_8889 : 32'hcccc_cccc]};
                bins fourth_slave = {[32'hcccc_cccd : 32'hffff_ffff]};
            }

            CP_AWLEN : coverpoint axi_cov_data.awlen {
                bins AW_LEN = {[1:15]};
            }

            CP_AWSIZE : coverpoint axi_cov_data.awsize {
                bins AW_SIZE[] = {0,1,2,3};
            }

            CP_AWBURST : coverpoint axi_cov_data.awburst {
                bins AW_BURST[] = {[0:2]};
            }

            // CP_AWVALID : coverpoint axi_cov_data.awvalid { bins AW_VALID[] = {0,1}; }
            // CP_AWREADY : coverpoint axi_cov_data.awready { bins AW_READY[] = {0,1}; }

            CP_W_ID : coverpoint axi_cov_data.wid {
                bins low = {[0:$]};
            }

            CP_W_LAST : coverpoint axi_cov_data.wlast {
                bins W_LAST[] = {0,1};
            }

            // CP_WVALID : coverpoint axi_cov_data.wvalid { bins W_VALID[] = {0,1}; }
            // CP_WREADY : coverpoint axi_cov_data.wready { bins W_READY[] = {0,1}; }

            CP_B_ID : coverpoint axi_cov_data.bid {
                bins low = {[0:$]};
            }

            CP_BRESP : coverpoint axi_cov_data.bresp {
                bins BRESP[] = {0,1};
            }

            // CP_BVALID : coverpoint axi_cov_data.bvalid { bins B_VALID[] = {0,1}; }
            // CP_BREADY : coverpoint axi_cov_data.bready { bins B_READY[] = {0,1}; }

            CP_AR_ID : coverpoint axi_cov_data.arid {
                bins low = {[0:$]};
            }

            CP_AR_ADDR : coverpoint axi_cov_data.araddr {
                bins slave_addr = {[32'h0000_0000 : 32'hffff_ffff]};
            }

            CP_ARLEN : coverpoint axi_cov_data.arlen {
                bins AR_LEN = {[1:15]};
            }

            CP_ARSIZE : coverpoint axi_cov_data.arsize {
                bins AR_SIZE[] = {0,1,2,3};
            }

            CP_ARBURST : coverpoint axi_cov_data.arburst {
                bins AR_BURST[] = {[0:2]};
            }

            CP_R_ID : coverpoint axi_cov_data.rid {
                bins low = {[0:$]};
            }

            CP_R_LAST : coverpoint axi_cov_data.rlast {
                bins R_LAST[] = {0,1};
            }

            // CP_RVALID : coverpoint axi_cov_data.rvalid { bins R_VALID[] = {0,1}; }
            // CP_RREADY : coverpoint axi_cov_data.rready { bins R_READY[] = {0,1}; }

    endgroup
 covergroup axi_wdata_dyn_cg with function sample(int i);

        CP_W_DATA : coverpoint axi_cov_data.wdata[i] {
            bins wdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};
        }

        CP_W_STRB : coverpoint axi_cov_data.wstrb[i] {
            bins W_STRB[] = {1,2,4,8,16,32,64,128,3,12,48,192,15,240,255};
        }

    endgroup


    covergroup axi_rdata_dyn_cg with function sample(int i);

        CP_R_DATA : coverpoint axi_cov_data.rdata[i] {
            bins rdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};
        }

        CP_RRESP : coverpoint axi_cov_data.rresp[i] {
            bins RRESP[] = {0};
        }

    endgroup

    covergroup ahb_cg;
        option.per_instance = 1;

        CP_HADDR : coverpoint ahb_cov_data.haddr {
            bins first_slave  = {[32'h0000_0000 : 32'h4444_4444]};
            bins second_slave = {[32'h4444_4445 : 32'h8888_8888]};
            bins third_slave  = {[32'h8888_8889 : 32'hcccc_cccc]};
            bins fourth_slave = {[32'hcccc_cccd : 32'hffff_ffff]};
        }

        CP_HWRITE : coverpoint ahb_cov_data.hwrite {
            bins WRITE[] = {0,1};
        }

        CP_HSIZE : coverpoint ahb_cov_data.hsize {
            bins H_SIZE[] = {0,1,2,3};
        }

        CP_HREADY : coverpoint ahb_cov_data.hready {
            bins H_READY[] = {1};
        }

        CP_HRESP : coverpoint ahb_cov_data.hresp {
            bins H_RESP[] = {0,1};
        }

        CP_HWDATA : coverpoint ahb_cov_data.hwdata {
            bins ahb_wdata =
            {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};
        }

        CP_HRDATA : coverpoint ahb_cov_data.hrdata {
            bins ahb_rdata =
            {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};
        }

    endgroup

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);

        axi_cg          = new();
        axi_rst_cg      = new();
        ahb_cg          = new();
        ahb_rst_cg      = new();
        axi_wdata_dyn_cg = new();
        axi_rdata_dyn_cg = new();

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"configuration is not set properly")

        /*fifo_axi_rst_h   = new(env_cfg.no_of_duts);
        fifo_ahb_rst_h   = new(env_cfg.no_of_duts);
        fifo_axi_h       = new(env_cfg.no_of_duts);
        fifo_axi_wdata_h = new(env_cfg.no_of_duts);
        fifo_axi_rdata_h = new(env_cfg.no_of_duts);
        fifo_ahb_h       = new(env_cfg.no_of_duts);*/

       // foreach(fifo_axi_rst_h[i])
            fifo_axi_rst_h = new($sformatf("fifo_axi_rst_h"), this);

        /*foreach(fifo_ahb_rst_h[i])
            fifo_ahb_rst_h[i] = new($sformatf("fifo_ahb_rst_h[%0d]",i), this);*/
            fifo_ahb_rst_h = new($sformatf("fifo_ahb_rst_h"), this);

        //foreach(fifo_axi_h[i])
            fifo_axi_h = new($sformatf("fifo_axi_h"), this);

       // foreach(fifo_axi_wdata_h[i])
            fifo_axi_wdata_h = new($sformatf("fifo_axi_wdata_h"), this);

       // foreach(fifo_axi_rdata_h[i])
            fifo_axi_rdata_h = new($sformatf("fifo_axi_rdata_h"), this);

        //foreach(fifo_ahb_h[i])
            fifo_ahb_h = new($sformatf("fifo_ahb_h"), this);

    endfunction
  task run_phase(uvm_phase phase);

    fork

        begin
            forever
                begin
                    fifo_axi_rst_h.get(axi_rst_xtn_h);
                    axi_rst_check(axi_rst_xtn_h);
                    axi_rst_cov_data = new axi_rst_xtn_h;
                    axi_rst_cg.sample();
                end
        end

        begin
            forever
                begin
                    fifo_ahb_rst_h.get(ahb_rst_xtn_h);
                    ahb_rst_check(ahb_rst_xtn_h);
                    ahb_rst_cov_data = new ahb_rst_xtn_h;
                    ahb_rst_cg.sample();
                end
        end

        begin
            forever
                begin
                    fifo_axi_h.get(axi_xtn_h);
                    axi_cov_data = new axi_xtn_h;
                    axi_cg.sample();

                    foreach(axi_cov_data.wdata[i])
                    axi_wdata_dyn_cg.sample(i);

                    foreach(axi_cov_data.rdata[i])
                    axi_rdata_dyn_cg.sample(i);
                end
        end

        begin
            forever
                begin
                    fifo_ahb_h.get(ahb_xtn_h);
                    ahb_cov_data = new ahb_xtn_h;
                    data_compare(ahb_xtn_h);
                    ahb_cg.sample();
                end
        end

        begin
            forever
                begin
                    fifo_axi_wdata_h.get(axi_wdata);
                    wdata.push_back(axi_wdata);
                end
        end

        begin
            forever
                begin
                    fifo_axi_rdata_h.get(axi_rdata);
                    rdata.push_back(axi_rdata);
                end
        end

    join
 endtask
 task axi_rst_check(axi_rst_xtn axi_rst_xtn_h);

        if(axi_rst_xtn_h.aresetn == 1'b0)
        begin
            $display("=================================================================");
            if(axi_rst_xtn_h.bvalid == 1'b0 && axi_rst_xtn_h.rvalid == 1'b0) begin
            `uvm_info(get_type_name(),
                        "axi reset operation is successful",
                        UVM_LOW)
            $display("=================================================================");
            end
            else
            `uvm_error(get_type_name(),
                        "axi reset operation is not successful")
        end

    endtask


    task ahb_rst_check(ahb_rst_xtn ahb_rst_xtn_h);
        if(ahb_rst_xtn_h.hresetn == 1'b0)
            begin
                if(ahb_rst_xtn_h.htrans == 2'b00)begin
            $display("=================================================================");
                    `uvm_info(get_type_name(),
                                "ahb reset operation successful",
                                UVM_LOW)
            $display("=================================================================");
            end
                else
                    `uvm_error(get_type_name(),
                                "ahb reset operation not successful");
            end
    endtask

    task data_compare(ahb_xtn ahb_xtn_h);

        axi_xtn axi_xtn_h;

        if(ahb_xtn_h.hwrite == 1)
        begin

            wait(wdata.size != 0);

            axi_xtn_h = wdata.pop_front();

            if(axi_xtn_h.temp_wdata == ahb_xtn_h.hwdata)
                begin
            $display("=================================================================");
                    `uvm_info(get_type_name(),
                                "data is matched",
                                UVM_LOW)

                    `uvm_info(get_type_name(),
                                $sformatf("axi_temporary_wdata: %0d , ahb_hwdata: %0d",
                                        axi_xtn_h.temp_wdata,
                                        ahb_xtn_h.hwdata),
                                UVM_LOW)
            $display("=================================================================");
                end

            else
                begin
            $display("=================================================================");
                `uvm_error(get_type_name(),
                            "data is mismatched")
            $display("=================================================================");
                end

        end
 else
            begin

                wait(rdata.size != 0);

                axi_xtn_h = rdata.pop_front();

                if(axi_xtn_h.temp_rdata == ahb_xtn_h.hrdata)
                    begin
            $display("=================================================================");
                        `uvm_info(get_type_name(),
                                    "data is matched",
                                    UVM_LOW)

                        `uvm_info(get_type_name(),
                                    $sformatf("axi_temporary_rdata: %0d , ahb_hrdata: %0d",
                                            axi_xtn_h.temp_rdata,
                                            ahb_xtn_h.hrdata),
                                    UVM_LOW)
            $display("=================================================================");
                    end

                else
                    begin
            $display("=================================================================");
                        `uvm_error(get_type_name(),
                                    "data is mismatched")
            $display("=================================================================");
                    end

            end
    endtask

endclass
