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

5) 
Ingen spørsmål knyttet til oppgaven, se kode.

6) 
Får følgende feilmelding:
"Error:  ./rtl/NtnuTfe4171Lab1Fifo.sv:44: The expression in the reset condition of the 'if' statement in this 'always' block can only be a simple identifier or its negation. (ELAB-303)"

Feilen var at første if i always_ff må være en sjekk for bare reset. Programmet syntetiserer nå etter å ha lagt til denne sjekken.

7) 
alle warnings i .log:
Warning:  Latch inferred in design NtnuTfe4171Lab1Fifo read with 'hdlin_check_no_latch' (ELAB-395)

Warning: In design 'NtnuTfe4171Lab1Fifo', cell 'C1219' does not drive any nets. (LINT-1)
Warning: In design 'NtnuTfe4171Lab1Fifo', cell 'C1273' does not drive any nets. (LINT-1)

Warning: Main library 'class' does not specify the following unit required for power: 'Leakage Power'. (PWR-424)
Warning: Target library(s) are not characterized for internal power.  Compile with power constraints is NOT recommended. (PWR-13)

Den første advarselen er nesten alltid et problem. latcher fører ofte til udefinert oppførsel og er gjerne et resultat av feil design, ofte hvis man har glemt å sette alle variabler i alle stier i en kombinatorisk krets.

De to neste advarslene er død logikk. Synteseverktøyet har laget celler som ikke driver noe og dermed ikke gjør noen ting annet enn å ta opp plass. Det kan også være at vi ønsker at disse cellene egentlig skal gjøre noe, men finner ikke ut hva det potensielt kan være.

De to siste sier bare at vi ikke har ressurser i biblioteket til å analysere "Leakage Power" og "internal power", slik at vi ikke kan stole på power analyser.

Antar at vi bare bryr oss om første advarsel. Løsningen her er å tilordne rd_data verdi selv om if-sjekken feiler, slik at vi ikke trenger å huske forrige verdi i en latch. Setter bare rd_data = '0. Byttet også fra '<=' til '=', da kombinatoriske kretser ikke tillater den første. Etter ny syntese ble advarselen fjernet.

8) 
Disse assertionsene overvåkes kontinuerlig, slik at man slipper å skrive mange if-setninger. De er også bedre med tanke på gjenbruk i koden, både denne testbenchen og hvis det skal gjenbrukes i andre.

Bakdel er at de kan være vanskeligere å debugge og tar gjerne lengre tid å skrive for enkle testbencher.

9) 
Timeout er på 5.1us * 16MHz = ca 82 klokkesykluser.

Løsning 1:
Vi lager et ACK signal fra receiver til sender, som sier ifra at pakke 0 er prossessert. Når ACK går høy, får sender sende neste pakke.

Løsning 2:
Sender får lov til å begynne sending av neste pakke med en gang receiver har mottat forrige pakke og lagt den i intern buffer. Dette er mulig da FIFO kan holde en hel pakke. Bruker her ACK før pakken er ferdig behandlet. Dette er en optimalisert versjon av løsning 1.

Implementerer løsning 1.
La til en wait(receiver_ack) i sender-tråden, setter receiver_ack til 0 med en gang receiver tok imot en pakke, setter den høy etter pakken er ferdigprosessert og høy etter resets og flush. Resultatet er ingen errors.

OBS: Noe endringer på filstiene i run_tb.scr og modulnavn i architectural testbenchen.