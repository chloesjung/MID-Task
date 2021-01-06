function [] = rasterPlotMIDC1(cellData)
%Cohort1
%Fisrt nosepoke within LO + rewarded = RED
for n = 1:length(cellData)
    currRow = cellData{n};
    for nn = 1:length(currRow)
        hold on 
        if (any(currRow<=2) || any(currRow>=3.5))
        
            plot([currRow(nn) currRow(nn)],[n-1 n],'k')
            xlim([0 26]);
           
        else
          for nn=1
            plot([currRow(nn) currRow(nn)],[n-1 n],'r')
          end
          for nn = 2:length(currRow)
            plot([currRow(nn) currRow(nn)],[n-1 n],'k')
            xlim([0 26]);
          end
          
       
      
        end
    end
end
        