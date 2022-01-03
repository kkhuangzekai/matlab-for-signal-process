x=imread("default.jpg")

x=rgb2gray(x);%将数值矩阵X转换为灰度图像
Lh=length(h0);  %y00*2.5是为了提高这部分的亮度
Lx=length(x);
PCA(x)