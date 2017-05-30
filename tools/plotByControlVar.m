function plotByControlVar(x1, x2, ctrl, col1, col2, desc1, desc2, xdesc, plotErrBars)
p = [];
w = unique(ctrl);
for n = w
    x = x1(ctrl == n);
    p(n,1) = mean(x); p(n,2) = std(x);
    x = x2(ctrl == n);
    p(n,3) = mean(x); p(n,4) = std(x);
end
plot(w-0.1,p(w,1),'r'); hold on; 
plot(w+0.1,p(w,3),'b');
sd = '';
if plotErrBars
    errorbar(w-0.1, p(w,1), p(w,2), [col1 'x'])
    errorbar(w+0.1, p(w,3), p(w,4), [col2 'x'])
    sd = ' +/- 1 s.d.';
end
legend(desc1,desc2);
xlabel(xdesc)
ylabel(['Accuracy: mean' sd]);
grid minor
end