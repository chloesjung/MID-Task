
% MID5
    % Cohort1-rasterplotMIDC1
    
%%
clear
clc
%%
foldername='/Users/jung/Documents/MATLAB/MID/2019-04-01';
cd(foldername)

fileNames=dir('*.txt');

format long g

Rewards = [];
TotalPokes = [];
A = [];
LOPLatencies= {};
C = [];
CorrectNP = [];

%titles = {'M1'};
%titles = {'F1','F2','M1', 'M4'};
titles = {'F1','F2','M1', 'M2', 'M3', 'M4'};
%titles = {'F1','F2', 'M1', 'M4'};
txt = {'04-01'};

tic
for fileName=1:length(fileNames)
    
    SerialOutput=fileNames(fileName).name;
    fileID=fopen(SerialOutput);
    c=textscan(fileID,'%s','Delimiter','\n'); %%Looks for strings
    %Only delimiter is newline charcter (default also includes whitespace)
    fclose(fileID);
    %format events file
    c=c{1};
       
    PokeSerial=c(contains(c,'RPoke '));
    LickSerial=c(contains(c,'Lick '));
    LightOnSerial=c(contains(c,'On '));
    LightOffSerial=c(contains(c,'Off '));
    RewardSerial=c(contains(c,'Reward '));
    TrialSerial=c(contains(c,'Trial: '));
    
    test = regexp(PokeSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
    PokeTimestamps=cellfun(@cell2mat,test,'UniformOutput',0); %converts cell of cells into matrix of timestamps
    PokeTimestamps=str2double(PokeTimestamps)/1e3;
%     test = regexp(LickSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
%     LickSerialTimestamps=cellfun(@cell2mat,test,'UniformOutput',0); %converts cell of cells into matrix of timestamps
%     LickSerialTimestamps=str2double(LickSerialTimestamps)/1e3;
    test = regexp(LightOnSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
    LightOnTimestamps=cellfun(@cell2mat,test,'UniformOutput',0); %converts cell of cells into matrix of timestamps
    LightOnTimestamps=str2double(LightOnTimestamps)/1e3; %Gets rid of trial number in output message
    test = regexp(LightOffSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
    LightOffTimestamps=cellfun(@cell2mat,test,'UniformOutput',0); %converts cell of cells into matrix of timestamps
    LightOffTimestamps=str2double(LightOffTimestamps)/1e3; %Gets rid of trial number in output message
    test = regexp(RewardSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
    RewardTimestamps=cellfun(@cell2mat,test,'UniformOutput',0); %converts cell of cells into matrix of timestamps
    RewardTimestamps=str2double(RewardTimestamps)/1e3; %Gets rid of trial number in output message
    TrialTimestamps=LightOnTimestamps;
    test = regexp(TrialSerial,'[0-9]+.[0-9]+', 'match'); %Gets rid of non-numbers
    for i=1:length(test)
        %Because the trial number is part of the output
        [token,remain] = strtok(test{i});
        TrialTimestamps(i)=str2double(remain{1}(2:end));
    end
    TrialTimestamps=TrialTimestamps'/1e3; %Convert to seconds

%     lickBinSize=0.100; %in seconds
%     %Start at -1 seconds to properly count first trial?
%     lickBins=-1:lickBinSize:1200; %Session is 20 minutes long (1200 seconds)
%     lickRate=histc(LickSerialTimestamps,lickBins)/lickBinSize; %In Hz
%     lickRate=lickRate';
    
    pokeBinSize=0.100;
    %Start at -1 seconds to properly count first trial?
    pokeBins=-1:pokeBinSize:1800; %Session is 20 minutes long (1200 seconds)
    pokeRate=histc(PokeTimestamps,pokeBins)/pokeBinSize; %In Hz
    pokeRate=pokeRate';
    
    %%
    
    PokeLatencies={};
    allPokeLatencies=[];
%     LickLatencies={};
%     allLickLatencies=[];
    CSplus=[];
    LightOn=[];
    LightOff=[];
    
%     CSplus_licks=[];
%     LightOn_licks=[];
%     LightOff_licks=[];

    
    %     for i=1:(length(TrialTimestamps)-1)
    %         start=TrialTimestamps(i);
    %         finish=TrialTimestamps(i+1);
    %         OnTime=LightOnTimestamps(LightOnTimestamps>start&LightOnTimestamps<finish);
    %         OffTime=LightOffTimestamps(LightOffTimestamps>start&LightOffTimestamps<finish);
    %         size(find(pokeBins>(OffTime-1)&pokeBins<=(OffTime+10)))
    %
    %     end
    
    OnDuration=[]; %in seconds
    
    for i=1:(length(TrialTimestamps)-1)
        start=TrialTimestamps(i);finish=TrialTimestamps(i+1);
        OnTime=LightOnTimestamps(i);
        OffTime=LightOffTimestamps(i);
        
        %Round to nearest ms to get rid of floating point error
        OnDuration(i,:)=ceil(round((OffTime-OnTime),3)); 

        %CSplus+Delay
        CSplus=[CSplus;find(pokeBins>(start-1)&pokeBins<=(start+7))];
%         CSplus_licks=[CSplus_licks;find(lickBins>(start-1)&lickBins<=(start+7))];
        
        %Light ON
        LightOn=[LightOn;find(pokeBins>(OnTime-1)&pokeBins<=(OnTime+10))];
%         LightOn_licks=[LightOn_licks;find(lickBins>(OnTime-1)&lickBins<=(OnTime+10))];
        
        
        %Light OFF
        LightOff=[LightOff;find(pokeBins>(OffTime-2)&pokeBins<=(OffTime+10))];
%         LightOff_licks=[LightOff_licks;find(lickBins>(OffTime-1)&lickBins<=(OffTime+10))];
        
        
        temp1=PokeTimestamps(PokeTimestamps>start&PokeTimestamps<finish)-start;
%         temp2=LickSerialTimestamps(LickSerialTimestamps>start&LickSerialTimestamps<finish)-start;
        PokeLatencies{i}=temp1';
%         LickLatencies{i}=temp2';
        allPokeLatencies=[allPokeLatencies;temp1];
%         allLickLatencies=[allLickLatencies;temp2];
    end
    
    CSplus_ts=pokeBins(pokeBins>(start-1)&pokeBins<=(start+7))-start;
%     LightOn_ts=lickBins(lickBins>(OnTime-1)&lickBins<=(OnTime+10))-OnTime;
%     LightOff_ts=lickBins(lickBins>(OffTime-2)&lickBins<=(OffTime+10))-OffTime;
%     
    CSplusPokes=pokeRate(CSplus);
    LightOnPokes=pokeRate(LightOn);
    LightOffPokes=pokeRate(LightOff);
    
%     CSplusLicks=lickRate(CSplus_licks);
%     LightOnLicks=lickRate(LightOn_licks);
%     LightOffLicks=lickRate(LightOff_licks);
    
    PokeLatenciesMat = cell2mat(PokeLatencies);
    
%% ALL Pokes within LIGHT ON
    % finding light on pokes - RED + Black
      for i=1:(length(TrialTimestamps)-1)
        hi=LightOnTimestamps(i);bye=LightOffTimestamps(i);

        temp1=PokeTimestamps(PokeTimestamps>hi&PokeTimestamps<bye)-hi;
        LightOnPokeLatencies{i}=temp1';
        allPokeLatencies=[allPokeLatencies;temp1];

      end
      
  %find only the FIRST light on pokes - RED 
      
idx = ~cellfun('isempty',LightOnPokeLatencies);
firstLOP = zeros(size(LightOnPokeLatencies));
firstLOP(idx) = cellfun(@(v)v(1),LightOnPokeLatencies(idx));
firstLOPLatencies = firstLOP';
    
    %%

for n = 1:length(PokeLatencies)
    currRow = PokeLatencies{n};
    for nn = 1:length(currRow)
        hold on 
        if (any(currRow<=2) || any(currRow>=3.5))
            A = [A;[currRow(nn)]];
        else
            for nn=1
            LOPLatencies{fileName,n} = [currRow(nn)];
            end
            for nn = 2:length(currRow)
            C = [C;[currRow(nn)]];
            end
        end
    end
end
    %%

 figure;
  subplot(2,1,1); rasterPlotMIDC1(PokeLatencies);
  ylabel('Trials');
  xlim([0 26]); 
  title(titles{fileName});
  subplot(2,1,2); hist(PokeLatenciesMat,600) 
  ylabel('Nose Pokes');xlabel('Time (s)');xlim([0 26]); ylim([0 10]);
  text(21.5,8,txt,'Color','blue','FontSize',14)
  
 Rewards(1,fileName) = numel(RewardTimestamps);
 TotalPokes(1,fileName) = numel(PokeTimestamps);
 TotalTrials(1,fileName) = numel(TrialTimestamps);
 
end
LOPLatencies = LOPLatencies';

AvgLOPLat = [];
StarttoLO = LightOnTimestamps-TrialTimestamps';

LOPLatF1 = [LOPLatencies{:,1}]-StarttoLO;
LOPLatF1 = LOPLatF1(1,:);
AvgLOPLat(1) = mean(LOPLatF1);

LOPLatF2 = [LOPLatencies{:,2}]-StarttoLO;
LOPLatF2 = LOPLatF2(1,:);
AvgLOPLat(2) = mean(LOPLatF2);

LOPLatM1 = [LOPLatencies{:,3}]-StarttoLO;
LOPLatM1 = LOPLatM1(1,:);
AvgLOPLat(3) = mean(LOPLatM1);

LOPLatM2 = [LOPLatencies{:,4}]-StarttoLO;
LOPLatM2 = LOPLatM2(1,:);
AvgLOPLat(4) = mean(LOPLatM2);

LOPLatM3 = [LOPLatencies{:,5}]-StarttoLO;
LOPLatM3 = LOPLatM3(1,:);
AvgLOPLat(5) = mean(LOPLatM3);

LOPLatM4 = [LOPLatencies{:,6}]-StarttoLO;
LOPLatM4 = LOPLatM4(1,:);
AvgLOPLat(6) = mean(LOPLatM4);
% 
%  LOPLatM5 = [LOPLatencies{:,7}]-StarttoLO;
%  LOPLatM5 = LOPLatM5(1,:);
%  AvgLOPLat(7) = mean(LOPLatM5);

CorrectNP = [numel(LOPLatF1) numel(LOPLatF2) numel(LOPLatM1) numel(LOPLatM2) numel(LOPLatM3) numel(LOPLatM4)];
%CorrectNP = [numel(LOPLatF1)]
%CorrectNP = [numel(LOPLatF1) numel(LOPLatF2) numel(LOPLatM1) numel(LOPLatM2) numel(LOPLatM3) numel(LOPLatM4) numel(LOPLatM5)];

Rewards
AvgLOPLat
CorrectNP
TotalPokes



toc