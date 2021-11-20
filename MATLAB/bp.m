function[w1,b1,w2,b2]=bp(x_in,y_in)

step = input('迭代步数：');
s = input('学习因子：');
in = 9;                            % 输入神经元个数
hid = input('隐藏层神经元个数：');    % 隐藏层神经元个数n
out = 1;                            % 输出层神经元个数

w1 = randn(hid,in);             % 返回hid*in矩阵，即输入层到隐藏层的权值矩阵，每一行代表一样隐层单元的权值
b1 = randn(hid,1);               % 返回out*1矩阵，即输出层神经元的偏值
w2 =randn(out,hid);             % 返回out*hid矩阵，即隐藏层到输出层的权值矩阵
b2 = randn(out,1);             % 返回hid*1矩阵，即隐藏层神经元的偏值        


for i=0:step        %重复step次
    
    % 每次读取一次情况，计算各层输出
    for j=1:3
        x1 = x_in(:,j);       % 一次读取一列数据
        y1 = y_in(:,j);       % 结果

        hid_ = fp(w1,b1,x1);      % 计算隐层神经元的输出
        out_ = fp(w2,b2,hid_);    % 计算输出层神经元的输出

        %更新公式的实现，典型的反向传播算法更新各权值
        o_update = (y1-out_).*out_.*(1-out_);
        h_update = ((w2')*o_update).*hid_.*(1-hid_);

        outw_update = s*(o_update*(hid_'));
        outb_update = s*o_update;
        hidw_update = s*(h_update*(x1'));
        hidb_update = s*h_update;

        w2 = w2 + outw_update;
        b2 = b2+ outb_update;
        w1 = w1 +hidw_update;
        b1 =b1 +hidb_update;
    end
end  
end