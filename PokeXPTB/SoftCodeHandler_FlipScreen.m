function SoftCodeHandler_FlipScreen(Byte)
global window1
global window2
global imageTextureLeft
global imageTextureRight
global imageTextureWhite
global imageTextureBlack
switch Byte
    case 1 %between trials (WaitForInit state)
        disp('Waiting for trial initiation.')
        Screen('DrawTexture', window1, imageTextureBlack, [], [], 0);
        Screen('DrawTexture', window2, imageTextureBlack, [], [], 0);
    
        Screen('Flip', window1);
        Screen('Flip', window2);
    case 2 %trial start (WaitForPoke state)
        disp('Mouse has initiated trial. Waiting for choice.')
        Screen('DrawTexture', window1, imageTextureLeft, [], [], 0);
        Screen('DrawTexture', window2, imageTextureRight, [], [], 0);
    
        Screen('Flip', window1);
        Screen('Flip', window2);
    case 3 %Timeout
        disp('Mouse has chosen incorrectly.')
        Screen('DrawTexture', window1, imageTextureWhite, [], [], 0);
        Screen('DrawTexture', window2, imageTextureWhite, [], [], 0);
    
        Screen('Flip', window1);
        Screen('Flip', window2);
    otherwise
        disp('No SoftCode output.')
end