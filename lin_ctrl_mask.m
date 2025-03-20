classdef lin_ctrl_mask

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
        function MaskInitialization(maskInitContext)
            maskWorkspace = maskInitContext.MaskWorkspace;

            % Retrieving parameters
            Krp_angle = maskWorkspace.get('Krp_angle');
            Krp_angle_i = maskWorkspace.get('Krp_angle_i');
            Krp_rate = maskWorkspace.get('Krp_rate');
            Krp_accel = maskWorkspace.get('Krp_accel');
            
            Ky_angle = maskWorkspace.get('Ky_angle');
            Ky_rate = maskWorkspace.get('Ky_rate');
            Ky_accel = maskWorkspace.get('Ky_accel');

            Kr_rate = maskWorkspace.get('Kr_rate');
            
            Kh_angle = maskWorkspace.get('Kh_angle');
            Kh_rate = maskWorkspace.get('Kh_rate');
            Kh_accel = maskWorkspace.get('Kh_accel');

            Kp_angle = [Krp_angle; Krp_angle; Ky_angle; Kh_angle; Kh_angle; Kr_rate];
            Ki_angle = [Krp_angle_i; Krp_angle_i; 0; 0; 0; 0];
            Kd_rate = [Krp_rate; Krp_rate; Ky_rate; Kh_rate; Kh_rate; 0];
            Ka_accel = [Krp_accel; Krp_accel; Ky_accel; Kh_accel; Kh_accel; 0];

            maskWorkspace.set('Kp_angle', Kp_angle);
            maskWorkspace.set('Ki_angle', Ki_angle);
            maskWorkspace.set('Kd_rate', Kd_rate);
            maskWorkspace.set('Ka_accel', Ka_accel);
        end

        % Use the code browser on the left to add the callbacks.

    end
end