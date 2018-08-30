%%%%Map setting
%%x = 40(row) * 25  square
%%y = 43(col) * 20  square
%%%%%%%%
var winID : int
winID := Window.Open ("graphics:639;399")
var Invader : int % Picture invader
Invader := Pic.FileNew ("invader.jpg")  % load
Invader := Pic.Scale (Invader, 20, 20)  % Scale to 20 x 20
var invaderExplosion : int % pic explosion
invaderExplosion := Pic.FileNew ("invaderkilled.gif")
invaderExplosion := Pic.Scale (invaderExplosion, 20, 20)
%%%%%%% Picture for music on/off
var muted : int % Picture invader
muted := Pic.FileNew ("muted.bmp")  % load
muted := Pic.Scale (muted, 50, 50)  % Scale to 50 x 50
var notMuted : int % Picture invader
notMuted := Pic.FileNew ("volume on.bmp")  % load
notMuted := Pic.Scale (notMuted, 50, 50) % Scale to 50 x 50
var BOL_muted : boolean := false
process backGroundMusic
    Music.PlayFileLoop ("spaceinvaders1.mp3")
end backGroundMusic
fork backGroundMusic
%%%%
%% Initalize incase if reading later fails
var backGroundColor : int := black  % For redrawing
var shipColor : int := 72           % ship's color
%% Use to control loop outcome
var playerDead, exitCurrentLoop : boolean := false
var playerLife : int := 3
var playerWon : boolean := false
%% To display score ...etc
var font2 : int := Font.New ("Orator Std:14:Bold")
var message : string
%% To prevent lag
var invaderHit : boolean := false
%%%
process playerEffectShoot               % For when you shoot
    Music.PlayFile ("shoot.wav")        % Music effect
end playerEffectShoot
procedure drawTank (objectX, objectY, COLOR : int)  % Draw the tank get the color
    drawfillbox (objectX - 10, objectY, objectX + 10, objectY + 10, COLOR)      %Top
    drawfillbox (objectX - 5, objectY + 10, objectX + 5, objectY + 20, COLOR)   %Bottom
end drawTank
procedure drawShield (x, y : int)               % The barrier
    drawarc (180 + (x - 1) * 150, 185, 40, 40, 60, 120, black)
    %Left
    drawline (160 + (x - 1) * 150, 219, 150 + (x - 1) * 150, 219, black)
    drawline (150 + (x - 1) * 150, 249, 150 + (x - 1) * 150, 219, black)
    %Right
    drawline (210 + (x - 1) * 150, 219, 200 + (x - 1) * 150, 219, black)
    drawline (210 + (x - 1) * 150, 249, 210 + (x - 1) * 150, 219, black)
    %
    drawline (150 + (x - 1) * 150, 249, 210 + (x - 1) * 150, 249, black)
    drawfill (170 + (x - 1) * 150, 239, green, black)
    drawarc (180 + (x - 1) * 150, 185, 40, 40, 60, 120, red)
    drawline (160 + (x - 1) * 150, 219, 150 + (x - 1) * 150, 219, red)
    drawline (210 + (x - 1) * 150, 219, 200 + (x - 1) * 150, 219, red)
end drawShield

%VARIABLE DECLARATION
var NumRows, NumCols : int := 0
procedure RowCol (var NumRows, NumCols : int)   % Get the row,Col
    var StreamNum : int                         % Streamnum
    open : StreamNum, "map.txt", get            % Open the map
    get : StreamNum, NumRows                    % get the row
    get : StreamNum, NumCols                    % get the col
    close : StreamNum
end RowCol
procedure ReadMap (filename : string, var okay : boolean, var map : array 1 .. *, 1 .. * of int)
    var StreamNum : int         % initalizing
    %OPEN TEXT FILE
    NumRows := 0
    NumCols := 0
    open : StreamNum, filename, get
    if StreamNum >= 0 then
	%INPUT MAP DIRECTIONS
	get : StreamNum, NumRows
	get : StreamNum, NumCols
	get : StreamNum, backGroundColor
	%Input the map data
	for row : 1 .. NumRows
	    for col : 1 .. NumCols
		get : StreamNum, map (row, col)
	    end for
	end for
	%Close the file
	close : StreamNum
	okay := true
    else
	%ERROR OPENING FILE
	okay := false
    end if
end ReadMap
procedure DrawMapSquare (row, col : int, var map : array 1 .. *, 1 .. * of int)
    %DRAW ONE SQUARE OF THE MAP AT (col,row)
    var x, y : int
    % INITIALIZE THE CO-ORDINATES OF THE LOWER - LEFT CORNER
    x := (col - 1) * 40
    y := (maxy - 43) - (row - 1) * 43
    drawfillbox (x, y, x + 40, y + 43, map (row, col))
end DrawMapSquare


procedure DrawMap (var map : array 1 .. *, 1 .. * of int)
    % DRAW THE MAP FROM THE ARRAY
    var x, y : int
    %INITIALIZE THE CO-ORDINATE
    x := 0
    y := maxy - 40
    %Draw the Map
    for row : 1 .. NumRows
	for col : 1 .. NumCols
	    DrawMapSquare (row, col, map)
	    x := x + 40
	end for
	y := y - 40
	x := 0
    end for
end DrawMap

procedure playershot (var shot : array 1 .. * of boolean, var shotX, shotX1 : array 1 .. * of int, objectX : int)
    for i : 1 .. 5
	if shot (i) = false then % if it does shoot then
	    fork playerEffectShoot  % shoot music
	    shot (i) := true        % Disable it from acessing it untill it goes out
	    shotX (i) := objectX    % set the x so it wouldn't change
	    shotX1 (i) := objectX   % set the x so it wouldn't change
	    exit
	end if
    end for
end playershot
procedure animateMissle (var shotX, shotY, shotX1, shotY1 : array 1 .. * of int, var shot : array 1 .. * of boolean, objectX : int)
    var COLOR : int := 0            % color for the bullet
    randint (COLOR, 1, 255)         % randomize the color
    for i : 1 .. 5                  % 5 shot
	if shot (i) = true then     % if its still shooting
	    if shotY (i) < maxy then
		drawline (shotX (i), shotY (i), shotX1 (i), shotY1 (i), backGroundColor) %Erase
		drawbox (shotX (i) - 1, shotY (i), shotX1 (i) + 1, shotY1 (i), backGroundColor) %Draw
		shotY (i) += 15      % increase
		shotY1 (i) += 15     % increase
		drawline (shotX (i), shotY (i), shotX1 (i), shotY1 (i), COLOR) %Draw
		drawbox (shotX (i) - 1, shotY (i), shotX1 (i) + 1, shotY1 (i), backGroundColor) %Draw
	    elsif shotY (i) >= maxy then    % Reaches maxium of the screen
		drawline (shotX (i), shotY (i), shotX1 (i), shotY1 (i), backGroundColor) % Erase
		shotY (i) := 0          % Reinitalize
		shotY1 (i) := -50       % 50 apart
		shot (i) := false       % shot
	    end if
	end if
    end for
end animateMissle
procedure playerinvaderShot (var invaderShot : array 1 .. * of boolean, var invaderShotX, invaderShotX1, invaderShotY, invaderShotY1 : array 1 .. * of int, invaderX, invaderY : int)
    for i : 1 .. 5                              % 5 bullet
	if invaderShot (i) = false then         % if its not shot
	    invaderShot (i) := true             % Disable
	    invaderShotX (i) := invaderX        % initalize x value
	    invaderShotX1 (i) := invaderShotX (i) % initalize x value
	    invaderShotY (i) := invaderY            % initalize y value
	    invaderShotY1 (i) := invaderY - 10      % y1 will be the bottom part
	    exit
	end if
    end for
end playerinvaderShot
procedure animateInvaderMissle (var invaderShotX, invaderShotY, invaderShotX1, invaderShotY1 : array 1 .. * of int, var invaderShot : array 1 .. * of boolean, objectX : int)
    for i : 1 .. 5          % 5 invaderShot
	if invaderShot (i) = true then % if its still shooting
	    %If it hit the ship % kill the player
	    if whatdotcolor (invaderShotX (i), invaderShotY1 (i)) = shipColor then
		playerLife -= 1
		exitCurrentLoop := true
		Music.PlayFile ("explosion.wav")
	    else
		if invaderShotY (i) > 0 then % if its not pass the ground
		    drawline (invaderShotX (i), invaderShotY (i), invaderShotX1 (i), invaderShotY1 (i), backGroundColor) %Erase
		    invaderShotY (i) -= 5  % increase
		    invaderShotY1 (i) -= 5 % increase
		    drawline (invaderShotX (i), invaderShotY (i), invaderShotX1 (i), invaderShotY1 (i), brightred) %Draw
		elsif invaderShotY (i) <= 0 then % Reaches maxium of the screen
		    drawline (invaderShotX (i), invaderShotY (i), invaderShotX1 (i), invaderShotY1 (i), backGroundColor) % Erase
		    invaderShotY (i) := maxy - 50    % Reinitalize
		    invaderShotY1 (i) := maxy    % 50 apart
		    invaderShot (i) := false   % invaderShot
		end if
	    end if
	    for l : 0 .. 5
		if whatdotcolor (invaderShotX (i), invaderShotY1 (i) - l) = red then
		    drawline (invaderShotX (i), invaderShotY (i) - l, invaderShotX1 (i), invaderShotY1 (i) - l, backGroundColor)
		    invaderShotY (i) := maxy - 50 % Reinitalize
		    invaderShotY1 (i) := maxy  % 50 apart
		    invaderShot (i) := false   % invaderShot
		end if
	    end for
	end if
    end for
end animateInvaderMissle
procedure animationStartGame    % invaders going across the screen
    const CTR : int := 57       % center of rotation
    var rotatingInvader : array 0 .. 35 of int  % save 35 pics for each rotation
    rotatingInvader (0) := Pic.FileNew ("invader.jpg") % Draw the picture
    rotatingInvader (0) := Pic.Scale (rotatingInvader (0), 50, 50)
    Pic.Draw (rotatingInvader (0), 32, 32, picMerge) % Draw the picture
    rotatingInvader (0) := Pic.New (0, 0, 115, 115) % Save the picture
    for angle : 1 .. 35         % Rotation save to 35
	rotatingInvader (angle) := Pic.Rotate (rotatingInvader (0), angle * 10, CTR, CTR)
    end for
    var x : int := CTR      % Set to center point
    var y : int := CTR
    loop
	exit when x > maxx  %
	for angle : 0 .. 35
	    for invaders : 1 .. 7   % Draw 7 files
		drawfillbox (x - CTR, y - CTR + (invaders - 1) * 100, x - CTR + 100, y - CTR + (invaders - 1) * 100 + 100, black)
		delay (1)
		Pic.Draw (rotatingInvader (angle), x - CTR, y - CTR + (invaders - 1) * 50, picMerge)
	    end for
	    delay (1)
	    x += 5                  % move it by x
	end for
    end loop
end animationStartGame
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Initalize
const MAINMENU := 0
const PLAYGAME := 1
const INSTRUCTION := 2
const CREDIT := 3
const EXIT := 4
%%%Keys
const Key_esc := chr (27)
const Key_Right := "d"
const Key_Left := "a"
const Key_Shoot := "w"
% Initalize and set stage to mainmenu
var stage : int := MAINMENU
%   % Clicking function
var mouseX, mouseY, button, oldButton : int := 0
function clicked (x1, y1, x2, y2 : int) : boolean
    if mouseX > x1 and mouseX < x2 and mouseY > y1 and mouseY < y2 then
	result (true)
    else
	result (false)
    end if
end clicked
%%%% Main
procedure MenuScreen
    var muteBefore : boolean := BOL_muted
    setscreen ("Graphics:639,399,nobuttonbar")
    oldButton := button
    mousewhere (mouseX, mouseY, button)
    if mouseX > 550 and mouseY > 0 and mouseX < 590 and mouseY < 42
	    and button = 1 and oldButton = 0 then
	if BOL_muted = false then   % not muted
	    BOL_muted := true       % mute
	else
	    BOL_muted := false      % unmute it
	end if
    end if
    if BOL_muted = true then        % stop
	Pic.Draw (muted, 550, 0, picCopy)
	Music.PlayFileStop
    elsif BOL_muted = false then    % Play
	Pic.Draw (notMuted, 550, 0, picCopy)
	if BOL_muted not= muteBefore then
	    Music.PlayFileReturn ("spaceinvaders1.mp3")
	end if
    end if          % Font
    var font1 : int := Font.New ("Ariel:18x12:Italic")
    drawfill (0, 0, black, black)   % Menu
    Font.Draw ("Space Invader", maxx div 2 - 50, maxy - 50, font1, white)
    Font.Draw ("Play", maxx div 2 - 50, maxy - 150, font1, white)
    Font.Draw ("Instruction", maxx div 2 - 50, maxy - 200, font1, white)
    Font.Draw ("Credit", maxx div 2 - 50, maxy - 250, font1, white)
    Font.Draw ("Exit", maxx div 2 - 50, maxy - 300, font1, white)
    for i : 1 .. 4      % clicking for the menu
	if clicked (267, 248 - 50 * (i - 1), 438, 266 - 50 * (i - 1)) = true     %and whatdotcolor (mouseX, mouseY) = white
		then
	    if button = 0 then
		drawbox (267, 243 - 50 * (i - 1), 438, 268 - 50 * (i - 1), white)
	    elsif button = 1 then
		stage := i
		cls
	    end if
	else
	    drawbox (267, 243 - 50 * (i - 1), 438, 268 - 50 * (i - 1), whatdotcolor (0, 0))
	end if
    end for
end MenuScreen
% Load picture
var invader1, invader2, invader3 : int
invader1 := Pic.FileNew ("invader1.gif")
invader2 := Pic.FileNew ("invader2.gif")
invader3 := Pic.FileNew ("invader3.gif")

procedure Instruction
    %%%% Instruction
    setscreen ("Graphics:639,399")
    drawfill (0, 0, black, black)
    var font := Font.New ("OratorStd:16")   % Instruction
    Font.Draw ("Instruction", 250, 350, Font.New ("OratorStd:18:Bold"), white)
    drawfilloval (35, 306, 5, 5, white)
    Font.Draw ("Destory the ship from reaching pass the barrier", 50, 300, font, white)
    drawfilloval (35, 256, 5, 5, white)
    Font.Draw ("You are given 3 tank", 50, 250, font, white)
    drawfilloval (35, 206, 5, 5, white)
    Font.Draw ("PROTECT THE CITY", 50, 200, font, white)
    %%%%
    Font.Draw ("MAIN MENU", 50, 50, font, white)
    var mouseX, mouseY, button, oldButton : int := 0
    Pic.Draw (invader2, 15, 42, picCopy)        % Draw the invader
    Pic.Draw (invader2, 167, 42, picCopy)
    var colr, colr1 : int := white
    %
    loop
	Font.Draw ("MAIN MENU", 50, 50, font, colr)
	Font.Draw ("Game", 450, 50, font, colr1)
	oldButton := button
	mousewhere (mouseX, mouseY, button)
	% IF its over the menu button
	if mouseX >= 48 and mouseY <= 70 and mouseX < 166 and mouseY >= 45 then
	    colr := grey    % Turn grey
	    if button = 1 then
		stage := MAINMENU   % Change to menu
		cls                 % Clears screen
		exit
	    end if
	else
	    colr := white
	end if
	% if its over game 
	if mouseX >= 450 and mouseY <= 70 and mouseX < 500 and mouseY >= 45 then
	    colr1 := grey   % turn grey
	    if button = 1 then
		stage := PLAYGAME   % play the game
		cls
		exit
	    end if
	else
	    colr1 := white          % change back to grey
	end if
	% if mouseX >= 48 and mouseY <= 70 and mouseX < 166 and mouseY >= 45 then
	%     colr1 := grey
	% end if
    end loop
end Instruction
% Initalize
var animationDirection, animationX, animationY := 1
var shooting : boolean := false
procedure drawInvaderPicture
    var eventRandam := 1
    randint (eventRandam, 1, 10000)     % Randamize an variable
    if eventRandam > 9100 then      % if its 9100 or above
	if animationDirection = 1 then     % If its Left
	    animationX += 1         % Go left
	elsif animationDirection = 2 then     % Right
	    animationX -= 1         % Right
	end if                      % Erase
	drawfillbox (animationX, 350, animationX + 50, 400, black)
    end if
    if animationX >= 200 then       % Make it bounds
	animationDirection := 2
    elsif animationX <= 0 then
	animationDirection := 1
    end if                          % Draw the invader
    Pic.Draw (invader1, animationX, 350, picCopy)
    drawTank (115, 0, white)        % Draw the tank
    if shooting = true then         % If its gonna shoot
	animationY := animationY + 1
	drawline (115, animationY, 115, animationY + 50, white)
	delay (1)
	drawline (115, animationY, 115, animationY + 50, black)
	if animationY > 350 then
	    animationY := -100
	    shooting := false
	end if
	drawTank (115, 0, white)
    else
	if eventRandam = 10000 then     % randamizes if its 10000 then
	    shooting := true        % shoots
	end if
    end if
end drawInvaderPicture
procedure Credit    
% initalize
    var font := Font.New ("OratorStd:16")
    setscreen ("Graphics:639,399")
    cls
    % create the screen
    drawfill (0, 0, black, black)
    invader2 := Pic.Scale (invader2, 50, 50)
    Pic.Draw (invader2, maxx div 10, maxy - 100, picMerge)
    invader2 := Pic.Scale (invader2, 30, 30)
    % Draw the picture
    var colr, colr1 : int := white
    loop
	% Credit
	Font.Draw ("MAIN MENU", 50, 50, font, colr)
	Font.Draw ("Main Game by Ho Yin Ng", 400, 20, font, white)
	Font.Draw ("Sound effect, images:", 50, 200, font, white)
	Font.Draw ("www.classicgaming.cc/classics/spaceinvaders/sounds.php", 50, 150, font, white)
	mousewhere (mouseX, mouseY, button)
	% Back to menu button
	if mouseX >= 48 and mouseY <= 70 and mouseX < 166 and mouseY >= 45 then
	    colr := grey
	    if button = 1 then
		stage := MAINMENU
		cls
		exit
	    end if
	else
	    colr := white
	end if
    end loop
end Credit

process soundEffectExplosion
    Music.PlayFile ("invaderkilled.wav")
end soundEffectExplosion
%% Main Program
RowCol (NumRows, NumCols)
var map : array 1 .. NumRows, 1 .. NumCols of int
var ReadSuccessful : boolean
% Reads it 
ReadMap ("map.txt", ReadSuccessful, map)
procedure Game
    playerLife := 3             % Make sure Life is 3
    playerWon := false
    loop
	% Decloration for the game
	setscreen ("graphics:1000,860,nobuttonbar")
	if ReadSuccessful then
	    DrawMap (map)
	else
	    drawfill (0, 0, black, black)
	    backGroundColor := (black)
	end if
	%%% Invader property
	type property :         % Invader property
	    record
		x : int         % X, its x1 = x+1
		y : int         % y, its y1 = y+10
		stat : int         % alive or dead
	    end record
	%%%
	var invaderShotX, invaderShotY, invaderShotX1, invaderShotY1 : array 1 .. 5 of int
	var invaderShot : array 1 .. 5 of boolean
	for i : 1 .. 5          % initalize value on the invadershots
	    invaderShot (i) := false
	    invaderShotX (i) := 100 + i * 50
	    invaderShotY (i) := 0
	    invaderShotX1 (i) := 100 + i * 50
	    invaderShotY1 (i) := 30
	end for
	var fireChances : int
	%%% Shots property
	var shotX, shotY, shotX1, shotY1 : array 1 .. 5 of int
	var shot : array 1 .. 5 of boolean
	for i : 1 .. 5          % initalize value on the playershot
	    shot (i) := false
	    shotX (i) := 100 + i * 50
	    shotY (i) := 0
	    shotX1 (i) := 100 + i * 50
	    shotY1 (i) := 30
	end for

	%%% Invader property
	var invaderDead := 0            % How many invader are dead
	var numNpc : int := 40          % How many Npc
	var direction : int := 0        % Init direction
	var npc : array 1 .. numNpc of property %apply property to the array
	const dead := 0
	const alive := 1
	const movingLeft := 0
	const movingRight := 1
	% Move Counter
	%%%%%% Control
	var input : string (1) := ""
	% For user and its object
	var objectX : int := maxx div 2
	var oldX, oldY, objectY : int := 0         %Object property(previousx,prev..y,y,color)
	%var input : string (1) := ""     % Users Input
	for i : 1 .. numNpc
	    if i >= 0 and i <= 10 then      % Spacing
		npc (i).x := i * 35
		npc (i).y := 850
	    elsif i > 10 and i <= 20 then
		npc (i).x := (i - 10) * 35
		npc (i).y := 800
	    elsif i > 20 and i <= 30 then
		npc (i).x := (i - 20) * 35
		npc (i).y := 750
	    elsif i > 30 and i <= 40 then
		npc (i).x := (i - 30) * 35
		npc (i).y := 700
	    end if
	    npc (i).stat := 1
	end for 
	drawTank (objectX, objectY, shipColor)
	for numOfShield : 1 .. 6                % Draw 6 shield
	    drawShield (numOfShield, numOfShield)
	end for
	% previous is just initalizing
	loop % Main game
	    % Movment
	    for whichNpc : 1 .. numNpc          % first to last invader
		if npc (whichNpc).stat = alive then         % If is still alive
		    randint (fireChances, 1, 10000)         % randamize
		    if fireChances > 9990 - invaderDead then         %
			playerinvaderShot (invaderShot, invaderShotX, invaderShotX1, invaderShotY, invaderShotY1, npc (whichNpc).x + 5, npc (whichNpc).y + 5)
		    end if
		    for i : 1 .. 10         % Every Part of the line
			for shotArray : 1 .. 5         % Check for collusion IF IT HIT THE INVADER
			    if shotY1 (shotArray) - i >= npc (whichNpc).y and shotY1 (shotArray) - i <= npc (whichNpc).y + 10 and shotX1 (shotArray) >= npc (whichNpc).x and shotX1 (shotArray)
				    <=
				    npc (whichNpc).x + 10 then         % it hit the invader then
				npc (whichNpc).stat := dead         % Its dead
				shot (shotArray) := false          % Disable the shot
				fork soundEffectExplosion
				drawline (shotX (shotArray), shotY (shotArray), shotX1 (shotArray), shotY1 (shotArray), backGroundColor)
				Pic.Draw (invaderExplosion, npc (whichNpc).x, npc (whichNpc).y, picMerge)
				if invaderHit = false then
				    delay (22)
				end if
				invaderHit := true                 % Invader(s) was hit this round
				drawfillbox (npc (whichNpc).x, npc (whichNpc).y, npc (whichNpc).x + 20, npc (whichNpc).y + 20, backGroundColor)
				drawbox (shotX (shotArray) - 1, shotY (shotArray), shotX1 (shotArray) + 1, shotY1 (shotArray), backGroundColor)                                         %Draw
				npc (whichNpc).x := 0              % Move it outside
				npc (whichNpc).y := maxy + 10
				shotY (shotArray) := 10             %
				shotY1 (shotArray) := 30
				exit
			    end if
			end for
		    end for
		    % Erase future change to drawmap square
		    drawfillbox (npc (whichNpc).x, npc (whichNpc).y, npc (whichNpc).x + 20, npc (whichNpc).y + 20, backGroundColor)
		    if npc (whichNpc).x >= maxx then         % It had the right border then
			direction := movingLeft         % change direction
			for i : 1 .. numNpc         % Erase all current invader
			    drawfillbox (npc (i).x, npc (i).y, npc (i).x + 20, npc (i).y + 20, backGroundColor)
			    npc (i).y -= 15         % Invader move by 15 unit/ 20
			end for
		    elsif npc (whichNpc).x < 0 then
			direction := movingRight
			for i : 1 .. numNpc
			    drawfillbox (npc (i).x, npc (i).y, npc (i).x + 20, npc (i).y + 20, backGroundColor)
			    npc (i).y -= 15
			end for
		    end if
		    if direction = movingRight then         % If its moving right
			npc (whichNpc).x += 3          % increment 10
		    elsif direction = movingLeft then         % If its moving Left
			npc (whichNpc).x -= 3          % decrement 10
		    end if
		    Pic.Draw (Invader, npc (whichNpc).x, npc (whichNpc).y, picMerge)
		    if npc (whichNpc).y < 200 then           % When the invader reaches the pass the shields
			exitCurrentLoop := true         % Exit the game loop
			playerLife := 0              % Makes it game over
			exit                         % Stop moving the invaders
		    end if
		    %drawfillbox (npc (whichNpc).x, npc (whichNpc).y, npc (whichNpc).x + 10, npc (whichNpc).y + 10, green)
		elsif npc (whichNpc).stat = dead then
		    invaderDead := invaderDead + 1
		    drawfillbox (npc (whichNpc).x, npc (whichNpc).y, npc (whichNpc).x + 20, npc (whichNpc).y + 20, backGroundColor)
		end if
	    end for
	    message := "Invader dead: " + intstr (invaderDead)         % Display Score
	    drawfillbox (maxx - length (message) * 14, maxy - 14, maxx, maxy, backGroundColor)
	    Font.Draw (message, maxx - length (message) * 14, maxy - 14, font2, white)
	    %%%%%%%% Display Life
	    message := "Lifes: "            % Letter
	    Font.Draw (message, 0, maxy - 14, font2, white)         % Draw
	    if playerLife not= 0 then           % it doesn't glitch if player was shot
		for lives : 1 .. playerLife         % Display Lifes
		    drawTank (length (message) * 14 + (lives - 1) * 30, maxy - 14 - 10, shipColor)
		end for         % 14 represent the font,i - 1 means is 30 aparts
	    end if         % Erase previous
	    %%%%%%%%
	    if invaderDead >= numNpc then         % if all of them die
		playerWon := true
		exitCurrentLoop := true
	    end if
	    invaderDead := 0            % Reset counter
	    oldX := objectX             % Save the locate of the tank before
	    oldY := objectY             % Save the locate of the tank before
	    if hasch then
		getch (input)
	    end if
	    if input = Key_Right and objectX < maxx then    % If player press key d
		objectX := objectX + 5                  % Move right
		drawTank (oldX, oldY, backGroundColor)  % Erase
	    end if
	    if input = Key_Left and objectX > 1 then
		objectX := objectX - 5
		drawTank (oldX, oldY, backGroundColor)
	    end if
	    if input = Key_Shoot then
		playershot (shot, shotX, shotX1, objectX)         % find and shoot a missle the is avaible
	    end if
	    if oldX not= objectX or oldY not= objectY then
		drawTank (oldX, oldY, backGroundColor)
	    end if
	    drawTank (objectX, objectY, shipColor)
	    animateMissle (shotX, shotY, shotX1, shotY1, shot, oldX)
	    animateInvaderMissle (invaderShotX, invaderShotY, invaderShotX1, invaderShotY1, invaderShot, objectX)
	    input := ""
	    if not hasch and invaderHit = false then               % prevent lag when shooting
		delay (25)
	    end if
	    if exitCurrentLoop = true then
		cls
		exit
	    end if
	    invaderHit := false
	end loop
	exitCurrentLoop := false         % Reset
	if playerLife <= 0 then
	    DrawMap (map)
	    Invader := Pic.Scale (Invader, 50, 50)         % Scale to 20 x 20
	    for goingDownY : 1 .. maxy by 10
		for i : 1 .. 18
		    %Pic.Draw (Invader, 10 + invaders * 50, maxy - goingDownY, picMerge)
		    drawfillbox (0 + i * 50, maxy - goingDownY, 50 + i * 50, maxy - goingDownY + 50, backGroundColor)
		    Pic.Draw (Invader, i * 50, maxy - goingDownY, picMerge)
		    delay (1)
		end for
	    end for
	    Invader := Pic.Scale (Invader, 20, 20)         % Scale to 20 x 20
	    message := "YOU LOSE HHAHAHAHHAHAHHA"                                                   % Letter
	    drawfillbox (maxx - length (message) * 14, maxy - 14, maxx, maxy, backGroundColor)
	    Font.Draw (message, maxx div 3, (maxy - 14) div 2 + 150, font2, yellow)         % Draw
	    delay (5000)         % 5 second
	    exit
	end if

	if playerWon = true then         % 4 is the value that will be set when you win
	    DrawMap (map)
	    Invader := Pic.Scale (Invader, 100, 100)         % Scale to 20 x 20
	    Pic.Draw (Invader, maxx div 2, maxy div 2, picMerge)
	    Invader := Pic.Scale (Invader, 20, 20)         % Scale to 20 x 20
	    message := "WELL DONE EARTH-LINGS THIS TIME YOU WIN"                                                   % Letter
	    drawfillbox (maxx - length (message) * 14, maxy - 14, maxx, maxy, backGroundColor)
	    Font.Draw (message, maxx div 3, (maxy - 14) div 2, font2, black)         % Draw
	    delay (2000)         % 2 second
	    exit
	end if
    end loop         % loop of the games
end Game
%% Main
loop
    if stage = MAINMENU then
	MenuScreen            % Which mode to go to selection
	drawInvaderPicture    % animation on the side
    elsif stage = PLAYGAME then
	animationStartGame    % Animation
	Game                  % Goes to the game
	stage := MAINMENU     % after the loop goes back to main menu
    elsif stage = INSTRUCTION then
	Instruction
    elsif stage = CREDIT then
	Credit
    elsif stage = EXIT then
	% draw an animation of tank exploding
	Window.Close (winID)            % Close the window
	Music.PlayFileStop              % Make sure file stop
	exit
    end if
end loop
