//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:  
// Date:    
//////////////////////////////////////////////////

/* The assertions_hdlc module is a test module containing the concurrent
   assertions. It is used by binding the signals of assertions_hdlc to the
   corresponding signals in the test_hdlc testbench. This is already done in
   bind_hdlc.sv 

   For this exercise you will write concurrent assertions for the Rx module:
   - Verify that Rx_FlagDetect is asserted two cycles after a flag is received
   - Verify that Rx_AbortSignal is asserted after receiving an abort flag
*/

module assertions_hdlc (
  output int   ErrCntAssertions,
  input  logic Clk,
  input  logic Rst,
  input  logic Rx,
  input  logic Rx_FlagDetect,
  input  logic Rx_ValidFrame,
  input  logic Rx_AbortDetect,
  input  logic Rx_AbortSignal,
  input  logic Rx_Overflow,
  input  logic Rx_WrBuff,

  // Added signals
  input  logic Tx,
  input  logic TxEN,
  input  logic Tx_ValidFrame
);

  initial begin
    ErrCntAssertions  =  0;
  end

  /*******************************************
   *  Verify correct Rx_FlagDetect behavior  *
   *******************************************/

  sequence Rx_flag;
    // INSERT CODE HERE
    Rx == 0 ##1
    Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
    Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
    Rx == 0;
  endsequence

  // Check if flag sequence is detected
  property RX_FlagDetect;
    @(posedge Clk) Rx_flag |-> ##2 Rx_FlagDetect;
  endproperty

  RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
    $display("PASS: Flag detect");
  end else begin 
    $error("Flag sequence did not generate FlagDetect"); 
    ErrCntAssertions++; 
  end

  /********************************************
   *  Verify correct Rx_AbortSignal behavior  *
   ********************************************/

  //If abort is detected during valid frame. then abort signal should go high

  // INSERTED CODE START
  sequence Abort_flag;
    Rx == 0 ##1
    Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
    Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
    Rx == 1;
  endsequence
  // INSERTED CODE END

  property RX_AbortSignal;
    // INSERT CODE HERE
    @(posedge Clk) Abort_flag |-> ##2 Rx_AbortDetect;
  endproperty

  RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
    $display("PASS: Abort signal");
  end else begin 
    $error("AbortSignal did not go high after AbortDetect during validframe"); 
    ErrCntAssertions++; 
  end

  /********************************************
   *  Verify correct Idle_pattern behavior  *
   ********************************************/

    sequence Idle_Sequence;
        Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
        Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1 Rx == 1;
    endsequence

    property RX_IdleSignal;
        // INSERT CODE HERE
        @(posedge Clk) Idle_Sequence |->  !Rx_WrBuff;
    endproperty

    RX_IdleSignal_Assert : assert property (RX_IdleSignal) begin
        //$display("PASS: Idle signal");
     end else begin 
        $error("Idle squence went high without being in idle. Rx_wrbuff:%b",Rx_WrBuff); 
        ErrCntAssertions++; 
    end

    // Verify 0 insertion after 5 1's
    sequence zero_after_five_ones;
      (TxEN && Tx_ValidFrame && Tx)[*5];
    endsequence

    property property_zero_after_five_ones;
      @(posedge Clk) disable iff (!Rst)
      zero_after_five_ones |=> (Tx == 1'b0);
    endproperty

    assert_zero_after_five_ones: assert property (property_zero_after_five_ones) begin
      $display("PASS: Zero was inserted after 5 ones");
    end else begin
      $error("Zero was NOT inserted after 5 ones");
      ErrCntAssertions++;
    end
  
endmodule
