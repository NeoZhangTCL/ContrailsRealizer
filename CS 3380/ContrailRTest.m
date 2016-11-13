for figNum = 1:5
    for blockSize = [2, 7, 12]
        for p = [5, 15, 25]
            for fillGap = [200, 400 ,600 ]
                for minLength = [25,50,100]
                    ContrailRFunction(figNum, blockSize, p, fillGap, minLength);
                end
            end
        end
    end
end