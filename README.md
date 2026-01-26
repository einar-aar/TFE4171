TFE4171 Ex1 

1) 
Dette printes i loggen: “FIFO should be empty after draining” 

ReadBurstData skal lese og poppe alle elementer i FIFOen, slik at empty skal være høy etterpå. Asserten viser at empty er lav, slik at signalet empty viser til at det er flere elementer igjen (som det trolig ikke er).
Telte over loggen og ser at det leses 1 mindre verdi enn det som skrives før assertion kastes.

FIX: la til "@(posedge clk);" mellom readBurstData og assertion. Nå leser testbenchen alle verdier, og empty går trolig høy da vi ikke får error.

2 og 3) 
Endret "0:1023" til "$" i logic [WIDTH-1:0] expectedDataQueue [$];

Da det nå er en qeueu type dynamisk array, må vi legge til og fjerne fra arrayen noe annerledes for å ikke få "out of bounds error". Bruker .push_back() for å simulere skriving og legge til bakerst og .pop_front() for å simulere lesing og fjerne det elementet det leste elementet. Dette innebærer endring av funksjonene scoreBoardQueuePush og scoreBoardPopAndCheck.

For å resette scoreboardet, bruker vi .delete() da vi ikke vet hvor stor arrayen er. Dette innebærer endring av funksjonen scoreBoardReset.

4) 
assertions integrerer seg bedre med formell verifikasjon-verktøy, er enklere å lese og gir bedre feilraporter.