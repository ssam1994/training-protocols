function PokeX
global BpodSystem % Allows access to Bpod device from this function
MaxTrials = 10;
TrialTypes = ceil(rand(1,MaxTrials)*2);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

imX = imread('x.png');
imGray = imread('gray.png');
close all
p1 = [2730 -170 784 808]; %Position of left screen
p2 = [1930 -170 784 808]; %position of right screen
fig1 = figure('Position', p1, 'HandleVisibility', 'on');
h1 = image(imGray);
axis off

fig2 = figure('Position', p2, 'HandleVisibility', 'on');
h2 = image(imGray);
axis off

for currentTrial = 1:MaxTrials
    disp(['Trial# ' num2str(currentTrial) ' TrialType: ' num2str(TrialTypes(currentTrial))])
    if TrialTypes(currentTrial) == 1 % X to be displayed over port 1
        StateOnLeftPoke = 'LeftReward'; StateOnRightPoke = 'Timeout';
        set(h1, 'CData', imGray);
        set(h2, 'CData', imX);
        
    else % X to be displayed over port 2
        StateOnLeftPoke = 'Timeout'; StateOnRightPoke = 'RightReward';
        set(h1, 'CData', imX);
        set(h2, 'CData', imGray);
    end
    
    MyStateChangeConditions = {'Port1In', StateOnLeftPoke, 'Port3In', StateOnRightPoke};
    
    sma = NewStateMatrix();
    %Wait for nose poke
    %Code for Display
    
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
    
    %Timeout
    sma = AddState(sma, 'Name', 'Timeout', ...
        'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForPoke'},...
        'OutputActions', {'PWM1', 255, 'PWM3', 255});
    SendStateMatrix(sma); RawEvents = RunStateMatrix; % Send and run state matrix
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the current trial type to data
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end