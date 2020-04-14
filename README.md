# M/M/s/K amb cua múltiple

Simulació d'una cua amb s servidors i aforament màxim k. Els clients arribaran i seran servits d'acord amb una distribució exponencial.
Es serviran un total de n clients. Enlloc d'haver-hi una cua única, hi ha una cua per cada servidor.

Quan arriba un client:

- Si hi ha un servidor buit anirà al servidor buit.
- Si hi ha més d'un servidor buit té la mateixa probabilitat d'acabar a qualsevol servidor buit.
- Si tots els servidors estan plens anirà al que tingui menys cua, si hi ha dos o més servidors amb la cua mínima anira a qualsevol d'aquests amb la mateixa probabilitat.


## Resultat 
Al final en una taula T, es mostrarà de cada client servit:

- Número de client en ordre d'arribada. 'Num_Costumer' (entre 1 i n)
- Temps d'arribada. 'Arrival_Time'
- Quin servidor el serveix. 'Server' (entre 1 i s)
- Temps en que es comença a servir. 'Time_Service_Begins'
- Temps en que s'acaba de servir. 'Time_Service_Ends'
- Temps que ha tardat en servir-se. 'Service_Time'
- Temps que ha estat a la cua. 'Wq'
- Temps total al sistema. 'W'
- Temps de descans del servidor. 'Idle_Time'
