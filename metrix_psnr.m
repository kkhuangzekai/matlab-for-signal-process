function [metrix_value] = metrix_psnr(reference_image, query_image)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RGB to Gray
 if size(reference_image,3)~=1   % not gray
   org=rgb2gray(reference_image);
   %test=im2gray(query_image);
   test=imread(query_image);
   reference_image=org;
   query_image=test;
   reference_image=double(reference_image);  % uint8 to double
   query_image=double(query_image);
 else              % is gray
     reference_image=double(reference_image);
     query_image=double(query_image);
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mse_value = metrix_mse( reference_image, query_image );
metrix_value = 10*log10( 255*255 / mse_value );  %信噪比用分贝表示，越高越好

end