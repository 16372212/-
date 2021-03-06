
%gkdes_words=load_kdes_words_rgbd('gkdes',0.001);%彩色梯度特征
%rgbkdes_words=load_kdes_words_rgbd('rgbkdes',0.01);%彩色信息
gkdesdepth_words=load_kdes_words_rgbd('gkdesdepth',0.001);%深度梯度
%lbpkdes_words=load_kdes_words_rgbd('lbpkdes',0.01);%二值，轮廓信息（彩色）/
spinkdes_words=load_kdes_words_rgbd('spinkdes',0.1);%旋转
spinkdes_words.patch_size=40;
spinkdes_words.radius=0.25;


disp('computing kdes features for base superpixels... (could take a while)');

% run matlabpool first
for ii=1:nframe,
    %disp('%d\n', ii);
    
    id=num2str(ii,'%08d');
    savefile=[basefeatdir '/' id '.mat'];
    
   % if exist(savefile), continue; end;
    
    %if exist([imgdir '/' id '.jpg']) && exist([depthdir '/' id '.mat']) && exist([depthdir_raw '/' id '.mat']) ...
           % && exist([basesegdir '/' id '.mat'])
        
        
        %img=im2double(imread([imgdir '/' id '.jpg']));%彩色图像，删掉
        data=load([depthdir '/' id '.mat'],'depth');
        depth=double(data.depth)/1000;
        data=load([depthdir_raw '/' id '.mat'],'depth_raw');
        depth_raw=double(data.depth_raw)/1000;
        data=load([basesegdir '/' id '.mat'],'seg');
        seg=data.seg;
        
        % compute kdes features on seg
        %feaSet=gkdes_dense( img, gkdes_words.params, gkdes_words.grid_space );
        %feaSet.feaArr{1}=single(feaSet.feaArr{1});
        %gkdes=cksvd_emk_seg( feaSet, gkdes_words.words, gkdes_words.G, seg, gkdes_words.ktype, gkdes_words.kparam );
        
        %feaSet=rgbkdes_dense( img, rgbkdes_words.params, rgbkdes_words.grid_space );
        %feaSet.feaArr{1}=single(feaSet.feaArr{1});
        %rgbkdes=cksvd_emk_seg( feaSet, rgbkdes_words.words, rgbkdes_words.G, seg, rgbkdes_words.ktype, rgbkdes_words.kparam );
        
        feaSet=gkdes_dense( depth, gkdesdepth_words.params, gkdesdepth_words.grid_space );
        feaSet.feaArr{1}=single(feaSet.feaArr{1});
        gkdes_depth=cksvd_emk_seg( feaSet, gkdesdepth_words.words, gkdesdepth_words.G, seg, gkdesdepth_words.ktype, gkdesdepth_words.kparam );
        
       % feaSet=lbpkdes_dense( img, lbpkdes_words.params, lbpkdes_words.grid_space );
        %feaSet.feaArr{1}=single(feaSet.feaArr{1});
        %lbpkdes=cksvd_emk_seg( feaSet, lbpkdes_words.words, lbpkdes_words.G, seg, lbpkdes_words.ktype, lbpkdes_words.kparam );
        
        pcloud=DepthtoCloud(depth);
        normal=pcnormal(pcloud,0.05,8);
        normal=fix_normal_orientation( normal, pcloud );
        
        feaSet=spinkdes_dense(pcloud,normal,spinkdes_words.params,spinkdes_words.grid_space,spinkdes_words.patch_size,spinkdes_words.radius);
        feaSet.feaArr{1}=single(feaSet.feaArr{1});
        spinkdes=cksvd_emk_seg( feaSet, spinkdes_words.words, spinkdes_words.G, seg, spinkdes_words.ktype, spinkdes_words.kparam );
        
        f_ex=region_features_extra_rgbd( depth, depth_raw+mask*10, seg );
        
        gkdes=single(gkdes);
        rgbkdes=single(rgbkdes);
        gkdes_depth=single(gkdes_depth);
        spinkdes=single(spinkdes);
        lbpkdes=single(lbpkdes);
        f_ex=single(f_ex);
        
        save_feature_rgbd(savefile,gkdes,rgbkdes,gkdes_depth,lbpkdes,spinkdes,f_ex);
   % end
end    %  ii

