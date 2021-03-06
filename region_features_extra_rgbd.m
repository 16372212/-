
function f=region_features_extra( depth, depth_raw, seg )
%
% function f=region_features_extra( depth, depth_raw, seg )
%

%  additional features
%      area, perimeter, perimeter/area, moments x2,y2,xy
%      location, x,y,x2,y2,xy; d, d2, std(d) (d normalized as in Silberman)
%      percent of missing depth
%

nfeature=15;
nseg=max(seg(:))+1;    % assume seg starts with 0

[height,width]=size(seg);
npixel=height*width;

[xgrid,ygrid]=meshgrid(1:width,1:height);

f=zeros(nseg,nfeature);
count=0;

% area
area=accumarray( seg(:)+1, ones(npixel,1), [nseg 1] );

count=count+1;
f(:,count)=area;

% perimeter
indy=ygrid(2:end-1,2:end-1);
indy=indy(:);
indx=xgrid(2:end-1,2:end-1);
indx=indx(:);
ind0=sub2ind([height width],indy,indx);
ind1=sub2ind([height width],indy-1,indx);
ind2=sub2ind([height width],indy+1,indx);
ind3=sub2ind([height width],indy,indx-1);
ind4=sub2ind([height width],indy,indx+1);

bdr=( seg(ind0)~=seg(ind1) | seg(ind0)~=seg(ind2) | seg(ind0)~=seg(ind3) | seg(ind0)~=seg(ind4) );
perim=accumarray( seg(ind0)+1, bdr, [nseg 1] );
ind_bdr=setdiff( (1:npixel)',ind0);
perim=perim+accumarray( seg(ind_bdr)+1, ones(size(ind_bdr)), [nseg 1] );

count=count+1;
f(:,count)=perim;

% perimeter / area
count=count+1;
f(:,count)=perim ./ ( area+(area==0) );

% moments, x2, y2, xy
ycenter=accumarray( seg(:)+1, ygrid(:), [nseg 1] );
ycenter=ycenter./area;
xcenter=accumarray( seg(:)+1, xgrid(:), [nseg 1] );
xcenter=xcenter./area;

m_x2=accumarray( seg(:)+1, xgrid(:).^2, [nseg 1] );
m_y2=accumarray( seg(:)+1, ygrid(:).^2, [nseg 1] );
m_xy=accumarray( seg(:)+1, xgrid(:).*ygrid(:), [nseg 1] );
m_x2=m_x2./area;
m_x2=m_x2-xcenter.^2;
m_y2=m_y2./area;
m_y2=m_y2-ycenter.^2;
m_xy=m_xy./area;
m_xy=m_xy-xcenter.*ycenter;

count=count+1;
f(:,count)=m_x2;
count=count+1;
f(:,count)=m_y2;
count=count+1;
f(:,count)=m_xy;

% location, x,y,x2,y2,xy
x_n=( (xcenter/width)-0.5 )*2;
y_n=( (ycenter/height)-0.5 )*2;

count=count+1;
f(:,count)=x_n;
count=count+1;
f(:,count)=y_n;
count=count+1;
f(:,count)=x_n.^2;
count=count+1;
f(:,count)=y_n.^2;
count=count+1;
f(:,count)=x_n.*y_n;

% depth, normalized,normal
depth_n_m=max(depth,[],1);
depth_n_m=depth_n_m+(depth_n_m==0);
depth_n=depth ./ repmat( (depth_n_m), height, 1 );

d=accumarray( seg(:)+1, depth_n(:), [nseg 1 ] );
d=d./area;
d2=accumarray( seg(:)+1, depth_n(:).^2, [nseg 1 ] );
d2=d2./area;

count=count+1;
f(:,count)=d;
count=count+1;
f(:,count)=d.^2;
count=count+1;
f(:,count)=sqrt( max(d2-d.^2,0) );

% missing depth

% depth_raw should been masked with kinect_align_nodepth
m=accumarray( seg(:)+1, double(depth_raw(:)==0), [nseg 1] );
m=m./area;

count=count+1;
f(:,count)=m;

f=f(:,1:count);




