%% Get the mask of pixels to be perturbed for sparseEA
function Softmask = GetMask(RegionIndex,CAM,ImageSize)           
    RegionIndex = unique(RegionIndex);
    Mask  = reshape(CAM,1,ImageSize(1)*ImageSize(2));
    Softmask = -repmat(Mask(RegionIndex),[1 3]);
end