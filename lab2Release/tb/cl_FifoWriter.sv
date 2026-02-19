//====================================================================
//        Copyright (c) 2025
// Created : omqa at 2025-12-01
//====================================================================

// =========================================
// cl_FifoWriter : tasks take DUT signals as args
// =========================================

// Class for randomized write:
class cl_random_data #(parameter int WIDTH = 8);

  rand logic [WIDTH-1:0] rand_data;
  constraint c_rand_data { rand_data inside {[0:'h80]}; }

endclass

// Class for FiFo writer
class cl_FifoWriter #(parameter int WIDTH = 8) extends cl_TbUtils #(WIDTH);
  local virtual if_TbEvents.writer eif;
  // local cl_Scoreboard #(WIDTH) sb;
  // local cl_TbUtils    #(WIDTH) utils;
  virtual if_Fifo #(WIDTH) virtual_if;
  rand logic [WIDTH-1:0] random_data;
  cl_random_data #(WIDTH) random_data_2;

  function new(

    cl_Scoreboard #(WIDTH)      sb,
    virtual if_TbEvents.writer  eif,
    // cl_TbUtils   #(WIDTH)       utils,
    virtual if_Fifo #(WIDTH) tb_if);

    super.new(tb_if, sb);
    random_data_2 = new();

    // this.sb    = sb;
    this.eif   = eif;
    // this.utils = utils;
    this.virtual_if   = tb_if;
  
  endfunction

  // Single word write
  task ta_writeWord(
    input  bit               clk,
    input  bit               full,
    output bit               wr_en,
    output logic [WIDTH-1:0] wr_data,
    input  logic [WIDTH-1:0] data
  );
    //$display ("ta_writeWord function entered");
    //$display ("%t, %m", $realtime);
    @(posedge virtual_if.clk);
    //$display ("clk posedge triggered");
    //$display ("%t, clock edge", $realtime);
    if (!virtual_if.full) begin
      $display ("Not full");
      virtual_if.wr_en   = 1'b1;
      virtual_if.wr_data = data;
      sb.ta_queuePush(data);
    end else begin
      virtual_if.wr_en   = 1'b0;
      virtual_if.wr_data = '0;
      $display ("full");
    end
    @(posedge virtual_if.clk);
    virtual_if.wr_en   = 1'b0;
    virtual_if.wr_data = '0;
  endtask

  // Burst write
  task ta_writeBurst(
    input  int               n,
    input  int               seed,
    input  bit               clk,
    input  bit               full,
    output bit               wr_en,
    output logic [WIDTH-1:0] wr_data
  );
    //$display ("Begin write burst");
    for (int i = 0; i < n; i++) begin
      // logic [WIDTH-1:0] data = (seed + i) & {WIDTH{1'b1}};
      this.randomize();
      //$display ("Word %0d write initialized", i);
      ta_writeWord(clk, full, wr_en, wr_data, random_data);
      $display ("Word %0d written", i);
    end
  endtask

  // Transmit one packet
  task ta_xmitOnePacket(
    ref    int               currentPacketTxNum,
    input  int               numWordsInPacket,
    input  bit               clk,
    input  bit               full,
    input  bit               flush,
    output bit               wr_en,
    output logic [WIDTH-1:0] wr_data
  );
    random_data_2.randomize();
    // logic [WIDTH-1:0] data = $urandom_range(0, 'h80);
    $display ("\n\n**** %t : TX starting new packet %0d", $realtime, currentPacketTxNum);
    for (int i = 0; i < numWordsInPacket; i++) begin
      // data = (data + i) & {WIDTH{1'b1}};
      random_data_2.rand_data = (random_data_2.rand_data + i) & {WIDTH{1'b1}};
      if (virtual_if.full) begin
        wait (!virtual_if.full);
      end
      @(negedge virtual_if.clk);
      virtual_if.wr_en = 1'b1;
      if (i == 0) begin
        virtual_if.wr_data = currentPacketTxNum[WIDTH-1:0];
        sb.ta_queuePush(currentPacketTxNum[WIDTH-1:0]);
      end else begin
        // wr_data = data;
        virtual_if.wr_data = random_data_2.rand_data;
        // sb.ta_queuePush(data);
        sb.ta_queuePush(random_data_2.rand_data);
      end
    end
    @(negedge virtual_if.clk);
    virtual_if.wr_en  = 1'b0;
    virtual_if.wr_data = '0;
    $display ("%t : TX packet sent %0d", $realtime, currentPacketTxNum);
  endtask

  // Background TX model. Call once; it will run forever and react to eif.tx.
  task run(
    ref    int               currentPacketTxNum,
    ref    int               errorCnt,
    ref    int               packetAck[$],
    input  int               numWordsInPacket,
    input  realtime          packetTimeoutVal,
    input  bit               clk,
    input  bit               flush,
    input  bit               full,
    input  bit               empty,
    output bit               wr_en,
    output logic [WIDTH-1:0] wr_data
  );
    forever begin
      @(eif.tx);
      // Two independent behaviors that used to be separate always blocks
      fork
        begin : tx_proc_A
          // sendPacket + waitForFlushWhileTx
          fork
            begin : sendPacket
              ta_xmitOnePacket(currentPacketTxNum, numWordsInPacket, virtual_if.clk, virtual_if.full, virtual_if.flush, virtual_if.wr_en, wr_data);
            end : sendPacket
            begin : waitForFlushWhileTx
              wait (virtual_if.flush);
              $display ("**** %t : TX packet %0d flushed waiting for TX to complete.", $realtime, currentPacketTxNum);
              wr_en = 1'b0;
            end : waitForFlushWhileTx
          join_any
          disable fork;
          wait (!virtual_if.flush);
          currentPacketTxNum++;
        end : tx_proc_A

        begin : tx_proc_B
          automatic int thisPacketIndex = currentPacketTxNum;
          // timeout / ack / flush-wait trio
          fork
            begin : transmitPacketAndWaitForTimeout
              #(packetTimeoutVal);
              $display ("%t : TX timeout detected %0d", $realtime, thisPacketIndex);
              errorCnt++;
              $error;
              ta_flushFifo(errorCnt);
            end : transmitPacketAndWaitForTimeout

            begin : waitForAckInTx
              wait ( (packetAck.size() >= 1) && (packetAck[0] === thisPacketIndex) );
              #1 packetAck.pop_front();
              $display ("%t : TX ack received %0d", $realtime, thisPacketIndex);
            end : waitForAckInTx

            begin : waitForFlushWhileRx
              wait (virtual_if.flush);
              wait (!virtual_if.flush);
            end : waitForFlushWhileRx
          join_any
          disable fork;
        end : tx_proc_B
      join_none
    end
  endtask
endclass
