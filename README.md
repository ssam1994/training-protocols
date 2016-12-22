# training-protocols
MATLAB protocols for Bpod box training


FreeReward
 - rewards one of two ports upon nose poke

InitiateTrial
 - requires that the mouse poke initiation port, then rewards   either port upon nose poke
 - Timeout state if mouse does not initiate a trial
 - SoftCode handler code modified to change screens or play beep as timeout punishment

InitiateTrialSingleScreen
 - similar to initiate trial, but uses a single monitor
 - use when all three ports are on the same wall of the box

PokeX
 - display an image of the letter 'X' each trial and reward when the mouse chooses the port corresponding to the display (can modify the image file to gratings instead of 'X')

PokeXPTB
 - similar to PokeX, but uses a SoftCode handler so that you can change screens using PsychToolbox