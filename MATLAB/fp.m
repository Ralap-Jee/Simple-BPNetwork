

function [y] = fp(w,b,x)

y = w*x + b;                         % y 是n个隐层神经元的输出，是列向量
n = length(y);                       % n 隐层神经元数
for i =1:n
    y(i)=1.0/(1+exp(-y(i)));         % 隐层神经元利用S函数计算输出
end
y;
end



