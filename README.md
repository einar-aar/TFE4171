TFE4171 Ex1 

1) 

Dette printes i loggen: “FIFO should be empty after draining” 

ReadBurstData skal lese og poppe alle elementer i FIFOen, slik at empty skal være høy etterpå. Asserten viser at empty er lav, slik at signalet empty viser til at det er flere elementer igjen (som det trolig ikke er).  
