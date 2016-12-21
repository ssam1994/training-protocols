function SoftCodeHandler_FlipScreen(Byte)
global window1
global window2
global imageTextureGray
global imageTextureWhite
global imageTextureBlack
ifi1 = Screen('GetFlipInterval', window1);
ifi2 = Screen('GetFlipInterval', window2);

%Sound variables
InitializePsychSound(1);
nrchannels = 2;
sampfreq = 48000;
freq = 24000;
repetitions = 1;
beepLengthSecs = 5;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;

switch Byte
    case 1 %between trials (WaitForInit state)
        disp('Waiting for trial initiation.')
        Screen('DrawTexture', window1, imageTextureBlack, [], [], 0);
        Screen('DrawTexture', window2, imageTextureBlack, [], [], 0);
    
        Screen('Flip', window1);
        Screen('Flip', window2);
    case 2 %trial start (WaitForPoke state)
        disp('Mouse has initiated trial. Waiting for choice.')
        Screen('DrawTexture', window1, imageTextureGray, [], [], 0);
        Screen('DrawTexture', window2, imageTextureGray, [], [], 0);
    
        Screen('Flip', window1);
        Screen('Flip', window2);
    case 3 %Timeout
        disp('Mouse has chosen incorrectly.')
%         flipSecs = 0.2;
%         waitframes1 = round(flipSecs / ifi1);
%         waitframes2 = round(flipSecs / ifi2);

        % Flip outside of the loop to get a time stamp
%         vbl1 = Screen('Flip', window1);
%         vbl2 = Screen('Flip', window1);
        pahandle = PsychPortAudio('Open', [], 1, 1, sampfreq, nrchannels);
        myBeep = MakeBeep(freq, beepLengthSecs, sampfreq);
        PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);
        
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        %[actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
        %startCue = estStopTime + beepPauseTime;
        
%         for i=1:50
%             if mod(i,2)==1
                Screen('DrawTexture', window1, imageTextureWhite, [], [], 0);
                Screen('DrawTexture', window2, imageTextureWhite, [], [], 0);
                Screen('Flip', window1);
                Screen('Flip', window2);
%             else
%                 Screen('DrawTexture', window1, imageTextureBlack, [], [], 0);
%                 Screen('DrawTexture', window2, imageTextureBlack, [], [], 0);
%             end
% 
%             % Flip to the screen
%             vbl1 = Screen('Flip', window1, vbl1 + (waitframes1 - 0.5) * ifi1);
%             vbl2 = Screen('Flip', window2, vbl2 + (waitframes2 - 0.5) * ifi2);
% 
%         end
    
        PsychPortAudio('Stop', pahandle, 1, 1);
        PsychPortAudio('Close', pahandle);
    otherwise
        disp('No SoftCode output.')
end