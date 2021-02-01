function visualcorrelation()

maindir='.\Database';
subdir =  dir( maindir );

itr = 0;

alltemplates = zeros(5,480);
allmasks = zeros(5,480);
allmaskedtemplates = zeros(5,480);

for i = 1 : length( subdir )
    
    if( isequal( subdir( i ).name, '.' ) ||  isequal( subdir( i ).name, '..' ) ||  ~subdir( i ).isdir )
        continue;  
    end
    
    subdirpathL = fullfile( maindir, subdir( i ).name, 'L');
    subdirpathR = fullfile( maindir, subdir( i ).name, 'R');
    
    imagesL = dir( subdirpathL );
    imagesR = dir( subdirpathR );
    
    for j = 1 : length(imagesL)
        
        if( isequal( imagesL( j ).name, '.' ) ||  isequal( imagesL( j ).name, '..' ) )
            continue;  
        end
        
        imagepath = fullfile(subdirpathL, imagesL( j ).name);
        disp(imagepath)
        
        [A, B]=createiristemplate( imagepath );
        
        itr = itr + 1;
        templates(:,:,itr) = A;
        masks(:,:,itr) = B;
        
        alltemplates = cat(1,alltemplates,A);
        alltemplates = cat(1,alltemplates,zeros(5,480));
        
        allmasks = cat(1,allmasks,B);
        allmasks = cat(1,allmasks,zeros(5,480));
        
        A = logical(A);
        B = logical(B);
        masked = A & (~B);
        allmaskedtemplates = cat(1,allmaskedtemplates,masked);
        allmaskedtemplates = cat(1,allmaskedtemplates,zeros(5,480));
        
    end
    
    for j = 1 : length(imagesR)
        
        if( isequal( imagesR( j ).name, '.' ) ||  isequal( imagesR( j ).name, '..' ) )
            continue;  
        end
        
        imagepath = fullfile(subdirpathR, imagesR( j ).name);
        disp(imagepath)
        
        [A, B]=createiristemplate( imagepath );
        
        itr = itr + 1;
        templates(:,:,itr) = A;
        masks(:,:,itr) = B;
        
        alltemplates = cat(1,alltemplates,A);
        alltemplates = cat(1,alltemplates,zeros(5,480));
        
        allmasks = cat(1,allmasks,B);
        allmasks = cat(1,allmasks,zeros(5,480));
        
        A = logical(A);
        B = logical(B);
        masked = A & (~B);
        allmaskedtemplates = cat(1,allmaskedtemplates,masked);
        allmaskedtemplates = cat(1,allmaskedtemplates,zeros(5,480));
        
    end
    
    %fulldir=strcat(maindir,'\',subdir(i).name,'\');
    %save([fulldir, 'templatemask.mat'], 'A','B');

end

imwrite(alltemplates,'alltemplates.tif');
imwrite(allmasks,'allmasks.tif');
imwrite(allmaskedtemplates,'allmaskedtemplated.tif');

allhds = zeros(0,0);

for i = 1:itr
    A1 = templates(:,:,i);
    B1 = masks(:,:,i);
    temphds = zeros(0,0);
    for j = 1:itr
        A2 = templates(:,:,j);
        B2 = masks(:,:,j);
        hd = gethammingdistance(A1,B1,A2,B2,1);
        temphds = cat(2,temphds,hd);
    end
    allhds = cat(1,allhds,temphds);
end

imshow(allhds,[])