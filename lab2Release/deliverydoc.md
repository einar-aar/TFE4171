
1 & 2) 
The task ta_writeWord already has a $sisplay in the beginning that's never triggered. Therefore, we will add some in the task ta_writeBurst:

$display ("Begin write burst");
    for (int i = 0; i < n; i++) begin
      logic [WIDTH-1:0] data = (seed + i) & {WIDTH{1'b1}};
      $display ("Word %0d write initialized", i);
      ta_writeWord(clk, full, wr_en, wr_data, data);
      $display ("Word %0d written", i);
    end

After adding this, the last display printet in the .log is "Word 0 write initialized", meaning something wrong is happening when calling ta_writeWord.

Added displays before and after "@(posedge clk)" and found out it is here the program hangs. This is because signals that change over time and the class needs to react to, needs to be passed through an interface. if not, the class will receive a copy of the signal that won't be driven by the original signal. The solution was to add a virtual interface, pass in the testbench interface during creation of class instance and connect these two together.

declaration of virtual interface inside writer class: virtual if_Fifo #(WIDTH) virtual_if;

inside new() inside writer class: virtual if_Fifo #(WIDTH) tb_if

connect interfaces together: this.virtual_if   = tb_if;

usage of interface: @(posedge virtual_if.clk);

Now the ta_writeBurst finishes successfully, but ta_readBurst hangs. ta_readBurst and ta_readWord had the same bugs and same fixes. Simulation runs to completion, but we now get an error related to TX timeout.

3) 
