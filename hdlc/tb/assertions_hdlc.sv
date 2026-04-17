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
  input  logic Tx_ValidFrame,
  input  logic Rx_StartZeroDetect,
  input  logic ZeroDetect,
  input  logic Rx_EoF,
  input  logic Tx_AbortedTrans,
  input  logic Rx_FrameSize
);

  initial begin
    ErrCntAssertions  =  0;
  end


  /********************************************
   *  Verify correct Rx_FlagDetect behavior   *
   *          (Verify SOF and EOF)            *
   *******************************************/

  sequence Rx_flag;
    // INSERT CODE HERE
    Rx == 0 ##1
    Rx[*6] ##1
    Rx == 0;
  endsequence

  // Check if flag sequence is detected
  property Rx_Detect;
    @(posedge Clk) Rx_flag |-> ##2 Rx_FlagDetect;
  endproperty

  assert_Rx_Detect : assert property (Rx_Detect) begin
    $display("PASS: Rx Flag detect");
  end else begin 
    $error("Flag sequence did not generate FlagDetect"); 
    ErrCntAssertions++; 
  end

  /********************************************
   *  Verify correct Rx_AbortSignal behavior  *
   ********************************************/

  //If abort is detected during valid frame. then abort signal should go high

  sequence Abort_flag;
    Rx == 0 ##1
    Rx[*7];
  endsequence

  property Rx_Abort;
    @(posedge Clk) disable iff (!Rst)
    Abort_flag |-> ##2 Rx_AbortDetect;
  endproperty

  assert_Rx_Abort : assert property (Rx_Abort) begin
    $display("PASS: Abort signal");
  end else begin 
    $error("AbortSignal did not go high after AbortDetect during validframe"); 
    ErrCntAssertions++; 
  end

  /**********************************************
   *  Verify Rx_AbortSignal during valid frame  *
   *********************************************/

  sequence Abort_during_valid_frame;
    (Rx == 0 && Rx_ValidFrame) ## 1
    (Rx && Rx_ValidFrame)[*7];
  endsequence;

  property Rx_abort_during_valid_frame;
    @(posedge Clk) disable iff (!Rst)
    Abort_during_valid_frame |-> ##2 Rx_AbortDetect;
  endproperty

  assert_Rx_abort_during_valid_frame: assert property (Rx_abort_during_valid_frame) begin
    $display("PASS: Abort during valid frame");
  end else begin
    $error("FAIL: Abort not successfully asserted during valid frame");
    ErrCntAssertions++;
  end

  /********************************************
   *  Verify correct Idle_pattern behavior  *
   ********************************************/

  sequence Idle_Sequence;
    (Rx && !Rx_AbortDetect)[*8];
  endsequence

  property RX_IdleSignal;
      // INSERT CODE HERE
      @(posedge Clk) disable iff (!Rst)
      Idle_Sequence |=> !Rx_WrBuff;
  endproperty

  RX_IdleSignal_Assert : assert property (RX_IdleSignal) begin
      //$display("PASS: Idle signal");
    end else begin 
      $error("Idle squence went high without being in idle. Rx_wrbuff:%b",Rx_WrBuff); 
      ErrCntAssertions++; 
  end

  /******************************************
   *  Verify 0 insertion after 5 ones on TX *
   *****************************************/
  sequence tx_zero_after_five_ones;
    (Tx_ValidFrame && Tx)[*5];
  endsequence

  property property_tx_zero_after_five_ones;
    @(posedge Clk) disable iff (!Rst)
    tx_zero_after_five_ones |=> (Tx == 1'b0);
  endproperty

  assert_tx_zero_after_five_ones: assert property (property_tx_zero_after_five_ones) begin
    $display("PASS: Zero was inserted after 5 ones");
  end else begin
    $error("Zero was NOT inserted after 5 ones");
    ErrCntAssertions++;
  end

  /****************************************
   *  Verify 0 removal after 5 ones on RX *
   ***************************************/

  sequence rx_zero_after_five_ones;
    (Rx_ValidFrame && Rx_StartZeroDetect && Rx == 1'b1)[*5] ##1
    (Rx_ValidFrame && Rx_StartZeroDetect && Rx == 1'b0);
  endsequence

  property rx_detect_zero_after_ones;
    @(posedge Clk) disable iff (!Rst)
    rx_zero_after_five_ones |-> ZeroDetect;
  endproperty

  assert_rx_detect_zero_after_ones: assert property (rx_detect_zero_after_ones) begin
    $display("PASS: Zero was removed after 5 ones on Rx");
  end else begin
    $error("FAIL: Zero was not removes after 5 ones on Rx");
    ErrCntAssertions++;
  end
  
  always @(posedge Clk) begin
    if (Tx_ValidFrame) begin
      $display("Tx_ValidFrame is high %0t", $time);
    end
  end

/*****************************************************
 *  Check EoF received after whole RX frame received *
 ****************************************************/

property Rx_EoF_generated;
  @(posedge Clk) disable iff (!Rst)
  ($fell(Rx_ValidFrame) && !Rx_AbortDetect) |=> Rx_EoF;
endproperty

assert_Rx_EoF_generated: assert property (Rx_EoF_generated) begin
  $display("PASS: EoF generated");
end else begin
  $error("FAIL: EoF not generated");
  ErrCntAssertions++;
end

/************************************************
 *  Check Rx_Overflow when > 128 bytes received *
 ***********************************************/

int Rx_count;
always @(posedge Clk or negedge Rst) begin
  if (!Rst) begin
    Rx_count <= 0;
  end else begin
    if ($fell(Rx_ValidFrame)) begin // Reset counter after frame
      Rx_count <= 0;
    end else if (Rx_WrBuff) begin
      Rx_count <= Rx_count + 1;
    end
  end
end

property Rx_Overflow_generated;
  @(posedge Clk) disable iff (!Rst)
  (Rx_count >= 128) && Rx_WrBuff |-> Rx_Overflow;
endproperty

assert_Rx_Overflow_generated: assert property (Rx_Overflow_generated) begin
  $display("PASS: Rx_Overflow generated");
end else begin
  $error("FAIL: Rx_Overflow not asserted");
  ErrCntAssertions++;
end

endmodule
