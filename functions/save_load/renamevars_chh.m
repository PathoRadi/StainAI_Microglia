function table1=renamevars_chh(table1,oldname,newname)
eval([newname '=table1.' oldname ';']);
eval(['table1=addvars(table1,' newname ',''after'',''' oldname ''');'])
eval(['table1=removevars(table1,''' oldname ''');']);