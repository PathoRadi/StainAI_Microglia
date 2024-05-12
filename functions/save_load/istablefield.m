function TF=istablefield(table_temp,colname)
%table_temp=table_anova;colname='area0fff'
tablenames=table_temp.Properties.VariableNames;
if isempty(find(strcmpi(tablenames,colname)==1))==1
    TF=0;
else
    TF=1;
end