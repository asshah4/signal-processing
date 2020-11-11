function [DurX,DurY,DurZ,SumPN_X,SumPN_Y,SumPN_Z,loc_DB,loc_CS,wQRS_X_P,wQRS_Y_P,wQRS_Z_P,beatPVC,beatPVC_l]=find_QRSdur(QRS_xlead,QRS_ylead,QRS_zlead,fs)

AmpX=[]; ArX=[]; DurX=[]; SumPN_X=[];
AmpY=[]; ArY=[]; DurY=[]; SumPN_Y=[];
AmpZ=[]; ArZ=[]; DurZ=[]; SumPN_Z=[];

th_mn=6; %8

      for i=1:size(QRS_xlead,2)
          Temp=[];
          Temp=QRS_xlead(~isnan(QRS_xlead(:,i)),i);
          
          DurX(i)=length(Temp);
           
          if mean(Temp)>0
             AmpX(i)=max(Temp);
          else
             AmpX(i)=min(Temp);
          end
              
          if sum(Temp)>0
              ArX(i)=max(Temp);
          else
              ArX(i)=min(Temp);
          end
          
          SumPN_X(i,1)=sum(Temp(Temp>0));
          SumPN_X(i,2)=sum(Temp(Temp<0));
      end
      
      for i=1:size(QRS_ylead,2)
          Temp=[];
          Temp=QRS_ylead(~isnan(QRS_ylead(:,i)),i);
          
          DurY(i)=length(Temp);
         
          if mean(Temp)>0
             AmpY(i)=max(Temp);
          else
             AmpY(i)=min(Temp);
          end
              
          if sum(Temp)>0
              ArY(i)=max(Temp);
          else
              ArY(i)=min(Temp);
          end
          
          SumPN_Y(i,1)=sum(Temp(Temp>0));
          SumPN_Y(i,2)=sum(Temp(Temp<0));
      end

      for i=1:size(QRS_zlead,2)
          Temp=[];
          Temp=QRS_zlead(~isnan(QRS_zlead(:,i)),i);
          
          DurZ(i)=length(Temp);

          if mean(Temp)>0
             AmpZ(i)=max(Temp);
          else
             AmpZ(i)=min(Temp);
          end 
              
          if sum(Temp)>0
              ArZ(i)=max(Temp);
          else
              ArZ(i)=min(Temp);
          end
          
          SumPN_Z(i,1)=sum(Temp(Temp>0));
          SumPN_Z(i,2)=sum(Temp(Temp<0));
      end
      
      
      beatPVC=[];
      beatPVC_l=[];

      if ((max(abs(diff(DurX)))>th_mn) + (max(abs(diff(DurY)))>th_mn) + (max(abs(diff(DurZ)))>th_mn))>=2
          
          %values higher than threshold
          pv_x_h=[]; pv_y_h=[]; pv_z_h=[]; 
          
          pv_x_h=find(DurX>(mean(DurX)+mean(DurX)/10));
          pv_y_h=find(DurY>(mean(DurY)+mean(DurY)/10));
          pv_z_h=find(DurZ>(mean(DurZ)+mean(DurZ)/10));
          
          loc1_h=find(ismember(pv_x_h,pv_y_h)==1);
          loc2_h=find(ismember(pv_x_h,pv_z_h)==1);
          loc3_h=find(ismember(pv_y_h,pv_z_h)==1);
          
          if max([~isempty(loc1_h) ~isempty(loc2_h) ~isempty(loc3_h)])~=0
              [~,locV]=max([length(loc1_h) length(loc2_h) length(loc3_h)]);

              switch locV
                  case 1
                      beatPVC=pv_x_h(loc1_h);
                  case 2
                      beatPVC=pv_x_h(loc2_h);
                  case 3
                      beatPVC=pv_y_h(loc3_h);
                  otherwise
                      disp('');
              end
          end
          
          
          %values lower than threshold
          pv_x_l=[]; pv_y_l=[]; pv_z_l=[]; 
          
          pv_x_l=find(DurX<(mean(DurX)-mean(DurX)/10));
          pv_y_l=find(DurY<(mean(DurY)-mean(DurY)/10));
          pv_z_l=find(DurZ<(mean(DurZ)-mean(DurZ)/10));
          
          loc1_l=find(ismember(pv_x_l,pv_y_l)==1);
          loc2_l=find(ismember(pv_x_l,pv_z_l)==1);
          loc3_l=find(ismember(pv_y_l,pv_z_l)==1);
          
          if max([~isempty(loc1_l) ~isempty(loc2_l) ~isempty(loc3_l)])~=0
              [~,locV2]=max([length(loc1_l) length(loc2_l) length(loc3_l)]);

              switch locV2
                  case 1
                      beatPVC_l=pv_x_l(loc1_l);
                  case 2
                      beatPVC_l=pv_x_l(loc2_l);
                  case 3
                      beatPVC_l=pv_y_l(loc3_l);
                  otherwise
                      disp('');
              end
          end
          
          
      end
      
      
      % Check Amplitude
      PN_Amp_X=[]; PN_Amp_Y=[]; PN_Amp_Z=[];
      PN_Amp_X=AmpX>0;
      PN_Amp_Y=AmpY>0;
      PN_Amp_Z=AmpZ>0;
      
      PPX=length(find(PN_Amp_X==1))/length(PN_Amp_X); % Percentage of positive amplitudes
      PPY=length(find(PN_Amp_Y==1))/length(PN_Amp_Y);
      PPZ=length(find(PN_Amp_Z==1))/length(PN_Amp_Z);
      
      loc_DB_X=[]; loc_DB_Y=[]; loc_DB_Z=[]; loc_DB=[];
      
      if PPX~=0 && PPX~=1
          if PPX>0.5
              loc_DB_X=find(PN_Amp_X==0);
          else
              loc_DB_X=find(PN_Amp_X==1);
          end
      end
      
      if PPY~=0 && PPY~=1
          if PPY>0.5
              loc_DB_Y=find(PN_Amp_Y==0);
          else
              loc_DB_Y=find(PN_Amp_Y==1);
          end
      end
      
      if PPZ~=0 && PPZ~=1
          if PPZ>0.5
              loc_DB_Z=find(PN_Amp_Z==0);
          else
              loc_DB_Z=find(PN_Amp_Z==1);
          end
      end
      
%       if max([~isempty(loc_DB_X) ~isempty(loc_DB_Y) ~isempty(loc_DB_Z)])~=0
%           [~,locA]=max([length(loc_DB_X) length(loc_DB_Y) length(loc_DB_Z)]);
%           
%            switch locA
%               case 1
%                   loc_DB=loc_DB_X;
%               case 2
%                   loc_DB=loc_DB_Y;
%               case 3
%                   loc_DB=loc_DB_Z;
%               otherwise
%                   disp('');
%            end
%       end
      
      if max([~isempty(loc_DB_X) ~isempty(loc_DB_Z)])~=0
          [~,locA]=max([length(loc_DB_X) length(loc_DB_Z)]);
          
           switch locA
              case 1
                  loc_DB=loc_DB_X;
              case 2
                  loc_DB=loc_DB_Z;
              otherwise
                  disp('');
           end
      end
        
            
%       % Check Area
%       PN_Ar_X=[]; PN_Ar_Y=[]; PN_Ar_Z=[];
%       PN_Ar_X=ArX>0;
%       PN_Ar_Y=ArY>0;
%       PN_Ar_Z=ArZ>0;
%       
%       PAX=length(find(PN_Ar_X==1))/length(PN_Ar_X); % Percentage of positive area
%       PAY=length(find(PN_Ar_Y==1))/length(PN_Ar_Y);
%       PAZ=length(find(PN_Ar_Z==1))/length(PN_Ar_Z);
%       
%       loc_DB2_X=[]; loc_DB2_Y=[]; loc_DB2_Z=[]; loc_DB2=[];
%       
%       if PAX~=0 && PAX~=1
%           if PAX>0.5
%               loc_DB2_X=find(PN_Ar_X==0);
%           else
%               loc_DB2_X=find(PN_Ar_X==1);
%           end
%       end
%       
%       if PAY~=0 && PAY~=1
%           if PAY>0.5
%               loc_DB2_Y=find(PN_Ar_Y==0);
%           else
%               loc_DB2_Y=find(PN_Ar_Y==1);
%           end
%       end
%       
%       if PAZ~=0 && PAZ~=1
%           if PAZ>0.5
%               loc_DB2_Z=find(PN_Ar_Z==0);
%           else
%               loc_DB2_Z=find(PN_Ar_Z==1);
%           end
%       end
%       
% %       if max([~isempty(loc_DB2_X) ~isempty(loc_DB2_Y) ~isempty(loc_DB2_Z)])~=0
% %           [~,loc2A]=max([length(loc_DB2_X) length(loc_DB2_Y) length(loc_DB2_Z)]);
% %           
% %            switch loc2A
% %               case 1
% %                   loc_DB2=loc_DB2_X;
% %               case 2
% %                   loc_DB2=loc_DB2_Y;
% %               case 3
% %                   loc_DB2=loc_DB2_Z;
% %               otherwise
% %                   disp('');
% %            end
% %       end
%       
%       if max([~isempty(loc_DB2_X) ~isempty(loc_DB2_Z)])~=0
%           [~,loc2A]=max([length(loc_DB2_X) length(loc_DB2_Z)]);
%           
%            switch loc2A
%               case 1
%                   loc_DB2=loc_DB2_X;
%               case 2
%                   loc_DB2=loc_DB2_Z;  
%               otherwise
%                   disp('');
%            end
%       end
      
      
%       loc1_Am=find(ismember(loc_DB_X,loc_DB_Y)==1);
%       loc2_Am=find(ismember(loc_DB_X,loc_DB_Z)==1);
%       loc3_Am=find(ismember(loc_DB_Y,loc_DB_Z)==1);
%       
%       if max([~isempty(loc1_Am) ~isempty(loc2_Am) ~isempty(loc3_Am)])~=0
%           [~,locA]=max([length(loc1_Am) length(loc2_Am) length(loc3_Am)]);
% 
%           switch locA
%               case 1
%                   loc_DB=loc_DB_X(loc1_Am);
%               case 2
%                   loc_DB=loc_DB_X(loc2_Am);
%               case 3
%                   loc_DB=loc_DB_Y(loc3_Am);
%               otherwise
%                   disp('');
%           end
%       end
          

      % Check positive and negative area
      SumPN_X_N(1:length(SumPN_X(:,1)),2)=0;
      SumPN_Y_N(1:length(SumPN_Y(:,1)),2)=0;
      SumPN_Z_N(1:length(SumPN_Z(:,1)),2)=0;
      
      SumPN_X_N(:,1)=SumPN_X(:,1)/max(SumPN_X(:,1));
      SumPN_X_N(:,2)=abs(SumPN_X(:,2))/max(abs(SumPN_X(:,2)));
      SumPN_Y_N(:,1)=SumPN_Y(:,1)/max(SumPN_Y(:,1));
      SumPN_Y_N(:,2)=abs(SumPN_Y(:,2))/max(abs(SumPN_Y(:,2)));
      SumPN_Z_N(:,1)=SumPN_Z(:,1)/max(SumPN_Z(:,1));
      SumPN_Z_N(:,2)=abs(SumPN_Z(:,2))/max(abs(SumPN_Z(:,2)));
      
      PX_U=[]; PX_D=[]; PY_U=[]; PY_D=[]; PZ_U=[]; PZ_D=[]; th_UD=0.2;
      PX_U=find(SumPN_X_N(:,1)>((max(SumPN_X_N(:,1))-min(SumPN_X_N(:,1)))/2)+th_UD);
      PX_D=find(SumPN_X_N(:,1)<((max(SumPN_X_N(:,1))-min(SumPN_X_N(:,1)))/2)-th_UD);
      PY_U=find(SumPN_Y_N(:,1)>((max(SumPN_Y_N(:,1))-min(SumPN_Y_N(:,1)))/2)+th_UD);
      PY_D=find(SumPN_Y_N(:,1)<((max(SumPN_Y_N(:,1))-min(SumPN_Y_N(:,1)))/2)-th_UD);
      PZ_U=find(SumPN_Z_N(:,1)>((max(SumPN_Z_N(:,1))-min(SumPN_Z_N(:,1)))/2)+th_UD);
      PZ_D=find(SumPN_Z_N(:,1)<((max(SumPN_Z_N(:,1))-min(SumPN_Z_N(:,1)))/2)-th_UD);
      PX_U=PX_U'; PX_D=PX_D';
      PY_U=PY_U'; PY_D=PY_D';
      PZ_U=PZ_U'; PZ_D=PZ_D';
      
      NX_U=[]; NX_D=[]; NY_U=[]; NY_D=[]; NZ_U=[]; NZ_D=[];
      NX_U=find(SumPN_X_N(:,2)>((max(SumPN_X_N(:,2))-min(SumPN_X_N(:,2)))/2)+th_UD);
      NX_D=find(SumPN_X_N(:,2)<((max(SumPN_X_N(:,2))-min(SumPN_X_N(:,2)))/2)-th_UD);
      NY_U=find(SumPN_Y_N(:,2)>((max(SumPN_Y_N(:,2))-min(SumPN_Y_N(:,2)))/2)+th_UD);
      NY_D=find(SumPN_Y_N(:,2)<((max(SumPN_Y_N(:,2))-min(SumPN_Y_N(:,2)))/2)-th_UD);
      NZ_U=find(SumPN_Z_N(:,2)>((max(SumPN_Z_N(:,2))-min(SumPN_Z_N(:,2)))/2)+th_UD);
      NZ_D=find(SumPN_Z_N(:,2)<((max(SumPN_Z_N(:,2))-min(SumPN_Z_N(:,2)))/2)-th_UD);
      NX_U=NX_U'; NX_D=NX_D';
      NY_U=NY_U'; NY_D=NY_D';
      NZ_U=NZ_U'; NZ_D=NZ_D';
      
      CS_X=[]; CS_Y=[]; CS_Z=[];
      
      if min([range(SumPN_X_N(:,1)),range(SumPN_X_N(:,2))])>0.2
          [~,locX_PN]=min([length(PX_U)+length(NX_U),length(PX_U)+length(NX_D),length(PX_D)+length(NX_U),length(PX_D)+length(NX_D)]);
          switch locX_PN
              case 1
                  CS_X=[PX_U,NX_U(~ismember(NX_U,PX_U))];
              case 2
                  CS_X=[PX_U,NX_D(~ismember(NX_D,PX_U))];
              case 3
                  CS_X=[PX_D,NX_U(~ismember(NX_U,PX_D))];
              case 4
                  CS_X=[PX_D,NX_D(~ismember(NX_D,PX_D))];
              otherwise
                  disp('');
          end
%           CS_X=CS_X';
      end
      
      if min([range(SumPN_Y_N(:,1)),range(SumPN_Y_N(:,2))])>0.2
          [~,locY_PN]=min([length(PY_U)+length(NY_U),length(PY_U)+length(NY_D),length(PY_D)+length(NY_U),length(PY_D)+length(NY_D)]);
          switch locY_PN
              case 1
                  CS_Y=[PY_U,NY_U(~ismember(NY_U,PY_U))];
              case 2
                  CS_Y=[PY_U,NY_D(~ismember(NY_D,PY_U))];
              case 3
                  CS_Y=[PY_D,NY_U(~ismember(NY_U,PY_D))];
              case 4
                  CS_Y=[PY_D,NY_D(~ismember(NY_D,PY_D))];
              otherwise
                  disp('');
          end
%           CS_Y=CS_Y';
      end
      
      if min([range(SumPN_Z_N(:,1)),range(SumPN_Z_N(:,2))])>0.2
          [~,locZ_PN]=min([length(PZ_U)+length(NZ_U),length(PZ_U)+length(NZ_D),length(PZ_D)+length(NZ_U),length(PZ_D)+length(NZ_D)]);
          switch locZ_PN
              case 1
                  CS_Z=[PZ_U,NZ_U(~ismember(NZ_U,PZ_U))];
              case 2
                  CS_Z=[PZ_U,NZ_D(~ismember(NZ_D,PZ_U))];
              case 3
                  CS_Z=[PZ_D,NZ_U(~ismember(NZ_U,PZ_D))];
              case 4
                  CS_Z=[PZ_D,NZ_D(~ismember(NZ_D,PZ_D))];
              otherwise
                  disp('');
          end
%           CS_Z=CS_Z';
      end
      
%       loc1_CS=find(ismember(CS_X,CS_Y)==1);
%       loc2_CS=find(ismember(CS_X,CS_Z)==1);
%       loc3_CS=find(ismember(CS_Y,CS_Z)==1);

      loc_CS=[];
      loc_CS=[CS_X,CS_Y(~ismember(CS_Y,CS_X)),CS_Z(~ismember(CS_Z,CS_X)&~ismember(CS_Z,CS_Y))];
      loc_CS=sort(loc_CS);
      
%       if max([~isempty(loc1_CS) ~isempty(loc2_CS) ~isempty(loc3_CS)])~=0
%           [~,locV3]=max([length(loc1_CS) length(loc2_CS) length(loc3_CS)]);
% 
%           switch locV3
%               case 1
%                   loc_CS=CS_X(loc1_CS);
%               case 2
%                   loc_CS=CS_X(loc2_CS);
%               case 3
%                   loc_CS=CS_Y(loc3_CS);
%               otherwise
%                   disp('');
%           end
%       end
          
          
      
      % Wide QRS
      
      wQRS_X=[];wQRS_Y=[];wQRS_Z=[];
      wQRS_X=find((DurX*1000/fs>120)==1);
      wQRS_Y=find((DurY*1000/fs>120)==1);
      wQRS_Z=find((DurZ*1000/fs>120)==1);
      
      wQRS_X_P=0; wQRS_Y_P=0; wQRS_Z_P=0;
      if length(wQRS_X)/length(DurX)>0.7
          wQRS_X_P=1;
      end
      if length(wQRS_Y)/length(DurY)>0.7
          wQRS_Y_P=1;
      end
      if length(wQRS_Z)/length(DurZ)>0.7
          wQRS_Z_P=1;
      end
          
end