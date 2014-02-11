function funIDRnpFile(fIn,fOut,binSize,poolType)

% fIn  = file with Nelements rows and 2 columns of signals for each element in two replicas
% fOut = output file with per element IDR 
% binSize = size of the bins: =1 for discrete signals
% poolType =1 for sum, =2 for max

% load per element signals
s=load(fIn);

% maxS = maximum signal for iIDR calculation
maxS=max(s(:));

binC=(0:binSize:maxS)';
for ir=1:2
    countR(:,1,ir)=hist(s(:,ir),binC); % count elements that have certain signal level in each replica
    countR(:,2,ir)=hist(s(s(:,3-ir)==0,ir),binC); % count elements that have certain signal level in each replica and are 0 in the other replica
end

% npIDR vs signal level
npIDR=squeeze(sum(countR(:,2,:),3)./sum(countR(:,1,:),3)); % average npIDR
npIDR(isnan(npIDR))=0;

if poolType==1
    sPool=sum(s,2);
elseif poolType==2
    sPool=max(s,[],2);
end

Nelem=hist(sPool,binC(1:50))';
Nelem=cumsum(Nelem(end:-1:1));
Nelem=Nelem(end:-1:1);
fprintf(1,'Signal:\tnpIDR:\tNumber of elements:\n')
fprintf(1,'%g\t%7.5f\t%i\n',[binC(1:50) npIDR(1:50) Nelem]');

% npIDR per element
npIDRelement=zeros(size(s,1),1);
npIDRelement(sPool<binC(end))=npIDR(floor(sPool(sPool<binC(end))/binSize+0.5)+1);

fo1=fopen(fOut,'w');
fprintf(fo1,'%5.3f\n',npIDRelement);
fclose(fo1);





