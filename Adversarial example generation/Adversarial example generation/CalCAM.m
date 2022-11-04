%% Calculate classification activation map
function CAM = CalCAM(Image,ImageSize)
    proxynet      = squeezenet;
    layerName     = 'relu_conv10';
    proImageSize  = proxynet.Layers(1).InputSize;
    proSample     = imresize(Image,proImageSize(1:2));
    imageActivations = activations(proxynet,proSample,layerName);
    scores        = squeeze(mean(imageActivations,[1 2]));
    [~,classIds]  = maxk(scores,3);
    CAM           = imageActivations(:,:,classIds(1));
    CAM           = imresize(CAM,proImageSize(1:2));
    minimum       = min(CAM(:));
    maximum       = max(CAM(:));
    CAM           = (CAM-minimum)/(maximum-minimum);
    CAM(CAM<0.5)  = 0;
    CAM           = imresize(CAM,ImageSize(1:2));
end