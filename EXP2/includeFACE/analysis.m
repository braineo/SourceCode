% GUI�̃t�H���g
set(0, 'defaultUicontrolFontName', 'MS UI Gothic');
% ���̃t�H���g
set(0, 'defaultAxesFontName', 'Times New Roman');
% �^�C�g���A���߂Ȃǂ̃t�H���g
set(0, 'defaultTextFontName', 'Times New Roman');
% GUI �̃t�H���g�T�C�Y
set(0, 'defaultUicontrolFontSize', 19);
% ���̃t�H���g�T�C�Y
set(0, 'defaultAxesFontSize',19);
% �^�C�g���A���߂Ȃǂ̃t�H���g�T�C�Y
set(0, 'defaultTextFontSize', 19);

%savefile = '../../storage/EXP2_includeFAC_Test.mat'
savefile = '../../storage/EXP2_includeFAC_20111117.mat'
load(savefile);
% 'weight_tune','weight_tuneA','weight_tuneB','weight_all_A','weight_all_B',
% 'mNSS_tuned1','mNSS_tunedA','mNSS_tunedB','mNSS_tuned_all_A','mNSS_tuned_all_B','mTesting'
Y = zeros(4, 3);%(First n Saccades, legends)
e = zeros(4, 3);%
for order_fromfirst=1:4
    vals_tuned1 = [];
    vals_tunedA = [];
    vals_tunedB = [];
    vals_tuned_all_A = [];
    vals_tuned_all_B = [];
    vals_flat = [];
    for trial=1:10
        vals_tuned1 = [vals_tuned1 mean(mNSS_tuned1{trial}{order_fromfirst})];
        vals_tunedA = [vals_tunedA mean(mNSS_tunedA{trial}{order_fromfirst})];
        vals_tunedB = [vals_tunedB mean(mNSS_tunedB{trial}{order_fromfirst})];
        vals_tuned_all_A = [vals_tuned_all_A mean(mNSS_tuned_all_A{trial}{order_fromfirst})];
        vals_tuned_all_B = [vals_tuned_all_B mean(mNSS_tuned_all_B{trial}{order_fromfirst})];
        %vals_flat = [vals_flat mean(mNSS_flat{trial}{order_fromfirst})];
    end
    fprintf('order_fromfirst,tuned1,std\n');
    fprintf('%d,%f,%f,%f,%f\n', order_fromfirst,...
    mean(vals_tuned1), std(vals_tuned1), ...
    mean(vals_tuned_all_A), std(vals_tuned_all_A));
    
    [tuned1_max_value,tuned1_max_idx] = max(vals_tuned1);
    [tunedA_max_value,tunedA_max_idx] = max(vals_tunedA);
    [tunedB_max_value,tunedB_max_idx] = max(vals_tunedB);
    [tuned_all_max_value,tuned_all_max_idx] = max(vals_tuned_all_A);
    
    fprintf('order_fromfirst,tuned1_max_idx,value,tunedA_max_idx,value,tunedB_max_idx,value,tuned_all_max_idx,value\n');
    fprintf('%d,%d,%f,%d,%f,%d,%f,%d,%f\n', order_fromfirst,...
    tuned1_max_idx, tuned1_max_value, tunedA_max_idx, tunedA_max_value, tunedB_max_idx, tunedB_max_value, tuned_all_max_idx, tuned_all_max_value);

    %Y(order_fromfirst, 1) = mean(vals_tuned1);
    Y(order_fromfirst, 1) = mean(vals_tunedA);
    %Y(order_fromfirst, 3) = mean(vals_tunedB);
    Y(order_fromfirst, 2) = mean(vals_tuned_all_A);
    %Y(order_fromfirst, 5) = mean(vals_tuned_all_B);
    %e(order_fromfirst, 1) = std(vals_tuned1);
    e(order_fromfirst, 1) = std(vals_tunedA);
    %e(order_fromfirst, 3) = std(vals_tunedB);
    e(order_fromfirst, 2) = std(vals_tuned_all_A);
    %e(order_fromfirst, 5) = std(vals_tuned_all_B);
end

% ������Ȃ�
%Y(1, 3) = 1.151540;
%Y(2, 3) = 1.110507;
%Y(3, 3) = 1.074219;
%Y(4, 3) = 1.053586;
Y(1, 3) = 1.367625
Y(2, 3) = 1.274362
Y(3, 3) = 1.217889
Y(4, 3) = 1.188054

% �_�O���t�̕`��
figure, h = bar(Y,'hist'); % �n���h�����擾
hold on

[numgroups, numbars] = size(Y); % numgroups: �O���[�v��, numbars: �W�{��

% �e�_�O���t��X���W�l���擾
xdata = get(h,'XData'); % �o�͂̓Z���z��
% X���W����e�_�O���t�̒��S���W���v�Z
centerX = cellfun(@(x)(x(1,:)+x(3,:))/2,xdata,'UniformOutput', false);

% E = repmat(e,numgroups,1); % �O���t�\���p�Ƀf�[�^���g��
C = {'r', 'b', 'g'}; % �G���[�o�[�̐F

% �W���΍���_�O���t�ɏd�˂ĕ`��
for i = 1:numbars
errorbar(centerX{i,:}, Y(:,i), e(:,i), C{i},...
'linestyle', 'none','LineWidth',2);
end
title('NSS Performance(10 trials)');
xlabel('First n Saccades');
ylabel('NSS');
ylim([1.1,2.0]);
set(gcf,'Color','none');
set(gcf,'InvertHardcopy','off');
% legend('proposed','proposedA','proposedB','undivided learningA','undivided learningB','flat');
legend('proposed','undivided learning','flat');
print('-depsc2', 'Output.eps');
