function InitiateTrial
global BpodSystem % Allows access to Bpod device from this function
S = BpodSystem.ProtocolSettings;
if isempty(fieldnames(S))  
    S.RewardAmount = 20; %amount of water in uL
    S.ResponseTimeAllowed = 0;
    S.TimeoutDuration = 10;
end
leftValvePort = 1;
rightValvePort = 3;
InitPort = 'Port2In';
R = GetValveTimes(S.RewardAmount, [leftValvePort rightValvePort]); % Return the valve-open duration in seconds
LeftValveTime = R(1); 
RightValveTime = R(2);
BpodNotebook('init');
MaxTrials = 10;
TrialTypes = ceil(rand(1,MaxTrials)*2);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
close all
stereoMode = 6;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper
InitializeMatlabOpenGL;

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber1 = 2;
screenNumber2 = 3;

black = BlackIndex(screenNumber1);
white = WhiteIndex(screenNumber1);
grey = white / 2;

% Open an on screen window and color it grey
[window1, windowRect1] = PsychImaging('OpenWindow', screenNumber1, grey); %#ok<GPFST>

[window2, windowRect2] = PsychImaging('OpenWindow', screenNumber2, grey); %#ok<GPFST>
global window1 
global window2
% Set the blend funciton for the screen
Screen('BlendFunction', window1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('BlendFunction', window2, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels1, screenYpixels1] = Screen('WindowSize', window1);
[screenXpixels2, screenYpixels2] = Screen('WindowSize', window2);
% Define black, white and grey

imX = imread('grating-horizontal.png');
imGray = ones(screenYpixels1, screenXpixels1)*grey;
imBlack = zeros(screenYpixels1, screenXpixels1);
imWhite = ones(screenYpixels1, screenXpixels1);
% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter1, yCenter1] = RectCenter(windowRect1);
[xCenter2, yCenter2] = RectCenter(windowRect2);
% Get the size of the image
[s1, s2, s3] = size(imX);

%Image textures global so SoftCodeHandler function can access
global imageTextureGray %#ok<TLEV>
imageTextureGray = Screen('MakeTexture', window1, imGray);
global imageTextureBlack %#ok<TLEV>
imageTextureBlack = Screen('MakeTexture', window1, imBlack);
global imageTextureWhite %#ok<TLEV>
imageTextureWhite = Screen('MakeTexture', window1, imWhite);

%Main loop
%One iteration per trial
%State matrix run here
for currentTrial = 1:MaxTrials
    disp(['Trial# ' num2str(currentTrial) ])
    BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_FlipScreen';
    % Draw the image to the screen, unless otherwise specified PTB will draw
    % the texture full size in the center of the screen. We first draw the
    % image in its correct orientation.
    MyStateChangeConditions = {'Port1In', 'LeftReward', 'Port3In', 'RightReward'};
    InitiateChangeConditions = {InitPort, 'WaitForPoke', 'Port1In', 'Timeout', 'Port3In', 'Timeout'};
    
    sma = NewStateMatrix();
    %Wait for trial start
    sma = AddState(sma, 'Name', 'WaitForInit', ...
        'Timer', 0,...
        'StateChangeConditions', InitiateChangeConditions,...
        'OutputActions', {'PWM2', 50, 'SoftCode', 1});
    
    %Wait for choice
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0,...
        'StateChangeConditions', MyStateChangeConditions,...
        'OutputActions', {'SoftCode', 2});
    
    %Dispense reward
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', LeftValveTime,...
        'StateChangeConditions', {'Port1Out', 'Pause'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime,...
        'StateChangeConditions', {'Port3Out', 'Pause'},...
        'OutputActions', {'ValveState', 4});
    
    %Pause to allow mouse to drink
    sma = AddState(sma, 'Name', 'Pause', ...
        'Timer', 4,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    %Timeout
    sma = AddState(sma, 'Name', 'Timeout', ...
        'Timer', S.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'WaitForInit'},...
        'OutputActions', {'SoftCode', 3});
    
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
    if currentTrial == MaxTrials
        sca;
    end
end