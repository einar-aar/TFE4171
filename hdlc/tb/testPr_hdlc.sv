//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author: 
// Date:  
//////////////////////////////////////////////////

/* testPr_hdlc contains the simulation and immediate assertion code of the
   testbench. 

   For this exercise you will write immediate assertions for the Rx module which
   should verify correct values in some of the Rx registers for:
   - Normal behavior
   - Buffer overflow 
   - Aborts

   HINT:
   - A ReadAddress() task is provided, and addresses are documentet in the 
     HDLC Module Design Description
*/

program testPr_hdlc(
  in_hdlc uin_hdlc
);
  
  int TbErrorCnt;

  /****************************************************************************
   *                                                                          *
   *                               Student code                               *
   *                                                                          *
   ****************************************************************************/

  // VerifyAbortReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer is zero after abort.
  task VerifyAbortReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
  
    // INSERT CODE HERE
    //Checks that Rx_AbortSignal is high
    ReadAddress(8'h02,ReadData);
    assert(ReadData[5:0] === 6'b101000)
      else begin
        $error("VerifyAbortReceive failed, RXSC: %b",ReadData);
        TbErrorCnt++;
      end
    if (ReadData[5:0] === 6'b101000) begin
      ReadAddress(8'h03,ReadData);
      assert(!ReadData)
        else begin
          $error("VerifyAbortReceive failed, RX databuffer is %b and not Zero",ReadData);
          TbErrorCnt++;
        end
    end
  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyNormalReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);

    // INSERT CODE HERE
    ReadAddress(8'h02,ReadData);
    assert(ReadData[5:0] === 6'b100001)
      else begin
        $error("VerifyNormalReceive failed, RXSC: %b",ReadData);
        TbErrorCnt++;
      end

    if (ReadData[5:0] === 6'b100001) begin
      for (int i = 0; i < Size; i++) begin
        ReadAddress(8'h03, ReadData);
        //$display("Checking byte %0d", i);
        assert(data[i] === ReadData)
          else begin
            $error("VerifyNormalReceive failed for byte %0d, value is %0d, expected %0d, FCS: %H", i, ReadData, data[i], data[Size+1]);
            TbErrorCnt++;
          end
      end
    end
  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);

    // INSERT CODE HERE
    ReadAddress(8'h02,ReadData);
    assert(ReadData[5:0] === 6'b010001)
      else begin
        $error("VerifyOverflowReceive failed, RXSC: %b",ReadData);
        TbErrorCnt++;
      end
    if (ReadData[5:0] === 6'b010001) begin
      for (int i = 0; i < Size; i++) begin
        ReadAddress(8'h03,ReadData);
        //$display("Checking byte %0d", i);
        assert(data[i] === ReadData)
          else begin
          $error("VerifyNormalReceive failed for byte %0d, value is %0d, expected %0d, FCS: %H", i, ReadData, data[i], data[Size+1]);
          TbErrorCnt++;
          end
      end
    end
  endtask

  /****************************************************************************
   *                                                                          *
   *                             Simulation code                              *
   *                                                                          *
   ****************************************************************************/

  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    Init();
    $display("*************************************************************");
    $display("%t - Testing Receive Functionality", $time);
    $display("*************************************************************");

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive( 10, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 40, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 45, 0, 0, 0, 0, 0, 0); //Normal
    Receive(126, 0, 0, 0, 0, 0, 0); //Normal
    Receive(122, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 25, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 47, 0, 0, 0, 0, 0, 0); //Normal

    $display("*************************************************************");
    $display("%t - Testing Transmit Functionality", $time);
    $display("*************************************************************");

    Transmit();

    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end

  final begin

    $display("*********************************");
    $display("*                               *");
    $display("* \tAssertion Errors: %0d\t  *", TbErrorCnt + uin_hdlc.ErrCntAssertions);
    $display("*                               *");
    $display("*********************************");

  end

  task Init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Address     = 3'b000;
    uin_hdlc.WriteEnable =   1'b0;
    uin_hdlc.ReadEnable  =   1'b0;
    uin_hdlc.DataIn      =     '0;
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task InsertFlagOrAbort(int flag);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    if(flag)
      uin_hdlc.Rx = 1'b0;
    else
      uin_hdlc.Rx = 1'b1;
  endtask

  task MakeRxStimulus(logic [127:0][7:0] Data, int Size);
    logic [4:0] PrevData;
    PrevData = '0;
    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          uin_hdlc.Rx = 1'b0;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = Data[i][j];

        PrevData = PrevData >> 1;
        PrevData[4] = Data[i][j];
      end
    end
  endtask

  task Receive(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] ReceiveData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    string msg;
    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";
    $display("*************************************************************");
    $display("%t - Starting task Receive %s", $time, msg);
    $display("*************************************************************");

    for (int i = 0; i < Size; i++) begin
      ReceiveData[i] = $urandom;
    end
    ReceiveData[Size]   = '0;
    ReceiveData[Size+1] = '0;

    //Calculate FCS bits;
    GenerateFCSBytes(ReceiveData, Size, FCSBytes);
    ReceiveData[Size]   = FCSBytes[7:0];
    ReceiveData[Size+1] = FCSBytes[15:8];

    //Enable FCS
    if(!Overflow && !NonByteAligned)
      WriteAddress(2'h2, 8'h20);
    else
      WriteAddress(2'h2, 8'h00);

    //Generate stimulus
    InsertFlagOrAbort(1);
    
    MakeRxStimulus(ReceiveData, Size + 2);
    
    if(Overflow) begin
      OverflowData[0] = 8'h44;
      OverflowData[1] = 8'hBB;
      OverflowData[2] = 8'hCC;
      MakeRxStimulus(OverflowData, 3);
    end

    if(Abort) begin
      InsertFlagOrAbort(0);
    end else begin
      InsertFlagOrAbort(1);
    end

    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    if(Abort)
      VerifyAbortReceive(ReceiveData, Size);
    else if(Overflow)
      VerifyOverflowReceive(ReceiveData, Size);
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);

    #5000ns;
  endtask

  task GenerateFCSBytes(logic [127:0][7:0] data, int size, output logic[15:0] FCSBytes);
    logic [23:0] CheckReg;
    CheckReg[15:8]  = data[1];
    CheckReg[7:0]   = data[0];
    for(int i = 2; i < size+2; i++) begin
      CheckReg[23:16] = data[i];
      for(int j = 0; j < 8; j++) begin
        if(CheckReg[0]) begin
          CheckReg[0]    = CheckReg[0] ^ 1;
          CheckReg[1]    = CheckReg[1] ^ 1;
          CheckReg[13:2] = CheckReg[13:2];
          CheckReg[14]   = CheckReg[14] ^ 1;
          CheckReg[15]   = CheckReg[15];
          CheckReg[16]   = CheckReg[16] ^1;
        end
        CheckReg = CheckReg >> 1;
      end
    end
    FCSBytes = CheckReg;
  endtask
  task Transmit();
    static logic [2:0] Tx_SC = 3'h0;
    static logic [2:0] Tx_Buff = 3'h1;
    logic [7:0] WriteData;

    //Starting by clearing tx_sc
    WriteAddress(Tx_SC,8'b0);
    while(!uin_hdlc.Tx_Full)begin
      WriteData = $urandom;
      WriteAddress(Tx_Buff,WriteData);
    end
    $display("Tx_buffer is filled");
    //Start Tx and tx abort
    WriteAddress(Tx_SC,8'hff);
  endtask

  property Tx_AbortedTrans_Signal;
  @(posedge uin_hdlc.Clk)
    uin_hdlc.Tx_AbortFrame |-> ##[1:2] uin_hdlc.Tx_AbortedTrans;
  endproperty

  assert_Tx_AbortedTrans: assert property(Tx_AbortedTrans_Signal)begin
    $display("Tx_AbortedTrans passed");
  end else begin
    $error("Tx_AbortedTrans failed");
    TbErrorCnt++;
  end

endprogram
