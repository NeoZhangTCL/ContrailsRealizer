function [boolean] = validate(fPoint, sPoint, BW)
        
    fPointX = fPoint(1);
    fPointY = fPoint(2);
    sPointX = sPoint(1);
    sPointY = sPoint(2);
    
    pointsOnLine = 0;
    totalPoints = abs(sPointX - fPointX + 1);
    
    if(fPointX - fPointY == 0)
        for y = fPointY:sPointY
            x = fPointX;
            if (BW(x,y) == 1)
                pointsOnLine = pointsOnLine + 1; 
            end %end if 
        end %end for y   
    else
        slope = (fPointY-sPointY)/(fPointX-sPointX);
        for x = fPointX:sPointX
            y = round(x*slope + fPointY);
            if (BW(x,y) == 1)
                pointsOnLine = pointsOnLine + 1; 
            end %end if            
        end %end for X    
    end
    
    validRate = pointsOnLine/totalPoints;
    if (validRate >= 0.6)
        boolean = true;
    else
        boolean = false;
    end
end

