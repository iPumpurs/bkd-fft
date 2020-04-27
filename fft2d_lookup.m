clear all
close all

f = imread('vwdrive.jpg');
f = im2double(f);

figure(1); imshow(f, []);
hold on;

axis equal
axis manual
rect = imrect('PositionConstraintFcn', @(x) [x(1) x(2) min(x(3),x(4))*[1 1]]);

p = getPosition(rect);
x = p(1,1);
y = p(1,2);
w = p(1,3);
h = p(1,4);

f_cut = rgb2gray(f(y+1:y+h, x+1:x+w, :));
    N=length(f_cut);

f_cut = f_cut - mean(f_cut(:));
    
w12=hann(N)';
f_cut_win=(f_cut.*w12).*w12';
%figure, imshow(f_cut_win,[]);

f_cut_fft = fft2(f_cut_win);
log_f_cut = log(1+abs(fftshift(f_cut_fft)));
    log_f_cut = log_f_cut - min(log_f_cut(:));
    log_f_cut = log_f_cut / max(log_f_cut(:));

theta=[0:180];
[f_cut_rad,xp]=radon(log_f_cut,theta);
figure;
f_cut_rad = f_cut_rad - min(f_cut_rad(:));
f_cut_rad = f_cut_rad / max(f_cut_rad(:));
imshow(f_cut_rad, [],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
axis normal
xlabel('\theta (degrees)')
ylabel('L')

prompt = 'izpluduma lenkis: ';
lenkis = input(prompt);
    if lenkis == 0
        lenkis = 1;
    elseif lenkis == 45
        lenkis = lenkis + 1;
    end

gar=(-length(f_cut_rad)-1)/2:(length(f_cut_rad)-1)/2-1;
likne=f_cut_rad(:,lenkis);
polf=polyfit(gar,likne',2);
polv=polyval(polf,gar);
likne=likne-polv;

figure('Name', 'Radona transformacijas likne kustibas izpludumam'),
plot(gar,likne,'LineWidth', 1.25)
    xlim([-(length(f_cut_rad)-1)/2 (length(f_cut_rad)-1)/2])
    xticks([-(length(f_cut_rad)-1)/2 0 (length(f_cut_rad)-1)/2])
    grid on, grid minor
    %ylim([0 1.1])
    xlabel(['pixels']), ylabel('Amplitude')
    
    
N=length((f_cut_rad(:,lenkis)));
F=fft(f_cut_rad(:,lenkis));
    F=F-min(F);
    F=F/max(F);
Fr=(-N/2:N/2-1)*length(f_cut(:,1))/N;
figure('Name', 'FFT of RT'),
    plot(Fr-Fr(round(N/2)),abs(fftshift(F)),'LineWidth',1.25)
    ylim([0 1.1])
    grid on, grid minor
    xlabel(['pixels']), ylabel('Amplitude')


% SUBPLOTS KOPIGAM SKATAM:
subplot1=figure;
set(subplot1, 'Name', 'All images together');

subplot(2,2,[1,3]);
    imshow(f, []);
    title('Sample image')
    
subplot(2,2,2)
    imshow(f_cut, []);
    title('Cut-out of sample')
    
subplot(2,2,4);
    imshow(log_f_cut, []);
    title('First log-spectrum of cut-out');


    
