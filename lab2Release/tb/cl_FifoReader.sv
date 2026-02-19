//====================================================================
//        Copyright (c) 2025
// Created : omqa at 2025-12-01
//====================================================================


// =========================================
// cl_FifoReader : tasks take DUT/event signals as args
// =========================================
class cl_FifoReader #(parameter int WIDTH = 8) extends cl_TbUtils #(WIDTH);
  local virtual if_TbEvents.reader  eif;
  // local cl_Scoreboard #(WIDTH) sb;
  virtual if_Fifo #(WIDTH) virtual_if;

  function new(
    cl_Scoreboard #(WIDTH) sb,
    virtual if_TbEvents.reader  eif,
    virtual if_Fifo #(WIDTH) tb_if
  );

    super.new(tb_if, sb);

    // this.sb = sb;
    this.eif = eif;
    this.virtual_if = tb_if;
  endfunction

  // Single word read
  task ta_readWord(
    input  bit               clk,
    input  bit               empty,
    output bit               rd_en,
    input  logic [WIDTH-1:0] rd_data,
    output int               errors_added
  );
    errors_added = 0;
    @(posedge virtual_if.clk);
    if (!virtual_if.empty) begin
      virtual_if.rd_en = 1'b1;
      $display ("not empty");
    end else begin
      virtual_if.rd_en = 1'b0;
      $display ("empty");
    end
    @(posedge virtual_if.clk);
    if (virtual_if.rd_en && !virtual_if.empty) begin
      int localErrCount;
      sb.ta_popAndCheck(virtual_if.rd_data, localErrCount);
      errors_added += localErrCount;
      $display ("Word read");
    end
    virtual_if.rd_en = 1'b0;
  endtask

  // Burst read
  task ta_readBurst(
    input  int               n,
    input  bit               clk,
    input  bit               empty,
    output bit               rd_en,
    input  logic [WIDTH-1:0] rd_data,
    output int               errors_added
  );
    errors_added = 0;
    for (int i = 0; i < n; i++) begin
      int localErrCount; ta_readWord(virtual_if.clk, virtual_if.empty, virtual_if.rd_en, virtual_if.rd_data, localErrCount); errors_added += localErrCount;
      $display ("Word %0d read and popped", i);
    end
  endtask

  // Receive one packet
  task ta_receiveOnePacket(
    input  int               numWordsInPacket,
    input  bit               clk,
    input  bit               empty,
    output bit               rd_en,
    input  logic [WIDTH-1:0] rd_data,
    input  bit               flush,
    output int               rxPacketId,
    output int               errors_added
  );
    logic [WIDTH-1:0] data;
    errors_added = 0;
    for (int i=0; i<numWordsInPacket; i++) begin
      int localErrCount;
      if (virtual_if.empty) wait (!virtual_if.empty);
      @(negedge virtual_if.clk); virtual_if.rd_en = 1'b1;
      @(posedge virtual_if.clk) data = virtual_if.rd_data;
      sb.ta_popAndCheck(data, localErrCount); errors_added += localErrCount;
      if (i == 0) rxPacketId = data;
    end
    @(negedge virtual_if.clk); virtual_if.rd_en = 1'b0;
  endtask

  // Background RX model. Call once; it will run forever and react to posedge of eif.rxTrig.
  task run(
    ref    int               currentPacketRxNum,
    ref    int               rxPacketId,
    ref    int               errorCnt,
    ref    int               packetAck[$],
    input  int               numWordsInPacket,
    input  int               numCyclesToProcessPacket,
    input  bit               clk,
    input  bit               flush,
    output bit               rd_en,
    input  logic [WIDTH-1:0] rd_data,
    input  bit               empty
  );
    forever begin
      $display ("debug1");
      @(posedge eif.rxTrig);
      $display ("debug2");
      fork
        begin : receivePacket
          int localErrors, id;
          $display ("debug3");
          ta_receiveOnePacket(numWordsInPacket, virtual_if.clk, virtual_if.empty, virtual_if.rd_en, rd_data, virtual_if.flush, id, localErrors);
          rxPacketId = id;
          errorCnt  += localErrors;
          repeat (numCyclesToProcessPacket) @(posedge virtual_if.clk);
          $display ("%t : RX packet processed %0d with ID %0d", $realtime, currentPacketRxNum, rxPacketId);
          packetAck.push_back(rxPacketId);
          // packetAck.push_back(currentPacketRxNum);
          #1;
          currentPacketRxNum++;
        end : receivePacket

        begin : waitForFlush
          wait (virtual_if.flush);
          $display ("**** %t : RX packet %0d (ID=%0d) flushed.", $realtime, currentPacketRxNum, rxPacketId);
          @(negedge virtual_if.clk) rd_en = 1'b0;
          wait (!virtual_if.flush);
        end : waitForFlush
      join_any
      disable fork;
      eif.rxDone = 1;
      wait (eif.rxTrig === 0);
      #1ns; eif.rxDone = 0;
    end
  endtask
endclass

