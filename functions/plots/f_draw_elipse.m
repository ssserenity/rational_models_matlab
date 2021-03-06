function [ma stda mb stdb] = f_draw_elipse(vetA, vetB, realA, realB)
%% Plots a elipse with 95% of confiability based on data in vetA and vetB
% vetA:: data vector of variable A
% vetB:: data vector of variable B
%%
if max(size(vetA)) <= 1 || max(size(vetB)) <= 1
    warning('To plot something you must pass some array, not just a value ;)');
    return
end

mark_size=8;
figure;

[N, M]=size(vetA);
if M > N
	PN=[vetA', vetB'];
else
	PN=[vetA, vetB];
end
ma=mean(vetA);
mb=mean(vetB);
stda=std(vetA);
stdb=std(vetB);


% from here is only to plot the estimated points
plot(vetA, vetB, 'bo');
hold;
plot(ma, mb, 'kp', 'MarkerSize',mark_size, 'MarkerFaceColor', 'k');
hold;
if realA ~= 0 && realB ~= 0
	hold;
    plot(realA, realB, 'ks', 'MarkerSize',mark_size, 'MarkerFaceColor', 'k');
end
title('Estimativa dos parametros para o sistema BJ', 'FontSize',11)
xlabel('Estimativa \theta_1', 'FontSize',11)
ylabel('Estimativa \theta_2', 'FontSize',11)
legend('Estimativas', 'Media', 'real')

% chi^2 for 95% of confiability
chi = 5.991;
ang = linspace(0,2*pi,360)';
[avetor,SCR,avl] = princomp(PN);
Diagonal= diag(sqrt(chi*avl));
elipse=[cos(ang) sin(ang)] * Diagonal * avetor' + repmat(mean(PN), 360, 1);
line(elipse(:,1), elipse(:,2), 'linestyle', '-', 'color', 'k');
end
