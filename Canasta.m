function Canasta

% Programa de simulación de tiro a canasta (Baloncesto).

% La velocidad inicial de tiro se controla mediante los sliders,
% con coordenadas esféricas (módulo de la velocidad, ángulo azimutal y
% el complementario del ángulo cenital), con botones contiguos de reseteo (a 0) para
% los ángulos. Hay entradas de texto para elegir posición de disparo así
% como para el "dt", el intervalo de tiempo entre cada iteración; sin
% restricciones (por tanto se puede tirar desde zonas donde la pelota
% debería rebotar, esto es bajo el suelo o dentro del tablero, o poner
% intervalos de tiempo negativos,con resultados posiblemente
% sorprendentes). Por último se escoge qué consideraciones físicas se
% quieren tener en cuenta para simular el disparo además de la gravedad: el
% arrastre del aire o la fuerza del viento, con respectivas entradas para determinar
% sus magnitudes. Por lo demás, 'Limpia' borra las trayectorias de tiros
% anteriores por el bienestar del pc; '¡Apunta!' escoge la velocidad
% inicial apuntando automáticamente de forma que el próximo tiro enceste
% dadas las condiciones iniciales y empleando para ello un tiempo de vuelo
% que se ha especificado previamente (para cambiarlo, borrar el segmento
% 'seg', que es solo aclaratorio, y escribir únicamente la magnitud (en
% segundos)) (se nos muestra las componentes de la velocidad inicial
% escogida en el texto contiguo al slider del módulo de la velocidad);
% '¡Tira!' simplemente tira.

% Rodrigo Casado Noguerales, DG Física y Matemáticas, LDCC, UCM.



%%%Constantes

g=[0,0,-9.8]; Radbol=.12; Radaro=.23; es=.85; et=.5; Mbol=.6; %es=sqrt(h2=1.3/h1=1.8) (estándards de rebote); et estimado con buen juicio(inventado)



%%%Figura y ejes

f=figure('Name','Prueba','Visible','off','Units','Normalized','OuterPosition',[0,.05,1,.95]); %units: pixels default, 1920×1080

ax=axes; ax.Position=[0,0,1,1]; ax.Clipping='off';



%%%Variables iniciales


vo=2; a1=0; a2=0; ro=[0,7.5,2]; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)]; caso='g'; b=.01; vaire=[0,0,0];

dt=1/60; kill=0; tapunt=2;



%%%Objetos gráficos


hold on, dibuja_pista

q=quiver3(ro(1),ro(2),ro(3),voo(1),voo(2),voo(3),'r','LineWidth',2); %Vector de velocidad inicial

qv=quiver3(12.8,7.5,4.5,vaire(1),vaire(2),vaire(3),'g','LineWidth',2); %Vector de dirección e intensidad del viento

[a,aa]=meshgrid(linspace(0,2*pi,20),linspace(0,pi,10));
h=surf(ro(1)+Radbol*sin(aa).*cos(a),ro(2)+Radbol*sin(aa).*sin(a),ro(3)+Radbol*cos(aa),col(size(a),1,.35,0),... %.99,-.5,-.25
    'EdgeAlpha',.3,'LineWidth',.05); %Pelota



%%%Elementos y funciones


%Ángulo azimutal

slda1=uicontrol('Style','slider','Min',-180,'Max',180,'Value',0,...
    'Position',[10 580 300 20],'Callback',@slda1call);

    function slda1call(source,data)
        a1=-source.Value; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)];
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
    end

txta1=uicontrol('Style','text','String','Ángulo azimutal','Position',[10 600 90 15]);

push0a1=uicontrol('Style','pushbutton','String','0','Position',[315 580 30 20],'Callback',@push0a1call);
    function push0a1call(source,data);
        a1=0; slda1.Value=0; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)];
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
    end


%Ángulo cenital

slda2=uicontrol('Style','slider','Min',-90,'Max',90,'Value',0,...
    'Position',[10 530 300 20],'Callback',@slda2call);

    function slda2call(source,data)
        a2=source.Value; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)];
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
    end

txta2=uicontrol('Style','text','String','Ángulo cenital','Position',[10 550 90 15]);

push0a2=uicontrol('Style','pushbutton','String','0','Position',[315 530 30 20],'Callback',@push0a2call);
    function push0a2call(source,data)
        a2=0; slda2.Value=0; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)];
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
    end


%Módulo de la velocidad

sldvo=uicontrol('Style','slider','Min',0,'Max',20,'Value',1,...
    'Position',[10 480 300 20],'Callback',@sldvocall);

    function sldvocall(source,data)
        vo=source.Value; voo=vo*[cosd(a1)*cosd(a2),sind(a1)*cosd(a2),sind(a2)]; %ax.CameraTarget=voo;
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
        txtvodispval.String=['Vo = ',num2str(source.Value),' m/s'];
    end

txtvo=uicontrol('Style','text','String','Velocidad inicial','Position',[10 500 90 15]);

txtvodispval=uicontrol('Style','text','String','Vo = 2 m/s','Position',[320 480 90 15]);

align([slda1,slda2,sldvo,txta1,txta2,txtvo],'Center','None');


%Punto de tiro

editro=uicontrol('Style','edit','String','[0 , 7.5 , 2]','Position',[125 445 80 25],'Callback',@editrocall);

    function editrocall(source,data)
        ro=str2num(source.String);
        h.XData=ro(1)+Radbol*sin(aa).*cos(a); h.YData=ro(2)+Radbol*sin(aa).*sin(a); h.ZData=ro(3)+Radbol*cos(aa);
        q.XData=ro(1); q.YData=ro(2); q.ZData=ro(3);
    end

txtro=uicontrol('Style','text','String','Punto de tiro (x,y,z) =','Position',[5 450 120 15]);


%dt

editdt=uicontrol('Style','edit','String','1/60','Position',[245 445 40 25],'Callback',@editdtcall);

    function editdtcall(source,data)
        dt=str2num(source.String);
    end

txtdt=uicontrol('Style','text','String','"dt" =','Position',[212 450 30 15]);


%Popup para escoger consideraciones físicas

popup=uicontrol('Style','popup','String',{'Sin arrastre del aire','Con arrastre del aire','Con arrastre y viento'},...
    'Position', [10 435 140 0],'Callback', @popupcall);

    function popupcall(source,data)
        switch source.String{source.Value};
            case 'Sin arrastre del aire'
                caso='g'; editb.Visible='off'; txtb.Visible='off'; editvaire.Visible='off'; txtvaire.Visible='off';
            case 'Con arrastre del aire'
                caso='gr'; editb.Visible='on'; txtb.Visible='on'; editvaire.Visible='off'; txtvaire.Visible='off';
            case 'Con arrastre y viento'
                caso='grv'; editb.Visible='on'; txtb.Visible='on'; editvaire.Visible='on'; txtvaire.Visible='on';
        end
    end

editb=uicontrol('Style','edit','Visible','off','String','0.01','Position',[70 380 80 25],'Callback',@editbcall);

    function editbcall(source,data)
        b=str2num(source.String);
    end

txtb=uicontrol('Style','text','Visible','off','String','Valor de b:','Position',[10 380 60 15]);

align([editb,txtb],'None','Middle');

editvaire=uicontrol('Style','edit','Visible','off','String','[ 0 , 0 , 0 ]','Position',[70 345 80 25],'Callback',@editvairecall);

    function editvairecall(source,data)
        vaire=str2num(source.String);
        qv.UData=vaire(1); qv.VData=vaire(2); qv.WData=vaire(3);
    end

txtvaire=uicontrol('Style','text','Visible','off','String','Velociedad del viento:','Position',[10 340 60 30]);

align([editvaire,txtvaire],'None','Middle');


%!Tira¡

pushgo=uicontrol('Style','pushbutton','String','¡Tira!','Position',[350 585 60 35],'Callback',@pushgocall);

    function pushgocall(source,data)
        kill=0; tiro(ro,voo,caso,b,vaire)
    end


%Limpiar

pushcl=uicontrol('Style','pushbutton','String','Limpiar','Position',[350 505 60 35],'Callback',@pushclcall);

    function pushclcall(source,data)
        cla, hold on, dibuja_pista
        q=quiver3(ro(1),ro(2),ro(3),voo(1),voo(2),voo(3),'r','LineWidth',2);
        qv=quiver3(12.8,7.5,4.5,vaire(1),vaire(2),vaire(3),'g','LineWidth',2);
        [a,aa]=meshgrid(linspace(0,2*pi,20),linspace(0,pi,10));
        h=surf(ro(1)+Radbol*sin(aa).*cos(a),ro(2)+Radbol*sin(aa).*sin(a),ro(3)+Radbol*cos(aa),col(size(a),1,.35,0),...%.99,-.5,-.25),...
            'EdgeAlpha',.3,'LineWidth',.05);
        kill=1;
    end


%!Apunta¡

pushapunta=uicontrol('Style','pushbutton','String','¡Apunta!','Position',[350 545 60 35],'Callback',@pushapuntacall);

    function pushapuntacall(source,data)
        switch caso
            case 'g'
                voo=-g/2*tapunt+([12.42,7.5,3.05]-ro)/tapunt;
            case 'gr'
                ast=-g;
                voo=(([12.42,7.5,3.05]-ro)*b+ast*tapunt)/(1-exp(-b*tapunt))-ast/b;
            case 'grv'
                ast=-g-pi*Radbol^2/Mbol*(1/2*1.223*norm(vaire)/2)*vaire; %Fuerza empuje del aire: F=Área_de_ataque*Presión; P=K*Rho(aire)*v(aire)^2/2 en dirección de v; K=1/2 para esferas
                voo=(([12.42,7.5,3.05]-ro)*b+ast*tapunt)/(1-exp(-b*tapunt))-ast/b;
        end
        q.UData=voo(1); q.VData=voo(2); q.WData=voo(3);
        txtvodispval.String=['[',num2str(voo,'% 2.2f'),' ] m/s'];
    end

edittapunt=uicontrol('Style','edit','String','2 seg','Position',[245 410 40 25],'Callback',@edittapunttcall);

    function edittapunttcall(source,data)
        tapunt=str2num(source.String);
    end

txttapunt=uicontrol('Style','text','String','Tiempo de vuelo para apuntar:','Position',[160 408 80 30]);

f.Visible='on';



%%%Funciones

    function tiro(ro,vo,caso,b,vaire)
        
        r=ro; t=0; rebotes=0;
        
        while norm(r-[7,7.5,3])<30
            
            t=t+dt; [r,v]=movimiento(t,ro,vo,caso,b,vaire);
            
            [a,aa]=meshgrid(linspace(0,2*pi,20),linspace(0,pi,10));
            h.XData=r(1)+Radbol*sin(aa).*cos(a);
            h.YData=r(2)+Radbol*sin(aa).*sin(a);
            h.ZData=r(3)+Radbol*cos(aa);
            
            plot3(r(1),r(2),r(3),'b.','MarkerSize',4);
            
            drawnow
            
            if r(3)<Radbol && t>.05 %Rebotes con el suelo
                vo=v; vo(3)=-es*vo(3); ro=r; t=0;
                rebotes=rebotes+1;
            end
            
            if r(1)>=12.8-Radbol && r(1)<=12.8+Radbol && r(2)>=6.6-Radbol && r(2)<=8.4+Radbol && r(3)>=2.9-Radbol && r(3)<=3.9-Radbol %Rebotes con el tablero
                if (r(2)>=6.6-Radbol && r(2)<=6.6) || (r(2)>=8.4 && r(2)<=8.4+Radbol)
                    v(2)=-et*v(2); vo=v; ro=r; t=0;
                else
                    v(1)=-et*v(1); vo=v; ro=r; t=0;
                end
                rebotes=rebotes+1;
            end
            
            if sqrt((r(1)-12.42)^2+(r(2)-7.5)^2)<=.2 && (r(3)>=3.05-1.5*Radbol && r(3)<=3.05+1.5*Radbol) %Comprueba si has encestado
                if norm(v)<=6.5 %7.2 es aproximadamente la velocidad a partir de la cuál con dt=1/60, una bola podría recorrer Radbol en una sola iteración
                    if r(3)>=3.05-.5*Radbol && r(3)<=3.05+.5*Radbol
                        r=[12.42,7.5,3.02]; ro=r; t=0; v(2)=0; v(1)=0; vo=v/3; text(12.42,7.5,5,'¡Has encestado!')
                    end
                elseif norm(v)<=14
                    if r(3)>=3.05-Radbol && r(3)<=3.05+Radbol
                        r=[12.42,7.5,3.02]; ro=r; t=0; v(2)=0; v(1)=0; vo=v/3; text(12.42,7.5,5,'¡Has encestado!')
                    end
                else
                    r=[12.42,7.5,3.02]; ro=r; t=0; v(2)=0; v(1)=0; vo=v/3; text(12.42,7.5,5,'¡Has encestado!')
                end
            end
            
            if r(3)<Radbol && abs(v(3))<.05, r(3)=Radbol; ro=r; t=0; v(3)=0; vo=v; end %Corrección últimos rebotes
            
            if rebotes>=20, break, end
            
            if kill==1; break, end
            
        end
    end

    function[r,v]=movimiento(t,ro,vo,caso,b,vaire)
        switch caso
            case 'g'
                r=ro+vo*t+g/2*t^2;
                v=vo+g*t;
            case 'gr'
                ast=-g;
                r=ro+(ast/b+vo)/b*(1-exp(-b*t))-ast/b*t;
                v=(ast/b+vo)*exp(-b*t)-ast/b;
            case 'grv'
                ast=-g-pi*Radbol^2/Mbol*(1/2*1.223*norm(vaire)/2)*vaire; %Fuerza empuje del aire: F=Área_de_ataque*Presión; P=cte*Rho(aire)*v(aire)^2/2 en dirección de v; cte=1/2 para esferas
                r=ro+(ast/b+vo)/b*(1-exp(-b*t))-ast/b*t;
                v=(ast/b+vo)*exp(-b*t)-ast/b;
        end
    end

    function dibuja_pista
        
        %Suelo
        
        surf([0,14;0,14],[0,15;0,15]',zeros(2),col([2,2],.8,.8,1));
        
        %Palo y tablero
        
        [z,a]=meshgrid([0,2.9],linspace(0,2*pi,30));
        surf(14*ones(size(a))+.075*cos(a),7.5*ones(size(a))+.075*sin(a),z,col(size(a),0,0,0)) %palo
        surf([12.8,12.8],[6.6,8.4],[3.9,2.9;3.9,2.9],col([2,2],.7,.8,.8)) %tablero
        plot3([12.8,14,12.8],[6.6,7.5,8.4],[3.9,2.6,3.9],'k',...
            [12.8,14,12.8],[6.6,7.5,8.4],[2.9,2.6,2.9],'k','LineWidth',3) %palos sujeción
        plot3([12.8,12.8,12.8,12.8,12.8],[7.205,7.205,7.795,7.795,7.205],[3.05,3.5,3.5,3.05,3.05],'k-','LineWidth',1) %recuadro pequeño
        
        %Aro
        
        a=linspace(-pi/2,pi/2,180);
        plot3([12.42+Radaro*cos(a)],[7.5+Radaro*sin(a)],[3.05*ones(size(a))],'k-',...
            [12.42-Radaro*cos(a)],[7.5+Radaro*sin(a)],[3.05*ones(size(a))],'k-',... %aro
            [12.42-Radaro*cosd(150),12.8],[7.5+Radaro*sind(150),7.5+Radaro*sind(150)],[3.05,3.05],'k',...
            [12.42-Radaro*cosd(210),12.8],[7.5+Radaro*sind(210),7.5+Radaro*sind(210)],[3.05,3.05],'k','LineWidth',1.5) %palitos
        aa=linspace(0,2*pi,20); aa=[aa,aa(2)];
        for i=1:length(aa)-2
            plot3([12.42+Radaro*cos(aa(i)),12.42+Radaro/2*cos(aa(i+1)),12.42+Radaro*cos(aa(i+2))],...
                [7.5+Radaro*sin(aa(i)),7.5+Radaro/2*sin(aa(i+1)),7.5+Radaro*sin(aa(i+2))],...
                [3.05,3.05-2*Radaro,3.05],'k-','LineWidth',.3,'Color',[.6,.6,.5]) %red
        end
        
        %Lineas
        
        plot3([14,8.2,8.2,14],[5.4,6.6,8.4,9.6],[0,0,0,0],'k-',...
            [8.2+.9*cos(a)],[7.5+.9*sin(a)],[zeros(size(a))],'k-',...
            [8.2-.9*cos(a)],[7.5+.9*sin(a)],[zeros(size(a))],'k-',... %área
            [1.8*cos(a)],[7.5+1.8*sin(a)],[zeros(size(a))],'k-',...
            [.61*cos(a)],[7.5+.61*sin(a)],[zeros(size(a))],'k-',... %mediocampo
            [12.8-6.25*cos(a)],[7.5+6.25*sin(a)],[zeros(size(a))],'k',...
            [12.8,14],[13.75,13.75],[0,0],'k',[12.8,14],[1.25,1.25],[0,0],'k',... %línea triple
            'LineWidth',1)
        
        %Axes
        
        axis equal; axis([0,14,0,15,0,5]); ax.Box='on'; grid off; axis off
        
    end

    function[c]=col(d,r,g,b) %Función que genera matrices de dimensiones d de tripletas de valores r g b
        c(d(1),d(2))=0; c(:,:,1)=r; c(:,:,2)=g; c(:,:,3)=b;
    end

end