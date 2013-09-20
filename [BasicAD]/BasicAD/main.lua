--[[

	Basic A/D
    Copyright (C) < 2011-2012 >  < Whitetiger >

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


HOW TO CONTRIBUTE:

	Get in contact with me
		xfire: whitetigerswt
		MSN: whitetigerswt@live.com
		steam: mindfreak860
		youtube: mindfreak860

	anything is welcome, any contributions are welcome and wanted ranging from
		- BUG REPORTS
		- GRAPHICS DESIGN
		- SOUND DESIGN
		- SCRIPTING
		- IMPLEMENTATION
		- ENCOURAGEMENT
		- IDEAS
		- IMPROVEMENTS

	seriously, anyone is welcome to contribute and make this script better.


Credits:

Whitetiger - Programming


to-do:
	- testing base code, a lot. (server/client)

	- intro
	- removeworldmodel poles and random wires still
	- make map manager work... thus fixing /vote with votemanager
	- 3dtextlabel displaying the weapons the player chose in the round - show only to teammates and make it toggleable from client side, and damage labels above players head when you shoot them
	- wep.dat setweaponproperty edits in cfg
	- dxDrawImage and dx Image GUI and on death show stats distance fps ping etc of killer
	- class selection - redo it, have all the peds load at the same time, then move the camera onto the ped of that team. put them in interior 99999 in sf driving school so there are no problems
	- fix damage stuff, make a proper round functions and also don't round everytime someone makes damage, also damage is desynced between players


	-- to-do, not urgent.

	- auto-readd

	-- ideas, to be considered:

	- remove Round.LoserTeam and Round.WinnerReason and just add them as params for endRound( ) function
]]--



local COLOR_GREEN 		= 		"#33CC00";
local COLOR_RED 		= 		"#FF3300";
local COLOR_BLUE    	=       "#1975FF";
local COLOR_YELLOW  	=       "#FFFF00";
local COLOR_WHITE   	=       "#FFFFFF";

	SCRIPT_NAME			=		"";
	SCRIPT_VER			=		"0.01";

	MAX_BASES 			= 		200;
	MAX_ARENAS			=		200;
	baseInfo 			= 		{};
	arenaInfo			= 		{};
	Player 				= 		{};
	Timers        		=       {};
	Config        		=       {};
	Round         		=       {};
	Teams         		=       {};
	Weapons				= 		{};
	Vehicles     		=       {};

	BASE          		=        1; -- the base gametype
	TDM           		=        2; -- the TDM  gametype
--local <insertgametype> =     x; -- add-on  gametypes

local lDimension    	=        456;            -- lobby dimension
local rDimension    	=        lDimension + 1; -- the dimension used for players in rounds

function resourceStartNotify ( resourcename )
	if ( resourcename == getThisResource( ) ) then

		local ticks = getTickCount( );
		outputDebugString ( "Resource " .. getResourceName(resourcename) .. " loading...");
		getMaxBase ( );

		getMaxTDM  ( );

		loadConfig( );


		for i, v in ipairs(getElementsByType("player")) do
			triggerEvent( "onPlayerConnect", v, getPlayerName( v ), getPlayerIP( v ), getPlayerUserName( v ), getPlayerSerial( v ), getVersion().number, getPlayerVersion( v ) );
		end

		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "FPS");
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Dmg");
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Health");
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Kills");
		call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Deaths");


		setGameType( SCRIPT_NAME .. " v" .. SCRIPT_VER );

		outputDebugString ( "Resource " .. getResourceName(resourcename) .. " loaded." );

		outputDebugString ( "Took " .. round( getTickCount( ) - ticks ) .. " ms to load." );

	end
end

function playerConnect ( playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber, playerVersionString )


	local player = getPlayerFromName( playerNick );
	loadPlayerConfig( player );

	Player[player].Blip = createBlipAttachedTo( player, 0, Player[player].BlipSize, 255, 0, 0, 150 );

	setElementVisibleTo( source, Player[player].Blip, false );

	outputChatBox(playerNick .. " has connected to the server [" .. COLOR_YELLOW .. playerVersionString .. COLOR_WHITE .. "]", getRootElement(), 255, 255, 255, true);

	setElementData( source, "FPS", "N/A" );
	setElementData( source, "Dmg",    0  );
	setElementData( source, "Health", 0  );
	setElementData( source, "Kills",  0  );
	setElementData( source, "Deaths", 0  );

	setElementData( source, "round.health", 0 );
	setElementData( source, "round.dmg",    0 );

	resendPlayerModInfo( player );

	Player[player].Spawned = false;

end

function playerQuit( qtype, reason, theelement )

	if reason ~= false and isElement( theelement ) then
		outputChatBox( getPlayerName( source ) .. " has left the server. (Kicked/Banned by " .. COLOR_YELLOW .. theelement .. COLOR_WHITE .. ") (" .. qtype .. ") ", getRootElement( ), 255, 255, 255, true );
	elseif reason ~= false then
		outputChatBox( getPlayerName( source ) .. " has left the server. (" .. COLOR_RED .. qtype .. COLOR_WHITE .. ") (" .. COLOR_RED .. reason .. COLOR_WHITE .. ") (" .. round( getPedArmor( source ) ) .. " " .. round( getElementHealth( source ) ) .. ") ", getRootElement( ), 255, 255, 255, true );
	else
		outputChatBox( getPlayerName( source ) .. " has left the server. (" .. COLOR_RED .. qtype .. COLOR_WHITE .. ") (Armor: " .. round( getPedArmor( source ) ) .. " Health: " .. round( getElementHealth( source ) ) .. ") ", getRootElement( ), 255, 255, 255, true );
	end

	for v, i in ipairs( getElementsByType( "player" ) ) do

		if getElementData( i, "spectating", false ) == source then

			setCameraTarget( i, i );
			setElementAlpha( i, 255 );
			setElementData( i, "spectating", nil );

			triggerClientEvent( i, 						  "hideSpecGui", getRootElement( ), 1 );
			triggerClientEvent( Player[i].Spectating, 	  "hideSpecGui", getRootElement( ), 2 );

			Player[i].Spectating = nil;
		end

	end

	if Player[source].InRound == true then
		removePlayerFromRound( source );
	end

	if Player[source].InCP == true then
		Player[source].InCP = false;
		Round.PlayersInCP = Round.PlayersInCP - 1;
	end

	if isElement( Player[source].Blip ) then
		destroyElement( Player[source].Blip );
	end
	if isElement( source ) then
		destroyElement( source );
	end


end

function clientScriptSynced( )
	triggerClientEvent( source, "guiSpawnUpdate", getRootElement( ), 0, 0, 0, 0, nil, Teams.Attackers, Teams.Defenders, Round.TimeInCP );
end

function loadPlayerConfig( player )
	Player[player] 	  		 		= {};

	Player[player].InRound 	 		= nil;
	Player[player].PlayedRound  	= nil;
	Player[player].RoundLoading 	= nil;
	Player[player].InCP				= nil;
	Player[player].Vehicle			= nil;
	Player[player].BlipSize     	= 2;
	Player[player].ScreenLastTaken  = nil;

	setFPSLimit( Config.FPSLimit );

	resendPlayerModInfo( player );

	bindKey ( player, "F4",    "down", onPlayerPressF4    );

end

function loadVehicleConfig( vehicle, player )
	Vehicles[vehicle]			= {};
	Vehicles[vehicle].Player	= player;
	Vehicles[vehicle].InRound	= Player[player].InRound;
	Player[player].Vehicle		= vehicle;
end

function onPlayerPressF4( presser, key, keystate )

	if Player[presser].InRound == true then
		return outputChatBox( COLOR_RED .. "Error " .. COLOR_WHITE .. "Cannot switch teams while in a round!", presser, 255, 255, 255, true );
	end

	if 	   getPlayerTeam( presser ) == Teams.Attackers then
		triggerEvent( "asignTeam", presser, 2 );
	elseif getPlayerTeam( presser ) == Teams.Defenders then
		triggerEvent( "asignTeam", presser, 1 );
	end
end

function showEndRoundGui( )
	local table = {};
	for v, i in ipairs( getElementsByType( "player" ) ) do
		if Player[i].PlayedRound then
			table[v] = i;
		end
	end
	triggerClientEvent(getRootElement( ), "showEndRoundDXText", getRootElement( ), table );
end

function playerSpawn( posX, posY, posZ, spawnRotation, theTeam, theSkin, theInterior, theDimension )
	for i=0, 230 do
		setPedStat( source, i, Config[i].pedStats );
	end
	setElementHealth 	( source, Config.LobbyHP );
	setPedArmor		 	( source, Config.LobbyAP );
	setElementData		( source, "Health", Config.LobbyHP + Config.LobbyAP );
	toggleAllControls	( source, true       	 );
	setElementFrozen 	( source, false     	 );
	setElementAlpha  	( source, 255        	 );
	setElementDimension	( source, lDimension 	 );
	Player[source].Spawned = true;

	for v, i in ipairs( getElementsByType( "player" ) ) do
		if not Player[i].InRound and not Player[i].InRound then
			setElementVisibleTo( Player[source].Blip, i, true );
		elseif Player[i].InRound and Player[source].InRound and getPlayerTeam( source ) == getPlayerTeam( i ) then
			setElementVisibleTo( Player[source].Blip, i, true );
		end
	end

end

function teamHandler( teamindex )
	local pos = Config.Lobby;
	local team = teamIndexToTeam( teamindex );
	if team 	== "Defenders" then

		spawnPlayer( source, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.DefSkin, 0, 0 );
		setPlayerTeam ( source, Teams.Defenders );

		outputChatBox(getPlayerName( source ) .. " has spawned as " .. rgbtohex( getTeamColor( Teams.Defenders ) ) .. Teams.DefName .. " (Defenders)", getRootElement(), 255, 255, 255, true );
	elseif team == "Attackers" then
		spawnPlayer( source, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.AttSkin, 0, 0 );
		setPlayerTeam ( source, Teams.Attackers );

		outputChatBox(getPlayerName( source ) .. " has spawned as " .. rgbtohex( getTeamColor( Teams.Attackers ) ) .. Teams.AttName .. " (Attackers)", getRootElement(), 255, 255, 255, true );
	elseif team == "Auto-Assign" then
		local a, b = countPlayersInTeam( Teams.Attackers ), countPlayersInTeam( Teams.Defenders );
		-- a = attackers
		-- b = defenders
		if a > b then
			-- their are more players playing on attackers than defenders!
			teamHandler ( 2 );
			-- defenders team index is 2
		elseif b > a then
			-- their are more players playing on defenders than attackers!
			teamHandler ( 1 );
			-- attackers team index is 2
		else return teamHandler( 1, math.random( 2 ) ); end
	end

	setCameraTarget ( source, source );

	local t = getAttachedElements( source );
	if t then
		for v, i in ipairs( t ) do
			if ( getElementType ( i ) == "blip" ) then
				local r, g, b = getTeamColor( getPlayerTeam( source ));
				setBlipColor( i, r, g, b, 150 );
				clearElementVisibleTo( i );
				--setElementVisibleTo( i, getRootElement( ), true );
				setElementDimension( i, getElementDimension( source ) );
			end
		end
	end
	return 1;
end

function getgun( playerSource, name, wepid, ammo )
	if Round.IsRoundStarted == true then
		if Player[playerSource].InRound == true then
			outputChatBox( COLOR_RED .. "Error " .. COLOR_WHITE .. "You cannot use this command while in a round!", playerSource, 255, 255, 255, true );
		end
	end

	if not isNumeric( ammo ) then ammo = 9999; end
	if not ammo then ammo = 9999; end

	local wep = getWeaponIDFromPartName( wepid );
	if not isValidWeapon( wep ) then
		outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid weapon.", playerSource, 0, 0, 0, true );
		return false;
	end
	if tonumber( Weapons.Getgun[wep] ) == 1 then
		giveWeapon(playerSource, tonumber( wep ), tonumber( ammo ), true);
		outputChatBox( COLOR_WHITE .. "You've gotten " .. COLOR_BLUE .. getWeaponNameFromID( wep ) .. COLOR_GREEN .. " Ammo: " .. ammo, playerSource, 0, 0, 0, true );
	else return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "This weapon is disabled.", playerSource, 255, 255, 255, true ) end
	return true;
end

function startBaseCmd( playerSource, cmd, baseid ) -- remember to make this not a command later
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is already started!", playerSource, 255, 255, 255, true ) end
	if baseid == nil then baseid = -1 end
	baseid = tonumber(baseid);
	if baseid == -1 then baseid = determineRandomBase( ) end

	if countPlayersInTeam( Teams.Attackers ) == 0 or countPlayersInTeam( Teams.Defenders ) == 0 then
		outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Not enough players.", playerSource, 255, 255, 255, true);
		return 0;
	end

	if not startBase( baseid ) then
		outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid base id!", playerSource, 255, 255, 255, true );
	else outputChatBox( COLOR_WHITE .. getPlayerName(playerSource) .. " has started base: ".. COLOR_RED .. baseid, getRootElement( ), 255, 255, 255, true ) end
end


function startBase( baseid )

    local startbase = startResource( getResourceFromName( "base-" .. baseid ) );
	if startbase == true then

		local spawn = getElementsByType( "spawnpoint" );
		--local teams = getElementsByType( "team"       );
		for v, i in ipairs( spawn ) do
			baseInfo[i]					=	{};
			baseInfo[baseid]			=   {};
			baseInfo[i].PosX			=	getElementData( i, "posX" 		);
			baseInfo[i].PosY			=	getElementData( i, "posY" 		);
			baseInfo[i].PosZ			=	getElementData( i, "posZ" 		);
			baseInfo[i].Team			=	getElementData( i, "team" 	  	);
			baseInfo[baseid].Interior	= 	getElementData( i, "interior" 	); -- yes, base id, interior should be the same on all spawn points.
			baseInfo[i].RotX			=	getElementData( i, "rotX" 		);
			baseInfo[i].RotY			=	getElementData( i, "rotY" 		);
			baseInfo[i].RotZ			=	getElementData( i, "rotZ" 		);
		end
		local cp = getElementsByType( "checkpoint" );
		for v, i in ipairs( cp ) do
			baseInfo[i]					=	{};
			baseInfo[i].PosX			=	getElementData( i, "posX" 		);
			baseInfo[i].PosY			=	getElementData( i, "posY" 		);
			baseInfo[i].PosZ			=	getElementData( i, "posZ" 		);
			baseInfo[i].RotX			=	getElementData( i, "rotX" 		);
			baseInfo[i].RotY			=	getElementData( i, "rotY" 		);
			baseInfo[i].RotZ			=	getElementData( i, "rotZ" 		);
		end

		for v, i in ipairs(getElementsByType("player")) do
			if isPlayerSpawned( i ) then
				if isPedInVehicle( i ) then
					local t = getPedOccupiedVehicle( i );
					removePedFromVehicle( i );
					destroyElement( t );
				end

				if getCameraTarget( i ) ~= i then

					setCameraTarget( i, i );
					setElementAlpha( i, 255 );
					setElementData( i, "spectating", nil );

					triggerClientEvent( i, 						  "hideSpecGui", getRootElement( ), 1 );
					triggerClientEvent( Player[i].Spectating, 	  "hideSpecGui", getRootElement( ), 2 );

					Player[i].Spectating = nil;

				end

				Player[i].RoundLoading  	= true;
				Player[i].InRound 			= true;
				Player[i].PlayedRound   	= true;
				Player[i].ScreenLastTaken   = nil;

				for k, j in ipairs( cp ) do
					triggerClientEvent(i, "roundLoadUpdate", getRootElement( ), baseInfo[j].PosX, baseInfo[j].PosY, baseInfo[j].PosZ, 50, true);
					-- there shouldn't be more than 1 checkpoint, otherwise you've unleashed the beast
				end

				outputDebugString( "BASEID: " .. baseid			  );
				setElementDimension( i, rDimension 				  );
				setElementInterior(  i, baseInfo[baseid].Interior );

				setElementHealth( i, Config.RoundHP );
				setPedArmor( i, Config.RoundAP );

				setElementData( i, "Health", Config.RoundHP + Config.RoundAP );

				setElementAlpha( i, Config.GunmenuAlpha );
				showPlayerHudComponent( i, "all", false );

				setElementData( i, "round.health", Config.RoundHP + Config.RoundAP );
				setElementData( i, "round.dmg",    0 							   );

				takeAllWeapons( i );

				local team = getPlayerTeam( i );
				if team ~= nil then
					for k, j in ipairs( shuffle( spawn ) ) do
						if ( team == Teams.Attackers and baseInfo[j].Team == "Att" ) or ( team == Teams.Defenders and baseInfo[j].Team == "Def" ) then
							setElementPosition( i, baseInfo[j].PosX, baseInfo[j].PosY, baseInfo[j].PosZ );
						end
					end

					local t = getAttachedElements( i );
					if t then
						for j, k in ipairs( t ) do
							if ( getElementType ( k ) == "blip" ) then
								setElementDimension(  k, getElementDimension( i ) );
								clearElementVisibleTo( k );
								for h, n in ipairs( getPlayersInTeam( team ) ) do
									if n ~= i then
										setElementVisibleTo(  k, n, true  );
									end
								end
							end
						end
					end
				end
				toggleAllControls( i, false, true, false );
				resendPlayerModInfo( i );
			end
		end


		Timers.RoundTimer    = setTimer(roundLoadUpdate, 1000, Round.LoadTime+1, "Base", Round.LoadTime);

		for k, j in ipairs( cp ) do
			Round.CP         = createMarker( baseInfo[j].PosX, baseInfo[j].PosY, baseInfo[j].PosZ - 1.0, "cylinder", Config.CPSize, Config.CPColor[1], Config.CPColor[2], Config.CPColor[3], Config.CPColor[4] );
		end

		Round.Blip			 = createBlipAttachedTo( Round.CP, 0 );

		setBlipOrdering( Round.Blip, 1 );
		setElementDimension( Round.CP, rDimension );
		setElementInterior ( Round.CP, baseInfo[baseid].Interior );
		addEventHandler( "onMarkerHit",   Round.CP, onPlayerEnterCheckpoint, true );
		addEventHandler( "onMarkerLeave", Round.CP, onPlayerLeaveCheckpoint, true );

		Round.LoadTime 		 = Config.LoadTime;
		Round.ID 		 	 = baseid;
		Round.IsRoundStarted = true;
		Round.TimeInCP       = Config.CPTime;
		Round.PlayersInCP 	 = 0;
		Round.Gametype       = BASE;
		--Round.TotalAtt       = countPlayersInTeam( Teams.Attackers );
		--Round.TotalDef	   = countPlayersInTeam( Teams.Defenders );

		setGameType( "Base #" .. baseid );

		roundLoadUpdate( "Base" );
	end

	setTeamFriendlyFire( Teams.Attackers, false );
	setTeamFriendlyFire( Teams.Defenders, false );

	return startbase;
end

function startTdmCmd( playerSource, cmd, tdmid ) -- remember to make this not a command later
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is already started!", playerSource, 255, 255, 255, true ) end
	if tdmid == nil then tdmid = -1 end

	tdmid = tonumber(tdmid);
	if tdmid == -1 then tdmid = determineRandomTDM( ) end

	if countPlayersInTeam( Teams.Attackers ) == 0 or countPlayersInTeam( Teams.Defenders ) == 0 then
		outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Not enough players.", playerSource, 255, 255, 255, true);
		return 0;
	end

	if not startTdm( tdmid ) then
		outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid tdm id!", playerSource, 255, 255, 255, true );
	else return outputChatBox( COLOR_WHITE .. getPlayerName(playerSource) .. " has started arena: ".. COLOR_RED .. tdmid, getRootElement( ), 255, 255, 255, true ) end
end

function startTdm( tdmid )



	local tdm = startResource( getResourceFromName( "arena-" .. tdmid ) );
	if tdm then

		local spawn = getElementsByType( "spawnpoint" );
		--local teams = getElementsByType( "team"       );
		for v, i in ipairs( spawn ) do
			arenaInfo[i]				=	{};
			arenaInfo[tdmid]			=   {};
			arenaInfo[i].PosX			=	getElementData( i, "posX" 		);
			arenaInfo[i].PosY			=	getElementData( i, "posY" 		);
			arenaInfo[i].PosZ			=	getElementData( i, "posZ" 		);
			arenaInfo[i].Team			=	getElementData( i, "team" 	  	);
			arenaInfo[tdmid].Interior	= 	getElementData( i, "interior" 	); -- yes, TDM id, interior should be the same on all spawn points.
			arenaInfo[i].RotX			=	getElementData( i, "rotX" 		);
			arenaInfo[i].RotY			=	getElementData( i, "rotY" 		);
			arenaInfo[i].RotZ			=	getElementData( i, "rotZ" 		);

			--outputChatBox( getElementData( i, "posX" ) .. " " .. getElementData( i, "posY" ) .. " " .. getElementData( i, "posZ" ), getRootElement( ), 255, 255, 255, true );
		end
		local cp = getElementsByType( "checkpoint" );
		for v, i in ipairs( cp ) do
			arenaInfo[i]				=	{};
			arenaInfo[i].PosX			=	getElementData( i, "posX" 		);
			arenaInfo[i].PosY			=	getElementData( i, "posY" 		);
			arenaInfo[i].PosZ			=	getElementData( i, "posZ" 		);
			arenaInfo[i].RotX			=	getElementData( i, "rotX" 		);
			arenaInfo[i].RotY			=	getElementData( i, "rotY" 		);
			arenaInfo[i].RotZ			=	getElementData( i, "rotZ" 		);
		end

		for v, i in ipairs( getElementsByType( "player" ) ) do
			if isPlayerSpawned( i ) then
				local team = getPlayerTeam( i );
				if team ~= nil then
					if isPedInVehicle( i ) then
						local t = getPedOccupiedvehicle( i );
						removePedFromVehicle( i );
						destroyElement( t );
					end

					spawn = shuffle( spawn );

					Player[i].ScreenLastTaken   = nil;
					Player[i].RoundLoading  = true;
					Player[i].InRound 		= true;
					Player[i].PlayedRound   = true;

					if getCameraTarget( i ) ~= i then

						setCameraTarget( i, i );
						setElementAlpha( i, 255 );
						setElementData( i, "spectating", nil );

						triggerClientEvent( i, 						  "hideSpecGui", getRootElement( ), 1 );
						triggerClientEvent( Player[i].Spectating, 	  "hideSpecGui", getRootElement( ), 2 );

						Player[i].Spectating = nil;

					end

					setElementDimension( i, rDimension );
					setElementInterior(  i, arenaInfo[tdmid].Interior );

					setElementHealth( i, Config.RoundHP );
					setPedArmor( i, Config.RoundAP );

					setElementData( i, "Health", Config.RoundHP + Config.RoundAP );

					setElementAlpha( i, Config.GunmenuAlpha );
					showPlayerHudComponent( i, "all", false );

					setElementData( i, "round.health", Config.RoundHP + Config.RoundAP );
					setElementData( i, "round.dmg",    0 							   );

					takeAllWeapons( i );

					for k, j in ipairs( cp ) do
						triggerClientEvent( i, "roundLoadUpdate", getRootElement( ), arenaInfo[j].PosX, arenaInfo[j].PosY, arenaInfo[j].PosZ, 50, true);
					end

					for k, j in ipairs( spawn ) do
						if ( team == Teams.Attackers and arenaInfo[j].Team == "Att" ) or ( team == Teams.Defenders and arenaInfo[j].Team == "Def" ) then
							setElementPosition( i, arenaInfo[j].PosX, arenaInfo[j].PosY, arenaInfo[j].PosZ);
						end
					end

					local t = getAttachedElements( i );
					if t then
						for j, k in ipairs( t ) do
							if ( getElementType ( k ) == "blip" ) then
								setElementDimension(  k, getElementDimension( i ) );
								clearElementVisibleTo( k );
								for h, n in ipairs( getPlayersInTeam( team ) ) do
									if n ~= i then
										setElementVisibleTo(  k, n, true  );
									end
								end
							end
						end
					end
					toggleAllControls( i, false, true, false );
					resendPlayerModInfo( i );
				end
			end
		end
		Timers.RoundTimer     = setTimer(roundLoadUpdate, 1000, Round.LoadTime+1, "Arena", Round.LoadTime);

		Round.LoadTime 		 = Config.LoadTime;
		Round.ID 		 	 = tdmid;
		Round.IsRoundStarted = true;
		Round.TimeInCP       = Config.CPTime;
		Round.PlayersInCP 	 = 0;
		Round.Gametype       = TDM;
		--Round.TotalAtt       = countPlayersInTeam( Teams.Attackers );
		--Round.TotalDef		 = countPlayersInTeam( Teams.Defenders );

		setGameType( "Arena #" .. tdmid );

		roundLoadUpdate( "Arena" );
	end

	setTeamFriendlyFire( Teams.Attackers, false );
	setTeamFriendlyFire( Teams.Defenders, false );

	return tdm;
end

function playerDamage( attacker, wep, bodypart, hp )

	if hp == 0 then
		return 1;
	end

	if source ~= attacker then
		triggerClientEvent( source,   "showDamageGui", source, attacker, wep, bodypart, hp );

		if isElement( attacker ) and getElementType( attacker ) == "player" then
			setElementData( attacker, "Dmg", round( getElementData( attacker, "Dmg" ) + hp ) );
			triggerClientEvent( attacker, "showDamageGui", source, attacker, wep, bodypart, hp );
			if Player[attacker].InRound then
				setElementData( attacker, "round.dmg", round( getElementData( attacker, "round.dmg" ) + hp ) );
			end
		end
		local currhp = round( getElementHealth( source ) + getPedArmor( source ) );
		setElementData( source, "Health", currhp );
		if Player[source].InRound then
			setElementData( source, "round.health", currhp );
		end
	end
	return 1;
end


function roundLoadUpdate( roundtype )
	for v, i in ipairs(getElementsByType("player")) do
		if Player[i].RoundLoading == true then
			triggerClientEvent(i, "updateRoundLoadText", getRootElement(), roundtype, Round.LoadTime);
		end
	end
	if Round.LoadTime == 0 then
		onRoundLoadFinish( );
	end
	Round.LoadTime = Round.LoadTime - 1;
end

function onRoundLoadFinish()
	if isTimer( Timers.RoundTimer ) then killTimer( Timers.RoundTimer ); end
	local baseid = Round.ID;
	for v, i in ipairs(getElementsByType("player")) do
		if Player[i].InRound == true then
			addPlayerToRound( i );
			takeScreen( i );
		end
	end
	Round.Minutes    =     (Config.RoundTime / 60) / 1000; -- since the time is saved in miliseconds, convert it to minutes.
	Round.Seconds    =     (Config.RoundTime % 60) / 1000; -- convert to seconds too.

	Timers.RoundTimer = setTimer( roundUpdate, 1000, 0, BASE, Round.ID );
	-- todo: base update timer 1000 ms during entire round
end

function roundUpdate( gametype, roundid )

	if Round.Paused == true then
		killTimer( Timers.RoundTimer );
		-- we re-set the timer when the round is unpaused.
	end
	Round.Seconds       = Round.Seconds - 1;
	if Round.Seconds < 0 then
		Round.Minutes   = Round.Minutes - 1;
		Round.Seconds   = 59;
	end
	if Round.Minutes < 1 and Round.Seconds < 1 then
		Round.LoserTeam = Teams.Attackers;
		Round.WinnerReason = "Time Up";
		endRound( );
	end
	local atthp, defhp = 0, 0;
	for v, i in ipairs(getElementsByType("player")) do
		if Player[i].InRound == true then
			setElementData( i, "round.health", round( getPedArmor( i ) + getElementHealth( i ) ) );
			if Player[i].InCP == true and isElement( Round.CP ) then
				if isElementWithinMarker( i, Round.CP ) then
					Round.TimeInCP = Round.TimeInCP - 1;
					if Round.TimeInCP == 0 then
						Round.LoserTeam = Teams.Defenders;
						Round.WinnerReason = "CP Capture";
						endRound( );
					end
				else
					Player[i].InCP = false;
				end
			end
			if getPlayerTeam( i ) 	  == Teams.Attackers then
				atthp = atthp + getElementHealth( i ) + getPedArmor( i );
			elseif getPlayerTeam( i ) == Teams.Defenders then
				defhp = defhp + getElementHealth( i ) + getPedArmor( i );
			end

			if Player[i].ScreenLastTaken ~= Round.Minutes and math.random( 0, Round.Seconds ) == Round.Seconds - 1 then
				takeScreen( i );
				Player[i].ScreenLastTaken = Round.Minutes;
			end
		end
	end
	if Round.PlayersInCP == 0 then
		Round.TimeInCP         = Config.CPTime;
	end

	local Table 		= {};
	Table.Minutes		= Round.Minutes;
	Table.Seconds       = Round.Seconds;
	Table.CP			= Round.PlayersInCP and Round.TimeInCP;
	Table.AttHP			= round( atthp );
	Table.DefHP			= round( defhp );
	Table.AttPlayers    = Round.TotalAtt;
	Table.DefPlayers    = Round.TotalDef;

	triggerClientEvent( getRootElement( ), "roundUpdate", getRootElement( ), gametype, roundid, Table );
	-- todo: update gui on client end, update CP gui on client end, send as a param in a triggerclientevent

end

function player_Wasted ( ammo, attacker, weapon, bodypart )
	if Player[source].InRound == true then
		if attacker then
			outputChatBox( "" .. COLOR_RED .. getPlayerName( attacker ) .. " killed " .. getPlayerName( source ) .. " (" .. COLOR_BLUE .. getWeaponNameFromID( weapon ) .. ", " .. getBodyPartName( bodypart ) .. ")", getRootElement( ), 255, 255, 255, true );
		else
			outputChatBox( "" .. COLOR_RED .. getPlayerName( source ) .. " suicided!", getRootElement( ), 255, 255, 255, true );
		end
		Player[source].InRound = false;
		subtractPlayerFromRound( source );
	end
	local pos = Config.Lobby;
	if getPlayerTeam( source ) == Teams.Defenders then
		setTimer( spawnPlayer, 3000, 1, source, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.DefSkin, 0, lDimension, Teams.Defenders );
	elseif getPlayerTeam( source ) == Teams.Attackers then
		setTimer( spawnPlayer, 3000, 1, source, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.AttSkin, 0, lDimension, Teams.Attackers );
	end
	if isElement( attacker ) then
		local kills = getElementData( attacker, "Kills", false );
		if not kills then kills = 0; end
		setElementData( attacker, "Kills", kills + 1 );
	end
	local deaths = getElementData( source, "Deaths", false );
	if not deaths then deaths = 0; end
	setElementData( source, "Deaths", deaths + 1 );
	if Player[source].InCP == true then
		Player[source].InCP = false;
		Round.PlayersInCP = Round.PlayersInCP - 1;
	end
	for v, i in ipairs( getElementsByType( "player" ) ) do

		if getElementData( i, "spectating", false ) == source then

			setCameraTarget( i, i );
			setElementAlpha( i, 255 );
			setElementData( i, "spectating", nil );

			triggerClientEvent( i, 						  "hideSpecGui", getRootElement( ), 1 );
			triggerClientEvent( Player[i].Spectating, 	  "hideSpecGui", getRootElement( ), 2 );

			Player[i].Spectating = nil;
		end

	end

	Player[source].Spawned = false;

end

function endRoundCmd( playerSource, cmd )

	if isPlayerMod( playerSource ) ~= true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently not underway", playerSource, 255, 255, 255, true ) end

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has ended the round.", getRootElement( ), 255, 255, 255, true );

	endRound( );
end

function giveMenuCmd( playerSource, cmd, player )
	if isPlayerMod( playerSource ) ~= true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently not underway", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );

	if target 				  == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " Invalid player!", playerSource, 255, 255, 255, true ) end
	if isPedDead( target )    == true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is dead!", playerSource, 255, 255, 255, true ) end
	if Player[target].InRound == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is not in the round!", playerSource, 255, 255, 255, true ) end

	for i=0, 12 do
		local slot = getPedWeapon( target, i );
		if slot > 0 then
			local team = getPlayerTeam( target );
			if team == Teams.Attackers then
				Weapons.Gunmenu.Limits.AttUsed[slot] = Weapons.Gunmenu.Limits.AttUsed[slot] - 1;
			elseif team == Teams.Defenders then
				Weapons.Gunmenu.Limits.DefUsed[slot] = Weapons.Gunmenu.Limits.DefUsed[slot] - 1;
			end
		end
	end

	triggerClientEvent( target, "showGunMenu", getRootElement( ), Weapons.Gunmenu );

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has given the gunmenu to " .. getPlayerName( target ), getRootElement( ), 255, 255, 255, true );

end

function endRound( )

	if Round.LoserTeam 	   == Teams.Attackers then
		if Round.WinnerReason == "Elimination" then
			outputChatBox( rgbtohex( getTeamColor( Teams.Defenders ) ) .. getTeamName( Teams.Defenders ) .. COLOR_WHITE ..  " has defeated " .. rgbtohex( getTeamColor( Teams.Attackers ) ) .. getTeamName( Teams.Attackers ) .. COLOR_WHITE .. "(ELIMINATION)", getRootElement( ), 255, 255, 255, true );
		elseif Round.WinnerReason == "Time Up" then
			outputChatBox( rgbtohex( getTeamColor( Teams.Defenders ) ) .. getTeamName( Teams.Defenders ) .. COLOR_WHITE ..  " has defeated " .. rgbtohex( getTeamColor( Teams.Attackers ) ) .. getTeamName( Teams.Attackers ) .. COLOR_WHITE .. "(TIME UP)", getRootElement( ), 255, 255, 255, true );
		end
		Teams.DefWins = Teams.DefWins + 1;
	elseif Round.LoserTeam == Teams.Defenders then
		if Round.WinnerReason == "CP Capture" then
			outputChatBox( rgbtohex( getTeamColor( Teams.Attackers ) ) .. getTeamName( Teams.Attackers ) .. COLOR_WHITE ..  " has defeated " .. rgbtohex( getTeamColor( Teams.Defenders ) ) .. getTeamName( Teams.Defenders ) .. COLOR_WHITE .. "(CP CAPTURE)", getRootElement( ), 255, 255, 255, true );
		elseif Round.WinnerReason == "Elimination" then
			outputChatBox( rgbtohex( getTeamColor( Teams.Attackers ) ) .. getTeamName( Teams.Attackers ) .. COLOR_WHITE ..  " has defeated " .. rgbtohex( getTeamColor( Teams.Defenders ) ) .. getTeamName( Teams.Defenders ) .. COLOR_WHITE .. "(ELIMINATION)", getRootElement( ), 255, 255, 255, true );
		end
		Teams.AttWins = Teams.AttWins + 1;
	end

	for i=1, 46 do
		Weapons.Gunmenu.Limits.AttUsed[i] 	= 0;
		Weapons.Gunmenu.Limits.DefUsed[i] 	= 0;
	end

	destroyInRoundVehicles( );

	outputChatBox("end round called", getRootElement(), 255, 255, 255, true);


	if Round.Gametype == BASE then

		destroyElement( Round.CP   );
		destroyElement( Round.Blip );

		--local t =

		stopResource( getResourceFromName( "base-" .. Round.ID ) );

	elseif Round.Gametype == TDM then
		stopResource( getResourceFromName( "arena-" .. Round.ID ) );
	end

	killTimer( Timers.RoundTimer );

	local _table 		  = {};


	for v, i in ipairs( getElementsByType( "player" ) ) do


		setElementDimension( i, lDimension );
		setElementAlpha( i, 255 );
		setCameraTarget ( i, i );

		resetBlipSettings( i );

		local pos = Config.Lobby;
		if getPlayerTeam( i ) 	  == Teams.Defenders then
			spawnPlayer( i, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.DefSkin, 0, 0 );
		elseif getPlayerTeam( i ) == Teams.Attackers then
			spawnPlayer( i, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0.0, Teams.AttSkin, 0, 0 );
		end


		Player[i].InRound = false;

		if Player[i].PlayedRound then
			_table[i] = true;
		else
			_table[i] = false;
		end
		Player[i].PlayedRound = false;
	end

	setTeamFriendlyFire( Teams.Attackers, true );
	setTeamFriendlyFire( Teams.Defenders, true );

	setGameType( SCRIPT_NAME .. " v" .. SCRIPT_VER );

	triggerClientEvent( getRootElement( ), "onRoundEnd", getRootElement( ), _table, Round.LoserTeam, Teams.AttWins, Teams.DefWins );

	Round.LoadTime 		  = -1;
	Round.ID         	  = -1;
	Round.IsRoundStarted  = false;
	Round.TimeInCP        = Config.CPTime;
	Round.PlayersInCP 	  = 0;
	Round.Gametype        = 0;
	Round.TotalAtt        = 0;
	Round.TotalDef        = 0;
	Round.LoserTeam		  = nil;
	Round.WinnerReason    = nil;

end

function addPlayerToRound( player )
	triggerClientEvent	  ( player, "roundLoadFinish", getRootElement( ), Teams.Attackers, Teams.Defenders, Config.CPTime, Weapons.Gunmenu );
	triggerClientEvent	  ( player, "showGunMenu", getRootElement( ), Weapons.Gunmenu );
	triggerClientEvent	  ( player, "showTheProperHud", getRootElement( ) );
	setElementFrozen  	  ( player, false );
	setCameraTarget   	  ( player, player );
	setElementHealth  	  ( player, Config.RoundHP );
	setPedArmor       	  ( player, Config.RoundAP );
	setElementData		  ( player, "Health", Config.RoundHP + Config.RoundAP );
	setElementAlpha       ( player, 255 );
	setElementDimension   ( player, rDimension );
	if Round.Gametype == BASE then
		setElementInterior    ( player, baseInfo[Round.ID].Interior );
	elseif Round.Gametype == TDM then
		setElementInterior    ( player, arenaInfo[Round.ID].Interior );
	end

	Player[player].InRound 			= true;
	Player[player].PlayedRound 		= true;

	local team = getPlayerTeam( player );
	if 		getPlayerTeam( player ) == Teams.Defenders then
		Round.TotalDef = Round.TotalDef + 1;
	elseif getPlayerTeam( player ) == Teams.Attackers then
		Round.TotalAtt = Round.TotalAtt + 1;
	end

	if Round.Gametype == BASE then
		for k, j in ipairs( getElementsByType( "spawnpoint" ) ) do
			if ( team == Teams.Attackers and baseInfo[j].Team == "Att" ) or ( team == Teams.Defenders and baseInfo[j].Team == "Def" ) then
				setElementPosition( player, baseInfo[j].PosX, baseInfo[j].PosY, baseInfo[j].PosZ);
			end
		end
	elseif Round.Gametype == TDM then
		for k, j in ipairs( getElementsByType( "spawnpoint" ) ) do
			if ( team == Teams.Attackers and arenaInfo[j].Team == "Att" ) or ( team == Teams.Defenders and arenaInfo[j].Team == "Def" ) then
				setElementPosition( player, arenaInfo[j].PosX, arenaInfo[j].PosY, arenaInfo[j].PosZ);
			end
		end
	end
end

function removePlayerFromRound( player )
	Player[player].InRound = false;
	triggerClientEvent( player, "resetRoundVariables", getRootElement( ) );
	spawnAtLobby( player );
	subtractPlayerFromRound( player );

end

function onPlayerPickedWeapons( wep1, wep2 )
	-- source = player that picked weapons.
	--wep1, wep2 = getWeaponIDFromName( wep1 ), getWeaponIDFromName( wep2 );

	if getPlayerTeam( source ) 	   == Teams.Attackers then

		if wep1 ~= false then
			if Weapons.Gunmenu.Limits.AttUsed[wep1] + 1 > Weapons.Gunmenu.Limits[wep1] then
				triggerClientEvent( source, "showGunMenu", getRootElement( ), Weapons.Gunmenu );
				return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "weapon " .. getWeaponNameFromID( wep1 ) .. " has reached it's weapon limit! choose again.", source, 255, 255, 255, true );
			end

			Weapons.Gunmenu.Limits.AttUsed[wep1] = Weapons.Gunmenu.Limits.AttUsed[wep1] + 1;
		end


		if wep2 ~= false then
			if Weapons.Gunmenu.Limits.AttUsed[wep2] + 1 > Weapons.Gunmenu.Limits[wep2] then
				triggerClientEvent( source, "showGunMenu", getRootElement( ), Weapons.Gunmenu );
				return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "weapon " .. getWeaponNameFromID( wep2 ) .. " has reached it's weapon limit! choose again.", source, 255, 255, 255, true );
			end

			Weapons.Gunmenu.Limits.AttUsed[wep2] = Weapons.Gunmenu.Limits.AttUsed[wep2] + 1;
		end
	elseif getPlayerTeam( source ) == Teams.Defenders then

		if wep1 ~= false then
			if Weapons.Gunmenu.Limits.DefUsed[wep1] + 1 > Weapons.Gunmenu.Limits[wep1] then
				triggerClientEvent( source, "showGunMenu", getRootElement( ), Weapons.Gunmenu );
				return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "weapon " .. getWeaponNameFromID( wep1 ) .. " has reached it's weapon limit! choose again.", source, 255, 255, 255, true );
			end

			Weapons.Gunmenu.Limits.DefUsed[wep1] = Weapons.Gunmenu.Limits.DefUsed[wep1] + 1;
		end

		if wep2 ~= false then
			if Weapons.Gunmenu.Limits.DefUsed[wep2] + 1 > Weapons.Gunmenu.Limits[wep2] then
				triggerClientEvent( source, "showGunMenu", getRootElement( ), Weapons.Gunmenu );
				return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "weapon " .. getWeaponNameFromID( wep2 ) .. " has reached it's weapon limit! choose again.", source, 255, 255, 255, true );
			end

			Weapons.Gunmenu.Limits.DefUsed[wep2] = Weapons.Gunmenu.Limits.DefUsed[wep2] + 1;
		end
	end
	setElementAlpha( source, 255 							  );
	takeAllWeapons(  source 								  );
	if wep1 then
		giveWeapon(  source, wep1, Weapons.Gunmenu.Ammo[wep1] );
	end
	if wep2 then
		giveWeapon(  source, wep2, Weapons.Gunmenu.Ammo[wep2] );
	end
	for i=1, #Weapons.Gunmenu.Autogiven.Weapons do
		outputDebugString("" .. Weapons.Gunmenu.Autogiven.Weapons[i] );
		giveWeapon( source, Weapons.Gunmenu.Autogiven.Weapons[i], Weapons.Gunmenu.Autogiven.Ammo[i] );
	end

end

function onPlayerEnterCheckpoint( hit, dimension )
	if dimension == true and source == Round.CP and getElementType( hit ) == "player" and getPedOccupiedVehicle( hit ) == false then
		if Player[hit].InRound == true then
			if getPlayerTeam( hit ) == Teams.Attackers then
				Player[hit].InCP        = true;
				Round.PlayersInCP 		= Round.PlayersInCP + 1;
			elseif getPlayerTeam( hit ) == Teams.Defenders then
				Round.TimeInCP = Config.CPTime;
			end
		end
	end
end

function onPlayerLeaveCheckpoint( hit, dimension )
	if dimension == true and source == Round.CP and getElementType( hit ) == "player" and getPedOccupiedVehicle( hit ) == false then
		Player[hit].InCP     						  = false;
		if Round.PlayersInCP ~= 0 then Round.PlayersInCP = Round.PlayersInCP - 1; end
	end
end

function teamIndexToTeam( teamindex )
	if 		teamindex == 0 then return "Auto-Assign"
	elseif  teamindex == 1 then return "Attackers"
	elseif 	teamindex == 2 then return "Defenders"
	else return nil end
end

function indexToTeam( team )
	if 		team == 0 then return 0;
	elseif  team == Teams.Attackers then return 1;
	elseif 	team == Teams.Defenders then return 2;
	else return nil end
end

function calculateSpawnGUILabels( team )
	if team 	== "Auto-Assign" then
		triggerClientEvent(source, "guiSpawnUpdate", getRootElement( ), 0, 0, 0, 0, nil, Teams.Attackers, Teams.Defenders, Round.TimeInCP );
	elseif team == "Defenders"   then
		triggerClientEvent(source, "guiSpawnUpdate", getRootElement( ), countPlayersInTeam(Teams.Defenders), Teams.DefSkin, Teams.DefWins, Teams.AttWins, Teams.Defenders, Teams.Attackers, Teams.Defenders, Round.TimeInCP );
	elseif team == "Attackers"   then
		triggerClientEvent(source, "guiSpawnUpdate", getRootElement( ), countPlayersInTeam(Teams.Attackers), Teams.AttSkin, Teams.AttWins, Teams.DefWins, Teams.Attackers, Teams.Attackers, Teams.Defenders, Round.TimeInCP );
	end
end

function isValidWeapon(wep)
	if not isNumeric( wep ) then return false; end
	wep = tonumber(wep);
	if wep > 0 and wep < 46 then
		return true;
	end
	return false;
end

function isNumeric(a)
	if tonumber(a) ~= nil then
		return true;
	end
end

function isPlayerAdmin( player )
	if isGuestAccount( getPlayerAccount( player ) ) then return false; end
	return isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "Admin" ) );
end

function isPlayerMod( player )
	if isGuestAccount( getPlayerAccount( player ) ) then return false; end
	return isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "Moderator" ) ) or isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "SuperModerator" ) ) or isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "Admin" ) );
end

function isPlayerSuperMod( player )
	if isGuestAccount( getPlayerAccount( player ) ) then return false; end
	return isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "SuperModerator" ) ) or isObjectInACLGroup ( "user." .. getPlayerName( player ), aclGetGroup ( "Admin" ) );
end



-- this function isn't used anymore, previous base load system


--[[function LoadBases()
	local file
	for i=0, MAX_BASES do
		file = "bases/" .. i .. ".xml";

		local xml   = xmlLoadFile(file)
		if xml then
			baseInfo[i] 				= 		{};

			local att 					=		xmlFindChild(xml, "attackers", 0)
			local def					= 		xmlFindChild(xml, "defenders", 0)
			local cp  					= 		xmlFindChild(xml, "cp", 0)
			local stats 				= 		xmlFindChild(xml, "stats", 0)

			baseInfo[i].Interior        =       xmlNodeGetValue(xmlFindChild(xml, "interior", 0));

			baseInfo[i].AttackerX 		= 		xmlNodeGetValue(xmlFindChild(att, "posX", 0));
			baseInfo[i].AttackerY 		= 		xmlNodeGetValue(xmlFindChild(att, "posY", 0));
			baseInfo[i].AttackerZ		=		xmlNodeGetValue(xmlFindChild(att, "posZ", 0));

			baseInfo[i].DefenderX 		=		xmlNodeGetValue(xmlFindChild(def, "posX", 0));
			baseInfo[i].DefenderY 		= 		xmlNodeGetValue(xmlFindChild(def, "posY", 0));
			baseInfo[i].DefenderZ 		= 		xmlNodeGetValue(xmlFindChild(def, "posZ", 0));

			baseInfo[i].CheckpointX 	= 		xmlNodeGetValue(xmlFindChild(cp, "posX", 0));
			baseInfo[i].CheckpointY 	= 		xmlNodeGetValue(xmlFindChild(cp, "posY", 0));
			baseInfo[i].CheckpointZ 	= 		xmlNodeGetValue(xmlFindChild(cp, "posZ", 0));

			baseInfo[i].AttackerWins    =       xmlNodeGetValue(xmlFindChild(stats, "AttackerWins", 0));
			baseInfo[i].DefenderWins    =       xmlNodeGetValue(xmlFindChild(stats, "DefenderWins", 0));
			baseInfo[i].TimesPlayed     =       xmlNodeGetValue(xmlFindChild(stats, "TimesPlayed", 0));

			baseInfo[i].Exists          =       true;

			baseInfo.TotalBases			=		i;

			xmlUnloadFile( xml );
		end
	end
end]]

function getMaxBase()
	for i=1, MAX_BASES do
		if getResourceFromName( "base-" .. tostring( i ) ) ~= false then
			baseInfo.TotalBases	=	i;
		end
	end
end

function getMaxTDM()
	for i=1, MAX_ARENAS do
		if getResourceFromName( "arena-" .. tostring( i ) ) ~= false then
			arenaInfo.TotalArenas	=	i;
		end
	end
end

function loadConfig( )
	local xml, round, cfg, stats, teams, guns, limits;
	if not fileExists("config/cfg.xml") then
		xml = xmlCreateFile( "config/cfg.xml", "root" );

		round 		= xmlCreateChild( xml,  "newroot" 	);
		cfg 		= xmlCreateChild( xml,  "newroot" 	);
		stats 		= xmlCreateChild( xml,  "newroot" 	);
		teams 		= xmlCreateChild( xml,  "newroot" 	);
		guns 		= xmlCreateChild( xml,  "newroot" 	);
		limits 		= xmlCreateChild( guns, "newroot" 	);


		xmlNodeSetName( round,  "round" 		);
		xmlNodeSetName( cfg,    "cfg"   		);
		xmlNodeSetName( guns,   "guns"  		);
		xmlNodeSetName( stats,  "stats" 		);
		xmlNodeSetName( teams,  "teams" 		);
		xmlNodeSetName( limits, "limits" 		);

		local LoadTime = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( LoadTime, "LoadTime" );
		xmlNodeSetValue( LoadTime, "10" );

		local FPSLimit = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( FPSLimit, "FPSLimit" );
		xmlNodeSetValue( FPSLimit, "45" );

		local Lobby = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Lobby, "Lobby" );
		xmlNodeSetValue( Lobby, "1381.584594, 2183.483642, 11.023437" );

		local CPSize = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( CPSize, "CPSize" );
		xmlNodeSetValue( CPSize, "2" );

		local CPColor = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( CPColor, "CPColor" );
		xmlNodeSetValue( CPColor, "255, 0, 0, 75" );

		local CPTime = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( CPTime, "CPTime" );
		xmlNodeSetValue( CPTime, "20" );

		local CarDistance = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( CarDistance, "CarDistance" );
		xmlNodeSetValue( CarDistance, "150" );

		local RoundHP = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( RoundHP, "RoundHP" );
		xmlNodeSetValue( RoundHP, "100" );

		local RoundAP = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( RoundAP, "RoundAP" );
		xmlNodeSetValue( RoundAP, "100" );

		local LobbyHP = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LobbyHP, "LobbyHP" );
		xmlNodeSetValue( LobbyHP, "100" );

		local LobbyAP = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LobbyAP, "LobbyAP" );
		xmlNodeSetValue( LobbyAP, "100" );

		local Roundtime = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( Roundtime, "RoundTime" );
		xmlNodeSetValue( Roundtime, "600000" );

		local Wind = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Wind, "Wind" );
		xmlNodeSetValue( Wind, "0, 0, 0" );

		local Glitches = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Glitches, "Glitches" );
		xmlNodeSetValue( Glitches, "true, false, true, true, false" );

		local GunmenuAlpha = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( GunmenuAlpha, "GunmenuAlpha" );
		xmlNodeSetValue( GunmenuAlpha, "0" );

		local farClipDistance = xmlCreateChild( round, "newchild" );
		xmlNodeSetName( farClipDistance, "farClipDistance" );
		xmlNodeSetValue( farClipDistance, "2000" );

		local clanTag = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( clanTag, "clanTag" );
		xmlNodeSetValue( clanTag, "[U]" );

	--------------------------------------------------------------------

		local Gunmenu1 = xmlCreateChild( guns, "newchild" );
		xmlNodeSetName( Gunmenu1, "Gunmenu1" );
		xmlNodeSetValue( Gunmenu1, "24, 34, 27, 31" );

		local Gunmenu2 = xmlCreateChild( guns, "newchild" );
		xmlNodeSetName( Gunmenu2, "Gunmenu2" );
		xmlNodeSetValue( Gunmenu2, "25, 30, 29" );


		-- Okay, now before I get yelled at there IS a reason there is 2 loops to do this        V
		-- The reason it does 2 loops is because I don't care about effincency AND it will show in the .cfg file correctly by doing 2 loops and ONLY by doing 2 loops.
		for i=1, 46 do
			local maxuses = xmlCreateChild( limits, "newchild" );
			xmlNodeSetName( maxuses, "limits_" .. i );
			xmlNodeSetValue( maxuses, "999" );

			local wep = xmlCreateChild( guns, "newchild" );
			xmlNodeSetName( wep, "wep_" .. i );
			xmlNodeSetValue( wep, "1" );

		end

		for i=1, 46 do
			local ammo = xmlCreateChild( limits, "newchild" );
			xmlNodeSetName( ammo, "ammo_" .. i );
			xmlNodeSetValue( ammo, "9999" );
		end
		-- Back to normal.

		for i=0, 230 do

			local stat = xmlCreateChild( stats, "newchild" );
			xmlNodeSetName( stat, "stats_" .. i );
			xmlNodeSetValue( stat, "999" );

		end

		local AttSkin = xmlCreateChild( teams, "newchild" );
		xmlNodeSetName( AttSkin, "AttSkin" );
		xmlNodeSetValue( AttSkin, "230" );

		local DefSkin = xmlCreateChild( teams, "newchild" );
		xmlNodeSetName( DefSkin, "DefSkin" );
		xmlNodeSetValue( DefSkin, "231" );

		local AttName = xmlCreateChild( teams, "newchild" );
		xmlNodeSetName( AttName, "AttName" );
		xmlNodeSetValue( AttName, "Attackers" );

		local DefName = xmlCreateChild( teams, "newchild" );
		xmlNodeSetName( DefName, "DefName" );
		xmlNodeSetValue( DefName, "Defenders" );

		local removeModels = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( removeModels, "removeModels" );
		xmlNodeSetValue( removeModels, "7598, 7541, 7542, 7543, 7562, 7563, 7564, 7565, 7566, 7567, 7568, 7569, 7570, 7571, 7572, 7573, 7574, 7575, 7576, 7577, 7578, 7607, 7608, 7609, 7638, 7639, 7640, 7641, 7642, 7643, 7644, 7645, 7646, 7647, 7648, 7649, 956, 955, 1211, 737, 1686, 3791, 3787 3789, 3794, 3792, 3790, 3459, 3460, 3447, 3459, 1350, 956, 955, 1211, 737, 1290, 1315, 1283, 3875, 1232, 1226, 3463, 1278, 7078, 7077, 7076, 7075, 1294, 8086, 8085, 8084, 8083, 8082, 8081, 1308, 16372, 16373, 16374, 16371, 13440, 1351, 13441, 13442, 13443, 13444, 13447, 13448, 13449, 13451, 13452, 3465, 7080, 7079, 7081, 7082, 7083, 7084, 7085, 7086, 7087, 13436, 13205, 13437, 13374, 5025, 5088, 4984, 4982, 4983, 4981, 1307, 3516, 7637, 13375, 1284, 1297, 17504, 1231, 5783, 6362, 6499, 6363, 10703, 10736, 3855, 17886, 17887, 17875, 17874, 17518, 17876, 13137, 10012, 10040" );
		-- all these IDs are random poles/wires connecting to poles around GTA SA.

		local Sync = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Sync, "Sync" );
		xmlNodeSetValue( Sync, "1" );


		xmlSaveFile( xml );
	else
		xml = xmlLoadFile( "config/cfg.xml" );

		round 		= xmlFindChild( xml,  "round",  0 	);
		cfg 		= xmlFindChild( xml,  "cfg",    0 	);
		stats 		= xmlFindChild( xml,  "stats",  0 	);
		teams 		= xmlFindChild( xml,  "teams",  0 	);
		guns 		= xmlFindChild( xml,  "guns",   0	);
		limits 		= xmlFindChild( guns, "limits", 0 	);
	end



	Config.RoundTime      		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "RoundTime",			0 ) ) ); -- in miliseconds.
	Config.CPSize         		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "CPSize",   			0 ) ) );
	Config.CPTime         		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "CPTime",   			0 ) ) );
	Config.CarDistance						= tonumber( xmlNodeGetValue( xmlFindChild( round, "CarDistance",		0 ) ) );
	Config.RoundHP        		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "RoundHP",			0 ) ) );
	Config.RoundAP        		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "RoundAP",			0 ) ) );
	Config.LoadTime 	   		  			= tonumber( xmlNodeGetValue( xmlFindChild( round, "LoadTime", 			0 ) ) );

	Config.FPSLimit        		  			= tonumber( xmlNodeGetValue( xmlFindChild( cfg,   "FPSLimit", 			0 ) ) );
	Config.Sync        		  				= tonumber( xmlNodeGetValue( xmlFindChild( cfg,   "Sync", 				0 ) ) );
	Config.FarClip							= tonumber( xmlNodeGetValue( xmlFindChild( cfg,   "farClipDistance",	0 ) ) );
	Config.LobbyHP							= tonumber( xmlNodeGetValue( xmlFindChild( cfg,   "LobbyHP",			0 ) ) );
	Config.LobbyAP							= tonumber( xmlNodeGetValue( xmlFindChild( cfg,   "LobbyAP",			0 ) ) );

	Config.clanTag							= tostring( xmlNodeGetValue( xmlFindChild( cfg,   "clanTag", 			0 ) ) );

	Config.RemoveModels						= split	  ( xmlNodeGetValue( xmlFindChild( cfg,   "removeModels",  		0 ) ), ", " );
	Config.Wind								= split   ( xmlNodeGetValue( xmlFindChild( cfg,   "Wind",	  			0 ) ), ", " );
	Config.Glitches							= split   ( xmlNodeGetValue( xmlFindChild( cfg,   "Glitches",  			0 ) ), ", " );
	Config.Lobby           		  			= split   ( xmlNodeGetValue( xmlFindChild( cfg,   "Lobby",    			0 ) ), ", " );

	Config.CPColor        		  			= split   ( xmlNodeGetValue( xmlFindChild( round, "CPColor",  			0 ) ), ", " );



	for i=1, 5 do
		Config.Glitches[i] = tobool( Config.Glitches[i] );
	end

	-- Config.Glitches table index:
	-- 1 - quickreload
	-- 2 - fastmove
	-- 3 - fastfire
	-- 4 - cbug
	-- 5 - high close range damage

	Config.GunmenuAlpha						= tonumber( xmlNodeGetValue( xmlFindChild( round, "GunmenuAlpha",	0 ) ) );

	Round.LoadTime 		  		  			= -1;
	Round.ID         		  				= -1;
	Round.IsRoundStarted  		  			= false;
	Round.TimeInCP        		  			= Config.CPTime;
	Round.PlayersInCP 	 		  			= 0;
	Round.Gametype        		  			= 0;
	Round.TotalAtt       		  			= 0;
	Round.TotalDef        		 			= 0;
	Round.LoserTeam		  		  			= nil;
	Round.WinReason							= nil;
	Round.Paused							= false;

	Weapons.Gunmenu		   		  			= {};

	Weapons.Gunmenu.Autogiven	  			= {};
	Weapons.Gunmenu.Autogiven.Weapons		= {};
	Weapons.Gunmenu.Autogiven.Ammo			= {};

	local valnode = xmlFindChild( guns, "AutoGiven", 0 );

	if valnode then
		for v, i in ipairs( xmlNodeGetChildren( valnode ) ) do
			local name = xmlNodeGetName( i );
			local placeholder, foundloc = string.find(string.lower( name ), "wep" );

			if foundloc ~= nil then
				local t =  tonumber( string.sub( name, foundloc+1 ) );
				Weapons.Gunmenu.Autogiven.Weapons[t] 	= tonumber( xmlNodeGetValue( i ) );
			end

			if foundloc == nil then
				placeholder, foundloc = string.find(string.lower( name ), "ammo" );

				if foundloc ~= nil then
					local t = tonumber( string.sub( name, foundloc+1 ) );
					Weapons.Gunmenu.Autogiven.Ammo[t] 		= tonumber( xmlNodeGetValue( i ) );
				end
			end
		end
	end

	Weapons.Gunmenu[1] 			  			= split( xmlNodeGetValue( xmlFindChild( guns, "Gunmenu1", 0 ) ), ", " );

	Weapons.Gunmenu[2] 			  			= split( xmlNodeGetValue( xmlFindChild( guns, "Gunmenu2", 0 ) ), ", " );

	Weapons.Gunmenu.Limits		  			= {};

	Weapons.Gunmenu.Limits.AttUsed 			= {};
	Weapons.Gunmenu.Limits.DefUsed 			= {};

	Weapons.Gunmenu.Ammo					= {};

	Weapons.Getgun							= {};

	for i=1, 46 do

		Weapons.Gunmenu.Limits		  [i]	= tonumber( xmlNodeGetValue( xmlFindChild( limits, "limits_" .. tostring( i ), 0 ) ) ); -- TODO: read from files
		Weapons.Gunmenu.Ammo		  [i]	= tonumber( xmlNodeGetValue( xmlFindChild( guns,   "ammo_"   .. tostring( i ), 0 ) ) );
		Weapons.Gunmenu.Limits.AttUsed[i] 	= 0;
		Weapons.Gunmenu.Limits.DefUsed[i] 	= 0;

		Weapons.Getgun				  [i]	= tonumber( xmlNodeGetValue( xmlFindChild( guns, "wep_"     .. tostring( i ), 0 ) ) );
	end


	if xml then
		for i=0, 230 do
			Config[i]		   		 		= {};
			Config[i].pedStats       		= xmlNodeGetValue( xmlFindChild( stats, "stats_" .. tostring( i ), 0 ) );
			--Config[i].pedStats 		 	= 999;

		end

	end


	for v, i in ipairs( getElementsByType( "player" ) ) do
		if Player[i] == nil then
			Player[i] = {};
		end
	end

	Teams.Attackers  			 			= createTeam( "Attackers", 255, 0, 0 );
	Teams.Defenders	 			 			= createTeam( "Defenders", 0, 0, 255 );

	Teams.AttWins  				 			= 0;
	Teams.DefWins  				 			= 0;

	Teams.AttSkin       		 			= tonumber( xmlNodeGetValue( xmlFindChild( teams, "AttSkin",	0 ) ) );
	Teams.DefSkin       		 			= tonumber( xmlNodeGetValue( xmlFindChild( teams, "DefSkin",	0 ) ) );

	Teams.DefName       		 			= xmlNodeGetValue( xmlFindChild( teams, "DefName",	0 ) );
	Teams.AttName       		 			= xmlNodeGetValue( xmlFindChild( teams, "AttName",	0 ) );

	xmlSaveFile( xml );
	xmlUnloadFile( xml );

	setWindVelocity( Config.Wind[1], Config.Wind[2], Config.Wind[3] );

	setMinuteDuration( 0 );

	setGlitchEnabled( "quickreload", 		  Config.Glitches[1] 	);
	setGlitchEnabled( "fastmove",    		  Config.Glitches[2]    );
	setGlitchEnabled( "crouchbug",   		  Config.Glitches[3]	);
	setGlitchEnabled( "fastfire",             Config.Glitches[4]    );
	setGlitchEnabled( "highcloserangedamage", Config.Glitches[5]  	);

	--setWeaponProperty( 25, "pro", "anim_breakout_time", 0 );
	--setWeaponProperty( 24, "pro", "anim_breakout_time", 0 );

	setFPSLimit( Config.FPSLimit );

	setFarClipDistance( Config.FarClip );

	for v, i in ipairs( Config.RemoveModels ) do
		removeWorldModel( tonumber( i ), 9999.0, 0.0, 0.0, 0.0 );
	end
end


function rgbtohex(r,g,b)
  return string.format("#%02X%02X%02X", r,g,b)
end

function round(num)
	if not isNumeric( num ) then
		outputDebugString( "round() tried to convert '" .. num .. "' to an integer and failed.", 1 );
		return;
	end
	return math.floor( tonumber( num ) );
end

function spawnVehicleForPlayer( playerSource, cmd, ... )
	if Player[playerSource].InRound == true then
		if getPlayerTeam( playerSource ) ~= Teams.Attackers then
			return outputChatBox("" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. " You must be on the attacking team to spawn a vehicle while a base is started!", playerSource, 255, 255, 255, true);
		end
	end

	if Round.Gametype == TDM then return outputChatBox( "" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. "Cannot spawn a vehicle at this time", playerSource, 255, 255, 255, true ) end


	if Player[playerSource].InRound == true and Round.IsRoundStarted == true and Round.Gametype == BASE then
		outputChatBox("" .. baseInfo[Round.ID].Interior );
		if tonumber( baseInfo[Round.ID].Interior ) ~= 0 then return outputChatBox( "" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. "You cannot spawn a vehicle in an interior!", playerSource, 255, 255, 255, true ) end
		local x, y, z = getElementPosition( playerSource );
		for v, i in ipairs( getElementsByType( "spawnpoint" ) ) do
			if baseInfo[i].Team == "Att" and getPlayerTeam( playerSource ) == Teams.Attackers then
				local dis = getDistanceBetweenPoints3D( baseInfo[i].PosX, baseInfo[i].PosY, baseInfo[i].PosZ, x, y, z );
				if dis > Config.CarDistance then
					return outputChatBox("" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. "You are to far away from your spawn to create a vehicle!", playerSource, 255, 255, 255, true );
				end
				break; -- end loop after 1 random spawn check of an attacker
			end
		end
	end


	if not isPlayerSpawned( playerSource ) then
		return outputChatBox("" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. " You must be spawned.", playerSource, 255, 255, 255, true);
	end
	if isPedInVehicle( playerSource ) == true then
		destroyElement( getPedOccupiedVehicle( playerSource ) );
	end
	if isElement( Player[playerSource].Vehicle ) and not Vehicles[Player[playerSource].Vehicle].InRound then
		local t = getVehicleOccupant( Player[playerSource].Vehicle );
		if t then
			if Player[t].Vehicle then
				destroyElement( Player[t].Vehicle );
			end
			Player[t].Vehicle = Player[playerSource].Vehicle;
		else destroyElement( Player[playerSource].Vehicle ) end
	end
	-- this next function will also work if you put in a regular vehicle ID
	local veh = getVehicleModelFromPartName( ... );
	if veh ~= false then
		local x, y, z = getElementPosition( playerSource );
		local rx, ry, rz = getElementRotation( playerSource );
		local vehicle = createVehicle( veh, x, y, z, rx, ry, rz, "TIGEROWNS" );

		if isElement( vehicle ) then
			loadVehicleConfig( vehicle, playerSource );
			setElementDimension( vehicle, getElementDimension( playerSource ) );
			setElementInterior ( vehicle, getElementInterior ( playerSource ) );
			warpPedIntoVehicle( playerSource, vehicle );
			setVehicleColor( vehicle, getTeamColor( getPlayerTeam ( playerSource ) ) );
			toggleVehicleRespawn ( vehicle, false );

			--triggerClientEvent( getRootElement( ), "onVehicleCreated", vehicle );

			local upgrades = getVehicleCompatibleUpgrades( vehicle );
			for v, i in ipairs( upgrades ) do
				if getVehicleUpgradeSlotName( i ) == "Nitro" or getVehicleUpgradeSlotName( i ) == "Hydraulics" then
					addVehicleUpgrade( vehicle, i );
				end
			end
			outputChatBox("" .. COLOR_WHITE .. "Spawned a " .. getVehicleName( vehicle ) .. COLOR_GREEN .. " ( ID: " .. veh .. " )", playerSource, 255, 255, 255, true );
		else return outputChatBox("" .. COLOR_RED .. " Error: " .. COLOR_WHITE .. "Invalid ID!", playerSource, 255, 255, 255, true ); end
	end
end

function balance( playerSource, cmd )
	if isPlayerMod( playerSource ) ~= true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently underway", playerSource, 255, 255, 255, true ) end

	local divisor = round( ( countPlayersInTeam( Teams.Attackers ) + countPlayersInTeam( Teams.Defenders ) ) / 2 );

	for v, i in ipairs( shuffle( getElementsByType( "player" ) ) ) do
		if countPlayersInTeam( Teams.Attackers ) > divisor then
			setPlayerTeam( i, Teams.Defenders );
		elseif countPlayersInTeam( Teams.Defenders ) >= divisor then
			setPlayerTeam( i, Teams.Attackers );
		else
			local rand = math.random( 2 );
			if rand == 1 then
				setPlayerTeam( i, Teams.Attackers );
			else
				setPlayerTeam( i, Teams.Defenders );
			end
		end
	end
	outputChatBox( "" .. COLOR_WHITE .. getPlayerName( playerSource ) .. COLOR_YELLOW .. " has balanced the teams!", getRootElement( ), 255, 255, 255, true );
end

function add( playerSource, cmd, player )
	if isPlayerMod( playerSource ) ~= true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently not underway", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );

	if target 				  == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " Invalid player!", playerSource, 255, 255, 255, true ) end
	if isPedDead( target )    == true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is dead!", playerSource, 255, 255, 255, true ) end
	if Player[target].InRound == true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is already in the round!", playerSource, 255, 255, 255, true ) end

	addPlayerToRound( target );

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. " has added " .. getPlayerName( target ) .. " from the round.", getRootElement( ), 255, 255, 255, true );

end

function removePlayer( playerSource, cmd, player )
	if isPlayerMod( playerSource ) ~= true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently not underway", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );

	if target 				  == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " Invalid player!", playerSource, 255, 255, 255, true ) end
	if isPedDead( target )    == true  then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is dead!", playerSource, 255, 255, 255, true ) end
	if Player[target].InRound == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " This player is not in the round!", playerSource, 255, 255, 255, true ) end

	removePlayerFromRound( target );

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. " has removed " .. getPlayerName( target ) .. " from the round.", getRootElement( ), 255, 255, 255, true );

end

function determineRandomBase( )
	local base = math.random( baseInfo.TotalBases );
	if getResourceFromName("base-" .. base) == false then
		return determineRandomBase( );
	end
	return tonumber( base );
end

function determineRandomTDM( )
	local arena = math.random( arenaInfo.TotalArenas );
	if getResourceFromName("arena-" .. arena) == false then
		return determineRandomTDM( );
	end
	return tonumber( arena );
end

function getVehicleModelFromPartName(partName)
	if partName == false or partName == nil then return false end
	if isNumeric( partName ) then return tonumber( partName ) end
    local model = getVehicleModelFromName(partName)
    if model then
        return tonumber(model)
    else
        for id = 400, 611 do
            if (string.find(string.lower(getVehicleNameFromModel(id)), tostring(string.lower(partName))) ~= nil) then
                return tonumber(id)
            end
        end
    end
	return false;
end

function getWeaponIDFromPartName( partName )
	if partName == false or partName == nil then return false end
	if isNumeric( partName ) then return tonumber( partName ) end
    local model = getWeaponIDFromName( partName );
    if model then
        return tonumber(model)
    else
        for id = 0, 46 do
            if (string.find(string.lower(getWeaponNameFromID(id)), tostring(string.lower(partName))) ~= nil) then
                return tonumber(id)
            end
        end
    end
	return false;
end

function getPlayerFromPartialName (name)
	if name == false then return false end
    for i,player in ipairs (getElementsByType("player")) do
            if getPlayerName(player) == name then
                    return player
            end
            if string.find(string.lower(getPlayerName(player)),string.lower(name),0,false) then
                    return player;
            end
    end
    return false;
end


function getTeamFromPartialName ( name )
	if name == false then return false end
    for v, i in ipairs( getElementsByType( "team" ) ) do
        if getTeamName( i ) == name then
                return i;
        end
        if string.find(string.lower(getTeamName(i)),string.lower(name),0,false) then
                return i;
        end
    end
    return false;
end

function playerVehicleEnter( _vehicle, seat, jacked )

	local vehicle = getElementModel( _vehicle );
	-- disables driveby, hydra missles, hunter missles/gun etc
	if getVehicleType( vehicle ) == "Bike" or getVehicleType( vehicle ) == "BMX" or vehicle == 520 or vehicle == 447 or vehicle == 476 or vehicle == 425 or vehicle == 430 or vehicle == 407 or vehicle == 432 then
		toggleControl ( source, "vehicle_secondary_fire", false );
		toggleControl ( source, "vehicle_fire", 		  false );
	end

end

function playerVehicleExit( _vehicle, seat, jacked )

	local vehicle = getElementModel( _vehicle );
	if getVehicleType( vehicle ) == "Bike" or getVehicleType( vehicle ) == "BMX" or vehicle == 520 or vehicle == 447 or vehicle == 476 or vehicle == 425 or vehicle == 430 or vehicle == 407 or vehicle == 432 then
		toggleControl ( source, "vehicle_secondary_fire", false );
		toggleControl ( source, "vehicle_fire", 		  false );
	end

end

function setTeamCmd( playerSource, cmd, player, team )
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently underway", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );
	local _team  = getTeamFromPartialName  ( team   );

	if not target then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid player!", playerSource, 255, 255, 255, true );
	elseif not _team then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid team!",   playerSource, 255, 255, 255, true );
	end

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has set " .. getPlayerName( target ) .. " to team " .. rgbtohex( getTeamColor( _team ) ) .. getTeamName( _team ), getRootElement( ), 255, 255, 255, true );

	triggerEvent( "asignTeam", target, indexToTeam( _team ) );
end

function setHpCmd( playerSource, cmd, player, newhealth )
	if isPlayerSuperMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );

	if not target then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid player!", playerSource, 255, 255, 255, true );
	end

	if newhealth == nil then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid health!", playerSource, 255, 255, 255, true );
	end

	setElementHealth( target, newhealth );

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has set " .. getPlayerName( target ) .. "'s health to: " .. newhealth, getRootElement( ), 255, 255, 255, true );

end

function setApCmd( playerSource, cmd, player, newarmor )
	if isPlayerSuperMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end

	local target = getPlayerFromPartialName( player );

	if not target then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid player!", playerSource, 255, 255, 255, true );
	end

	if newarmor == nil then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid armor!", playerSource, 255, 255, 255, true );
	end

	setPedArmor( target, newarmor );

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has set " .. getPlayerName( target ) .. "'s armor to: " .. newarmor, getRootElement( ), 255, 255, 255, true );

end

function healAllCmd( playerSource, cmd )
	if isPlayerSuperMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end

	for v, i in ipairs( getElementsByType( "player" ) ) do

		setElementHealth( i, Round.HP );

	end

	outputChatBox( COLOR_YELLOW .. getPlayerName( playerSource ) .. COLOR_WHITE .. " has healed all players.", getRootElement( ), 255, 255, 255, true );

end

function getPlayerTeamSkin( player )

	if 	   getPlayerTeam( player ) == Teams.Attackers then
		return Teams.AttSkin;
	elseif getPlayerTeam( player ) == Teams.Defenders then
		return Teams.DefSkin;
	end
end


function spawnAtLobby( player )
	local pos = Config.Lobby;
	spawnPlayer( player, tonumber( pos[1] ), tonumber( pos[2] ), tonumber( pos[3] ), 0, getPlayerTeamSkin( player ) );
end

function isPlayerSpawned( player )
	return Player[player].Spawned;
end

function subtractPlayerFromRound( player )
	if getPlayerTeam( player ) 	 == Teams.Attackers then
		Round.TotalAtt = Round.TotalAtt - 1;
		if Round.TotalAtt == 0 then
			Round.LoserTeam = Teams.Attackers;
			Round.WinnerReason = "Elimination";
			endRound( );
		end
	elseif getPlayerTeam( player ) == Teams.Defenders then
		Round.TotalDef = Round.TotalDef - 1;
		if Round.TotalDef == 0 then
			Round.LoserTeam = Teams.Defenders;
			Round.WinnerReason = "Elimination";
			endRound( );
		end
	end
end

function shuffle(t)
  local n = #t

  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end

  return t
end

function playerSpecPlayer( playerSource, cmd, player )

	if Player[playerSource].InRound == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Cannot spectate while in a round!", playerSource, 255, 255, 255, true ) end
	player = getPlayerFromPartialName( player );
	if player == nil and player ~= playerSource then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Invalid player!", playerSource, 255, 255, 255, true ) end

	local pteam, team = getPlayerTeam( playerSource ), getPlayerTeam( player );
	if team and pteam and isPlayerSpawned( player ) and isPlayerSpawned( playerSource ) then
		if team == pteam then
			if getCameraTarget( player ) == player then

				setElementAlpha( playerSource, 0 );
				setCameraTarget( playerSource, player );

				Player[playerSource].Spectating = player;

				setElementData( playerSource, "spectating", player );
				setElementDimension( playerSource, getElementDimension( player ) );

				outputChatBox( "** You are now spectating " .. getPlayerName( player ), playerSource, 255, 255, 255, true );

				triggerClientEvent( playerSource, "showSpecGui", getRootElement( ), 1, player );
				triggerClientEvent( player, "showSpecGui", getRootElement( ), 2, playerSource );
			else return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Player is spectating someone else.", playerSource, 255, 255, 255, true ) end
		else return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Player is not on your team!", playerSource, 255, 255, 255, true ) end
	else return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Player is not spawned.", playerSource, 255, 255, 255, true ) end
end

function specOffPlayer( playerSource, cmd, ... )

	if Player[playerSource].Spectating ~= nil then
		if getCameraTarget( playerSource ) ~= playerSource then

			setCameraTarget( playerSource, playerSource );
			Player[playerSource].Spectating = nil;

			setElementAlpha( playerSource, 255 );

			setElementData( playerSource, "spectating", nil );

			triggerClientEvent( playerSource, "hideSpecGui", getRootElement( ), 1);
			triggerClientEvent( player, 	  "hideSpecGui", getRootElement( ), 2);

		else Player[playerSource].Spectating = nil end
	else return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not spectating anyone.", playerSource, 255, 255, 255, true ) end
end

local mods = { "ped.ifp", "weapon.dat", "carmods.dat", "animgrp.dat", "ar_stats.dat", "melee.dat", "clothes.dat", "object.dat",
			  "default.dat", "surface.dat", "default.ide", "gta.dat", "surfinfo.dat", "peds.ide", "vehicles.ide", "pedstats.dat",
			  "water.dat", "txdcut.ide", "water1.dat", "weapons.col", "plants.dat", "furnitur.dat", "procobj.dat", "main.scm",
			  "handling.cfg", "peds.col", "vehicles.col"};

function playerModInfo( file, modz )
	for v, i in ipairs( mods ) do
		if file == mods[v] then
			--outputChatBox("modded file infoz: " .. file .. " " .. modz, source );
			kickPlayer( source, "Modifying " .. file );
		end
	end

end

function startRound( gtype, id )

	if gtype == "base" then
		startBase( id );
	elseif gtype == "arena" or gtype == "tdm" then
		startTdm( id );
	end
end

function allVotedGui( )
	triggerClientEvent( "votedGui", getRootElement( ) );
end

function tobool(v)
    return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

function takeScreen( playerSource )
	local upload = tonumber( getElementData( playerSource, "Upload" ) );
	if upload < 10000 then
		triggerEvent("onPlayerScreenShot", playerSource, getThisResource( ), "uploadspeed" );
	end
	takePlayerScreenShot( playerSource, getElementData( playerSource, "Width" ), getElementData( playerSource, "Height" ), "", 15, upload);
end

function onScreenShot( resource, status, pixels, timestamp, tag )
	if resource == getThisResource( ) then
		if status == "ok" then
			local realtime = getRealTime( );
			local file = fileCreate( "screenshots/" .. getPlayerName( source ) .. "/" .. realtime.timestamp .. ".jpeg" );
			if file then
				fileWrite( file, pixels );
				fileClose( file );
			end
		elseif status == "disabled" then
			kickPlayer( source, "Disabled screenshots upload.");
		elseif status == "uploadspeed" then
			setElementData( source, "Upload", 10000 );
			outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. " Your upload speed has been adjusted to 10kb/s", source, 255, 255, 255, true );
		end
	end
end

function pauseRoundCmd( playerSource, cmdName )
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is not currently underway", playerSource, 255, 255, 255, true ) end
	if Round.Paused 			   == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "The round is already paused!", playerSource, 255, 255, 255, true ) end
	if Round.LoadTime 				> 0     then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "The round is loading.", playerSource, 255, 255, 255, true ) end

	pauseRound( );

	outputChatBox( COLOR_YELLOW .. "** " .. getPlayerName( playerSource ) .. " has paused the round!", getRootElement( ), 255, 255, 255, true );

end

function unpauseRoundCmd( playerSource, cmdName )
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is not currently underway", playerSource, 255, 255, 255, true ) end
	if Round.Paused 			   == false then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "The round is not already paused!", playerSource, 255, 255, 255, true ) end
	if Round.LoadTime 				> 0     then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "The round is loading.", playerSource, 255, 255, 255, true ) end

	unpauseRound( );

	outputChatBox( COLOR_YELLOW .. "** " .. getPlayerName( playerSource ) .. " has unpaused the round!", getRootElement( ), 255, 255, 255, true );

end

function swapTeamsCmd( playerSource, cmdname )
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end
	if Round.IsRoundStarted 	   == true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "A round is currently underway", playerSource, 255, 255, 255, true ) end

	swapTeams( );

	outputChatBox( COLOR_YELLOW .. "** " .. getPlayerName( playerSource ) .. " has swapped the teams!", getRootElement( ), 255, 255, 255, true );

end

function resetscoresCmd( playerSource, cmdname )
	if isPlayerMod( playerSource ) ~= true then return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "You are not an admin.", playerSource, 255, 255, 255, true ) end

	resetScores( );

	outputChatBox( COLOR_YELLOW .. "** " .. getPlayerName( playerSource ) .. " has reset the team scores!", getRootElement( ), 255, 255, 255, true );

end

function pauseRound( )

	Round.Paused = true;

	for v, i in ipairs( getElementsByType( "player" ) ) do
		if Player[i].InRound == true then
			if isPedInVehicle( i ) then
				setElementFrozen( getPedOccupiedVehicle( i ), true );
			end
			toggleAllControls( i, false, true, false );
			triggerClientEvent( i, "roundPaused", getRootElement( ) );
		end
	end
end

function unpauseRound( )

	Round.Paused = false;

	for v, i in ipairs( getElementsByType( "player" ) ) do
		if Player[i].InRound == true then
			if isPedInVehicle( i ) then
				setElementFrozen( getPedOccupiedVehicle( i ), false );
			end
			toggleAllControls( i, true, true, true );
			triggerClientEvent( i, "roundunPaused", getRootElement( ) );
		end
	end

	Timers.RoundTimer = setTimer( roundUpdate, 1000, 0, Round.Gametype, Round.ID );
end

function swapTeams( )
	--Teams.AttName, Teams.DefName = Teams.DefName, Teams.AttName;
	--Teams.AttSkin, Teams.DefSkin = Teams.AttSkin, Teams.DefSkin;

	local doneAlready = {};
	for v, i in ipairs( getPlayersInTeam( Teams.Attackers ) ) do
		doneAlready[i] = true;
		setPlayerTeam( i, Teams.Defenders );
		setPedSkin( i, Teams.DefSkin );
	end

	for v, i in ipairs( getPlayersInTeam( Teams.Defenders ) ) do

		if doneAlready[i] == nil then
			setPlayerTeam( i, Teams.Attackers );
			setPedSkin( i, Teams.AttSkin );
		end
	end


	setTeamName( Teams.Defenders, Teams.DefName );
	setTeamName( Teams.Attackers, Teams.AttName );
end


function resetScores( )
	Teams.AttWins = 0;
	Teams.DefWins = 0;

	triggerClientEvent( getRootElement( ), "updateTeamScore", getRootElement( ), 0, 0 );

end

function resetBlipSettings( player )
	if isElement( Player[player].Blip ) then
		clearElementVisibleTo( Player[player].Blip );
		setElementVisibleTo( Player[player].Blip, player, false );
		local r, g, b = getTeamColor( getPlayerTeam( player ));
		setBlipColor( Player[player].Blip, r, g, b, 150 );
	end
end

function destroyInRoundVehicles( )

	for v, i in ipairs( getElementsByType( "vehicle" ) ) do
		if Vehicles[i].InRound == true then
			destroyElement( i );
		end
	end
end

function playerChat( message, mtype )
	if message[1] == "#" then
		if(string.find( string.lower( thenConfig.clanTag ), tostring( string.lower( getPlayerName( source ) ) ) ) ~= nil) then
			for v, i in ipairs( getElementsByType( "player" ) ) do
				if(string.find( string.lower( thenConfig.clanTag ), tostring( string.lower( getPlayerName( i ) ) ) ) ~= nil) then
					outputChatBox( thenConfig.clanTag .. " Chat " .. getPlayerName( source ) .. ": " .. message, i, 255, 255, 255, true );
				end
			end
			cancelEvent( );
		end
	end
end


function sync( vars )

	if Config.Sync == 0 then
		return outputChatBox( COLOR_RED .. "Error: " .. COLOR_WHITE .. "Sync is disabled.", source, 255, 255, 255, true );
	end

	vars.fs = getPedFightingStyle( source );

	spawnPlayer( source, vars.x, vars.y, vars.z, 0.0, vars.skin, vars.interior, vars.dimension, team );

	setPedArmor( source, vars.ar );
	setElementHealth( source, vars.hp );

	setPedFightingStyle( source, vars.fs );

	setElementFrozen( source, vars.frozen );

	setPlayerWantedLevel( source, vars.wlevel );

	setPlayerMoney( source, vars.money );

	setElementVelocity( source, vars.vx, vars.vy, vars.vz );
	setElementRotation( source, vars.rx, vars.ry, vars.rz );

	setPedChoking( source, vars.choking );
	setPedOnFire( source, vars.fire );
	setPedHeadless( source, vars.headless );

	takeAllWeapons( source );

	for i=1, 11 do
		if vars.weps[i] ~= nil and vars.weps[i] ~= 0 and vars.ammo[i] ~= nil and vars.ammo[i] ~= 0 then
			giveWeapon( source, vars.weps[i], vars.ammo[i] );
		end
	end

	setPedWeaponSlot( source, vars.orig );

	if Player[source].InRound then
		setElementDimension( source, rDimension 	);
		setElementVisibleTo( Round.CP, source, true );
	end

	resendPlayerModInfo( source );


end


------------------------------------------------
--                 Handlers                   --
------------------------------------------------

addEvent( "asignTeam", 			  	true );
addEvent( "onClientScriptSynced", 	true );
addEvent( "getSpawnGuiInformation", true );
addEvent( "onPlayerPickWeapons",	true );
addEvent( "startRound",				true );
addEvent( "showAllVoteGui",			true );
addEvent( "finishSyncing",			true );

addCommandHandler( "startbase", 	startBaseCmd			  );
addCommandHandler( "balance",   	balance					  );
addCommandHandler( "shuffle",   	balance					  );
addCommandHandler( "add",       	add					      );
addCommandHandler( "remove",    	removePlayer			  );
addCommandHandler( "gun",    		getgun 	  				  );
addCommandHandler( "getgun", 		getgun 	  				  );
addCommandHandler( "car", 	    	spawnVehicleForPlayer 	  );
addCommandHandler( "v", 	    	spawnVehicleForPlayer 	  );
addCommandHandler( "vehicle", 		spawnVehicleForPlayer 	  );
addCommandHandler( "end",      		endRoundCmd               );
addCommandHandler( "givemenu",  	giveMenuCmd				  );
addCommandHandler( "setteam",   	setTeamCmd				  );
addCommandHandler( "sethp",     	setHpCmd				  );
addCommandHandler( "sethealth", 	setHpCmd				  );
addCommandHandler( "setarmor",  	setApCmd				  );
addCommandHandler( "setarmour", 	setApCmd				  );
addCommandHandler( "healall",		healAllCmd				  );
addCommandHandler( "starttdm",  	startTdmCmd				  );
addCommandHandler( "spec",			playerSpecPlayer		  );
addCommandHandler( "specoff",		specOffPlayer		  	  );
addCommandHandler( "pause",     	pauseRoundCmd			  );
addCommandHandler( "unpause",   	unpauseRoundCmd			  );
addCommandHandler( "swap",   		swapTeamsCmd			  );
addCommandHandler( "resetscores", 	resetscoresCmd		  	  );


addEventHandler( "onPlayerConnect",	       getRootElement( ), playerConnect 	  	  );
addEventHandler( "onResourceStart", 	   getRootElement( ), resourceStartNotify 	  );
addEventHandler( "onPlayerChat",		   getRootElement( ), playerChat			  );
addEventHandler( "asignTeam"	  , 	   getRootElement( ), teamHandler         	  );
addEventHandler( "onClientScriptSynced",   getRootElement( ), clientScriptSynced  	  );
addEventHandler( "getSpawnGuiInformation", getRootElement( ), calculateSpawnGUILabels );
addEventHandler( "onPlayerWasted",         getRootElement( ), player_Wasted           );
addEventHandler( "onPlayerPickWeapons",    getRootElement( ), onPlayerPickedWeapons   );
addEventHandler( "onPlayerSpawn", 		   getRootElement( ), playerSpawn 			  );
addEventHandler( "onPlayerDamage", 		   getRootElement( ), playerDamage            );
addEventHandler( "onPlayerQuit",           getRootElement( ), playerQuit			  );
addEventHandler( "onPlayerVehicleEnter",   getRootElement( ), playerVehicleEnter	  );
addEventHandler( "onPlayerVehicleExit",    getRootElement( ), playerVehicleExit 	  );
addEventHandler( "onPlayerModInfo",		   getRootElement( ), playerModInfo			  );
addEventHandler( "onPlayerScreenShot",	   getRootElement( ), onScreenShot			  );
addEventHandler( "startRound",			   getRootElement( ), startRound			  );
addEventHandler( "showAllVotedGui",		   getRootElement( ), allVotedGui			  );
addEventHandler( "finishSyncing",		   getRootElement( ), sync			  		  );
