function SoftCodeHandler_FlipScreen(Byte)
global window
global timeoutDuration
global imageTextureGray
global imageTextureWhite
global imageTextureBlack
ifi = Screen('GetFlipInterval', window);

%Sound variables
InitializePsychSound(1);
nrchannels = 2;
sampfreq = 48000;
freq = 24000;
repetitions = 1;
beepLengthSecs = timeoutDuration;
startCue = 0;
waitForDeviceStart = 1;

switch Byte
    case 1 %between trials (WaitForInit state)
        disp('Waiting for trial initiation.')
        Screen('DrawTexture', window, imageTextureBlack, [], [], 0);
        Screen('Flip', window);
        
    case 2 %trial start (WaitForPoke state)
        disp('Mouse has initiated trial. Waiting for choice.')
        Screen('DrawTexture', window, imageTextureGray, [], [], 0);
        Screen('Flip', window);
        
    case 3 %Timeout
        disp('Mouse has chosen incorrectly.')

        pahandle = PsychPortAudio('Open', [], 1, 1, sampfreq, nrchannels);
        myBeep = MakeBeep(freq, beepLengthSecs, sampfreq);
        PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);
        
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);

        Screen('DrawTexture', window, imageTextureBlack, [], [], 0);
        Screen('Flip', window);
        PsychPortAudio('Stop', pahandle, 1, 1);
        PsychPortAudio('Close', pahandle);
        
    otherwise
        disp('No SoftCode output.')
end