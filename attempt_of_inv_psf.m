%%--------------------------------
% Blur convolution example with FFT images
%%--------------------------------

clear all
close all

%% Original Image
f = imread('f1_car.jpg');
f = im2double(f);

figure; imshow(f, []);

[xes, yes] = size(squeeze(f(:,:,1)));

xc = xes(1)/2+128;
yc = yes(1)/2-128;

%halfside = max(abs(xes(2)-xc), abs(yes(2)-yc));
halfside = 96;     % iegust (izgriez) apgabalu, kura veiks FFT


f_cut = rgb2gray(f(yc-halfside+1:yc+halfside, xc-halfside+1:xc+halfside, :));
%figure;
    %imshow(f_cut, []);
    N=length(f_cut);
    
w12=hann(N)';

f_cut_win=(f_cut.*w12).*w12';

f_cut_fft = fft2(f_cut_win);
log_f_cut = log(1+abs(fftshift(f_cut_fft)));
    
%% PSF
h = imread('deg30.jpg');		% PSF filename
%h = imresize(h,0.5);
h = im2double(h);

[hxes, hyes] = size(squeeze(h(:,:,1)));
hxc = hxes(1)/2;
hyc = hyes(1)/2;

%h_cut = rgb2gray(h(hyc-halfside/2+1:hyc+halfside/2, hxc-halfside/2+1:hxc+halfside/2, :));
h_cut=rgb2gray(h(1:hyes(1),1:hxes(1),:));
    N_h=length(h_cut);
    
w12=hann(N_h)';

h_cut_win=(h_cut.*w12).*w12';

h_cut_fft = fft2(h_cut_win);
log_h_cut = log(0.25+abs(fftshift(h_cut_fft)));

%% CONVOLUTED IMAGE
% Specify distortion parameters:
number_of_quantization_levels = 2^16;
noise_energy = 0.0; % use range 0 to 1

h = (h(:,:,1) + h(:,:,2) + h(:,:,3)) / 3;
yhc = ceil(size(h,1)/2);
xhc = ceil(size(h,2)/2);

g = zeros(size(f));
g(:,:,1) = imfilter(f(:,:,1), h, 'replicate');
g(:,:,2) = imfilter(f(:,:,2), h, 'replicate');
g(:,:,3) = imfilter(f(:,:,3), h, 'replicate');

% Applying some quantization noise and white noise:
g = g - min(min(min(g)));
g = g / max(max(max(g)));
g = round(g * (number_of_quantization_levels - 1)) / (number_of_quantization_levels - 1);
g = g + randn(size(g)) * noise_energy;


bb = add_mask_to_image(g, []);
figure; imshow(bb, []);

b_cut = rgb2gray(bb(yc-halfside+1:yc+halfside, xc-halfside+1:xc+halfside, :));
    N_b=length(b_cut);
    
w12=hann(N_b)';

b_cut_win=(b_cut.*w12).*w12';

b_cut_fft = fft2(b_cut_win);
log_b_cut = log(0.01+abs(fftshift(b_cut_fft)));

theta=[0:180];
[b_cut_rad,xp]=radon(log_b_cut,theta);
figure;
b_cut_rad = b_cut_rad - min(b_cut_rad(:));
b_cut_rad = b_cut_rad / max(b_cut_rad(:));
imshow(b_cut_rad, [],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
xlabel('\theta (degrees)')
ylabel('x''')

%% ALL IMAGES TOGETHER

subplot3=figure;
set(subplot3, 'Name', 'Images and their FFTs');
set(subplot3, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

subplot(2,3,1);
    imshow(f_cut, []);
    title('Sample image')
    
subplot(2,3,4);
    imshow(log_f_cut, []);

subplot(2,3,2);
    imshow(h_cut, []);
    title('Sample PSF')
    
subplot(2,3,5);
    imshow(log_h_cut, []);
    
subplot(2,3,3);
    imshow(b_cut,[]);
    title('Final image')
    
subplot(2,3,6);
    imshow(log_b_cut, []);
    
%% Test to see whether inverting PSF and convoluting it with blurred image will do anything    
h = imread('deg30.jpg');
h = im2double(h);

[hxes, hyes] = size(squeeze(h(:,:,1)));
hxc = hxes(1)/2;
hyc = hyes(1)/2;

%h_cut = rgb2gray(h(hyc-halfside/2+1:hyc+halfside/2, hxc-halfside/2+1:hxc+halfside/2, :));
h_cut=rgb2gray(h(1:hyes(1),1:hxes(1),:));
    N_h=length(h_cut);
    
w12=hann(N_h)';

h_cut_win=(h_cut.*w12).*w12';

h_cut_fft = fft2(h_cut_win);
log_h_cut = log(0.25+abs(fftshift(h_cut_fft)));

f = bb;
%f = imcomplement(f);

[xes, yes] = size(squeeze(f(:,:,1)));

xc = xes(1)/2+128;
yc = yes(1)/2-128;

f_cut = rgb2gray(f(yc-halfside+1:yc+halfside, xc-halfside+1:xc+halfside, :));
%figure;
    %imshow(f_cut, []);
    N=length(f_cut);
    
w12=hann(N)';

f_cut_win=(f_cut.*w12).*w12';

f_cut_fft = fft2(f_cut_win);
log_f_cut = log(1+abs(fftshift(f_cut_fft)));

number_of_quantization_levels = 2^16;
noise_energy = 0.0; % use range 0 to 1

h = (h(:,:,1) + h(:,:,2) + h(:,:,3)) / 3;
yhc = ceil(size(h,1)/2);
xhc = ceil(size(h,2)/2);

g = zeros(size(f));
g(:,:,1) = imfilter(f(:,:,1), h, 'replicate');
g(:,:,2) = imfilter(f(:,:,2), h, 'replicate');
g(:,:,3) = imfilter(f(:,:,3), h, 'replicate');

% Applying some quantization noise and white noise:
g = g - min(min(min(g)));
g = g / max(max(max(g)));
g = round(g * (number_of_quantization_levels - 1)) / (number_of_quantization_levels - 1);
g = g + randn(size(g)) * noise_energy;

bb = add_mask_to_image(g, []);
figure; imshow(bb, []);

b_cut = rgb2gray(bb(yc-halfside+1:yc+halfside, xc-halfside+1:xc+halfside, :));
    N_b=length(b_cut);
    
w12=hann(N_b)';

b_cut_win=(b_cut.*w12).*w12';

b_cut_fft = fft2(b_cut_win);
log_b_cut = log(0.01+abs(fftshift(b_cut_fft)));

subplot4=figure;
set(subplot4, 'Name', 'Images and their FFTs');
set(subplot4, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

subplot(2,3,1);
    imshow(f_cut, []);
    title('Sample image')
    
subplot(2,3,4);
    imshow(log_f_cut, []);

subplot(2,3,2);
    imshow(h_cut, []);
    title('Sample PSF')
    
subplot(2,3,5);
    imshow(log_h_cut, []);
    
subplot(2,3,3);
    imshow(b_cut,[]);
    title('Final image')
    
subplot(2,3,6);
    imshow(log_b_cut, []);

