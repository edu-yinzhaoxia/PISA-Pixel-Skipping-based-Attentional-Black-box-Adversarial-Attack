classdef Adv_Attack_ImageNet < PROBLEM
% <problem> <Adversarial example generation>
% The adversarial attack problem
% ObjFunction  --- 0 --- The second objective to be optimized (0-L_0 norm,1-L_2 norm)
% TargetModel  --- 0 --- The target model specified (0-ResNet101,1-Inception-v3)
% TargetImage  --- 1 --- No. of the image to be attacted
% DimReduction --- 0 --- The manner of the reduction specified (0-3)
% MaxInfNorm   ---255--- The maximum L_Inf norm of the perturbation (0-255)

% All the images are taken from the ILSVRC2012

    properties(Access = public)
        Sample;        % Data of image set
        Category;      % Labels of image set
        RegionIndex;   % Indexes of regions to be perturbed
        Net;           % Target model
        ImageSize;     % Size of each image
        TrueLabel;     % True label
    end
   
    methods
        %% Initialization
        function obj = Adv_Attack_ImageNet()
            % Load target model
            TargetModel = obj.Global.parameter.Adv_Attack_ImageNet{2};
            switch TargetModel
                case 0
                    net = resnet101;
                case 1
                    net = inceptionv3;
            end
            
            % Load data
            load label.mat
            Catalogue  = matlab.io.datastore.DsFileReader('Adv_Attack_ImageNet.m');
            Catalogue  = erase(Catalogue.Name,"Adv_Attack_ImageNet.m");
            Catalogue  = strcat(Catalogue,'ori');
            fileFolder = fullfile(Catalogue);
            dirOutput  = dir(fullfile(fileFolder,'*.JPEG'));
            fileNames  = {dirOutput.name};
            ImageNo    = obj.Global.parameter.Adv_Attack_ImageNet{3};
            ImageSize  = net.Layers(1).InputSize;
            Image      = imread(fileNames{ImageNo});
            Sample     = imresize(Image,ImageSize(1:2));
            Category   = str2double(val(val(:,1) == fileNames{ImageNo},2))+1; %#ok<USENS>
            TrueLabel  = synsetwords(Category,1);

            % Dimension reduction methods
            DimReduction = obj.Global.parameter.Adv_Attack_ImageNet{4};
            switch DimReduction
                case 0  % Without any reduction method
                    RegionIndex   = 1:1:ImageSize(1)*ImageSize(2);
                    
                case 1  % Reduction with pixel skipping
                     RegionIndex = PixelSkipping(ImageSize);
                    
                case 2  % Reduction with segementation
                    CAM = CalCAM(Image,ImageSize);
                    RegionIndex   = find(CAM>0)'; 
                    obj.Global.softmask = GetMask(RegionIndex,CAM,ImageSize); 
					
                case 3  % CAM + Pixel skipping  
                    CAM = CalCAM(Image,ImageSize);
                    RegionIndex1  = PixelSkipping(ImageSize);
                    RegionIndex2  = find(CAM>0)';
                    RegionIndex   = intersect(RegionIndex1,RegionIndex2); 
                    obj.Global.softmask = GetMask(RegionIndex,CAM,ImageSize); 
            end
            
            % Parameter setting
            obj.Sample          = Sample;
            obj.Category        = Category;
            obj.TrueLabel       = TrueLabel;
            obj.RegionIndex     = RegionIndex;
            obj.Net             = net;
            obj.ImageSize       = ImageSize;
            obj.Global.M        = 2;
            obj.Global.D        = 3*length(RegionIndex);
            obj.Global.lower    = zeros(1,obj.Global.D);
            obj.Global.upper    = ones(1,obj.Global.D)*obj.Global.parameter.Adv_Attack_ImageNet{5}/255; 
            obj.Global.encoding = 'real'; 
        end
        
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            PopObj     = zeros(size(PopDec,1),2);
            New_Image  = uint8(zeros([obj.ImageSize,size(PopDec,1)]));
            for i = 1 : size(PopObj,1)
                PerturbInd = zeros(obj.ImageSize(1:2));
                for j  = 1 : 3
                    Perturb                  = zeros(obj.ImageSize(1:2));
                    Perturb(obj.RegionIndex) = Perturb(obj.RegionIndex)+PopDec(i,(j-1)*obj.Global.D/3+1:j*obj.Global.D/3);
                    PerturbInd               = PerturbInd + double(Perturb~=0);
                    New_Image(:,:,j,i)       = uint8(255*(double(obj.Sample(:,:,j))/255 + Perturb));
                end
                if obj.Global.parameter.Adv_Attack_ImageNet{1}==0
                    PopObj(i,2) = length(find(PerturbInd~= 0));
                end
            end
            
            [classname, score] = classify(obj.Net,New_Image);
            PopObj(:,1) = score(:,obj.Category);
            if obj.Global.parameter.Adv_Attack_ImageNet{1}==1
                PopObj(:,2) = vecnorm(PopDec,2,2);% l2-norm
            end

            % Visualization of Optimization Results
            if obj.Global.evaluated == obj.Global.evaluation
                Visualization(obj,PopObj,PopDec,score,New_Image,classname,obj.Global.parameter.Adv_Attack_ImageNet{1});
            end
        end
    end
end