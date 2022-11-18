function PlotData( Room, Array, Source, Point, Param, AudioField, View)
        
    % Create Sphare to illustrade microphone array
    [Sphere.x, Sphere.y, Sphere.z] = sphere(80);
    Sphere.x = Sphere.x * Array.Radius * 2;
    Sphere.y = Sphere.y * Array.Radius * 2;
    Sphere.z = Sphere.z * Array.Radius * 2;
    
    % Create Sphare to illustrade prohebited area according to
    % Farfield condition
    [AudioField.x, AudioField.y, AudioField.z] = sphere(6);
    
    
    AudioField.x = AudioField.x * (2*AudioField.Radius);
    AudioField.y = AudioField.y * (2*AudioField.Radius);
    AudioField.z = AudioField.z * (2*AudioField.Radius);
    
    % Create line to illustrade microphone array stand
    Stand.x = [Array.x Array.x];
    Stand.y = [Array.y Array.y];
    Stand.z = [0 (Array.z - Array.Radius)];
    
    
    % Create line to illustrade axis according to azimith and elevation
    Axis.label = ['x' 'y' 'z'];
    Axis.x = [0 Room.width;
              Array.x Array.x;
              Array.x Array.x
             ];
    
    Axis.y = [Array.y Array.y;
              0 Room.length;
              Array.y Array.y
              
             ];
    
    Axis.z = [Array.z Array.z;
              Array.z Array.z;
              0 Room.hight
             ];
    
         
    TextOffset = 0.1;    
     
    % figure(Figure);
    hold on;
    grid on; 
    % view([45 34]);
    view(View);
    axis([0 Room.width 0 Room.length 0 Room.hight]);
    xlabel('x (width) [m]', 'Interpreter', 'Latex');
    ylabel('y (length) [m]', 'Interpreter', 'Latex');
    zlabel('z (hight) [m]', 'Interpreter', 'Latex');
    
    % Plot Axis
    for CountAxis = 1:length(Axis.x)
        plot3(Axis.x(CountAxis,:), Axis.y(CountAxis,:), Axis.z(CountAxis,:), '.-', 'Color','black', 'LineWidth', 1);
        text(Axis.x(CountAxis,2)+0.1 ,Axis.y(CountAxis,2) ,Axis.z(CountAxis,2),Axis.label(CountAxis),'FontWeight','bold','FontSize',14, 'Interpreter', 'Latex');
    end
    
    
    % Plot Array
    plot3(Sphere.x + Array.x , Sphere.y + Array.y, Sphere.z + Array.z);
    plot3(Stand.x, Stand.y, Stand.z, 'LineWidth', 2, 'Color','black');
    
    % Plot far-fealt
    %plot3(AudioField.x + Array.x , AudioField.y + Array.y, AudioField.z + Array.z,'Color','red');
    %text(Array.x, Array.y, Array.z+AudioField.Radius+0.09 ,sprintf('Farfeald %i Hz',AudioField.f_min),'EdgeColor','red');

    if (strcmp(Param,'PosOnly'))
        text(Source.Pos(Source.X,Point) + TextOffset,Source.Pos(Source.Y,Point),Source.Pos(Source.Z,Point) + TextOffset ,num2str(Point),'Color','red','FontSize',12,'FontWeight','bold', 'Interpreter', 'Latex');
        plot3(Source.Pos(Source.X,Point),Source.Pos(Source.Y,Point),Source.Pos(Source.Z,Point),...
                    'mo', ...
                    'Color','r' , ...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',[.49 1 .63],...
                    'MarkerSize',10);
                
                
                
    else if (strcmp(Param,'all'))
            
            plot3(Source.PosInterpolated(Source.X,:), Source.PosInterpolated(Source.Y,:), Source.PosInterpolated(Source.Z,:), '.-b');

            for CountPos = 1:Source.NumOfPos
                if(CountPos < Source.NumOfPos)
                    text(Source.Pos(Source.X,CountPos) + TextOffset,Source.Pos(Source.Y,CountPos),Source.Pos(Source.Z,CountPos) + TextOffset ,num2str(CountPos),'Color','red','FontSize',12,'FontWeight','bold', 'Interpreter', 'Latex');
                end
                plot3(Source.Pos(Source.X,CountPos),Source.Pos(Source.Y,CountPos),Source.Pos(Source.Z,CountPos),...
                            'mo', ...
                            'Color','r' , ...
                            'MarkerEdgeColor','k',...
                            'MarkerFaceColor',[.49 1 .63],...
                            'MarkerSize',10);
            end
        end
    end
    
   
    hold off;
end