TFE4171 Ex1 

1) 

Dette printes i loggen: “FIFO should be empty after draining” 

ReadBurstData skal lese og poppe alle elementer i FIFOen, slik at empty skal være høy etterpå. Asserten viser at empty er lav, slik at signalet empty viser til at det er flere elementer igjen (som det trolig ikke er).
Telte over loggen og ser at det leses 1 mindre verdi enn det som skrives før assertion kastes.

FIX: la til "@(posedge clk);" mellom readBurstData og assertion. Nå leser testbenchen alle verdier, og empty går trolig høy da vi ikke får error.