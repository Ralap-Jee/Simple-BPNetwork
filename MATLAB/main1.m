100


input=[1,1,0;1,0,1;0,1,0;0,1,1;1,0,0;0,1,1,;0,0,1;1,1,0;1,0,1];
output=[0,1,2];

% 矩阵归一化
input_ = mapminmax(input,0,1);
output_ =mapminmax(output,0,1);

tic
% 训练数据
[w_1,b_1,w_2,b_2]=bp(input_,output_);
toc

 %   t=[1,0,1,1,0,1,0,1,0]';
    t=[0,1,0,1,0,1,1,0,1]';
    hi = fp(w_1,b_1,t);
    ou= fp(w_2,b_2,hi);
    
   
%输出mif
hex_w_1 = num2hex(single(w_1));
hex_w_2 = num2hex(single(w_2));
hex_b_1 = num2hex(single(b_1));
hex_b_2 = num2hex(single(b_2));

%%%%%%%%%%%%%%%%%%%%%
%%%%%%File Print%%%%%
%%%%%%%%%%%%%%%%%%%%%
fid = fopen('bpparams.mif','w');
fprintf(fid,'%s\n','WIDTH = 32;');
fprintf(fid,'%s\n','DEPTH = 45;');
fprintf(fid,'%s\n','ADDRESS_RADIX = UNS;');
fprintf(fid,'%s\n','DATA_RADIX = HEX;');
fprintf(fid,'%s\n','CONTENT BEGIN');
label = 0;
for i=1:36
   fprintf(fid, '%d',label);            %w_1
   label = label + 1;
   fprintf(fid, '%s',': '); 
   fprintf(fid, '%s;\n',hex_w_1(i,:));
end
for i=1:4
   fprintf(fid, '%d',label);            %w_2
   label = label + 1;
   fprintf(fid, '%s',': '); 
   fprintf(fid, '%s;\n',hex_w_2(i,:));
end
for i=1:4
   fprintf(fid, '%d',label);            %b_1
   label = label + 1;
   fprintf(fid, '%s',' : '); 
   fprintf(fid, '%s;\n',hex_b_1(i,:));
end
   fprintf(fid, '%d',label);            %b_2
   label = label + 1;
   fprintf(fid, '%s',' : '); 
   fprintf(fid, '%s;\n',hex_b_2);
fprintf(fid,'%s\n','END;');
fclose(fid);
