function[w1,b1,w2,b2]=bp(x_in,y_in)

step = input('����������');
s = input('ѧϰ���ӣ�');
in = 9;                            % ������Ԫ����
hid = input('���ز���Ԫ������');    % ���ز���Ԫ����n
out = 1;                            % �������Ԫ����

w1 = randn(hid,in);             % ����hid*in���󣬼�����㵽���ز��Ȩֵ����ÿһ�д���һ�����㵥Ԫ��Ȩֵ
b1 = randn(hid,1);               % ����out*1���󣬼��������Ԫ��ƫֵ
w2 =randn(out,hid);             % ����out*hid���󣬼����ز㵽������Ȩֵ����
b2 = randn(out,1);             % ����hid*1���󣬼����ز���Ԫ��ƫֵ        


for i=0:step        %�ظ�step��
    
    % ÿ�ζ�ȡһ�����������������
    for j=1:3
        x1 = x_in(:,j);       % һ�ζ�ȡһ������
        y1 = y_in(:,j);       % ���

        hid_ = fp(w1,b1,x1);      % ����������Ԫ�����
        out_ = fp(w2,b2,hid_);    % �����������Ԫ�����

        %���¹�ʽ��ʵ�֣����͵ķ��򴫲��㷨���¸�Ȩֵ
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