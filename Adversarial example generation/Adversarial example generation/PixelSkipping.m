%% Reduction with pixel skipping
function RegionIndex = PixelSkipping(ImageSize)
     RegionIndex   = 1:1:ImageSize(1)*ImageSize(2);
     for i = 1 : ImageSize(1)*ImageSize(2)
         [row,col] = ind2sub([ImageSize(1),ImageSize(2)], RegionIndex(i));
         if xor(mod(row,2), mod(col,2))
             RegionIndex(i) = 0;
         end
     end
     RegionIndex    = unique(RegionIndex); 
     RegionIndex(1) = []; % delete zero element
end