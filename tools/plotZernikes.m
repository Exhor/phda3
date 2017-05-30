clear all
d = 15;
x = 680*2;
close all
hold on
tt = tt_setup(d, x);
colormap jet

w = [81 34 7]
n = length(w)

for i = 1:n
    k = reshape(abs(tt.zerPolys(:,w(i))),x,x);
    kkmod(x*i-x+1:x*i,1:x) = k;
    k = reshape(angle(tt.zerPolys(:,w(i))),x,x);
    kkarg(x*i-x+1:x*i,1:x) = k;
end
subplot(1,2,1)
image(kkmod,'CDataMapping','scaled')
set(gca,'xtick',[]);set(gca,'xticklabel',[]);set(gca,'ytick',[]);set(gca,'yticklabel',[])
axis equal
subplot(1,2,2)
image(kkarg,'CDataMapping','scaled')
set(gca,'xtick',[]);set(gca,'xticklabel',[]);set(gca,'ytick',[]);set(gca,'yticklabel',[])
axis equal
% plot([1 6*x],[x x],'g')
% for i = 1:n-1
%     plot([i*x i*x],[1 2*x],'g')
% end

m = [];
for xx = 1:x; 
    for yy = 1:x
        if (xx-x/2)^2+(yy-x/2)^2 > x^2/4
            m = [m; xx yy];
        end
    end
end

% for c = 1:2
% subplot(1,2,c)
% for i = 1:n
%     cy = i*x-x/2;
%     cx = x/2;
%     plot(cx - x/2 + m(:,1), cy - x/2 + m(:,2), 'w.')        
% end
% end
