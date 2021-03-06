function fname = print_table_Na(N_mean, N_std, N_ESS,...
    N_mean_DA_min, N_std_DA_min, N_ESS_DA_min,...
    N_mean_DA_max, N_std_DA_max, N_ESS_DA_max,...
    Time,ext,path)

    N_mean = [N_mean, N_mean_DA_min, N_mean_DA_max];
    N_std = [N_std, N_std_DA_min, N_std_DA_max];
    N_ESS = [N_ESS, N_ESS_DA_min, N_ESS_DA_max];

    fname = [path,'BKM_Na',ext,'.tex'];
    
%     params = {'$ Na_{5}$ &', '$ Na_{15}$ &', '$ Na_{25}$ &', '$ Na_{35}$ &','$ Na_{min}$ &','$ Na_{max}$ &'};

    method = {'DA','Adapt10','Adapt20','Adapt30','Bin10','Bin20','Bin30', 'Exact'};
    K = length(method);

    FID = fopen(fname, 'w+');
    fprintf(FID, '{\\setlength{\\tabcolsep}{1.5pt}\n');
   
    fprintf(FID, '{\\scriptsize \n');
    fprintf(FID, '{ \\renewcommand{\\arraystretch}{1.2} \n');

    fprintf(FID, '\\begin{table} \n');
    fprintf(FID, '\\hspace*{-3.5cm} \n');
%     fprintf(FID, '\\center \n');
%     fprintf(FID, '\\begin{tabular}{cc cccc cc} \n');
    fprintf(FID, '\\begin{tabular}{cc ccc ccc ccc cc} \n');
    fprintf(FID, '\\hline \n');
%     fprintf(FID, [' Method & & '...
%                 '$ Na_{5}$ &', '$ Na_{15}$ &', '$ Na_{25}$ &',...
%                 '$ Na_{35}$ &','$ Na_{min}$ &','$ Na_{max}$ ',...
%                  ' \\\\ \\hline  \\hline\n']);
%     fprintf(FID, [' Method & & '...
%                 '$ Na_{6}$ &', '$ Na_{15}$ &', '$ Na_{24}$ &',...
%                 '$ Na_{33}$ &','$ Na_{min}$ &','$ Na_{max}$ ',...
%                  ' \\\\ \\hline  \\hline\n']);
      fprintf(FID, [' Method & & '...
                '$ Na_{4}$ &', '$ Na_{8}$ &', '$ Na_{12}$ &',...
                '$ Na_{16}$ &', '$ Na_{20}$ &', '$ Na_{24}$ &',...
                '$ Na_{28}$ &', '$ Na_{32}$ &', '$ Na_{36}$ &',...
                '$ Na_{min}$ &','$ Na_{max}$ ',...
                 ' \\\\ \\hline  \\hline\n']);           
    for ii = 1:K
        fprintf(FID, '\\rowcolor{LightCyan} \n');
        fprintf(FID, '%s & Mean \n', method{ii});
%         for jj = 1:6
        for jj = 1:11
            fprintf(FID,' & %6.4f ', N_mean(ii,jj));
        end
        fprintf(FID,' \\\\  [0.75ex] \n');

        fprintf(FID, ' & (Std) \n');
%         for jj = 1:6
        for jj = 1:11
            fprintf(FID,' & (%6.4f) ', N_std(ii,jj));
        end
        fprintf(FID,' \\\\  [0.75ex] \n'); 
        
        fprintf(FID, ' & ESS \n');
%         for jj = 1:6
        for jj = 1:11
            fprintf(FID,' & %6.4f ', N_ESS(ii,jj));
        end
        fprintf(FID,' \\\\  [0.75ex] \n');

        fprintf(FID, '[%6.2f s]  & ESS/sec. \n', Time(ii));
%         for jj = 1:6
        for jj = 1:11
            fprintf(FID,'& %6.4f ', N_ESS(ii,jj)/Time(ii));
        end
        fprintf(FID,' \\\\  [1.3ex] \n');        
    end
    fprintf(FID,'   \\hline \n');

%     fprintf(FID, ['\\multicolumn{8}{p{11cm}}{\\footnotesize{ESS: at lag equal to the ' ...
%     'lowest order at which sample autocorrelation is not significant.}}  \\\\ \n']);
%     fprintf(FID, ['\\multicolumn{8}{p{11cm}}{\\footnotesize{$Na_{min}$/$Na_{max}$: ' ...
%     'corresponding to the lowest/highest ESS for the DA method.}}  \\\\ \n']);
%     fprintf(FID, ['\\multicolumn{8}{p{11cm}}{\\footnotesize{Computing times '...
%         ' (in seconds) in square brackets.}}  \\\\ \n']);
    
    fprintf(FID, ['\\multicolumn{13}{p{11cm}}{\\footnotesize{ESS: at lag equal to the ' ...
    'lowest order at which sample autocorrelation is not significant.}}  \\\\ \n']);
    fprintf(FID, ['\\multicolumn{13}{p{11cm}}{\\footnotesize{$Na_{min}$/$Na_{max}$: ' ...
    'corresponding to the lowest/highest ESS for the DA method.}}  \\\\ \n']);
    fprintf(FID, ['\\multicolumn{13}{p{11cm}}{\\footnotesize{Computing times '...
        ' (in seconds) in square brackets.}}  \\\\ \n']);


    fprintf(FID, '\\end{tabular}\n ');
    
    caption = ['\\caption{Posterior means, standard deviations and '...
        'effective sample sizes (ESS) of the model parameters ' ...
        'for $M=10000$ posterior draws after a burn-in of $10000$ for the lapwings data.}\n'];
    fprintf(FID, caption);

    label = ['\\label{tab:BKM_theta',ext,'}  \n'];
    fprintf(FID, label);
    
    fprintf(FID, '\\end{table}\n');
    
    fprintf(FID, '}');
    fprintf(FID, '} \\normalsize');
    fclose(FID);
end