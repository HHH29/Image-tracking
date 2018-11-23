clear;
clc;

%��HSV�ռ��У���������ɫ����ͨ������ϳ�Ϊһά��������(ֱ��ͼ)ʱ��һά���������Ĵ�СΪv_count
v_count=331;
%�������ӵĸ���
N=2000;
%��Ƶ�����е�ͼ��֡��
n=40;
%��һ֡ͼ������
first=100;
%��˹�ֲ�����
new_sita=0.2;
%Ŀ����������ʱ�̵��ƶ��ٶȣ���άvx,vy��
vx=[0,0,0];
vy=[0,0,0];
%��ȡĿ���ٶȵ�ʱ���õ�����runtime
runtime=3;
%�洢�ṹ���ָ��
struct_index=0;
%����������ӵķ���
sigma_x=5;
sigma_y=5;
%ǰ10֡ͼ����Ŀ��ģ������ƶ�
pre_probability=zeros(1,10);
%�ж��Ƿ�����ز���
resample_judge=0;

%�õ�Ŀ��ģ��ĳ�ʼ����
I=imread('E:\�ļ�\��ѧ�о�\SRTP\����\�����˲�\version3.0\����ͼƬ8\100.jpg');
%��ʾ��һ֡����
imshow(I);
%%�ڵ�һ֡��ͨ������ֶ�ѡ������Ŀ��
rect = getrect();
x1 = rect(1); 
x2 = rect(1) + rect(3);
y1 = rect(2);
y2 = rect(2) + rect(4);

%�õ���ʼ����Ŀ������������
x=round((x1+x2)/2);
y=round((y1+y2)/2);
%�õ�����Ŀ����������Բ�ĳ��̰����ƽ��
hx=((x2-x1)/2)^2;
hy=((y2-y1)/2)^2;
%upper_hists=I(y1:y,x1:x2,:);
%lower_hists=I(y:y2,x1:x2,:);
%�õ�ͼ�εı߽�
sizeimage=size(I);
image_boundary_x=int16(sizeimage(2)); % ��
image_boundary_y=int16(sizeimage(1)); % ��

[H,S,V]=rgb_to_rank(I);
%��ʼ�����õ����ӵĳ�ʼ�ֲ�������ʼȨֵΪ1/N
[Sample_Set,Sample_probability,Estimate,target_histgram]=initialize(x,y,hx,hy,H,S,V,N,image_boundary_x,image_boundary_y,v_count,new_sita);
pre_probability(1)=Estimate(1).probability;


%�ӵڶ�֡����ѭ�������Ľ�����ȥ
for loop=2:n
    struct_index=struct_index+1;
    a=num2str(loop+first-1);
    %�򿪲���ʾͼƬ
    b=[a,'.jpg'];
    b=['E:\�ļ�\��ѧ�о�\SRTP\����\�����˲�\version3.0\����ͼƬ8\',b]; %#ok<AGROW>
    I=imread(b);
    [H,S,V]=rgb_to_rank(I);
    %�����������
    

    [Sample_Set,after_prop]=reproduce(Sample_Set,vx,vy,image_boundary_x,image_boundary_y,I,N,sigma_x,sigma_y,runtime);    
    %�ó�������Ŀ����ڵ�ǰ֡��Ԥ��λ��
    [Sample_probability,Estimate,vx,vy,TargetPic,Sample_histgram]=evaluate(Sample_Set,Estimate,target_histgram,new_sita,loop,after_prop,H,S,V,N,image_boundary_x,image_boundary_y,v_count,vx,vy,hx,hy,Sample_probability);
    %ģ�����ʱ���ز����ж�ʱ����Ҫ�õ���һ����ȨֵSample_probability 
    %kpl = Estimate(loop).probability
    
    
    %ģ�����
    if(loop<=10) %ǰ10֡���������������Ҫ������д���
        sum_probability=0;
        for p=1:loop-1
            sum_probability=sum_probability+pre_probability(p);
        end 
        mean_probability=sum_probability/(loop-1);
    else %ֱ����ȡ��ֵ
        mean_probability=mean(pre_probability);
    end
    
   %�����һʱ�̵���ɫֱ��ͼ�����Ա�ƽ��ֵ�Ŀ����Դ�����Ҫ�������ɫֱ��ͼ������ɫֱ��ͼģ�����
    if(Estimate(loop).probability>mean_probability+1)
        [target_histgram,pre_probability]=update_target(target_histgram,Sample_histgram,Sample_probability,pre_probability,Estimate,N,v_count,loop,resample_judge);
   
    %�����һʱ�̵���ɫֱ��ͼ�����Ա�ƽ��ֵ�Ŀ�����С�����Բ�����ģ����£�����Ҫ��pre_probability���и��²���   
    else
        if(loop>10) 
             for k=1:9
                 pre_probability(k)=pre_probability(k+1);
             end
             pre_probability(10)=Estimate(loop).probability;
        else 
            pre_probability(loop)=Estimate(loop).probability;
        end
    end
     
    resample_judge=0;
        
    %�ж��Ƿ���Ҫ�ز���
    back_sum_weight=0;
    for judge=1:N
        back_sum_weight=back_sum_weight+(Sample_probability(judge))^2;
    end
    sum_weight=1/back_sum_weight;
    if(sum_weight<N)
        %�ز�������
        usetimes=reselect(Sample_probability,N);
        [Sample_Set,Sample_probability]=assemble(Sample_Set,usetimes,Sample_probability,N); %�����������
        resample_judge=1;
    end
    
    
%�õ�Ŀ���˶��Ĺ켣
if(struct_index==1)
    routine.x=round(Estimate(loop).x);
    routine.y=round(Estimate(loop).y);
else
    routine(struct_index).x=round(Estimate(loop).x); %#ok<SAGROW>
    routine(struct_index).y=round(Estimate(loop).y); %#ok<SAGROW>
end
i=1;
j=1;
while(j<=struct_index)
    for new_x=routine(j).x-i:routine(j).x+i
       for new_y=routine(j).y:routine(j).y+i
            TargetPic(new_y,new_x,1)=0;
            TargetPic(new_y,new_x,2)=0;
            TargetPic(new_y,new_x,3)=255;
       end
    end   
    j=j+1;
end
     imshow(TargetPic);


end



