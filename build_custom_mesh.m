%
% Made by Henrique B. de Souza
% This file contains an example script of how to build a model and mesh
%
 


%Make an empty model
model=createpde;

% Geometry settings
ScaleFactor=1e-2; %centimeters
L=30; %Container length
W=3/2; %Container Radius
Ws=1.75/2; %Container Inner radius
x_refrigerant=0;

%THE CONTAINER IS DEFINED HERE
container.dimensions=[L,W;L,Ws];
% container.dimensions=[L,W];
container.centered = true;
container.axis=[0,1,0];
container.angle=90;

%Function that adds the tube to the model
addTube(model,container,ScaleFactor);

%Cuboid refrigerant
refrigerant.dimensions=[10,1.7,.05];
refrigerant.centered=true; %x_refrigerant=0

%Function that adds the refrigerant to the model
addCuboidRefrigerant(model,refrigerant,ScaleFactor);

max_element_size=0; %Let matlab do its defaults
generateMesh(model,"GeometricOrder","quadratic",Hmax=max_element_size*sketch.ScaleFactor);

save("Mesh/custom_model.mat")

function addTube(model,settings,ScaleFactor)
    %Create the container
    g1 = multicylinder(settings.dimensions(:,2),settings.dimensions(:,1));
    
    %Scale and rotate the container according to settings
    g1=scale(g1,ScaleFactor);
    rotate(g1,settings.angle,[0,0,0],settings.axis);

    %Center the container
    bb = boundingBox(g1);
    currentCenter = mean(bb, 2);
    desiredCenter = [0;0;0];
    translation = desiredCenter - currentCenter;
    g1 = translate(g1, translation);

    %Add container to model
    model.Geometry = g1;
end

function addCuboidRefrigerant(model,settings,ScaleFactor)
    g1 = multicuboid(settings.dimensions(1),settings.dimensions(2),settings.dimensions(3));
    g1 = scale(g1,ScaleFactor);

    % Move to desired position
    if ~isfield(settings,'centered') 
        g1 = translate(g1,settings.position*ScaleFactor);
    elseif ~settings.centered
        g1 = translate(g1,settings.position*ScaleFactor);
    elseif settings.centered
        center = mean(g1.Vertices);
        g1 = translate(g1,-center);
    end

    addCell(model.Geometry,g1);
end