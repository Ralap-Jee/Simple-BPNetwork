

function [y] = fp(w,b,x)

y = w*x + b;                         % y ��n��������Ԫ���������������
n = length(y);                       % n ������Ԫ��
for i =1:n
    y(i)=1.0/(1+exp(-y(i)));         % ������Ԫ����S�����������
end
y;
end



