
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
Firstly, changed the sb in the parent class cl_TbUtils to protected, so that the reader and writer class inherit this value. Next, changed the start of the reader class to this:

local virtual if_TbEvents.reader  eif;
  //local cl_Scoreboard #(WIDTH) sb;
  virtual if_Fifo #(WIDTH) virtual_if;

  function new(
    cl_Scoreboard #(WIDTH) sb,
    virtual if_TbEvents.reader  eif,
    virtual if_Fifo #(WIDTH) tb_if
  );
    super.new(tb_if, sb);
    //this.sb = sb;
    this.eif = eif;
    this.virtual_if = tb_if;
  endfunction

The writer class to this:

class cl_FifoWriter #(parameter int WIDTH = 8) extends cl_TbUtils #(WIDTH);
  local virtual if_TbEvents.writer eif;
  // local cl_Scoreboard #(WIDTH) sb;
  // local cl_TbUtils    #(WIDTH) utils;
  virtual if_Fifo #(WIDTH) virtual_if;

  function new(

    cl_Scoreboard #(WIDTH)      sb,
    virtual if_TbEvents.writer  eif,
    // cl_TbUtils   #(WIDTH)       utils,
    virtual if_Fifo #(WIDTH) tb_if);

    super.new(tb_if, sb);

    // this.sb    = sb;
    this.eif   = eif;
    // this.utils = utils;
    this.virtual_if   = tb_if;
  
  endfunction

The instanciation of writer in tb to this: cl_FifoWriter #(WIDTH) writer = new(sb, ev_if, /*utils,*/ tb_if);

This works because the writer and reader objects inherit the characteristics of the base class by using the extend line in the definition. the base-part of the objects are instanciated with the super.new function, calling the constructor of the base class.

4) 
SystemVerilog creates a default constructor that instanciates the object and sets variables to default values. For example the q variable will be instanciated as empty.
The new function should only be explicitly defined when you want to pass in signals/variables or set variables to specific values.

5) 

6) 
Rand allows SystemVerilog to add the variable to the constrainted random environment, enabling functions to randomize the content inside q. This could help the testbench achieve fully exhaustive testing by testing situations the developer haven't thought of.