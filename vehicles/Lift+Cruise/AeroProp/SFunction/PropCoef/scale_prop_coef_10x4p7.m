function scale_prop_coef_10x4p7(scaling_factor)
    % Propeller data taken from the UIUC propeller data base

    funcDir = fileparts(mfilename('fullpath'));
    
    data1 = load('apcsf_10x4p7_4014.csv');
    data2 = load('apcsf_10x4p7_4997.csv');
    data3 = load('apcsf_10x4p7_5018.csv');
    data4 = load('apcsf_10x4p7_6020.csv');
    data5 = load('apcsf_10x4p7_6023.csv');
    data6 = load('apcsf_10x4p7_6512.csv');
    data7 = load('apcsf_10x4p7_6513.csv');
    
    
    J = [ data1(:,1); data2(:,1); data3(:,1); data4(:,1); data5(:,1); data6(:,1); data7(:,1) ];
    Ct = [ data1(:,2); data2(:,2); data3(:,2); data4(:,2); data5(:,2); data6(:,2); data7(:,2) ];
    Cp = [ data1(:,3); data2(:,3); data3(:,3); data4(:,3); data5(:,3); data6(:,3); data7(:,3) ];
    
    Ct_p = polyfit(J,Ct,2);
    Cp_p = polyfit(J,Cp,2);
    
    Jb = 0:0.01:1;
    
    Re_factor = scaling_factor^1.5;
    
    Ct_scaled = Ct*Re_factor^(-0.2);
    Cp_scaled = Cp * Re_factor^(-0.1);
    
    Ct_p_scaled = polyfit(J,Ct_scaled,2);
    Cp_p_scaled = polyfit(J,Cp_scaled,2);
    
    APCSF_10x4p7_scaled_coef = [Ct_p_scaled' Cp_p_scaled'];
    save(fullfile(funcDir, 'APCSF_10x4p7_scaled_coef.mat'), ...
         'APCSF_10x4p7_scaled_coef');
end