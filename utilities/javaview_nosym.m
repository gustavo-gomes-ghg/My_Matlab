function javaview_nosym(surface_handle, filename, destination, source, open_html )
% Syntax: 
%    javaview_nosym(surface_handle, filename, destination, source, open_html) 
% 
% Description:
%    This function generates output files for Javaview (www.javaview.de).
%    It allows to display and interact with 3d-Graph not only in the
%    javaview engine, but also in html-Documents. See javaview
%    documentation for more information about how to interact.
% 
%    This function depends of the installed toolboxes. If the Symbolic Math Tooolbox (SMT) is installed, the html is
%    exported half automatically/ half manually. If the SMT is not installed the function will open the
%    generated stl file in JavaView and you must modify the result manually (see without_mupad.pdf for further
%    information) and export it to html. Don't forget to have your jars-directory in the html-file.
%
%    With SMT there are 4 output files:
%        a) first file (.stl)is generated by the surf2stl function (Many
%           thanks to Bill McDonald, this function is availabe at the MCFE
%           and was pick of the week on June 5th, 2009)  
%        b) the second and third file (jvx) and (jvd) are input files for
%           javaview and are generated by mupad. The jvx-file describes the
%           3d-graph, the jvd file descrribes scene options
%        c) the last file is an html file, were the 3d-Graph is displayed
% 
%   Because the applet in html file need the javaruntime for javaview the
%   jars directory from the "source" (input parameter) directory is copied
%   to the destination folder.
%   open_html is true or false. When it is true your standard webbrowser is
%   opened and you will see the surface in the html file. 
% 
%   Parameter:
%       1. surface_handle - handle to surface graph
%       2. filename       - filename for *.stl, .jvx, *.jvd, *.html
%       3. destination    - folder where all files are saved
%       4. source         - source folder of jars (see jvaview installation path)
%       5. open_html      - shows the result html in your standard webbrowser
% 
%  Sorry for the work around with the handmade copy and paste when to 
%  generate the javaview files with SMT. But evalin(symengine, ...) does not produce
%  the required files.
% 
% Online Example: 
%       http://wwwpub.zih.tu-dresden.de/~s9034647/peaksurface.html
%       http://wwwpub.zih.tu-dresden.de/~s9034647/test.html
%
% Example:
%         su=2*pi/150;
%         sv=2*pi/20;
%         [u,v]=meshgrid(0:su:(2*pi),0:sv:(2*pi));
%         r1=2;
%         r2=0.4;
%         r3=0.3;
%         p1=2;
%         p2=3;
%         x=r1*cos(u*p1) + r2*cos(u*p1).*cos(u*p2) +r3*cos(u*p1).*sin(v);
%         y=r1*sin(u*p1) + r2*sin(u*p1).*cos(u*p2) +r3*sin(u*p1).*sin(v);
%         z=r2*sin(u*p2)+r3*cos(v);
%         h=surf(x,y,z);
%         javaview_nosym(h, 'test', 'C:\Users\sk\Desktop\3d-PDF\jvtest', 'C:\Program Files (x86)\JavaView\jars', 1);
%       
% 
% Bugs and suggestions:
%    Please send to Sven Koerner: koerner(underline)sven(add)gmx.de
% 
% You need to download and install first:
%    www.javaview.de 
%    http://blogs.mathworks.com/pick/2009/06/5/writing-to-stl-files/
%    (Symbolic Math Toolbox with MuPad)
% 
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
% Programmed by Sven Koerner: koerner(underline)sven(add)gmx.de
% Date: 2010/04/20 


%% Test - Configuration parameter
% open_html       = 0;
% filename        = 'jvfile';
% source          = 'C:\Program Files (x86)\JavaView\jars';  % source folder of jars (installed with javaview)
% destination     = 'C:\Users\sk\Desktop\3d-PDF\jvtest';     % destination folder


%% Get a couple of surface and axis properties
X               = get(surface_handle, 'XData');
Y               = get(surface_handle, 'YData');
Z               = get(surface_handle, 'ZData');

ah              = get(get(surface_handle,'Parent'));
x_lb            = get(ah.XLabel, 'String');
y_lb            = get(ah.YLabel, 'String');
z_lb            = get(ah.ZLabel, 'String');
header          = get(ah.Title,  'String');


%% Generate stl-File
stl_file        = [destination '\' filename '.stl'];
surf2stl(stl_file,X,Y,Z,'ascii');

% Test for Symbolic Math Toolbox
tb = ver('Symbolic');

if isempty(tb) 
    winopen(stl_file);   % Open the JavaView with the generated graph 
    
    % Now: Read the without_mupad.pdf for further Information
    
else % The symbolic Math Toolbox installed
    
    %% String generation
    p1              =  strrep(stl_file,'\','\\');
    p2              =  [filename,'.jvx'];
    p3              =  [filename,'.jvd'];
    
    mupad_str1 = ['plot(plot::SurfaceSTL("' p1 ' "), Scaling = Unconstrained, FillColorType=Rainbow, XLinesVisible = FALSE, YLinesVisible = FALSE,MeshVisible = FALSE, Header="' header ...
        '", XAxisTitle=" ' x_lb '", YAxisTitle=" ' y_lb '",  ZAxisTitle="' z_lb '", GridVisible=FALSE, Lighting = None, OutputFile="' p2 '")'];
    mupad_str2 = ['plot(plot::SurfaceSTL("' p1 ' "), Scaling = Unconstrained, FillColorType=Rainbow, XLinesVisible = FALSE, YLinesVisible = FALSE,MeshVisible = FALSE, Header="' header ...
        '", XAxisTitle=" ' x_lb '", YAxisTitle=" ' y_lb '",  ZAxisTitle="' z_lb '", GridVisible=FALSE, Lighting = None, OutputFile="' p3 '")'];
    
    
    %% MUPAD
    clipboard('copy',[mupad_str1 ': ' mupad_str2]);
    mpnb = mupad;
    
    %% now a strange workaround
    % evalin(symengine,mupad_str1);  % --> actually this doesn't work
    % evalin(symengine,mupad_str2);  % --> actually this doesn't work
    clc;
    reply = input('please press "strg-v" in open mupad notebook after the [-bracket (the text need to be red in mupad nb)! Then press first enter in mupad and then any key in matlab prompt here! ', 's');
    try
        movefile([cd '\' filename '.jvd'], destination);
        movefile([cd '\' filename '.jvx'], destination);
    catch
        disp('Have you really pasted the clipboard to mupad and press enter? - Try again')
    end;
    close(mpnb);
    
    
    %% Generate html-File
    fid         =   fopen([destination '\' filename '.html' ], 'w');
    html_str    =   {'<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>';
        '<html>';
        '<head>';
        '<meta generator="JavaView v.3.95.001"/>';
        '<meta date="Fri Sep 15 20:45:51 CEST 1978"/>';
        ['<title>' filename '.jvx</title>'];
        '</head>';
        '<body>';
        ['<h2> Applet shows ' filename  '.jvx (select a point with "h")</h2>'];
        '<applet height="512" archive="jars/javaview.jar" width="640" code="javaview.class">';
        %'<applet height="512" archive="http://www.javaview.de/demo/jars/javaview.jar" width="640" code="http://www.javaview.de/demo/javaview.class">';
        ['<param name=model value=" ' filename '.jvx">'];
        ['<param name=displayFile value=" ' filename '.jvd">'];
        '<param name=panel value="material">';
        '</applet>';
        '</body>';
        '</html>'};
    for i=1:1:size(html_str,1)
        fprintf(fid, char(html_str(i,1)));
    end;
    
    fclose(fid);
    
    %% Copy source for applet
    copyfile(source, [destination '\jars'] );
    
    
    %% open the html result in standard html-viewer (e.g. ie)
    if open_html
        winopen([destination '\' filename '.html' ]);
    end;
    
end;



