p1 = [2730 -170 784 808]; %Position of left screen
p2 = [1930 -170 784 808]; %position of right screen

figure('Position',p1)
h1 = image

%%
set(h1, 'CData', rand(100,100))


%%

imX = imread('x.png');
imGray = imread('gray.png');
close all
p1 = [2730 -170 784 808]; %Position of left screen
p2 = [1930 -170 784 808]; %position of right screen
fig1 = figure('Position', p1, 'HandleVisibility', 'on');
h1 = image(imGray);
%imshow(imGray, 'Parent', gca);

fig2 = figure('Position', p2, 'HandleVisibility', 'on');
h2=image(imGray);

%%

set(h1, 'CData', imX)
%%
set(h2, 'CData', rand(100,100))
