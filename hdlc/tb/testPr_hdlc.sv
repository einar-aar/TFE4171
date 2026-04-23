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

  task VerifyEmptyRxBuffer(input bit abort, input bit error, input bit dropped);

    logic [7:0] ReadData;

    ReadAddress(8'h02, ReadData);

    if (abort == 1) begin
      assert(ReadData[3] == 1'b1)
      else begin
      $error("FAIL: Abort signal bit not set in Rx_SC");
      TbErrorCnt++;
      end
    end

    if (error == 1) begin
      assert(ReadData[2] == 1'b1)
      else begin
      $error("FAIL: Frame error bit not set in Rx_SC");
      TbErrorCnt++;
      end
    end

    if (dropped == 1) begin
      assert(ReadData[1] == 1'b1)
      else begin
      $error("FAIL: Dropped bit not set in Rx_SC");
      TbErrorCnt++;
      end
    end

    assert(ReadData[0] == 1'b0)
    else begin
      $error("FAIL: Rx_Ready signal is high while abort, frame error or drop frame signal is also high");
      TbErrorCnt++;
    end

    ReadAddress(8'h03, ReadData);

    assert(ReadData == 8'h00)
    else begin
      $error("FAIL: Rx buffer contains other values than 0, while abort, frame error or drop frame signal is high");
      TbErrorCnt++;
    end

    $display("PASS: Verify empty Rx buffer during abort, frame error or frame drop");
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
    uin_hdlc.DataIn      =   8'b0;
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

    if(Abort) begin
      VerifyAbortReceive(ReceiveData, Size);
      VerifyEmptyRxBuffer(1, 0, 0);
    end
    else if(FCSerr || NonByteAligned) begin
      VerifyEmptyRxBuffer(0, 1, 0);
    end
    else if(Drop) begin
      VerifyEmptyRxBuffer(0, 0, 1);
    end
    else if(Overflow) begin
      VerifyOverflowReceive(ReceiveData, Size);
    end
    else if(!SkipRead) begin
      VerifyNormalReceive(ReceiveData, Size);
    end

    #5000ns;
  endtask

  task GenerateFCSBytes(logic [128:0][7:0] data, int size, output logic[15:0] FCSBytes);
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

  task automatic GenerateCRCBytes(
  input  logic [127:0][7:0] data,
  input  int size,
  output logic [15:0] fcs
);
  logic [15:0] crc, old_crc;
  logic inbit;
  int i, j;

  crc = 16'h0000;

  // Real message bytes
  for (i = 0; i < size; i++) begin
    for (j = 0; j < 8; j++) begin
      old_crc = crc;
      inbit   = data[i][j];

      crc[0]    = inbit ^ old_crc[15];
      crc[1]    = old_crc[0];
      crc[2]    = old_crc[1] ^ old_crc[15];
      crc[14:3] = old_crc[13:2];
      crc[15]   = old_crc[14] ^ old_crc[15];
    end
  end

  // Append 16 zero bits
  for (j = 0; j < 16; j++) begin
    old_crc = crc;
    inbit   = 1'b0;

    crc[0]    = inbit ^ old_crc[15];
    crc[1]    = old_crc[0];
    crc[2]    = old_crc[1] ^ old_crc[15];
    crc[14:3] = old_crc[13:2];
    crc[15]   = old_crc[14] ^ old_crc[15];
  end

  fcs = crc;
endtask

function automatic logic [7:0] Reverse8(input logic [7:0] b);
  Reverse8 = {b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7]};
endfunction

  task VerifyCRC(logic [128:0][7:0] data, int size);
    
    logic [15:0] actual_crc;
    logic [15:0] test_crc;
    logic [15:0] expected_crc;

    GenerateCRCBytes(data, size, expected_crc);

    wait(uin_hdlc.Tx_FCSDone);

    wait(uin_hdlc.Tx_WriteFCS);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    actual_crc[15:8] = uin_hdlc.Tx_Data;
    test_crc[15:8] = Reverse8(uin_hdlc.Tx_Data);

    wait(uin_hdlc.Tx_WriteFCS);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    actual_crc[7:0] = uin_hdlc.Tx_Data;
    test_crc[7:0] = Reverse8(uin_hdlc.Tx_Data);

    assert(actual_crc == expected_crc) begin
      $display("PASS: valid CRC generated: %h", actual_crc);
    end else begin
      $error("FAIL: CRC not valid. got %b, expected %b hex: %h vs %h",
        actual_crc, expected_crc, actual_crc, expected_crc);
      TbErrorCnt++;
    end

    assert(actual_crc == expected_crc) begin
      $display("PASS: valid CRC generated: %h", actual_crc);
    end else begin
      $error("FAIL: CRC_test not valid. got %b, expected %b hex: %h vs %h",
        test_crc, expected_crc, test_crc, expected_crc);
      TbErrorCnt++;
    end
  endtask


  task TxOverflowCheck();
    logic [7:0] readData;
    static logic [2:0] Tx_SC = 3'b000;
    static int Tx_FullPos = 4;
    ReadAddress(Tx_SC, readData);

    assert_Tx_Overflow: assert(readData[Tx_FullPos] === 1'b1)begin
      $display("Tx_Full passed");
    end else begin
      $error("Tx_Full failed");
      TbErrorCnt++;
    end

  endtask

  task CompareTxData(logic [125:0] [7:0] DataArrayOne, logic [125:0] [7:0] DataArrayTwo);
    assert_TxDataArray: assert(DataArrayOne === DataArrayTwo)begin
      $display("The TxDataArrays Match");
    end else begin
      $error("The TxDataArrays don't match");
    end
  endtask

  task CheckTxSerialMatchesBuffer(input logic [125:0][7:0] exp_data, input int size);
    int byte_index;
    int bit_index;
    int ones_count;
    int local_errCount;
    logic [7:0] rx_byte;
    logic [7:0] flag_shift;
    bit started;

    local_errCount = 0;
    byte_index   = 0;
    bit_index    = 0;
    ones_count = 0;
    rx_byte    = 8'h00;
    flag_shift = 8'h00;
    started    = 0;

    $display("Checking TX serial output against TX buffer...");

    
    wait (uin_hdlc.Tx_ValidFrame);

    while (!started) begin
      @(posedge uin_hdlc.Clk);
      flag_shift = {uin_hdlc.Tx, flag_shift[7:1]}; 
      if (flag_shift == 8'b01111110) begin
        started = 1;
        $display("Start flag detected");
      end
    end

    while (byte_index < size) begin
      @(posedge uin_hdlc.Clk);

      if (ones_count == 5) begin
        if (uin_hdlc.Tx == 1'b0) begin
          ones_count = 0;
          continue;
        end
        else begin
          $error("Expected stuffed zero after five consecutive ones"); // Redundant check but nessesary for reconstruction of data
          TbErrorCnt++;
          ones_count = 0;
        end
      end

      rx_byte[bit_index] = uin_hdlc.Tx;
      bit_index++;

      if (uin_hdlc.Tx)
        ones_count++;
      else
        ones_count = 0;

      if (bit_index == 8) begin
        assert (rx_byte === exp_data[byte_index])begin
            //$display("TX byte %0d matched: %02h", byte_index, rx_byte);
          end else begin
            $error("TX serial mismatch at byte %0d: got %02h expected %02h",
                  byte_index, rx_byte, exp_data[byte_index]);
            TbErrorCnt++;
            local_errCount++;
          end

        rx_byte  = 8'h00;
        bit_index  = 0;
        byte_index++;
      end
    end
    assert_Tx_match_Tx_buffer: assert(local_errCount === 0)begin
      $display("TX serial output matches TX buffer");
    end else begin
      $error("TX serial output has mismatch from TX buffer");
    end
    
  endtask

  task Transmit();
    static logic [2:0] Tx_SC = 3'b000;
    static logic [2:0] Tx_Buff = 3'b001;
    int index;
    logic [125:0] [7:0] expData;
    logic [128:0] [7:0] crcData;
    logic [7:0] WriteData;

    $display("Start Transmit()");
    
    //Starting by clearing tx_sc
    WriteAddress(Tx_SC,8'b0);
    $display("Filling Tx_buffer");
    index = 0;
    while(!uin_hdlc.Tx_Full)begin
      WriteData = $urandom;
      expData[index] = WriteData;
      crcData[index] = WriteData;
      index++;
      WriteAddress(Tx_Buff,WriteData);
    end
    crcData[index]     = 8'h00;
    crcData[index + 1] = 8'h00;
    crcData[index+2]   = 8'h00;
    index--;
    $display("Tx_buffer is filled");
    CompareTxData(expData, uin_hdlc.Tx_DataArray[125:0]);
    TxOverflowCheck();
    
    //Do transmission to empty tx_buffer
    //Start Tx
    $display("Starting transmission for Tx_Done testing:");
    WriteAddress(Tx_SC,8'b00000010);

    fork
      VerifyCRC(crcData, index + 1);
      CheckTxSerialMatchesBuffer(expData,index);
    join

    //Wait for transmission to be done
    while(!uin_hdlc.Tx_Done)begin
      @(posedge uin_hdlc.Clk);
    end
    $display("Tx_Buffer empty, ending transmission");
    //Added to make sure we are not driving Tx_RdBuff for later Assertion
    @(posedge uin_hdlc.Clk)
    //End transmission
    WriteAddress(Tx_SC,8'b0);

    //Fill buffer back up
    $display("Filling Tx_Buffer");
    while(!uin_hdlc.Tx_Full)begin
      WriteData = $urandom;
      WriteAddress(Tx_Buff,WriteData);
    end
    $display("Tx_buffer is filled");
    TxOverflowCheck();
    //Do Abort transmission
    //Start Tx
    $display("Starting Tx");
    WriteAddress(Tx_SC,8'b00000010);
    repeat (50) @(posedge uin_hdlc.Clk);

    //Abort Tx
    $display("Aborting Tx");
    WriteAddress(Tx_SC,8'b00000100);
    repeat (50) @(posedge uin_hdlc.Clk);

    $display("End Transmit()");
  endtask

  //Concurrent assertions

  //Transmission Done
  property Tx_Done_Signal;
  @(posedge uin_hdlc.Clk)
    $rose(uin_hdlc.Tx_Done) && !uin_hdlc.Tx_AbortedTrans |-> $fell(uin_hdlc.Tx_RdBuff)
  endproperty

  assert_Tx_Done: assert property(Tx_Done_Signal) begin
    $display("Tx_Done asseriton passed");
  end else begin
    $error("Tx_Done assertion failed");
    TbErrorCnt++;
  end
  
  
endprogram
