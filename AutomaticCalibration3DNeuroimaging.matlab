
%ACQUIRE & STORE IMAGES

%makes this folder/path if it doesn't exist 
%"C:/Micro-Manager-1.4/insert-folder-name-here/" -> EX: 'C:/Micro-Manager-1.4/imagesKiana/''
savePath = '/Applications/Micro-Manager1.4/imagesKiana/';
if -exist (savePath, 'dir')
  else mkdir (savePath)
end

%Create a java object of class MMCcore 
import mmcorej.*;
mmc = CMMCore;
%Load configuration file
mmc.loadSystemConfiguration ('/Applications/Micro-Manager1.4/MMConfig_demo.cfg');

% Initialize Devices
mmc.initializeAllDevices();


%Z LOOP 

z_start = 0;
increment_value = 2;
z_max = 500;

%ZZ = vector -> stored these values in a vector
zz = z_start :   increment_value  : z_max;

%z-stack of images
%n = 1920 for OpenCVGrabber as tested by Mac 
%n = 2048 for Andor camera 
n=1920;
m = length(zz);
z_stack = zeros(n,n,m);

%length tells you how many elements are in that vector -> gonna go through all the values in the vector
for i = 1 : length(zz)
      
  %zz(i) = indexing through the vector 
  mmc.setPosition("ZStage", zz(i));
  %makes sure everything has stopped moving
  mmc.waitForSystem();
  %takes image acquisition
  mmc.snapImage();
  %gets image acquired from snapImage
  img=mmc.getImage();
  %z_stack (:, :, i) = stores image here.  -> first dimension : = rows,   second dimension :  = columns, i = index value 
  %reshape (img, n, n) = reshapes image into n x n dimensions
  z_stack (:, :, i) = reshape (img, n, n);
  
end

%saves position and image to the savePath (folder/directory) -> 'z_stack.mat' = name of this file
%[savePath 'z_stack.mat'] = concatination 
%save position (zz), save image (z_stack)
save([savePath 'z_stack.mat'], 'zz', 'z_stack', '-v7.3', '-nocompression')



%VIDEO TO DISPLAY IMAGES
%make a video with title of position, stop video and can see the image and its position (which is gonna be the title)


%how to start any video file
%savePath = folder where video while be stored/saved
%s_stack.avi = name
vidObj = VideoWriter ([savePath 'z_stack.avi']);
%5 frames per second 
vidObj.FrameRate = 5;
%opens video object
open(vidObj);

%object for the figure displayed (figure = window where video will be displayed, window where you can make plots)
h = figure;
%800 x 400 = width x height for window to display figures 
h.Position = [ 100 100 800 400];

%for loop for Z- -> at every loop you're adding a new frame to the video
for i = 1 : length(zz)
  %taking this slice out of the stack and displaying it as an image
  imagesc (z_stack (:, :, i));
  %gives each image the title of its position zz(i)
  title (['z= ' num2str(zz(i))]);
  %default color scaling bar
  colorbar; 
  % sets Font size
  set(gca, 'FontSize', 20);
  %saves each frame to the file (currFrame = what is in the figure window -> image and the title)
  currFrame = getframe(h);
  %adds this currFrame to the end of the vidObj
  writeVideo(vidObj, currFrame)
end 

%close video object
close(vidObj);
%close the figure (the figure is the window)
close(h)





