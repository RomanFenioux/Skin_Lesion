% close all
absc=(1:50);
etaThreshold=0.7;
diceSelected = diceList(etaList>etaThreshold);
absSelec = absc(etaList>etaThreshold);
diceRejected = diceList(etaList<etaThreshold);
absRejec = absc(etaList<etaThreshold);
etaSelected = etaList(etaList>etaThreshold);
etaRejected = etaList(etaList<etaThreshold);
figure(21);
plot(absSelec,diceSelected,'s','Color','red')
hold on
plot(absRejec,diceRejected,'s','Color','k')
plot(absSelec,etaSelected,'*','Color', 'green')
plot(absRejec,etaRejected,'*','Color', 'k')
plot(get(gca,'xlim'),[etaThreshold,etaThreshold],'--k'); 
hold off
title('dice index and separability measure eta')
legend('dice (accepted)','dice (rejected)','eta (accepted','eta (rejected)','Location','SouthWest')
% 
% figure;
% plot(diceSelected2,'-s','Color','red')
% hold on
% plot(etaSelected2,'-o','Color', 'green')
% hold off
% axis([0 numel(diceSelected)+1 0 1])
% title(sprintf('Channel %s - Dice and jaccard indices : d = %g, j = %g',channel,mean(diceList),mean(jaccardList)))
% legend('dice','eta','Location','SouthWest')


dmin_etadrop=[];
dSelect_etadrop=diceList;
numSelect=[];
etaSelect=etaList;
etaThreshList=[];
for i=1:numel(diceList)
    dmin_etadrop=[dmin_etadrop, min(dSelect_etadrop)];
    numSelect=[numSelect, numel(dSelect_etadrop)];
    [etamin,idmin]=min(etaSelect(:));
    dSelect_etadrop=diceList(etaList>etamin); 
    etaThreshList=[etaThreshList,etamin];
    etaSelect=[etaSelect(1:idmin-1);etaSelect( idmin+1:end)];
end

dmin_ddrop=[]; % list of the worst dice
dSelect_ddrop=diceList; % selected dices
numSelect=[]; % how many are selected
for i=1:numel(diceList)
    numSelect=[numSelect, numel(dSelect_ddrop)];
    dmin_ddrop=[dmin_ddrop, min(dSelect_ddrop)];
    [dmin,imin]=min(dSelect_ddrop(:));
    dSelect_ddrop=[dSelect_ddrop(1:imin-1); dSelect_ddrop(imin+1:end)];
end

% absc=100*(1:numel(diceList))/numel(diceList);
% F=figure(3);
% plot(absc,dmin_etadrop,'-or')
% hold on
% plot(absc,dmin_ddrop,'-ob')
% plot([0 46.5], [0.7 0.7],'--k'); 
% plot([46.5,46.5],[0.1,0.7],'--r'); 
% plot([18,18],[0.1,0.7],'--b'); 
% title('Worst performance when dropping worst dice or worst eta')
% xlabel('Rejection rate, %')
% ylabel('Lowest dice')
% 

%5 50% acception rate

