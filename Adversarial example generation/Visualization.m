%% Visualization of Optimization Results
function Visualization(obj,PopObj,PopDec,score,New_Image,classname,objfunction) 
    [~,label] = max(score,[],2);
    if ~isempty(min(PopObj(label ~= obj.Category,2),[],1))
        Index = find(PopObj(:,2) == min(PopObj(label ~= obj.Category,2),[],1));
        Index = Index(1);
        figure
        subplot(2,3,1);
        imshow(obj.Sample);
        [classname1,score1] = classify(obj.Net,obj.Sample); 
        title("True label "+ obj.TrueLabel+"! " +  string(classname1) + ", " + num2str(100*max(score1(obj.Category))) + "%");
        subplot(2,3,3);
        imshow(New_Image(:,:,:,Index));
        if objfunction ==0
            title(string(classname(Index)) + ", " + num2str(100*max(score(Index,:))) + "%"+ ", " +...
                "l0 norm: " + num2str(PopObj(Index,2)) + ", " +...
                "l2 norm: " + num2str(norm(PopDec(Index,:),2)/255));
        else
            title(string(classname(Index)) + ", " + num2str(100*max(score(Index,:))) + "%"+ ", " +...
                "l2 norm: " + num2str(PopObj(Index,2)));
        end
        
        d_a = double(New_Image(:,:,:,Index));
        d_b = double(obj.Sample);
        perturb = d_b - d_a;
        r = perturb(:,:,1);
        g = perturb(:,:,2);
        b = perturb(:,:,3);
        nz_r = find(r ~= 0);nz_g = find(g ~= 0);nz_b = find(b ~= 0);
        z_r = find(r == 0);z_g = find(g == 0);z_b = find(b == 0);
        max_r = max(r(:));min_r = min(r(:));
        max_g = max(g(:));min_g = min(g(:));
        max_b = max(b(:));min_b = min(b(:));
        kedu_r = max_r - min_r;
        kedu_g = max_g - min_g;
        kedu_b = max_b - min_b;
        for i=1:length(nz_r)
            if r(nz_r)>0
                r(nz_r) = 128+round(r(nz_r)./(max_r).*128);
            elseif r(nz_r)<0
                r(nz_r) = 128+round(r(nz_r)./(min_r).*128);
            end
        end
        for i=1:length(nz_g)
            if g(nz_g)>0
                g(nz_g) = 128+round(g(nz_g)./(max_g).*128);
            elseif g(nz_g)<0
                g(nz_g) = 128-round(g(nz_g)./(min_g).*128);
            end
        end
        for i=1:length(nz_b)
            if b(nz_b)>0
                b(nz_b) = 128+round(b(nz_b)./(max_b).*128);
            elseif b(nz_g)<0
                b(nz_b) = 128-round(b(nz_b)./(min_b).*128);
            end
        end
        r(z_r) = 128;
        g(z_g) = 128;
        b(z_b) = 128;
        r = uint8(r);
        g = uint8(g);
        b = uint8(b);
        %                     new_c = ones(224,224,3);
        %                     new_c = ones(299,299,3);
        new_c = ones(obj.ImageSize);
        new_c(:,:,1) = r;
        new_c(:,:,2) = g;
        new_c(:,:,3) = b;
        new_c = uint8(new_c);
        
        subplot(2,3,2);d = imshow(new_c);
        title("Perturbed pattern"); % set(d, 'AlphaData', alpha);
        subplot(2,3,4);imshow(r);title('r');
        subplot(2,3,5);imshow(g);title('g');
        subplot(2,3,6);imshow(b);title('b');
        
        str = 'Ori_';
        str = strcat(str,obj.TrueLabel);
        str = strcat(str,'.png');
        imwrite(obj.Sample,str);
        
        str1 = 'Adv_';
        str1 = strcat(str1,string(classname(Index)));
        str1 = strcat(str1,'.png');
        imwrite(New_Image(:,:,:,Index),str1);
        figure
    end
end