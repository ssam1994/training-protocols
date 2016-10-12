function Poke2AFC
global BpodSystem



S = BpodSystem.ProtocolSettings;
if isempty(fieldnames(S))  
    S.RewardAmount = 5;
    S.ResponseTimeAllowed = 0;
    S.TimeoutDuration = 0.5;
end

maxTrials = 10; %How many free rewards mouse gets during training
leftValvePort = 1;
rightValvePort = 3;
R = GetValveTimes(0, [leftValvePort rightValvePort]); % Return the valve-open duration in seconds
LeftValveTime = R(1); 
RightValveTime = R(2);

for currentTrial = 1:maxTrials
    disp(['Trial Number: ' num2str(currentTrial)])
    StateOnLeftPoke = 'LeftReward'; StateOnRightPoke = 'RightReward';
    sma = NewStateMatrix();
    %Wait for nose poke
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', StateOnLeftPoke, 'Port3In', StateOnRightPoke},...
        'OutputActions', {});
    
    %Dispense reward
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'ValveState', 4});  
    
    SendStateMatrix(sma); RawEvents = RunStateMatrix; % Send and run state matrix
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end
end