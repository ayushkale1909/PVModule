
Sim_program ='MSX60_PS_Test';

 t=1.5; Voc_array=210;
 %% Problem Definition
 Prob=@(t,x,S) OBJ_F(t,x,S);  % Cost Function
 nVar=1;             % Number of Decision Variables
 VarSize=[1 nVar];   % Size of Decision Variables Matrix
 VarMin=0;         % Lower Bound of Variables
 VarMax= 1;        % Upper Bound of Variables
 MaxVelocity=0.39;
 MinVelocity=0;
 %% PSO Parameters
MaxIt=15;      % Maximum Number of Iterations
nPop=4;        % Population Size (Swarm Size)
% PSO Parameters
% w=1;            % Inertia Weight
% wdamp=0.99;
% c1=2;         % Personal Learning Coefficient
% c2=2.0;         % Global Learning Coefficient
% 
% w=0.7;            % Inertia Weight
% wdamp=0.99;
% c1=1.5;         % Personal Learning Coefficient
% c2=1.5;         % Global Learning Coefficient


w=0.4;            % Inertia Weight
wdamp=0.99;
c1=1.2;        % Personal Learning Coefficient
c2=1.6 ;      % Global Learning Coefficient
%% Initialization
ep.Position=[];
ep.Cost=[];
ep.Velocity=[];
ep.Best.Position=[];
ep.Best.Cost=[];
p=repmat(ep,nPop,1);
GlobalBest.Cost=0;
 %% Populate 
 P=[0,0.2,0.5,0.8];
 for i=1:nPop
    % Initialize Position
    p(i).Position=P(i);
    % Initialize Velocity
    p(i).Velocity=zeros(VarSize);
    % Evaluation
    p(i).Cost=Prob(t,p(i).Position,Sim_program);
    
    % Update Personal Best
    p(i).Best.Position=p(i).Position;
    p(i).Best.Cost=p(i).Cost;
    %Update Global Best
    if p(i).Best.Cost > GlobalBest.Cost
        GlobalBest=p(i).Best;
    end 
 end 
  BestCost=zeros(MaxIt,1) ;
%% PSO Main Loop
disp('PSO Method');
for it=1:MaxIt
    
    for i=1:nPop
        
        % Update Velocity
        p(i).Velocity = w*p(i).Velocity ...
            +c1*rand(VarSize).*(p(i).Best.Position-p(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-p(i).Position);
      
        % Update Position
        p(i).Position = p(i).Position + p(i).Velocity;
        
        % Apply Lower and Upper Bound
        p(i).Position=max( p(i).Position,VarMin);
        p(i).Position=min( p(i).Position,VarMax);
        
%         % Apply Velocity Limits
        p(i).Velocity=max(p(i).Velocity,MinVelocity);
        p(i).Velocity=min(p(i).Velocity,MaxVelocity);
       
        % Evaluation
        p(i).Cost = Prob(t,p(i).Position,Sim_program);
        % Update Personal Best
        if p(i).Cost > p(i).Best.Cost
            
            p(i).Best.Position=p(i).Position;
            p(i).Best.Cost=p(i).Cost;
            % Update Global Best
            if p(i).Best.Cost > GlobalBest.Cost
                
                GlobalBest=p(i).Best;
                
            end
            
        end
        
    end
    BestCost(it)=GlobalBest.Cost;
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    %w=w*wdamp;
end
format shortG
D=GlobalBest.Position;
P=GlobalBest.Cost;
disp(['Pmpp  :',num2str(P)]);
disp(['Vmpp  :',num2str(D*Voc_array)]);

plot(BestCost,'LineWidth',2);hold all;
%semilogy(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;
