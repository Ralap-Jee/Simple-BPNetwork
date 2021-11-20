t1 = 0:1/8:7.5;
y1 = 1.0 + exp(-t1);
y2 = y1 .\ 1.0;
y3 = num2hex(single(y2));

t2 = -7.5:1/8:0;
y4 = 1.0 + exp(-t2);
y5 = y4 .\ 1.0;
y6 = num2hex(single(y5));

%%%%%%%%%%%%%%%%%%%%%
%%%%%%File Print%%%%%
%%%%%%%%%%%%%%%%%%%%%
fid = fopen('sigmoid_lut.mif','w');
fprintf(fid,'%s\n','WIDTH = 32;');
fprintf(fid,'%s\n','DEPTH = 122;');
fprintf(fid,'%s\n','ADDRESS_RADIX = UNS;');
fprintf(fid,'%s\n','DATA_RADIX = HEX;');
fprintf(fid,'%s\n','CONTENT BEGIN');
label = 0;
for i=1:61
   fprintf(fid, '%d',label);            
   label = label + 1;
   fprintf(fid, '%s',' : '); 
   fprintf(fid, '%s;\n',y3(i,:));
end
for i=1:61
   fprintf(fid, '%d',label);            
   label = label + 1;
   fprintf(fid, '%s',' : '); 
   fprintf(fid, '%s;\n',y6(62-i,:));
end
fprintf(fid,'%s\n','END;');
fclose(fid);
