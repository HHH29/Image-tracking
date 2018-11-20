function TBD_tracker_V01
clc;
close all;
clear;

addpath KPMtools;   %�ѿ��������˲���������ӵ���ǰ·��
%load HSV_histograms_2;    %��Ҫ���ٵ�Ŀ����Ϣ����
DATA_PATH = sprintf('data/');

x_dim= 4;   %״̬�ռ��ά��
model.A=eye(4);   %�����Ľ׵�λ����
model.sigmax= 5;
model.sigmay= 5;
model.sigmaw= 2;
model.sigmah= 2;
P_S= 0.8;   %ÿ��Ŀ��Ĵ�����
L_b=2;   %ÿ������Ŀ�����
model.bar_q= zeros(L_b,1);	%ÿ������Ŀ��Ĵ��ڸ���
model.bar_x= cell(L_b,1);   %ÿ������Ŀ��������λ��

model.bar_q(1)=1/10;
model.bar_x{1}=[1 170
                1 110
                10 40
                20 60];
            
model.bar_q(2)=1/10;
model.bar_x{2}=[180 310
                1 110
                10 40
                10 60];
            
model.bar_q(3)=1/10; 
model.bar_x{3}=[180 310
                120 230
                10 40
                10 60];
            
model.bar_q(4)=1/10; 
model.bar_x{4}=[1 170
                120 230
                10 40
                10 60];

Tmax= 50;  %Ŀ���������
T_threshold= 0.001;  %ɾ��Ŀ�����ֵ
f_unoccupied= 0.996;
Lmax_born= 10000;  %ÿ������Ŀ������������ 
Lmax_existing= 500;  %ÿ�����Ŀ������������ 
Lmin= 10;   %%ÿ��Ŀ�����С������ 

figure('Name', 'My Trial');
set(gcf,'DoubleBuffer','on');

%����data�ļ���������.bmp��ʽ��ͼƬ���������ݴ洢��imgLis������
%imgList = dirKPM(strcat(DATA_PATH, '*.bmp'));
%numImages = length(imgList);

%��ȡ��һ��ͼƬ
%filename = sprintf('%s%s', DATA_PATH, imgList{1});
%img = imread(filename);
%���ͼƬ�ǹ涨�ĳߴ磬��������Ϊ��ǰͼƬ���������ͼƬ��СΪ�涨�ߴ�
%[imgHeight,imgWidth,~] = size(img);
%if imgHeight == 240 && imgWidth == 360
%cur_img = img;
%else
%cur_img = imresize(img, [240 360]);
%end

%figure('Name', 'My Trial');
%set(gcf,'DoubleBuffer','on');   %����˫���棬��ֹͼ����˸
%scrsz = get(0,'ScreenSize');    %�õ���Ļ�ֱ���
%figposmatrix=[scrsz(3)*0.05 scrsz(4)*0.35 scrsz(3)*0.9 scrsz(4)*0.6];
%set(gcf, 'Position',figposmatrix);  %ͼ�񴰿ڴ�С����
%uicontrol('String', 'Pause', 'Callback', 'set(gcf, ''UserData'', 1)', 'Position', [70 10 50 20]);   %��ť��Pause��
%uicontrol('String', 'Close', 'Callback', 'set(gcf, ''UserData'', 999)', 'Position', [20 10 50 20]); %��ť��Close��
%set(gcf, 'UserData', 0);

%�õ�Ŀ��ģ��ĳ�ʼ����
I=imread('E:\�ļ�\��ѧ�о�\SRTP\����\CBMeMBer\data\1.bmp');
%��ʾ��һ֡����
imagesc(I);
%%�ڵ�һ֡��ͨ������ֶ�ѡ������Ŀ��
rect = getrect();
x1 = rect(1); 
x2 = rect(1) + rect(3);
y1 = rect(2);
y2 = rect(2) + rect(4);

%�õ���ʼ����Ŀ������������
y=round((y1+y2)/2);
%�õ�����Ŀ����������Բ�ĳ��̰����ƽ��
%hx=((x2-x1)/2)^2;
%hy=((y2-y1)/2)^2;
upper_hists=I(y1:y,x1:x2,:);
lower_hists=I(y:y2,x1:x2,:);
%compute_like(upper_hists_2,lower_hists_2,upper_hists,lower_hists)


time=0;
while time<179
    clear q_predict N_predict w_predict X_predict;
    time=time+1; pause(0.01);
    a=num2str(time);
    filename = sprintf('%s%s%s', DATA_PATH, a, '.bmp');
    img = imread(filename); %��ȡ��time��ͼƬ

%���ͼƬ�ǹ涨�ĳߴ磬��������Ϊ��ǰͼƬ���������ͼƬ��СΪ�涨�ߴ�
    [imgHeight, imgWidth , ~] = size(img);
    if imgHeight == 240 && imgWidth == 360
        cur_img = img;
    else
        cur_img = imresize(img, [240 360]);
    end


    if time==1
        L_predict= L_b;
        q_predict= model.bar_q;
        for j=1:L_b
            N_predict_unconstrained= max(round(model.bar_q(j)*Lmax_born),Lmin);
            [X_predict{j},~]= Constrained(gen_birthstate_density(model,j,N_predict_unconstrained)); %#ok<AGROW>
            N_predict(j)= size(X_predict{j},2); %#ok<AGROW>
            w_predict{j}= ones(N_predict(j),1)/N_predict(j); %#ok<AGROW>
        end
    else
        L_predict= L_b+ L_update;
        q_predict= model.bar_q; 
        for j=1:L_b
            N_predict_unconstrained= max(round(model.bar_q(j)*Lmax_born),Lmin);
            [X_predict{j},~]= Constrained(gen_birthstate_density(model,j,N_predict_unconstrained));
            N_predict(j)= size(X_predict{j},2);
            w_predict{j}= ones(N_predict(j),1)/N_predict(j);
        end
        count= L_b;
        
        for j=1:L_update %existing
            count= count+ 1;
            q_predict(count)= q_update(j)* P_S;
            [X_predict{count},indices]= Constrained(gen_newstate(model,X_update{j}));
            N_predict(count)= size(X_predict{count},2);
            w_predict{count}= w_update{j}(indices);
            w_predict{count}=w_predict{count}/sum(w_predict{count});
        end
    end
    
    clear q_update N_update w_update X_update;
    L_update= L_predict;
    X_update= X_predict;
    N_update= N_predict;
    for j=1:L_predict
        g_fun =compute_likelihood(f_unoccupied,upper_hists,lower_hists,X_predict{j},cur_img);
        w_temp= w_predict{j}.*g_fun;
        sum_w_temp = sum(w_temp);
        q_update(j)= min(1/(1 + abs(1-q_predict(j))*(q_predict(j)*sum_w_temp)),0.999); %#ok<AGROW>
        w_update{j}= w_predict{j}.*g_fun/(sum_w_temp); %#ok<AGROW>
    end
    
    for j=1:L_update
        N_update(j)= max(round(q_update(j)*Lmax_existing),Lmin);
        idxs= resample(w_update{j},N_update(j));
        w_update{j}= ones(N_update(j),1)/N_update(j);
        X_update{j}= X_update{j}(:,idxs);
    end
    
    idx= find( q_update > T_threshold );
    N_update2= N_update;
    q_update2= q_update;
    w_update2= w_update;
    X_update2= X_update;
    N_update= zeros(length(idx),1);
    q_update= zeros(length(idx),1);
    X_update= cell(length(idx),1);
    w_update= cell(length(idx),1);
    
    for i=1:length(idx)
        N_update(i)= N_update2(idx(i));
        q_update(i)= q_update2(idx(i));
        w_update{i}= w_update2{idx(i)};
        w_update{i}=w_update{i}/sum(w_update{i});
        X_update{i}= X_update2{idx(i)};
    end
    L_update= length(idx);
    
    if(L_update>0)
        [L_update,N_update,q_update,X_update,w_update]= merge_targets(q_update,X_update,w_update,1,inf);
    end
    
    if L_update > Tmax
        [~,idx]= sort(-q_update);
        N_update2= N_update;
        q_update2= q_update;
        w_update2= w_update;
        X_update2= X_update;
        N_update= zeros(Tmax,1);
        q_update= zeros(Tmax,1);
        w_update= cell(Tmax,1);
        X_update= cell(Tmax,1);
        for i=1:Tmax
            N_update(i)= N_update2(idx(i));
            q_update(i)= q_update2(idx(i));
            w_update{i}= w_update2{idx(i)};
            w_update{i}= w_update{i}/sum(w_update{i});
            X_update{i}= X_update2{idx(i)};
        end
        L_update= Tmax;
    end
    
    idx= find(q_update>0.001);
    hat_X=[]; hat_q=[];
    for j=1:length(idx)
        targest= sum(X_update{idx(j)}.*repmat(w_update{idx(j)}',[x_dim 1]),2);
        hat_X= [hat_X targest]; %#ok<AGROW>
        hat_q= [hat_q q_update(idx(j))]; %#ok<AGROW>
    end
    
    imagesc(cur_img); axis image;
    title('\bf\fontsize{14} Tracking Results');
    
    NO_PEOPLE=size(hat_X,2);
    
    if NO_PEOPLE>0
        for PNO=1:NO_PEOPLE
            rectangle('Position', ...
            [round(hat_X(1,PNO)) round(hat_X(2,PNO)) ...
            round(hat_X(3,PNO)) round(hat_X(4,PNO))],...
            'EdgeColor','r','LineWidth',2);
        end
    end



%usr_cmd = get(gcf, 'UserData');
%switch usr_cmd
%case 999
%close(gcf);
%case 1
%waitforbuttonpress;
%set(gcf, 'UserData', 0);
%end


end
%waitforbuttonpress;
%close(gcf);
end