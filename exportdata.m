function exportdata()

maindir='.\Database';
subdir =  dir( maindir );

itr = 0;

alltemplates = zeros(5,480);
allmasks = zeros(5,480);
allmaskedtemplates = zeros(5,480);
alljson = struct;
mastermask = zeros(20,480);
newtemplates = zeros(5,480);
allfilenames = ["sa","as"];
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
        % disp(imagepath)
        
        [A, B]=createiristemplate( imagepath );
        
        itr = itr + 1;
        templates(:,:,itr) = A;
        masks(:,:,itr) = B;
        
        mastermask = mastermask | B;
        
        maskedTemplate = double(A & ~B);
        maskedTemplate = reshape(maskedTemplate,[],1);
        filename = split(imagesL(j).name, '.');
        disp(filename{1})
        alljson = setfield(alljson, filename{1}, maskedTemplate');
        allfilenames(itr) = string(filename{1});
        
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
        % disp(imagepath)
        
        [A, B]=createiristemplate( imagepath );
        
        itr = itr + 1;
        templates(:,:,itr) = A;
        masks(:,:,itr) = B;
        
        mastermask = mastermask | B;
        
        maskedTemplate = double(A & ~B);
        maskedTemplate = reshape(maskedTemplate,[],1);
        filename = split(imagesR(j).name, '.');
        disp(filename{1})
        alljson = setfield(alljson, filename{1}, maskedTemplate');
        allfilenames(itr) = string(filename{1});
        
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

alljsondump = json.dump(alljson);
json.write(alljsondump,'./myjson1.json');

disp(allfilenames)
for j=1:itr
    templateForCalc = templates(:,:,j);
    templateForCalc = logical(templateForCalc) & ~(logical(mastermask));
    newtemplates = cat(1,newtemplates,templateForCalc);
    newtemplates = cat(1,newtemplates,zeros(5,480));
    templateForCalc = reshape(templateForCalc,[],1);
    templateForCalc = double(templateForCalc);
    alljson = setfield(alljson, (allfilenames(j)), templateForCalc');
end

imshow(newtemplates)
imshow(allmaskedtemplates)

alljsondump = json.dump(alljson);
json.write(alljsondump,'./myjson2.json');