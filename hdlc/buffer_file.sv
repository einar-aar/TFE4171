  /********************************************
   *  Verify correct Idle_pattern behavior  *
   ********************************************/
    logic rx_idle;

    assign rx_idle = !Rx_ValidFrame && !Rx_FlagDetect && 
                     !Rx_AbortDetect && !Rx_WrBuff;

    sequence Idle_Sequence;
        Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1
        Rx == 1 ##1 Rx == 1 ##1 Rx == 1 ##1 Rx == 1;
    endsequence

    property RX_IdleSignal;
        // INSERT CODE HERE
        @(posedge Clk) Idle_Sequence |=>  !Rx_WrBuff;
    endproperty

    RX_IdleSignal_Assert : assert property (RX_IdleSignal) begin
        $display("PASS: Idle signal");
     end else begin 
        $error("Idle squence went high without being in idle"); 
        ErrCntAssertions++; 
    end


   