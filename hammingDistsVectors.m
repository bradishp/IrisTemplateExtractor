function minHD = hammingDistsVectors(template1, mask1, template2, mask2, scales)

template1 = logical(template1);
mask1 = logical(mask1);

template2 = logical(template2);
mask2 = logical(mask2);

minHD = NaN;

% shift template left and right, use the lowest Hamming distance
for shifts=-8:8
    shiftedTemplate1 = circshift(template1, shifts*scales*20*2);
    shiftedMask1s = circshift(mask1, shifts*scales*20*2);
    
    mask = shiftedMask1s | mask2;
    
    numMaskedbits = sum(sum(mask == 1));
    totalbits = (size(shiftedTemplate1, 2)) - numMaskedbits;
    
    bitDiff = xor(shiftedTemplate1, template2);
    bitDiff = bitDiff & ~mask;
    hamDist = sum(sum(bitDiff==1));
    
    if totalbits == 0
        minHD = NaN;
    else
        hamDistPercent = hamDist / totalbits;
        if  hamDistPercent < minHD || isnan(minHD)
            minHD = hamDistPercent;
        end
    end
end