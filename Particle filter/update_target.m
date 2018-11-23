function [new_target_histgram,pre_probability]=update_target(target_histgram,Sample_histgram,Sample_probability,pre_probability,Estimate,N,v_count,loop,resample_judge)
if(resample_judge==0 || resample_judge==1)
    %ʹ��ֱ��ѡ�������N��������ѡ��N/5����Ȩֵ���ӣ��õ���Щ���ӵ�λ��
    n=N/5;
    location=zeros(1,n);
    for i=1:n
        k=i;
        for j=i+1:N
            if(Sample_probability(j)>Sample_probability(k))
                k=j;
            end
        end 
        tmp = Sample_probability(k);
        Sample_probability(k) = Sample_probability(i);
        Sample_probability(i) = tmp;
        location(i)=k;

        %if(k~=i)
            %Sample_probability(k)=-1;
        %else
            %location(i)=i;
        %end
    end

    %����ǰn����Ȩֵ�����ӵ�Ȩֵ�洢��model_probability
    model_probability=zeros(1,n);
    for i=1:n
        model_probability(i)=Sample_probability(i);
    end
    sum_model_probability=sum(model_probability);

    %Ȩֵ��һ��
    model_probability=model_probability./sum_model_probability;

    %��ƽ��ģ��
    average_target=zeros(1,v_count);
    for i=1:v_count
        j=1;
        while(j<=n)
            average_target(i)=average_target(i)+model_probability(j)*Sample_histgram(j,i);
            j=j+1;
        end
    end

%�����ز���������е�������ƽ��ģ��
else
    average_target=zeros(1,v_count);
    for i=1:v_count
        j=1;
        while(j<=N)
            average_target(i)=average_target(i)+Sample_probability(j)*Sample_histgram(j,i);
            j=j+1;
        end
    end
end

%�õ����µ�ģ��
new_target_histgram=0.1*average_target+0.9*target_histgram;

if(loop<=10)
    pre_probability(loop)=Estimate(loop).probability;
else
    for k=1:9
        pre_probability(k)=pre_probability(k+1);
    end
    pre_probability(10)=Estimate(loop).probability;
end

