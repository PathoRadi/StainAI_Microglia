function data1=reverse_bw(data1)
imbackground=true(size(data1.im0,1),size(data1.im0,2));
data1.imbackground=imbackground;
data1.im0gray = 255-rgb2gray(data1.im0);



