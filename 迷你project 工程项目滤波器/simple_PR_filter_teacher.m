x=imread("default.jpg")

x=rgb2gray(x);%����ֵ����Xת��Ϊ�Ҷ�ͼ��
Lh=length(h0);  %y00*2.5��Ϊ������ⲿ�ֵ�����
Lx=length(x);
PCA(x)