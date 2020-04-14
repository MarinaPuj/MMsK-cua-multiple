close all
clear all
clc


%% M/M/s/K Una cua per cada s. Client va a la cua m�s buida, si cues iguals = probabilitat d'acabar a cada cua
n=20;
lambda=2; %1 cada 2 minuts.
mu=4;%1 cada 4 minuts.
s=3; % N�mero de finestres
KK=0; %Si KK=1 hi ha aforament m�xim; Si KK=0 no hi ha aforament m�xim
K=8; % Aforament m�xim

for i=1:n
t(i,1)=i;
zero(i,1)=0;
end

noms={'Num_Costumer','Interarrival_time','Arrival_Time','Server','Time_Service_Begins','Time_Service_Ends','W','Idle_Time','Service_Time'};
T=table(t,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames', noms);

%Busquem per cada client
for i=1:n
    T.Interarrival_time(i)=exprnd(lambda); %interarrival time
    T.Arrival_Time(i)=sum(T.Interarrival_time); %Arribada al sistema
    T.Service_Time(i)=exprnd(mu); %Temps de servei
end

lliures=ones(1,s); %Els servidors lliures son els igual a 1. Si estan ocupats 0.
serv_end=zeros(1,s); %Temps d'acabar de servir de cada servidor. Al principi no han comen�at =0
Csys(1)=0; %N�mero clients al sistema
f=1; %�ndex de fora (rellevant si hi ha aforament m�xim)
fora(f)=0; %llista clients (Num_Costumer) que es queden fora (rellevant si hi ha aforament m�xim)


%Per cada client:
for i=1:n
    clients_sys=[]; %llista clients al sistema quan i entra. finestra + cua. ordenada segons temps de sortida (ascendent).
    serv=[]; %n�mero de servidor on est� cada client de la llista clients_sys.
    queue=zeros(1,s); %n�mero de clients a la cua de cada servidor (ordenat). Si servidor 2 hi ha 4clients queue(2)=4.
    cs=1; %�ndex de client_sys i de serv.
    
    %Calculem els servidors que estan lliures. Iterem al llarg dels servidors
    for ii=1:s
       if (T.Arrival_Time(i)>= serv_end(ii))  %Si el temps de fi de l'�ltim client servit pel servidor m (serv_end(m)) �s m�s petit que el temps d'arribada de i -> el servidor est� lliure
           lliures(ii)=1;
       else
           lliures(ii)=0;
       end
    end
    Csys(i)=0; 
    %Comparar arribada client i amb temps de fi de servei dels clients anteriors.
    for t=1:i   
        if(T.Arrival_Time(i)<T.Time_Service_Ends(t)) %Si el client t-�ssim acaba m�s tard de quan arriba l'i-�ssim. El client t-�ssim est� al sistema quan l'i-�ssim entra 
            Csys(i)=Csys(i)+1; %Numero de clients que hi ha sense contar a i.
            clients_sys(cs)=t; %Guardem el Num_Costumer del client t.
            serv(cs)=T.Server(t); %Guardem el numero de servidor del client t.
            cs=cs+1;
        end
    end
    
    %{
     disp('i');
     disp(i);
     disp(clients_sys); %llista clients al sistema quan i entra. finestra + cua. ordenada segons temps de sortida (ascendent).
     disp(serv); %n�mero de servidor on est� cada client de la llista clients_sys.
     disp(lliures); %Estat de cada servidor si lliure=1, ocupat=0;
     disp('temps fi:')
     disp(round(serv_end)); %Temps fi de servei de cada servidor
     %}
    
    %CAS1: Hi ha alg�n servidor lliure
    if(sum(lliures)~=0) 
        %Calcular a quin servidor anir� a parar.
        a=rand; %n�mero random entre 0 i 1
        pos=0; 
        if (sum(lliures)==1) %si nom�s hi ha un servidor lliure anir� al lliure
            pos=1; 
        elseif(a==1) %si la a=1 anir� a l'�ltim servidor lliure
            pos=sum(lliures);
        else 
            %Per tenir la mateixa probabilitat d'anar a cada servidor:
            %multipliquem a per el nombre de servidors lliures i eliminem els decimals, despr�s l'hi sumem 1. 
            %Exemple: 2 servidors lliures si a<0.5, pos=a*2 0<=pos<1, pos=0, pos=1; si 0.5<=a<1 1<=pos<2, pos=1, pos=2.
          pos=a*sum(lliures); 
          pos=floor(pos);
          pos=pos+1;
        end
        k=find(lliures==1); %�ndexs de servidors lliures
        T.Server(i)=k(pos); %Guardem el servidor que l'atendr�
        T.Time_Service_Begins(i)=T.Arrival_Time(i); %Nom�s arribar ser� servit ja que hi ha alg�n servidor lliure.
        T.Idle_Time(i)=T.Arrival_Time(i)-serv_end(k(pos)); %El servidor descansa des que marxa l'�ltim client fins que arriba aquest.
        T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
        T.W(i)=T.Service_Time(i);
        serv_end(T.Server(i))=T.Time_Service_Ends(i); %Guardem el temps en que el servidor acaba de servir a l'usuari i.
    %{
    disp(a);
    disp(T.Server(i)); %Servidor on va
    %}
        
    %CAS 2. No puc entrar. Hi ha aforament m�xim (KK=1) i el nombre de clients al sistema �s superior a K (l'aforament m�x)
    elseif(Csys(i)>=K && KK==1)
        Csys(i)=K;
        fora(f)=i; %Guardo a fora el Num_Costumer del client que no pot entrar
        f=f+1;
        
    %CAS 3. Tots servidors plens per� puc entrar a la cua %if (length(queue)+s<=K)
    else 
        
    %Mirar la cua de cada servidor.
    for m=1:s %Iterem al llarg dels servidors
        mm=find(serv==m); %serv: cont� el numero de servidor de cada client del sistema -> Busquem els que coincideixen amb el numero del servidor m. Obtindrem l'�ndex dins de serv.
        queue(m)=length(mm); %La llargada de mm ser� el nombre de clients al sistema que estan al servidor m. Ho guardem a queue(m).
        queue(m)=queue(m)-1; %Eliminem els que estan sent atesos
    end
    %Ex: Si el servidor 1 t� 3 clients, el 2 en t� 1, el 3 en t� 1 i el 4 en t� 3 ->queue=[3, 1, 1, 4] 
    
    %Mirar quin servidor t� menys cua.
    x=min(queue); %Valor m�nim de cua que haurem de fer = Valor minim del vector queue.
    xx=find(queue==x); %Trobem els servidors que tenen el valor m�nim de cua. xx vector que cont� el numero dels servidors amb la cua m�nima. 
    %Ex: Si queue=[3, 1, 1, 4] -> x=1 -> xx=[2,3] 
    
    %Calcular a quin servidor anir� a parar dels que tenen menys cua.
    a=rand; %n�mero random entre 0 i 1
    pos=0; 
    if (length(xx)==1) %si nom�s hi ha un servidor lliure anir� al lliure
        pos=1; 
    elseif(a==1) %si la a=1 anir� a l'�ltim servidor lliure
        pos=length(xx);
    else 
        %Per tenir la mateixa probabilitat d'anar a cada servidor:
        %multipliquem a per el nombre de servidors lliures i eliminem els decimals, despr�s l'hi sumem 1. 
        %Exemple: 2 servidors lliures si a<0.5, pos=a*2 0<=pos<1, pos=0, pos=1; si 0.5<=a<1 1<=pos<2, pos=1, pos=2.
      pos=a*length(xx); 
      pos=floor(pos);
      pos=pos+1;
    end
    T.Server(i)=xx(pos);
   
    %{
    disp(queue); %Numero de cua de cada servidor
    disp(a);
    disp(T.Server(i)); %Servidor on va
    %}
    
    T.Time_Service_Begins(i)=serv_end(T.Server(i)); %Comen�ar� a ser servit quan el servidor acabi
    T.Idle_Time(i)=0; %El servidor no descansar�
    T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+ T.Service_Time(i);
    T.Wq(i)=T.Time_Service_Begins(i)-T.Arrival_Time(i);
    T.W(i)=T.Wq(i)+T.Service_Time(i);
    serv_end(T.Server(i))=T.Time_Service_Ends(i); %Guardem el temps en que el servidor acaba de servir a l'usuari i.
 
    end
end

f=f-1; %N�mero de clients que no entren al sistema.
%disp(f/n);

%Creem una taula per a cada servidor:
%{
%Opci� 1. Saber nombre de servidors. No escalable.
k1=find(T.Server==1); %�ndexs de la taula T de clients que van al servidor 1
k2=find(T.Server==2); %�ndexs de la taula T de clients que van al servidor 2
k3=find(T.Server==3); %�ndexs de la taula T de clients que van al servidor 3
k4=find(T.Server==4); %�ndexs de la taula T de clients que van al servidor 4
M1=T(k1,:);
M2=T(k2,:);
M3=T(k3,:);
M4=T(k4,:);
%}
%%{
%Opci� 2. Escalable. Crear noms de variables de manera din�mica
for i=1:s
    genvarname('k',  num2str(i));
    eval(['k' num2str(i) '=find(T.Server==i)']);
    genvarname('MA',  num2str(i));
    eval(['MA' num2str(i) '= T(k' num2str(i) ',:)']);
end
%}


