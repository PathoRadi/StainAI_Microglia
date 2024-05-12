function data1=none(data1)
imbackground=true(size(data1.im0,1),size(data1.im0,2));
data1.imbackground=imbackground;
data1.im0gray=rgb2gray(data1.im0);


