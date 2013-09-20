--[[

	Analytical A/D
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



	You deserve software that is:-
	Free from restriction
	Free to share and Copy
	Free to work with others

	You deserve free software.


HOW TO CONTRIBUTE:

	get in contact with me
			xfire: whitetigerswt
			MSN: whitetigerswt@live.com
			steam: mindfreak860
			youtube: mindfreak860
			IRC: Whitetiger @ GTANET, Whitetiger @ focohub, regitetihW @ freenode

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

	Q: why isn't this a compiled .lua file?
	A: because.

	Q: why wouldn't you compile your script won't people steal your work?
	A: OH NOES, NOT STEAL MY WORK!



Credits:

Whitetiger - Programming
PotH3Ad    - Programming(?) & Graphics Design

]]


local Total_Teams           = 2 -- 0 - auto asign, 1 - attackers, 2 - defenders.
local Teams                 = {};
local Player 				= {};
local PlayerConfig          = {};
local Sounds				= {};
local Round					= {};
local Timers                = {};



COLOR_GREEN 		= 		"#33CC00";
COLOR_RED 			= 		"#FF3300";
COLOR_BLUE          =       "#1975FF";
COLOR_YELLOW        =       "#FFFF00";
COLOR_WHITE         =       "#FFFFFF";

function clientScriptLoad(resource)
	if resource ~= getThisResource() then return true end

	setCanSync( );

	showPlayerHudComponent( "all", false );
	setGameSpeed( 1.0 );

	Timers.OneSecondUpdate = setTimer( secondUpdate, 1000, 0 );

	triggerServerEvent( "onClientScriptSynced", localPlayer );

	Windows 						= {};
	Labels 							= {};
	Images            				= {};
	Buttons         				= {};
	DXText                     		= {};
	DXRectangle						= {};
	ProgressBar						= {};
	GridLists						= {};
	Memos							= {};
	Checkboxes						= {};

	local Width,Height          	= guiGetScreenSize( );

	setElementData( localPlayer, "Width",  Width  );
	setElementData( localPlayer, "Height", Height );


	DXRectangle.BaseLoad			= {};
	DXRectangle.BaseLoad.X			= 0.0
	DXRectangle.BaseLoad.Y			= ( Height * 959 ) / 1024;
	DXRectangle.BaseLoad.Width		= Width;
	DXRectangle.BaseLoad.Height		= ( Height * 1280 ) / 1024 -- NOT / 1280
	DXRectangle.BaseLoad.Color  	= tocolor( 0, 0, 0, 120 );
	DXRectangle.BaseLoad.PostGUI	= false;


	--Windows.BaseLoad 			= guiCreateWindow( 0, ( Height * 953 ) / 1024, ( Width * 1280 ) / 1280, ( Height * 71 ) / 1024, "", false ); -- not used anymore.
	Labels.RoundLoad 			= guiCreateLabel ( ( Width * 417 ) / 1280, ( Height * 962  ) / 1024, ( Width * 458  ) / 1280, ( Height * 46 ) / 1024, "Base starting in 5 seconds", false );


	guiSetFont( Labels.RoundLoad, "sa-header" )

	guiSetVisible( Labels.RoundLoad, false );


	-------------------------------------------------------------------------------------------------------------------------------------------


	Windows.SpawnWindow 		= guiCreateWindow( ( Width * 928 ) / 1280, ( Height * 356 ) / 1024, ( Width * 333 ) / 1280, ( Height * 324 ) / 1024, "Team Information", false  	 	   		);

	Windows.SpawnPlayerWindow   = guiCreateWindow( ( Width * 30 ) / 1280, ( Height * 329 ) / 1024, ( Width * 333 ) / 1024, ( Height * 324 ) / 1024, "Player list", false						);

	Labels.PlayerList  			= guiCreateLabel( ( Width * 9 ) / 1280, ( Height * 25 ) / 1024, ( Width * 144 ) / 1280, ( Height * 292 ) / 1024,   "", false, Windows.SpawnPlayerWindow 		);
	Labels.PlayerList2 			= guiCreateLabel( ( Width * 186 ) / 1280, ( Height * 25 ) / 1024, ( Width * 144 ) / 1280, ( Height * 292 ) / 1024, "", false, Windows.SpawnPlayerWindow 		);

	Labels.PanelPlayers 		= guiCreateLabel(  ( Width * 14 ) / 1280, ( Height * 98  ) / 1024, ( Width * 303 ) / 1280, ( Height * 82  ) / 1024, "Players: 0", false, Windows.SpawnWindow 	);
	Labels.PanelSkins 			= guiCreateLabel(  ( Width * 14 ) / 1280, ( Height * 36  ) / 1024, ( Width * 303 ) / 1280, ( Height * 82  ) / 1024, "Skin: 0", false, Windows.SpawnWindow 	   	);
	Labels.PanelWins 			= guiCreateLabel(  ( Width * 14 ) / 1280, ( Height * 151 ) / 1024, ( Width * 303 ) / 1280, ( Height * 82  ) / 1024, "Wins: 0", false, Windows.SpawnWindow   	);
	Labels.PanelLosses 			= guiCreateLabel(  ( Width * 14 ) / 1280, ( Height * 201 ) / 1024, ( Width * 303 ) / 1280, ( Height * 82  ) / 1024, "Losses: 0", false, Windows.SpawnWindow 	);
	Labels.PanelName 			= guiCreateLabel(  ( Width * 541 ) / 1280, ( Height * 138 ) / 1024, ( Width * 380 ) / 1280, ( Height * 112 ) / 1024, " ", false                           		);

	Buttons.LeftSpawn 			= guiCreateButton( ( Width * 444) / 1280,  ( Height * 886 ) / 1024, ( Width * 73 )  / 1280, ( Height * 73 ) / 1024, "<", false 			    		     		);
	Buttons.RightSpawn 			= guiCreateButton( ( Width * 702 ) / 1280, ( Height * 886 ) / 1024, ( Width * 73 )  / 1280, ( Height * 73 ) / 1024, ">", false 			    		     		);
	Buttons.Spawn               = guiCreateButton( ( Width * 518 ) / 1280, ( Height * 886 ) / 1024, ( Width * 184 ) / 1280, ( Height * 80 ) / 1024, "Spawn", false                       		);


	guiSetFont( Labels.PanelPlayers, "sa-header"	);
	guiSetFont( Labels.PanelSkins, "sa-header"		);
	guiSetFont( Labels.PanelWins, "sa-header"		);
	guiSetFont( Labels.PanelLosses, "sa-header"		);
	guiSetFont( Labels.PanelName, "sa-gothic"       );
	guiSetFont( Buttons.LeftSpawn, "sa-header"		);
	guiSetFont( Buttons.RightSpawn, "sa-header"		);
	guiSetFont( Buttons.Spawn, "clear-normal"		);


	guiLabelSetColor(Labels.PanelWins,	 0,255,0	);
	guiLabelSetColor(Labels.PanelLosses, 255,0,0	);


	guiWindowSetMovable( Windows.SpawnWindow, false 		);
	guiWindowSetSizable( Windows.SpawnWindow, false 		);

	guiWindowSetMovable( Windows.SpawnPlayerWindow, false 	);
	guiWindowSetSizable( Windows.SpawnPlayerWindow, false 	);

	guiSetVisible( Windows.SpawnWindow, 	  false );
	guiSetVisible( Buttons.LeftSpawn,         false );
	guiSetVisible( Buttons.RightSpawn,        false );
	guiSetVisible( Labels.PanelName,          false );



	addEventHandler( "onClientGUIClick", Buttons.LeftSpawn,  spawn_move, false );
	addEventHandler( "onClientGUIClick", Buttons.RightSpawn, spawn_move, false );
	addEventHandler( "onClientGUIClick", Buttons.Spawn,      spawn, 	 false );


	-------------------------------------------------------------------------------------

	Images.InRoundGUIBg 	  = guiCreateStaticImage( 0, ( Height * 970 ) / 1024, Width, ( Height * 54 ) / 1024, "images/inround.png", false );

	--Images.InRoundGUIHeartAtt = guiCreateStaticImage( Width - ( Width - 308 ),  Height - ( Height - 969 ), Width - ( Width - 46 ),   Height - ( Height - 55 ), "images/heart.png",   false );

	--Images.InRoundGUIHeartDef = guiCreateStaticImage( Width - ( Width - 1175 ), Height - ( Height - 963 ), Width - ( Width - 52 ),   Height - ( Height - 61 ), "images/heart.png",   false );

	guiSetVisible( Images.InRoundGUIBg, 	  false );

	ProgressBar.CP			= guiCreateProgressBar( ( Width * 446 ) / 1280, ( Height * 916 ) / 1024, ( Width * 386 ) / 1280, ( Height * 50 ) / 1024, false );
	guiSetAlpha( ProgressBar.CP, 0.5 );
	guiSetVisible( ProgressBar.CP, false );

	DXText.Clock           			= {};
	DXText.Clock.Text 				= " ";
	DXText.Clock.Left 				= ( Width  * 603   ) / 1280;
  	DXText.Clock.Top				= ( Height * 982   ) / 1024;
	DXText.Clock.Right      		= ( Width  * 634   ) / 1280;
	DXText.Clock.Bottom     		= ( Height * 1015  ) / 1280;
	DXText.Clock.Color      		= tocolor   ( 255, 0, 0, 255 );
	DXText.Clock.Scale      		= ( Width * 1.0 ) / 1280;
	DXText.Clock.Font       		= "bankgothic";
	DXText.Clock.AlignX     		= "left";
	DXText.Clock.AlignY     		= "top";
	DXText.Clock.Clip       		= false;
	DXText.Clock.WordBreak  		= false;
	DXText.Clock.PostGUI    		= true;

	DXText.TempDamageDef            = {};
	DXText.TempDamageDef.Text 		= " ";
	DXText.TempDamageDef.Left 		= ( Width  * 1096  ) / 1280;
  	DXText.TempDamageDef.Top		= ( Height * 922   ) / 1024;
	DXText.TempDamageDef.Right      = ( Width  * 1119  ) / 1280;
	DXText.TempDamageDef.Bottom     = ( Height * 946   ) / 1024;
	DXText.TempDamageDef.Color      = tocolor   ( 0, 255, 0, 255 );
	DXText.TempDamageDef.Scale      = ( Width * 2.0 ) / 1280;
	DXText.TempDamageDef.Font       = "pricedown";
	DXText.TempDamageDef.AlignX     = "left";
	DXText.TempDamageDef.AlignY     = "top";
	DXText.TempDamageDef.Clip       = false;
	DXText.TempDamageDef.WordBreak  = false;
	DXText.TempDamageDef.PostGUI    = false;


	DXText.DefendersRound            = {};
	DXText.DefendersRound.Text 		 = " ";
	DXText.DefendersRound.Left 		 = ( Width  * 1176  ) / 1280;
  	DXText.DefendersRound.Top		 = ( Height * 985   ) / 1024;
	DXText.DefendersRound.Right      = ( Width  * 1233  ) / 1280;
	DXText.DefendersRound.Bottom     = ( Height * 1022  ) / 1024;
	DXText.DefendersRound.Color      = tocolor( 0, 255, 0, 255 );
	DXText.DefendersRound.Scale      = ( Width * 1.5 ) / 1280;
	DXText.DefendersRound.Font       = "sans";
	DXText.DefendersRound.AlignX     = "left";
	DXText.DefendersRound.AlignY     = "top";
	DXText.DefendersRound.Clip       = false;
	DXText.DefendersRound.WordBreak  = false;
	DXText.DefendersRound.PostGUI    = true;

	DXText.DefendersRoundPlayers            = {};
	DXText.DefendersRoundPlayers.Text 		= " ";
	DXText.DefendersRoundPlayers.Left 		= ( Width  * 1104  ) / 1280;
  	DXText.DefendersRoundPlayers.Top		= ( Height * 985   ) / 1024;
	DXText.DefendersRoundPlayers.Right      = ( Width  * 1157  ) / 1280;
	DXText.DefendersRoundPlayers.Bottom     = ( Height * 1021  ) / 1024;
	DXText.DefendersRoundPlayers.Color      = tocolor   ( 0, 255, 0, 255 );
	DXText.DefendersRoundPlayers.Scale      = ( Width * 1.5 ) / 1280;
	DXText.DefendersRoundPlayers.Font       = "sans";
	DXText.DefendersRoundPlayers.AlignX     = "left";
	DXText.DefendersRoundPlayers.AlignY     = "top";
	DXText.DefendersRoundPlayers.Clip       = false;
	DXText.DefendersRoundPlayers.WordBreak  = false;
	DXText.DefendersRoundPlayers.PostGUI    = true;

	DXText.DefendersRoundHealth             = {};
	DXText.DefendersRoundHealth.Text 		= " ";
	DXText.DefendersRoundHealth.Left 		= ( Width  * 961   ) / 1280;
  	DXText.DefendersRoundHealth.Top		 	= ( Height * 985   ) / 1024;
	DXText.DefendersRoundHealth.Right      	= ( Width  * 1016  ) / 1280;
	DXText.DefendersRoundHealth.Bottom     	= ( Height * 1006  ) / 1024;
	DXText.DefendersRoundHealth.Color      	= tocolor   ( 0, 255, 0, 255 );
	DXText.DefendersRoundHealth.Scale      	= ( Width * 1.5 ) / 1280;
	DXText.DefendersRoundHealth.Font       	= "sans";
	DXText.DefendersRoundHealth.AlignX     	= "left";
	DXText.DefendersRoundHealth.AlignY    	= "top";
	DXText.DefendersRoundHealth.Clip       	= false;
	DXText.DefendersRoundHealth.WordBreak  	= false;
	DXText.DefendersRoundHealth.PostGUI    	= true;


	DXText.TempDamageAtt            	= {};
	DXText.TempDamageAtt.Text 			= " ";
	DXText.TempDamageAtt.Left 			= ( Width  * 244   ) / 1280;
  	DXText.TempDamageAtt.Top			= ( Height * 920   ) / 1024;
	DXText.TempDamageAtt.Right      	= ( Width  * 392   ) / 1280;
	DXText.TempDamageAtt.Bottom     	= ( Height * 985   ) / 1024;
	DXText.TempDamageAtt.Color      	= tocolor   ( 255, 0, 0, 255 );
	DXText.TempDamageAtt.Scale      	= ( Width * 2.0 ) / 1280;
	DXText.TempDamageAtt.Font       	= "pricedown";
	DXText.TempDamageAtt.AlignX     	= "left";
	DXText.TempDamageAtt.AlignY     	= "top";
	DXText.TempDamageAtt.Clip       	= false;
	DXText.TempDamageAtt.WordBreak  	= false;
	DXText.TempDamageAtt.PostGUI    	= false;

	DXText.AttackersRound            	= {};
	DXText.AttackersRound.Text 		 	= " ";
	DXText.AttackersRound.Left 		 	= ( Width  * 20    ) / 1280;
  	DXText.AttackersRound.Top		 	= ( Height * 985   ) / 1024;
	DXText.AttackersRound.Right      	= ( Width  * 94    ) / 1280;
	DXText.AttackersRound.Bottom     	= ( Height * 1010  ) / 1024;
	DXText.AttackersRound.Color      	= tocolor   ( 255, 0, 0, 255 );
	DXText.AttackersRound.Scale      	= ( Width * 1.5 ) / 1280;
	DXText.AttackersRound.Font       	= "sans";
	DXText.AttackersRound.AlignX     	= "left";
	DXText.AttackersRound.AlignY     	= "top";
	DXText.AttackersRound.Clip       	= false;
	DXText.AttackersRound.WordBreak  	= false;
	DXText.AttackersRound.PostGUI   	= true;

	DXText.AttackersRoundPlayers            = {};
	DXText.AttackersRoundPlayers.Text 		= " ";
	DXText.AttackersRoundPlayers.Left 		= ( Width  * 129   ) / 1280;
  	DXText.AttackersRoundPlayers.Top		= ( Height * 985   ) / 1024;
	DXText.AttackersRoundPlayers.Right      = ( Width  * 137   ) / 1280;
	DXText.AttackersRoundPlayers.Bottom     = ( Height * 995   ) / 1024;
	DXText.AttackersRoundPlayers.Color      = tocolor   ( 255, 0, 0, 255 );
	DXText.AttackersRoundPlayers.Scale      = ( Width * 1.5 ) / 1280;
	DXText.AttackersRoundPlayers.Font       = "sans";
	DXText.AttackersRoundPlayers.AlignX     = "left";
	DXText.AttackersRoundPlayers.AlignY     = "top";
	DXText.AttackersRoundPlayers.Clip       = false;
	DXText.AttackersRoundPlayers.WordBreak  = false;
	DXText.AttackersRoundPlayers.PostGUI    = true;

	DXText.AttackersRoundHealth             = {};
	DXText.AttackersRoundHealth.Text 		= " ";
	DXText.AttackersRoundHealth.Left 		= ( Width  * 265   ) / 1280;
  	DXText.AttackersRoundHealth.Top		 	= ( Height * 985   ) / 1024;
	DXText.AttackersRoundHealth.Right      	= ( Width  * 296   ) / 1280;
	DXText.AttackersRoundHealth.Bottom     	= ( Height * 1000  ) / 1024;
	DXText.AttackersRoundHealth.Color      	= tocolor   ( 255, 0, 0, 255 );
	DXText.AttackersRoundHealth.Scale      	= ( Width * 1.5 ) / 1280;
	DXText.AttackersRoundHealth.Font       	= "sans";
	DXText.AttackersRoundHealth.AlignX     	= "left";
	DXText.AttackersRoundHealth.AlignY    	= "top";
	DXText.AttackersRoundHealth.Clip       	= false;
	DXText.AttackersRoundHealth.WordBreak  	= false;
	DXText.AttackersRoundHealth.PostGUI    	= true;

	DXText.CPTime            		 		= {};
	DXText.CPTime.Text 		 		 		= " ";
	DXText.CPTime.Left 						= ( Width  * 565   ) / 1280;
  	DXText.CPTime.Top						= ( Height * 925   ) / 1024;
	DXText.CPTime.Right     		 		= ( Width  * 682   ) / 1280;
	DXText.CPTime.Bottom    		 		= ( Height * 947   ) / 1024;
	DXText.CPTime.Color     				= tocolor	 ( 0, 0, 0, 255   );
	DXText.CPTime.Scale    		 	 		= ( Width * 2.0 ) / 1280;
	DXText.CPTime.Font      		 		= "default";
	DXText.CPTime.AlignX    		 		= "left";
	DXText.CPTime.AlignY    		 		= "top";
	DXText.CPTime.Clip     		     		= false;
	DXText.CPTime.WordBreak 				= false;
	DXText.CPTime.PostGUI   		 		= true;




	-------------------------------------------------------------------------------------


	Windows.Gunmenu 		= guiCreateWindow  ( ( Width / 2 ) - ( ( Width * 537 ) / 1280) / 2, ( Height / 2 ) - ( ( Height * 439 ) / 1024) / 2, ( Width * 537 ) / 1280, ( Height * 439 ) / 1024, "Gunmenu", 	  false     				);

	GridLists.Gunmenu1 	    = guiCreateGridList( ( Width * 12 ) / 1280, ( Height * 27 ) / 1024, ( Width * 248 ) / 1280, ( Height * 198 ) / 1024, 		  false, Windows.Gunmenu 	);

	GridLists.Gunmenu2		= guiCreateGridList( ( Width * 276 ) / 1280, ( Height * 26 ) / 1024, ( Width * 239 ) / 1280, ( Height * 198 ) / 1024, 		  false, Windows.Gunmenu 	);

	Buttons.Gunmenu 		= guiCreateButton  ( ( Width * 192 ) / 1280, ( Height * 354 ) / 1024, ( Width * 141 ) / 1280, ( Height * 72 ) / 1024, "Done", false, Windows.Gunmenu   );

	addEventHandler( "onClientGUIClick", Buttons.Gunmenu, onClientPickWeapons, false );

	guiGridListSetSelectionMode( GridLists.Gunmenu1, 2 );
	guiGridListSetSelectionMode( GridLists.Gunmenu2, 2 );

	guiGridListAddColumn( GridLists.Gunmenu2, "Weapon", ( Width * 1.0 ) / 1280  );
	guiGridListAddColumn( GridLists.Gunmenu1, "Weapon", ( Width * 1.0 ) / 1280 );
	guiSetAlpha( 		  Windows.Gunmenu, 				0.5	 );
	guiWindowSetSizable ( Windows.Gunmenu, false 			 );
	guiWindowSetMovable ( Windows.Gunmenu, false 			 );

	guiSetVisible( Windows.Gunmenu, false 					);

	DXText.Gunmenu            		 = {};
	DXText.Gunmenu[1]	      		 = {};
	DXText.Gunmenu[1].Text	 		 = " ";
	DXText.Gunmenu[1].Left 			 = ( Width  * 774   		) / 1280;
  	DXText.Gunmenu[1].Top			 = ( Height * 540   		) / 1024;
	DXText.Gunmenu[1].Right     	 = ( Width  * 887   		) / 1280;
	DXText.Gunmenu[1].Bottom    	 = ( Height * 602   		) / 1024;
	DXText.Gunmenu[1].Color     	 = tocolor	 ( 255, 255, 255, 255   );
	DXText.Gunmenu[1].Scale    		 = ( Width * 2.0 ) / 1280;
	DXText.Gunmenu[1].Font      	 = "default";
	DXText.Gunmenu[1].AlignX    	 = "left";
	DXText.Gunmenu[1].AlignY    	 = "top";
	DXText.Gunmenu[1].Clip     		 = false;
	DXText.Gunmenu[1].WordBreak 	 = true;
	DXText.Gunmenu[1].PostGUI   	 = true;

	DXText.Gunmenu[2]	      		 = {};
	DXText.Gunmenu[2].Text	 		 = " ";
	DXText.Gunmenu[2].Left 			 = ( Width  * 415   		) / 1280;
  	DXText.Gunmenu[2].Top			 = ( Height * 540   		) / 1024;
	DXText.Gunmenu[2].Right     	 = ( Width  * 539   		) / 1280;
	DXText.Gunmenu[2].Bottom    	 = ( Height * 614   		) / 1024;
	DXText.Gunmenu[2].Color     	 = tocolor	 ( 255, 255, 255, 255   );
	DXText.Gunmenu[2].Scale    		 = ( Width * 2.0 ) / 1280;
	DXText.Gunmenu[2].Font      	 = "default";
	DXText.Gunmenu[2].AlignX    	 = "left";
	DXText.Gunmenu[2].AlignY    	 = "top";
	DXText.Gunmenu[2].Clip     		 = false;
	DXText.Gunmenu[2].WordBreak 	 = true;
	DXText.Gunmenu[2].PostGUI   	 = true;

	-------------------------------------------------------------------------------------
												--  ( Width / 2 ) - ( ( Width * 537 ) / 1280 ) / 2, ( Height / 2 ) - ( ( Height * 439 ) / 1024 ) / 2, ( Width * 537 ) / 1280, ( Height * 439 ) / 1024
	Images.RoundEndTemplate = guiCreateStaticImage( ( Width * 252 ) / 1280, ( Height * 227 ) / 1280, ( Width * 798 ) / 1280, ( Height * 616 ) / 1024, "images/roundend.png", false );
	guiSetAlpha( Images.RoundEndTemplate, 0.75 );

	guiSetVisible( Images.RoundEndTemplate, false );

	-------------------------------------------------------------------------------------

	DXText.DmgDealt            		 		= {};
	DXText.DmgDealt.Text 		 		 	= " ";
	DXText.DmgDealt.Left 					= ( Width  * 92    ) / 1280;
  	DXText.DmgDealt.Top						= ( Height * 745   ) / 1024;
	DXText.DmgDealt.Right     		 		= ( Width  * 402   ) / 1280;
	DXText.DmgDealt.Bottom    		 		= ( Height * 768   ) / 1024;
	DXText.DmgDealt.Color     				= tocolor( 0, 255, 0, 255 );
	DXText.DmgDealt.Scale    		 	 	= ( Width * 1.2 ) / 1280;
	DXText.DmgDealt.Font      		 		= "default-bold";
	DXText.DmgDealt.AlignX    		 		= "left";
	DXText.DmgDealt.AlignY    		 		= "top";
	DXText.DmgDealt.Clip     		     	= false;
	DXText.DmgDealt.WordBreak 				= false;
	DXText.DmgDealt.PostGUI   		 		= true;

	DXText.DmgDealt.Alpha 					= 0;

	DXText.DmgTaken            		 		= {};
	DXText.DmgTaken.Text 		 		 	= " ";
	DXText.DmgTaken.Left 					= ( Width  * 797   ) / 1280;
  	DXText.DmgTaken.Top						= ( Height * 745   ) / 1024;
	DXText.DmgTaken.Right     		 		= ( Width  * 1107  ) / 1280;
	DXText.DmgTaken.Bottom    		 		= ( Height * 767   ) / 1024;
	DXText.DmgTaken.Color     				= tocolor( 0, 0, 255, 255 );
	DXText.DmgTaken.Scale    		 	 	= ( Width * 1.2 ) / 1280;
	DXText.DmgTaken.Font      		 		= "default-bold";
	DXText.DmgTaken.AlignX    		 		= "left";
	DXText.DmgTaken.AlignY    		 		= "top";
	DXText.DmgTaken.Clip     		     	= false;
	DXText.DmgTaken.WordBreak 				= false;
	DXText.DmgTaken.PostGUI   		 		= true;

	DXText.DmgTaken.Alpha 				    = 0;

	--------------------------------------------------------------------------------------

	--dxDrawText("Attackers 0 - 0 Defenders",993.0,197.0,1116.0,230.0,tocolor(255,255,255,255),1.0,"beckett","left","top",false,false,false)

	-- Direct X Drawing


	DXText.Score							= {}
	DXText.Score.Defenders					= {}

	DXText.Score.Defenders.Text 			= " ";
	DXText.Score.Defenders.Left 			= ( Width  * 1135  ) / 1280;
  	DXText.Score.Defenders.Top				= ( Height * 192   ) / 1024;
	DXText.Score.Defenders.Right     		= ( Width  * 1150  ) / 1280;
	DXText.Score.Defenders.Bottom    		= ( Height * 223   ) / 1024;
	DXText.Score.Defenders.Color     		= tocolor	 ( 255, 255, 255, 255   );
	DXText.Score.Defenders.Scale    		= ( Width * 1.5 ) / 1280;
	DXText.Score.Defenders.Font      		= "clear";
	DXText.Score.Defenders.AlignX    		= "left";
	DXText.Score.Defenders.AlignY    		= "top";
	DXText.Score.Defenders.Clip     		= false;
	DXText.Score.Defenders.WordBreak		= false;
	DXText.Score.Defenders.PostGUI   		= true;


	DXText.Score.Attackers					= {}

	DXText.Score.Attackers.Text 			= " ";
	DXText.Score.Attackers.Left 			= ( Width  * 950   ) / 1280;
  	DXText.Score.Attackers.Top				= ( Height * 192   ) / 1024;
	DXText.Score.Attackers.Right     		= ( Width  * 1050  ) / 1280;
	DXText.Score.Attackers.Bottom    		= ( Height * 273   ) / 1024;
	DXText.Score.Attackers.Color     		= tocolor	 ( 255, 255, 255, 255   );
	DXText.Score.Attackers.Scale    		= ( Width * 1.5 ) / 1280;
	DXText.Score.Attackers.Font      		= "clear";
	DXText.Score.Attackers.AlignX    		= "left";
	DXText.Score.Attackers.AlignY    		= "top";
	DXText.Score.Attackers.Clip     		= false;
	DXText.Score.Attackers.WordBreak		= false;
	DXText.Score.Attackers.PostGUI   		= true;

	DXText.Score.RealScore					= {}

	DXText.Score.RealScore.Text 			= " ";
	DXText.Score.RealScore.Left 			= ( Width  * 1070  ) / 1280;
  	DXText.Score.RealScore.Top				= ( Height * 192   ) / 1024;
	DXText.Score.RealScore.Right     		= ( Width  * 1180  ) / 1280;
	DXText.Score.RealScore.Bottom    		= ( Height * 256   ) / 1024;
	DXText.Score.RealScore.Color     		= tocolor	 ( 255, 255, 255, 255   );
	DXText.Score.RealScore.Scale    		= ( Width * 1.5 ) / 1280;
	DXText.Score.RealScore.Font      		= "clear";
	DXText.Score.RealScore.AlignX    		= "left";
	DXText.Score.RealScore.AlignY    		= "top";
	DXText.Score.RealScore.Clip     		= false;
	DXText.Score.RealScore.WordBreak		= false;
	DXText.Score.RealScore.PostGUI   		= true;

	DXRectangle.Score 						= {};

	DXRectangle.Score.X						= ( Width  * 926  ) / 1280
	DXRectangle.Score.Y						= ( Height * 184  ) / 1024;
	DXRectangle.Score.Width					= ( Width  * 352  ) / 1280;
	DXRectangle.Score.Height				= ( Height * 1280 ) / 1024 -- NOT / 1280
	DXRectangle.Score.Color  				= tocolor( 0, 0, 0, 125 );
	DXRectangle.Score.PostGUI				= false;

	--------------------------------------------------------------------------------------

	Memos.Credits = guiCreateMemo( ( Width * 420 ) / 1280, ( Height * 340 ) / 1024, ( Width * 474 ) / 1280, ( Height * 346 ) / 1024, "Programmed by Whitetiger\nImages by PotH3Ad\nBases created by [U] Clan\n Arenas created by [U] Clan\nTesting: [U]18\nOther credits: MTA Team, 90NINE, Boylett, 50p", false );
	guiMemoSetReadOnly( Memos.Credits, true );
	guiSetEnabled( Memos.Credits, false );

	Buttons.Credits = guiCreateButton( ( Width * 568 ) / 1280, ( Height * 620 ) / 1024, ( Width * 157 ) / 1280, ( Height * 60 ) / 1024, "Close", false );

	guiSetVisible( Memos.Credits, false );
	guiSetVisible( Buttons.Credits, false );

	addEventHandler( "onClientGUIClick", Buttons.Credits, onCreditsClose, false );

	--------------------------------------------------------------------------------------

	Windows.Spec 			= guiCreateWindow( ( Width * 908 ) / 1280, ( Height * 724 ) / 1024, ( Width * 372 ) / 1280, ( Height * 232 ) / 1024, "Spectate info", false );
	Labels.SpecInfo 		= guiCreateLabel( ( Width * 32 ) / 1280, ( Height * 41 ) / 1024, ( Width * 176 ) / 1280, ( Height * 191 ) / 1024, "Team: Attackers\nFPS: 10\nHealth: 100\nArmor:100\nRecent Damage Dealt: 50\nRecent Damage Taken: 50\nSpeed: 50 km/h", false, Windows.Spec )
							  guiSetFont( Labels.SpecInfo, "default-bold-small" );
	Labels.SpecWeps 		= guiCreateLabel( ( Width * 234 ) / 1280, ( Height * 39 ) / 1024, ( Width * 131 ) / 1280, ( Height * 176 ) / 1024, "Deagle (9999) (7)\nShotgun (9999) (1)\nTec-9 (9999) (50)", false, Windows.Spec );
							  guiSetFont( Labels.SpecWeps, "default-bold-small" );
	Checkboxes.Spec 		= guiCreateCheckBox( ( Width * 168 ) / 1280, ( Height * 195 ) / 1024, ( Width * 200 ) / 1280, ( Height * 17 ) / 1024, "Show spectate info", true, false, Windows.Spec );
							  guiSetFont( Checkboxes.Spec,"default-bold-small" );


	Labels.SpecingYou = guiCreateLabel( ( Width * 756 ) / 1280, ( Height * 671 ) / 1024, ( Width * 418 ) / 1280, ( Height * 332 ) / 1024,"Spectating you\n ", false );
	guiSetFont( Labels.SpecingYou,"default-bold-small" );

	guiSetVisible( Labels.SpecingYou, false );
	guiSetVisible( Windows.Spec,      false );

	---------------------------------------------------------------------------------------

	GridLists.Vote = guiCreateGridList( ( Width * 1024 ) / 1280, ( Height * 412 ) / 1024, ( Width * 255 ) / 1280, ( Height * 352 ) / 1024, false );
	guiGridListSetSelectionMode( GridLists.Vote, 5 		);

	guiGridListAddColumn( GridLists.Vote, "Base",  0.4 	);

	guiGridListAddColumn( GridLists.Vote, "Votes", 0.4 	);

	guiSetAlpha( GridLists.Vote, 0.5 					);

	guiSetVisible( GridLists.Vote, false 				);

	--------------------------------------------------------------------------------------


	Images.Paused = guiCreateStaticImage( ( Width * 458 ) / 1280, ( Height * 354 ) / 1024, ( Width * 370 ) / 1280, ( Height * 336 ) / 1024, "images/pause.png", false );

	guiSetVisible( Images.Paused, false );

	--------------------------------------------------------------------------------------

	DXText.TempDmgDef						= {}

	DXText.TempDmgDef.Text 		 		 	= "";
	DXText.TempDmgDef.Left 					= ( Width  * 947   ) / 1280;
  	DXText.TempDmgDef.Top					= ( Height * 933   ) / 1024;
	DXText.TempDmgDef.Right     		 	= ( Width  * 1114  ) / 1280;
	DXText.TempDmgDef.Bottom    		 	= ( Height * 1020  ) / 1024;
	DXText.TempDmgDef.Color     			= tocolor	 ( 0, 0, 255, 255 );
	DXText.TempDmgDef.Scale    		 	 	= ( Width * 2.0 ) / 1280;
	DXText.TempDmgDef.Font      		 	= "arial";
	DXText.TempDmgDef.AlignX    		 	= "left";
	DXText.TempDmgDef.AlignY    		 	= "top";
	DXText.TempDmgDef.Clip     		     	= false;
	DXText.TempDmgDef.WordBreak				= false;
	DXText.TempDmgDef.PostGUI   		 	= false;

	DXText.TempDmgDef.Alpha					= 0;

	DXText.TempDmgAtt						= {}

	DXText.TempDmgAtt.Text 		 		 	= "";
	DXText.TempDmgAtt.Left 					= ( Width  * 252   ) / 1280;
  	DXText.TempDmgAtt.Top					= ( Height * 933   ) / 1024;
	DXText.TempDmgAtt.Right     		 	= ( Width  * 419   ) / 1280;
	DXText.TempDmgAtt.Bottom    		 	= ( Height * 1020  ) / 1024;
	DXText.TempDmgAtt.Color     			= tocolor	 ( 255, 0, 0, 255 );
	DXText.TempDmgAtt.Scale    		 	 	= ( Width * 2.0 ) / 1280;
	DXText.TempDmgAtt.Font      		 	= "arial";
	DXText.TempDmgAtt.AlignX    		 	= "left";
	DXText.TempDmgAtt.AlignY    		 	= "top";
	DXText.TempDmgAtt.Clip     		     	= false;
	DXText.TempDmgAtt.WordBreak				= false;
	DXText.TempDmgAtt.PostGUI   		 	= false;

	DXText.TempDmgAtt.Alpha					= 0;


	--------------------------------------------------------------------------------------

	loadPlayerConfig( );


end


function loadEndRoundDxText( _table )
	local Width, Height          							 = guiGetScreenSize( );
	local attleft, atttop, attright, attbottom 				 = 0, 0, 0, 0;
	local defleft, deftop, defright, defbottom 				 = 0, 0, 0, 0;
	Round.EndRoundDXTextPlayers 					 		 = {};
	DXText.EndRound									 		 = {};
	DXText.EndRound.Attackers						 		 = {};
	DXText.EndRound.Defenders						 		 = {};
	local r, g, b											 = getTeamColor( Teams.Attackers );
	local a                         						 = 255;
	local attcol 											 = tocolor( r, g, b, a );
	r, g, b													 = getTeamColor( Teams.Defenders );
	-- don't change alpha.
	local defcol									 		 = tocolor( r, g, b, a );


	for v, i in ipairs( getElementsByType( "player" ) ) do
		-- create all repeating dxtext.
		-- this looks complicated, but it's not that difficult to understand.
		Round.EndRoundDXTextPlayers[i] = _table[i];
		if _table[i] == false or _table[i] == nil then
			-- nothing

		elseif getPlayerTeam( i ) == Teams.Attackers then

			DXText.EndRound.Attackers[v]					 = {};
			DXText.EndRound.Attackers[v].Name				 = {};


			DXText.EndRound.Attackers[v].Name.Text    	 	 = getPlayerName( i );
			DXText.EndRound.Attackers[v].Name.Left 		 	 = ( ( Width  * 273	) / 1280 ) + attleft;
			DXText.EndRound.Attackers[v].Name.Top		 	 = ( ( Height * 298 ) / 1024 ) + atttop;
			DXText.EndRound.Attackers[v].Name.Right      	 = ( ( Width  * 376 ) / 1280 ) + attright;
			DXText.EndRound.Attackers[v].Name.Bottom     	 = ( ( Height * 319 ) / 1024 ) + attbottom;
			DXText.EndRound.Attackers[v].Name.Color      	 = attcol;
			DXText.EndRound.Attackers[v].Name.Scale    	 	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Attackers[v].Name.Font       	 = "sans";
			DXText.EndRound.Attackers[v].Name.AlignX     	 = "left";
			DXText.EndRound.Attackers[v].Name.AlignY     	 = "top";
			DXText.EndRound.Attackers[v].Name.Clip     	 	 = false;
			DXText.EndRound.Attackers[v].Name.WordBreak  	 = false;
			DXText.EndRound.Attackers[v].Name.PostGUI    	 = true;

			DXText.EndRound.Attackers[v].Dmg			 	 = {};

			DXText.EndRound.Attackers[v].Dmg.Text    	 	 = tostring( getElementData( i, "round.dmg", false ) );
			DXText.EndRound.Attackers[v].Dmg.Left 		 	 = ( ( Width  * 574 ) / 1280 ) + attleft;
			DXText.EndRound.Attackers[v].Dmg.Top		 	 = ( ( Height * 298 ) / 1024 ) + atttop;
			DXText.EndRound.Attackers[v].Dmg.Right     	 	 = ( ( Width  * 669 ) / 1280 ) + attright;
			DXText.EndRound.Attackers[v].Dmg.Bottom    	 	 = ( ( Height * 333 ) / 1024 ) + attbottom;
			DXText.EndRound.Attackers[v].Dmg.Color     	 	 = attcol;
			DXText.EndRound.Attackers[v].Dmg.Scale    	 	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Attackers[v].Dmg.Font      	 	 = "sans";
			DXText.EndRound.Attackers[v].Dmg.AlignX    	 	 = "left";
			DXText.EndRound.Attackers[v].Dmg.AlignY    	 	 = "top";
			DXText.EndRound.Attackers[v].Dmg.Clip     	 	 = false;
			DXText.EndRound.Attackers[v].Dmg.WordBreak 	 	 = false;
			DXText.EndRound.Attackers[v].Dmg.PostGUI   	 	 = true;

			DXText.EndRound.Attackers[v].Health			 	 = {};

			local hp = getElementData( i, "round.health", false );
			if hp ~= "Dead" then hp = round( hp ) end

			DXText.EndRound.Attackers[v].Health.Text    	 = tostring( hp );
			DXText.EndRound.Attackers[v].Health.Left 		 = ( ( Width  * 429 ) / 1280 ) + attleft;
			DXText.EndRound.Attackers[v].Health.Top		 	 = ( ( Height * 298 ) / 1024 ) + atttop;
			DXText.EndRound.Attackers[v].Health.Right     	 = ( ( Width  * 509	) / 1280 ) + attright;
			DXText.EndRound.Attackers[v].Health.Bottom    	 = ( ( Height * 329 ) / 1024 ) + attbottom;
			DXText.EndRound.Attackers[v].Health.Color     	 = attcol;
			DXText.EndRound.Attackers[v].Health.Scale    	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Attackers[v].Health.Font      	 = "sans";
			DXText.EndRound.Attackers[v].Health.AlignX    	 = "left";
			DXText.EndRound.Attackers[v].Health.AlignY    	 = "top";
			DXText.EndRound.Attackers[v].Health.Clip     	 = false;
			DXText.EndRound.Attackers[v].Health.WordBreak 	 = false;
			DXText.EndRound.Attackers[v].Health.PostGUI   	 = true;


			attleft, atttop, attright, attbottom 		 	  = attleft + 0, atttop + ( ( Height * 43 ) / 1024 ), attright + ( ( Width * -439 ) / 1280 ), attbottom + ( ( Height * 70 ) / 1024 );

		---------------------------------------
		---------------Defenders---------------
		---------------------------------------



		elseif getPlayerTeam( i ) == Teams.Defenders then

			DXText.EndRound.Defenders[v]					 = {};
			DXText.EndRound.Defenders[v].Name				 = {};


			DXText.EndRound.Defenders[v].Name.Text    	 	 = getPlayerName( i );
			DXText.EndRound.Defenders[v].Name.Left 		 	 = ( ( Width  * 689 ) / 1280 ) + defleft;
			DXText.EndRound.Defenders[v].Name.Top		 	 = ( ( Height * 296 ) / 1024 ) + deftop;
			DXText.EndRound.Defenders[v].Name.Right      	 = ( ( Width  * 802 ) / 1280 ) + defright;
			DXText.EndRound.Defenders[v].Name.Bottom     	 = ( ( Height * 323 ) / 1024 ) + defbottom;
			DXText.EndRound.Defenders[v].Name.Color      	 = defcol;
			DXText.EndRound.Defenders[v].Name.Scale    	 	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Defenders[v].Name.Font       	 = "sans";
			DXText.EndRound.Defenders[v].Name.AlignX     	 = "left";
			DXText.EndRound.Defenders[v].Name.AlignY     	 = "top";
			DXText.EndRound.Defenders[v].Name.Clip     	 	 = false;
			DXText.EndRound.Defenders[v].Name.WordBreak  	 = false;
			DXText.EndRound.Defenders[v].Name.PostGUI    	 = true;

			DXText.EndRound.Defenders[v].Dmg				 = {};

			DXText.EndRound.Defenders[v].Dmg.Text    	 	 = tostring( getElementData( i, "round.dmg", false ) );
			DXText.EndRound.Defenders[v].Dmg.Left 		 	 = ( ( Width  * 989  ) / 1280 ) + defleft;
			DXText.EndRound.Defenders[v].Dmg.Top		 	 = ( ( Height * 299  ) / 1024 ) + deftop;
			DXText.EndRound.Defenders[v].Dmg.Right      	 = ( ( Width  * 1069 ) / 1280 ) + defright;
			DXText.EndRound.Defenders[v].Dmg.Bottom     	 = ( ( Height * 330  ) / 1024 ) + defbottom;
			DXText.EndRound.Defenders[v].Dmg.Color      	 = defcol;
			DXText.EndRound.Defenders[v].Dmg.Scale    	 	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Defenders[v].Dmg.Font       	 = "sans";
			DXText.EndRound.Defenders[v].Dmg.AlignX     	 = "left";
			DXText.EndRound.Defenders[v].Dmg.AlignY     	 = "top";
			DXText.EndRound.Defenders[v].Dmg.Clip     	 	 = false;
			DXText.EndRound.Defenders[v].Dmg.WordBreak  	 = false;
			DXText.EndRound.Defenders[v].Dmg.PostGUI    	 = true;

			DXText.EndRound.Defenders[v].Health				 = {};

			local hp = getElementData( i, "round.health", false );
			if hp ~= "Dead" then hp = round( hp ) end
			DXText.EndRound.Defenders[v].Health.Text    	 = tostring( hp );
			DXText.EndRound.Defenders[v].Health.Left 		 = ( ( Width  * 851 ) / 1280 ) + defleft;
			DXText.EndRound.Defenders[v].Health.Top		 	 = ( ( Height * 298 ) / 1024 ) + deftop;
			DXText.EndRound.Defenders[v].Health.Right      	 = ( ( Width  * 931	) / 1280 ) + defright;
			DXText.EndRound.Defenders[v].Health.Bottom     	 = ( ( Height * 329 ) / 1024 ) + defbottom;
			DXText.EndRound.Defenders[v].Health.Color      	 = defcol;
			DXText.EndRound.Defenders[v].Health.Scale    	 = ( Width * 1.0 ) / 1280;
			DXText.EndRound.Defenders[v].Health.Font       	 = "sans";
			DXText.EndRound.Defenders[v].Health.AlignX     	 = "left";
			DXText.EndRound.Defenders[v].Health.AlignY     	 = "top";
			DXText.EndRound.Defenders[v].Health.Clip     	 = false;
			DXText.EndRound.Defenders[v].Health.WordBreak  	 = false;
			DXText.EndRound.Defenders[v].Health.PostGUI    	 = true;

			defleft, deftop, defright, defbottom 		 	 = defleft + 0, deftop + ( ( Height * 43 ) / 1024 ), defright + ( ( Width * -439 ) / 1280 ), defbottom + ( ( Height * 70 ) / 1024 );
		end

		-- so, Since we don't know the exact amount of players that are playing, we have to use a loop with dynamic numbers when ever a base is played
		-- so for example:
		-- we have 5 players each team
		-- 3 * 10 = 30
		-- we will generate 30 dxtext's for end round, it is possible to do 1 * 10 dx text's
		-- the reason i'm not doing that is because it can cause conflicts with multiple resolutions
		-- this way will work on all resolutions and should look normal.
	end




	DXText.EndRound.Defenders.PlayerName			 = {};

	DXText.EndRound.Defenders.PlayerName.Text		 = "Player Name";
	DXText.EndRound.Defenders.PlayerName.Left 		 = ( Width  * 698	) / 1280;
	DXText.EndRound.Defenders.PlayerName.Top		 = ( Height * 273 	) / 1024;
	DXText.EndRound.Defenders.PlayerName.Right       = ( Width  * 800 	) / 1280;
	DXText.EndRound.Defenders.PlayerName.Bottom      = ( Height * 306 	) / 1024;
	DXText.EndRound.Defenders.PlayerName.Color       = tocolor	 ( 255, 255, 255, 255 );
	DXText.EndRound.Defenders.PlayerName.Scale    	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Defenders.PlayerName.Font        = "default";
	DXText.EndRound.Defenders.PlayerName.AlignX      = "left";
	DXText.EndRound.Defenders.PlayerName.AlignY      = "top";
	DXText.EndRound.Defenders.PlayerName.Clip     	 = false;
	DXText.EndRound.Defenders.PlayerName.WordBreak   = false;
	DXText.EndRound.Defenders.PlayerName.PostGUI     = true;


	DXText.EndRound.Defenders.DmgName				 = {};

	DXText.EndRound.Defenders.DmgName.Text			 = "Dmg";
	DXText.EndRound.Defenders.DmgName.Left 		 	 = ( Width  * 988	) / 1280;
	DXText.EndRound.Defenders.DmgName.Top		 	 = ( Height * 272	) / 1024;
	DXText.EndRound.Defenders.DmgName.Right       	 = ( Width  * 1083	) / 1280;
	DXText.EndRound.Defenders.DmgName.Bottom      	 = ( Height * 313	) / 1024;
	DXText.EndRound.Defenders.DmgName.Color       	 = tocolor ( 255, 255, 255, 255 );
	DXText.EndRound.Defenders.DmgName.Scale    	 	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Defenders.DmgName.Font        	 = "default";
	DXText.EndRound.Defenders.DmgName.AlignX      	 = "left";
	DXText.EndRound.Defenders.DmgName.AlignY      	 = "top";
	DXText.EndRound.Defenders.DmgName.Clip     	 	 = false;
	DXText.EndRound.Defenders.DmgName.WordBreak   	 = false;
	DXText.EndRound.Defenders.DmgName.PostGUI     	 = true;

	DXText.EndRound.Defenders.HealthName			 = {};

	DXText.EndRound.Defenders.HealthName.Text		 = "Health";
	DXText.EndRound.Defenders.HealthName.Left 		 = ( Width  * 848	) / 1280;
	DXText.EndRound.Defenders.HealthName.Top		 = ( Height * 272	) / 1024;
	DXText.EndRound.Defenders.HealthName.Right       = ( Width  * 1083	) / 1280;
	DXText.EndRound.Defenders.HealthName.Bottom      = ( Height * 313	) / 1024;
	DXText.EndRound.Defenders.HealthName.Color       = tocolor ( 255, 255, 255, 255 );
	DXText.EndRound.Defenders.HealthName.Scale    	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Defenders.HealthName.Font        = "default";
	DXText.EndRound.Defenders.HealthName.AlignX      = "left";
	DXText.EndRound.Defenders.HealthName.AlignY      = "top";
	DXText.EndRound.Defenders.HealthName.Clip     	 = false;
	DXText.EndRound.Defenders.HealthName.WordBreak   = false;
	DXText.EndRound.Defenders.HealthName.PostGUI     = true;

	DXText.EndRound.Defenders.TeamName			 	 = {};

	DXText.EndRound.Defenders.TeamName.Text		 	 = getTeamName( Teams.Defenders );
	DXText.EndRound.Defenders.TeamName.Left 		 = ( Width  * 824	) / 1280;
	DXText.EndRound.Defenders.TeamName.Top		 	 = ( Height * 217	) / 1024;
	DXText.EndRound.Defenders.TeamName.Right       	 = ( Width  * 972	) / 1280;
	DXText.EndRound.Defenders.TeamName.Bottom      	 = ( Height * 263	) / 1024;
	DXText.EndRound.Defenders.TeamName.Color       	 = defcol;
	DXText.EndRound.Defenders.TeamName.Scale    	 = ( Width * 2.3 ) / 1280;
	DXText.EndRound.Defenders.TeamName.Font        	 = "sans";
	DXText.EndRound.Defenders.TeamName.AlignX      	 = "left";
	DXText.EndRound.Defenders.TeamName.AlignY      	 = "top";
	DXText.EndRound.Defenders.TeamName.Clip     	 = false;
	DXText.EndRound.Defenders.TeamName.WordBreak   	 = false;
	DXText.EndRound.Defenders.TeamName.PostGUI     	 = true;

	-- att

	DXText.EndRound.Attackers.PlayerName			 = {};

	DXText.EndRound.Attackers.PlayerName.Text		 = "Player Name";
	DXText.EndRound.Attackers.PlayerName.Left 		 = ( Width  * 270	) / 1280;
	DXText.EndRound.Attackers.PlayerName.Top		 = ( Height * 273	) / 1024;
	DXText.EndRound.Attackers.PlayerName.Right       = ( Width  * 319	) / 1280;
	DXText.EndRound.Attackers.PlayerName.Bottom      = ( Height * 297	) / 1024;
	DXText.EndRound.Attackers.PlayerName.Color       = tocolor	 ( 255, 255, 255, 255 );
	DXText.EndRound.Attackers.PlayerName.Scale    	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Attackers.PlayerName.Font        = "default";
	DXText.EndRound.Attackers.PlayerName.AlignX      = "left";
	DXText.EndRound.Attackers.PlayerName.AlignY      = "top";
	DXText.EndRound.Attackers.PlayerName.Clip     	 = false;
	DXText.EndRound.Attackers.PlayerName.WordBreak   = false;
	DXText.EndRound.Attackers.PlayerName.PostGUI     = true;

	DXText.EndRound.Attackers.DmgName				 = {};

	DXText.EndRound.Attackers.DmgName.Text			 = "Dmg";
	DXText.EndRound.Attackers.DmgName.Left 		 	 = ( Width  * 576	) / 1280;
	DXText.EndRound.Attackers.DmgName.Top		 	 = ( Height * 272	) / 1024;
	DXText.EndRound.Attackers.DmgName.Right       	 = ( Width  * 671	) / 1280;
	DXText.EndRound.Attackers.DmgName.Bottom      	 = ( Height * 309	) / 1024;
	DXText.EndRound.Attackers.DmgName.Color       	 = tocolor ( 255, 255, 255, 255 );
	DXText.EndRound.Attackers.DmgName.Scale    	 	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Attackers.DmgName.Font        	 = "default";
	DXText.EndRound.Attackers.DmgName.AlignX      	 = "left";
	DXText.EndRound.Attackers.DmgName.AlignY      	 = "top";
	DXText.EndRound.Attackers.DmgName.Clip     	 	 = false;
	DXText.EndRound.Attackers.DmgName.WordBreak   	 = false;
	DXText.EndRound.Attackers.DmgName.PostGUI     	 = true;

	DXText.EndRound.Attackers.HealthName			 = {};

	DXText.EndRound.Attackers.HealthName.Text		 = "Health";
	DXText.EndRound.Attackers.HealthName.Left 		 = ( Width  * 426	) / 1280;
	DXText.EndRound.Attackers.HealthName.Top		 = ( Height * 274	) / 1024;
	DXText.EndRound.Attackers.HealthName.Right       = ( Width  * 514	) / 1280;
	DXText.EndRound.Attackers.HealthName.Bottom      = ( Height * 297	) / 1024;
	DXText.EndRound.Attackers.HealthName.Color       = tocolor ( 255, 255, 255, 255 );
	DXText.EndRound.Attackers.HealthName.Scale    	 = ( Width * 1.0 ) / 1280;
	DXText.EndRound.Attackers.HealthName.Font        = "default";
	DXText.EndRound.Attackers.HealthName.AlignX      = "left";
	DXText.EndRound.Attackers.HealthName.AlignY      = "top";
	DXText.EndRound.Attackers.HealthName.Clip     	 = false;
	DXText.EndRound.Attackers.HealthName.WordBreak   = false;
	DXText.EndRound.Attackers.HealthName.PostGUI     = true;

	DXText.EndRound.Attackers.TeamName			 	 = {};

	DXText.EndRound.Attackers.TeamName.Text		 	 = getTeamName( Teams.Attackers );
	DXText.EndRound.Attackers.TeamName.Left 		 = ( Width  * 341	) / 1280;
	DXText.EndRound.Attackers.TeamName.Top		 	 = ( Height * 217	) / 1024;
	DXText.EndRound.Attackers.TeamName.Right       	 = ( Width  * 489	) / 1280;
	DXText.EndRound.Attackers.TeamName.Bottom      	 = ( Height * 263	) / 1024;
	DXText.EndRound.Attackers.TeamName.Color       	 = attcol;
	DXText.EndRound.Attackers.TeamName.Scale    	 = ( Width * 2.3 ) / 1280;
	DXText.EndRound.Attackers.TeamName.Font        	 = "sans";
	DXText.EndRound.Attackers.TeamName.AlignX      	 = "left";
	DXText.EndRound.Attackers.TeamName.AlignY      	 = "top";
	DXText.EndRound.Attackers.TeamName.Clip     	 = false;
	DXText.EndRound.Attackers.TeamName.WordBreak   	 = false;
	DXText.EndRound.Attackers.TeamName.PostGUI     	 = true;

end

function spawn_move( button )
	if source == Buttons.LeftSpawn then
		Player.ClassSelect = Player.ClassSelect - 1;
		-- the player has moved left
		if Player.ClassSelect < 0 then
			-- if their team index is less than 0, set it to the max teams.
			Player.ClassSelect = Total_Teams;
		end
		updateSpawnGui( Player.ClassSelect );
		-- update the spawn gui information for players, wins, losses, skin etc.
	elseif source == Buttons.RightSpawn then
		Player.ClassSelect = Player.ClassSelect + 1;
		-- the player has moved right
		if Player.ClassSelect > Total_Teams then
			-- if the team index is to high, set it to 0
			Player.ClassSelect = 0;
		end
		updateSpawnGui( Player.ClassSelect );
		-- update the spawn gui information for players, wins, losses, skin etc.
	end

end

function clientPreRender ( delay )
	if Player.CameraSpin == true and Player.RoundLoading == true and Round.LoadTime <= 5 and Player.CameraDistance > 0 then spinPlayerCamera( Player.CameraX, Player.CameraY, Player.CameraZ, Player.CameraDistance - 0.2, Player.CameraSpin );
	elseif Player.CameraSpin == true then spinPlayerCamera( Player.CameraX, Player.CameraY, Player.CameraZ, Player.CameraDistance, Player.CameraSpin ) end

	-- restore ped movements to sp
	if PlayerConfig.OrignalCtrls then
		toggleControl( "left", 				true );
		toggleControl( "previous_weapon", 	true );
		toggleControl( "next_weapon", 	    true );
		if getControlState( "left" ) and getControlState( "right" ) then
			toggleControl( "left", false );
		end
		if getControlState( "crouch" ) and not getControlState( "aim_weapon" ) then
			local slot = getPedWeaponSlot( localPlayer );
			setPedWeaponSlot( localPlayer, 0 );
			setPedWeaponSlot( localPlayer, slot );
		end
	end
end


function damageGui( attacker, wep, bodypart, hp )
	-- source = player taken dmg

	local x, y, z;
	if attacker ~= false and isElement( source ) then x, y, z = getElementPosition( source ) end
	local x2, y2, z2;
	if attacker ~= false and isElement( attacker ) then
		x2, y2, z2 = getElementPosition( attacker )
	end

	if getPlayerTeam( source ) == Teams.Defenders then
		Teams.DefDmg = round( Teams.DefDmg + hp );
		DXText.TempDmgDef.Text = tostring( Teams.DefDmg );
		DXText.TempDmgDef.Alpha = 255;
	elseif getPlayerTeam( source ) == Teams.Attackers then
		Teams.AttDmg = round( Teams.AttDmg + hp );
		DXText.TempDmgAtt.Text = tostring( Teams.AttDmg );
		DXText.TempDmgAtt.Alpha = 255;
	end
	if isElement( attacker ) and attacker == localPlayer and attacker ~= source then

		if Player.RecentPlayerDealt ~= attacker then
			Player.RecentDmgDealt = 0;
		end
		Player.RecentDmgDealt = Player.RecentDmgDealt + hp;

		if wep ~= false then
			DXText.DmgDealt.Text = getPlayerName( source ) .. " / " .. getWeaponNameFromID( wep ) .. " / " .. round( Player.RecentDmgDealt ) .. " / " .. round( getDistanceBetweenPoints3D( x, y, z, x2, y2, z2 ) ) .. " distance";
		end
		DXText.DmgDealt.Alpha = 255;

		Player.RecentPlayerDealt = attacker;

		Sounds.HitSound = playSound( "sounds/hit.mp3" );

	elseif source == localPlayer then

		if Player.RecentPlayerTaken ~= source then
			Player.RecentDmgTaken = 0;
		end
		Player.RecentDmgTaken = Player.RecentDmgTaken + hp;

		if isElement( attacker ) and getElementType( attacker ) == "player" and wep ~= nil and isNumeric( Player.RecentDmgTaken ) then
			DXText.DmgTaken.Text = getPlayerName( attacker ) .. " / " .. getWeaponNameFromID( wep ) .. " / " .. round( Player.RecentDmgTaken ) .. " / " .. round( getDistanceBetweenPoints3D( x, y, z, x2, y2, z2 ) ) .. " distance";
		elseif wep ~= nil and Player.recentDmgTaken ~= nil and source ~= nil and wep ~= false and Player.RecentDmgTaken ~= false then
			DXText.DmgTaken.Text = getPlayerName( source ) .. " / " .. getWeaponNameFromID( wep ) .. " / " .. round( Player.RecentDmgTaken );
		else
			DXText.DmgTaken.Text = getPlayerName( source ) .. " / " .. round( hp );
		end

		DXText.DmgTaken.Alpha = 255;

		Player.RecentPlayerTaken = source;
	end

	return 1;
end

function clientRender ( )

	if Player.InRound == true then
		--              Text                Left align       Top Align           Right align         Bottom align         Color                    Scale               Font       Align X and Y relative to other alives     Text cut off    cut off text to a new line   show dxtext over other GUI elements
		dxDrawText( DXText.Clock.Text, DXText.Clock.Left, DXText.Clock.Top, DXText.Clock.Right, DXText.Clock.Bottom, DXText.Clock.Color, DXText.Clock.Scale, DXText.Clock.Font, DXText.Clock.AlignX, DXText.Clock.AlignY, DXText.Clock.Clip, DXText.Clock.WordBreak,     DXText.Clock.PostGUI );
		dxDrawText( DXText.CPTime.Text, DXText.CPTime.Left, DXText.CPTime.Top, DXText.CPTime.Right, DXText.CPTime.Bottom, DXText.CPTime.Color, DXText.CPTime.Scale, DXText.CPTime.Font, DXText.CPTime.AlignX, DXText.CPTime.AlignY, DXText.CPTime.Clip, DXText.CPTime.WordBreak, DXText.CPTime.PostGUI );

		dxDrawText( DXText.TempDamageDef.Text, DXText.TempDamageDef.Left, DXText.TempDamageDef.Top, DXText.TempDamageDef.Right, DXText.TempDamageDef.Bottom, DXText.TempDamageDef.Color, DXText.TempDamageDef.Scale, DXText.TempDamageDef.Font, DXText.TempDamageDef.AlignX, DXText.TempDamageDef.AlignY, DXText.TempDamageDef.Clip, DXText.TempDamageDef.WordBreak, DXText.TempDamageDef.PostGUI );
		dxDrawText( DXText.TempDamageAtt.Text, DXText.TempDamageAtt.Left, DXText.TempDamageAtt.Top, DXText.TempDamageAtt.Right, DXText.TempDamageAtt.Bottom, DXText.TempDamageAtt.Color, DXText.TempDamageAtt.Scale, DXText.TempDamageAtt.Font, DXText.TempDamageAtt.AlignX, DXText.TempDamageAtt.AlignY, DXText.TempDamageAtt.Clip, DXText.TempDamageAtt.WordBreak, DXText.TempDamageAtt.PostGUI );

		dxDrawText( DXText.DefendersRound.Text, DXText.DefendersRound.Left, DXText.DefendersRound.Top, DXText.DefendersRound.Right, DXText.DefendersRound.Bottom, DXText.DefendersRound.Color, DXText.DefendersRound.Scale, DXText.DefendersRound.Font, DXText.DefendersRound.AlignX, DXText.DefendersRound.AlignY, DXText.DefendersRound.Clip, DXText.DefendersRound.WordBreak, DXText.DefendersRound.PostGUI );
		dxDrawText( DXText.DefendersRoundPlayers.Text, DXText.DefendersRoundPlayers.Left, DXText.DefendersRoundPlayers.Top, DXText.DefendersRoundPlayers.Right, DXText.DefendersRoundPlayers.Bottom, DXText.DefendersRoundPlayers.Color, DXText.DefendersRoundPlayers.Scale, DXText.DefendersRoundPlayers.Font, DXText.DefendersRoundPlayers.AlignX, DXText.DefendersRoundPlayers.AlignY, DXText.DefendersRoundPlayers.Clip, DXText.DefendersRoundPlayers.WordBreak, DXText.DefendersRoundPlayers.PostGUI );
		dxDrawText( DXText.DefendersRoundHealth.Text, DXText.DefendersRoundHealth.Left, DXText.DefendersRoundHealth.Top, DXText.DefendersRoundHealth.Right, DXText.DefendersRoundHealth.Bottom, DXText.DefendersRoundHealth.Color, DXText.DefendersRoundHealth.Scale, DXText.DefendersRoundHealth.Font, DXText.DefendersRoundHealth.AlignX, DXText.DefendersRoundHealth.AlignY, DXText.DefendersRoundHealth.Clip, DXText.DefendersRoundHealth.WordBreak, DXText.DefendersRoundHealth.PostGUI );

		dxDrawText( DXText.AttackersRound.Text, DXText.AttackersRound.Left, DXText.AttackersRound.Top, DXText.AttackersRound.Right, DXText.AttackersRound.Bottom, DXText.AttackersRound.Color, DXText.AttackersRound.Scale, DXText.AttackersRound.Font, DXText.AttackersRound.AlignX, DXText.AttackersRound.AlignY, DXText.AttackersRound.Clip, DXText.AttackersRound.WordBreak, DXText.AttackersRound.PostGUI );
		dxDrawText( DXText.AttackersRoundHealth.Text, DXText.AttackersRoundHealth.Left, DXText.AttackersRoundHealth.Top, DXText.AttackersRoundHealth.Right, DXText.AttackersRoundHealth.Bottom, DXText.AttackersRoundHealth.Color, DXText.AttackersRoundHealth.Scale, DXText.AttackersRoundHealth.Font, DXText.AttackersRoundHealth.AlignX, DXText.AttackersRoundHealth.AlignY, DXText.AttackersRoundHealth.Clip, DXText.AttackersRoundHealth.WordBreak, DXText.AttackersRoundHealth.PostGUI );
		dxDrawText( DXText.AttackersRoundPlayers.Text, DXText.AttackersRoundPlayers.Left, DXText.AttackersRoundPlayers.Top, DXText.AttackersRoundPlayers.Right, DXText.AttackersRoundPlayers.Bottom, DXText.AttackersRoundPlayers.Color, DXText.AttackersRoundPlayers.Scale, DXText.AttackersRoundPlayers.Font, DXText.AttackersRoundPlayers.AlignX, DXText.AttackersRoundPlayers.AlignY, DXText.AttackersRoundPlayers.Clip, DXText.AttackersRoundPlayers.WordBreak, DXText.AttackersRoundPlayers.PostGUI );
	end
	if Player.InMenu == true then
		dxDrawText( DXText.Gunmenu[1].Text, DXText.Gunmenu[1].Left, DXText.Gunmenu[1].Top, DXText.Gunmenu[1].Right, DXText.Gunmenu[1].Bottom, DXText.Gunmenu[1].Color, DXText.Gunmenu[1].Scale, DXText.Gunmenu[1].Font, DXText.Gunmenu[1].AlignX, DXText.Gunmenu[1].AlignY, DXText.Gunmenu[1].Clip, DXText.Gunmenu[1].WordBreak, DXText.Gunmenu[1].PostGUI );
		dxDrawText( DXText.Gunmenu[2].Text, DXText.Gunmenu[2].Left, DXText.Gunmenu[2].Top, DXText.Gunmenu[2].Right, DXText.Gunmenu[2].Bottom, DXText.Gunmenu[2].Color, DXText.Gunmenu[2].Scale, DXText.Gunmenu[2].Font, DXText.Gunmenu[2].AlignX, DXText.Gunmenu[2].AlignY, DXText.Gunmenu[2].Clip, DXText.Gunmenu[2].WordBreak, DXText.Gunmenu[2].PostGUI );
	end
	if Player.RoundLoading == true then
		dxDrawRectangle( DXRectangle.BaseLoad.X, DXRectangle.BaseLoad.Y, DXRectangle.BaseLoad.Width, DXRectangle.BaseLoad.Height, DXRectangle.BaseLoad.Color, DXRectangle.BaseLoad.PostGUI );
	end
	if Player.ShowEndRound == true then

		dxDrawText( DXText.EndRound.Attackers.TeamName.Text, DXText.EndRound.Attackers.TeamName.Left, DXText.EndRound.Attackers.TeamName.Top, DXText.EndRound.Attackers.TeamName.Right, DXText.EndRound.Attackers.TeamName.Bottom, DXText.EndRound.Attackers.TeamName.Color, DXText.EndRound.Attackers.TeamName.Scale, DXText.EndRound.Attackers.TeamName.Font, DXText.EndRound.Attackers.TeamName.AlignX, DXText.EndRound.Attackers.TeamName.AlignY, DXText.EndRound.Attackers.TeamName.Clip, DXText.EndRound.Attackers.TeamName.WordBreak, DXText.EndRound.Attackers.TeamName.PostGUI );
		dxDrawText( DXText.EndRound.Defenders.TeamName.Text, DXText.EndRound.Defenders.TeamName.Left, DXText.EndRound.Defenders.TeamName.Top, DXText.EndRound.Defenders.TeamName.Right, DXText.EndRound.Defenders.TeamName.Bottom, DXText.EndRound.Defenders.TeamName.Color, DXText.EndRound.Defenders.TeamName.Scale, DXText.EndRound.Defenders.TeamName.Font, DXText.EndRound.Defenders.TeamName.AlignX, DXText.EndRound.Defenders.TeamName.AlignY, DXText.EndRound.Defenders.TeamName.Clip, DXText.EndRound.Defenders.TeamName.WordBreak, DXText.EndRound.Defenders.TeamName.PostGUI );

		dxDrawText( DXText.EndRound.Defenders.PlayerName.Text, DXText.EndRound.Defenders.PlayerName.Left, DXText.EndRound.Defenders.PlayerName.Top, DXText.EndRound.Defenders.PlayerName.Right, DXText.EndRound.Defenders.PlayerName.Bottom, DXText.EndRound.Defenders.PlayerName.Color, DXText.EndRound.Defenders.PlayerName.Scale, DXText.EndRound.Defenders.PlayerName.Font, DXText.EndRound.Defenders.PlayerName.AlignX, DXText.EndRound.Defenders.PlayerName.AlignY, DXText.EndRound.Defenders.PlayerName.Clip, DXText.EndRound.Defenders.PlayerName.WordBreak, DXText.EndRound.Defenders.PlayerName.PostGUI );
		dxDrawText( DXText.EndRound.Attackers.PlayerName.Text, DXText.EndRound.Attackers.PlayerName.Left, DXText.EndRound.Attackers.PlayerName.Top, DXText.EndRound.Attackers.PlayerName.Right, DXText.EndRound.Attackers.PlayerName.Bottom, DXText.EndRound.Attackers.PlayerName.Color, DXText.EndRound.Attackers.PlayerName.Scale, DXText.EndRound.Attackers.PlayerName.Font, DXText.EndRound.Attackers.PlayerName.AlignX, DXText.EndRound.Attackers.PlayerName.AlignY, DXText.EndRound.Attackers.PlayerName.Clip, DXText.EndRound.Attackers.PlayerName.WordBreak, DXText.EndRound.Attackers.PlayerName.PostGUI );

		dxDrawText( DXText.EndRound.Defenders.HealthName.Text, DXText.EndRound.Defenders.HealthName.Left, DXText.EndRound.Defenders.HealthName.Top, DXText.EndRound.Defenders.HealthName.Right, DXText.EndRound.Defenders.HealthName.Bottom, DXText.EndRound.Defenders.HealthName.Color, DXText.EndRound.Defenders.HealthName.Scale, DXText.EndRound.Defenders.HealthName.Font, DXText.EndRound.Defenders.HealthName.AlignX, DXText.EndRound.Defenders.HealthName.AlignY, DXText.EndRound.Defenders.HealthName.Clip, DXText.EndRound.Defenders.HealthName.WordBreak, DXText.EndRound.Defenders.HealthName.PostGUI );
		dxDrawText( DXText.EndRound.Attackers.HealthName.Text, DXText.EndRound.Attackers.HealthName.Left, DXText.EndRound.Attackers.HealthName.Top, DXText.EndRound.Attackers.HealthName.Right, DXText.EndRound.Attackers.HealthName.Bottom, DXText.EndRound.Attackers.HealthName.Color, DXText.EndRound.Attackers.HealthName.Scale, DXText.EndRound.Attackers.HealthName.Font, DXText.EndRound.Attackers.HealthName.AlignX, DXText.EndRound.Attackers.HealthName.AlignY, DXText.EndRound.Attackers.HealthName.Clip, DXText.EndRound.Attackers.HealthName.WordBreak, DXText.EndRound.Attackers.HealthName.PostGUI );

		dxDrawText( DXText.EndRound.Defenders.DmgName.Text, DXText.EndRound.Defenders.DmgName.Left, DXText.EndRound.Defenders.DmgName.Top, DXText.EndRound.Defenders.DmgName.Right, DXText.EndRound.Defenders.DmgName.Bottom, DXText.EndRound.Defenders.DmgName.Color, DXText.EndRound.Defenders.DmgName.Scale, DXText.EndRound.Defenders.DmgName.Font, DXText.EndRound.Defenders.DmgName.AlignX, DXText.EndRound.Defenders.DmgName.AlignY, DXText.EndRound.Defenders.DmgName.Clip, DXText.EndRound.Defenders.DmgName.WordBreak, DXText.EndRound.Defenders.DmgName.PostGUI );
		dxDrawText( DXText.EndRound.Attackers.DmgName.Text, DXText.EndRound.Attackers.DmgName.Left, DXText.EndRound.Attackers.DmgName.Top, DXText.EndRound.Attackers.DmgName.Right, DXText.EndRound.Attackers.DmgName.Bottom, DXText.EndRound.Attackers.DmgName.Color, DXText.EndRound.Attackers.DmgName.Scale, DXText.EndRound.Attackers.DmgName.Font, DXText.EndRound.Attackers.DmgName.AlignX, DXText.EndRound.Attackers.DmgName.AlignY, DXText.EndRound.Attackers.DmgName.Clip, DXText.EndRound.Attackers.DmgName.WordBreak, DXText.EndRound.Attackers.DmgName.PostGUI );

		for v, i in ipairs( getElementsByType( "player" ) ) do

			if Round.EndRoundDXTextPlayers[i] ~= true then
				-- nothing
			else

				if getPlayerTeam( i ) 	  == Teams.Attackers and DXText.EndRound.Attackers[v].Name.Text ~= nil then
					dxDrawText( DXText.EndRound.Attackers[v].Name.Text, DXText.EndRound.Attackers[v].Name.Left, DXText.EndRound.Attackers[v].Name.Top, DXText.EndRound.Attackers[v].Name.Right, DXText.EndRound.Attackers[v].Name.Bottom, DXText.EndRound.Attackers[v].Name.Color, DXText.EndRound.Attackers[v].Name.Scale, DXText.EndRound.Attackers[v].Name.Font, DXText.EndRound.Attackers[v].Name.AlignX, DXText.EndRound.Attackers[v].Name.AlignY, DXText.EndRound.Attackers[v].Name.Clip, DXText.EndRound.Attackers[v].Name.WordBreak, DXText.EndRound.Attackers[v].Name.PostGUI );
					dxDrawText( DXText.EndRound.Attackers[v].Health.Text, DXText.EndRound.Attackers[v].Health.Left, DXText.EndRound.Attackers[v].Health.Top, DXText.EndRound.Attackers[v].Health.Right, DXText.EndRound.Attackers[v].Health.Bottom, DXText.EndRound.Attackers[v].Health.Color, DXText.EndRound.Attackers[v].Health.Scale, DXText.EndRound.Attackers[v].Health.Font, DXText.EndRound.Attackers[v].Health.AlignX, DXText.EndRound.Attackers[v].Health.AlignY, DXText.EndRound.Attackers[v].Health.Clip, DXText.EndRound.Attackers[v].Health.WordBreak, DXText.EndRound.Attackers[v].Health.PostGUI );
					dxDrawText( DXText.EndRound.Attackers[v].Dmg.Text, DXText.EndRound.Attackers[v].Dmg.Left, DXText.EndRound.Attackers[v].Dmg.Top, DXText.EndRound.Attackers[v].Dmg.Right, DXText.EndRound.Attackers[v].Dmg.Bottom, DXText.EndRound.Attackers[v].Dmg.Color, DXText.EndRound.Attackers[v].Dmg.Scale, DXText.EndRound.Attackers[v].Dmg.Font, DXText.EndRound.Attackers[v].Dmg.AlignX, DXText.EndRound.Attackers[v].Dmg.AlignY, DXText.EndRound.Attackers[v].Dmg.Clip, DXText.EndRound.Attackers[v].Dmg.WordBreak, DXText.EndRound.Attackers[v].Dmg.PostGUI );
				elseif getPlayerTeam( i ) == Teams.Defenders and DXText.EndRound.Defenders[v].Name.Text ~= nil then
					dxDrawText( DXText.EndRound.Defenders[v].Name.Text, DXText.EndRound.Defenders[v].Name.Left, DXText.EndRound.Defenders[v].Name.Top, DXText.EndRound.Defenders[v].Name.Right, DXText.EndRound.Defenders[v].Name.Bottom, DXText.EndRound.Defenders[v].Name.Color, DXText.EndRound.Defenders[v].Name.Scale, DXText.EndRound.Defenders[v].Name.Font, DXText.EndRound.Defenders[v].Name.AlignX, DXText.EndRound.Defenders[v].Name.AlignY, DXText.EndRound.Defenders[v].Name.Clip, DXText.EndRound.Defenders[v].Name.WordBreak, DXText.EndRound.Defenders[v].Name.PostGUI );
					dxDrawText( DXText.EndRound.Defenders[v].Health.Text, DXText.EndRound.Defenders[v].Health.Left, DXText.EndRound.Defenders[v].Health.Top, DXText.EndRound.Defenders[v].Health.Right, DXText.EndRound.Defenders[v].Health.Bottom, DXText.EndRound.Defenders[v].Health.Color, DXText.EndRound.Defenders[v].Health.Scale, DXText.EndRound.Defenders[v].Health.Font, DXText.EndRound.Defenders[v].Health.AlignX, DXText.EndRound.Defenders[v].Health.AlignY, DXText.EndRound.Defenders[v].Health.Clip, DXText.EndRound.Defenders[v].Health.WordBreak, DXText.EndRound.Defenders[v].Health.PostGUI );
					dxDrawText( DXText.EndRound.Defenders[v].Dmg.Text, DXText.EndRound.Defenders[v].Dmg.Left, DXText.EndRound.Defenders[v].Dmg.Top, DXText.EndRound.Defenders[v].Dmg.Right, DXText.EndRound.Defenders[v].Dmg.Bottom, DXText.EndRound.Defenders[v].Dmg.Color, DXText.EndRound.Defenders[v].Dmg.Scale, DXText.EndRound.Defenders[v].Dmg.Font, DXText.EndRound.Defenders[v].Dmg.AlignX, DXText.EndRound.Defenders[v].Dmg.AlignY, DXText.EndRound.Defenders[v].Dmg.Clip, DXText.EndRound.Defenders[v].Dmg.WordBreak, DXText.EndRound.Defenders[v].Dmg.PostGUI );
				end
			end
		end
	end
	if DXText.DmgTaken.Alpha 	 ~= 0 then
		DXText.DmgTaken.Color = tocolor( 0, 0, 255, DXText.DmgTaken.Alpha );
		dxDrawText( DXText.DmgTaken.Text, DXText.DmgTaken.Left, DXText.DmgTaken.Top, DXText.DmgTaken.Right, DXText.DmgTaken.Bottom, DXText.DmgTaken.Color, DXText.DmgTaken.Scale, DXText.DmgTaken.Font, DXText.DmgTaken.AlignX, DXText.DmgTaken.AlignY, DXText.DmgTaken.Clip, DXText.DmgTaken.WordBreak, DXText.DmgTaken.PostGUI );
		DXText.DmgTaken.Alpha = DXText.DmgTaken.Alpha - 1;
	else Player.RecentDmgTaken = 0 end
	if DXText.DmgDealt.Alpha 	 ~= 0 then
		DXText.DmgDealt.Color = tocolor( 0, 255, 0, DXText.DmgDealt.Alpha );
		dxDrawText( DXText.DmgDealt.Text, DXText.DmgDealt.Left, DXText.DmgDealt.Top, DXText.DmgDealt.Right, DXText.DmgDealt.Bottom, DXText.DmgDealt.Color, DXText.DmgDealt.Scale, DXText.DmgDealt.Font, DXText.DmgDealt.AlignX, DXText.DmgDealt.AlignY, DXText.DmgDealt.Clip, DXText.DmgDealt.WordBreak, DXText.DmgDealt.PostGUI );
		DXText.DmgDealt.Alpha = DXText.DmgDealt.Alpha - 1;
	else Player.RecentDmgDealt = 0 end

	if DXText.TempDmgDef.Alpha 	 ~= 0 and Player.InRound then
		DXText.TempDmgDef.Color = tocolor(  0, 0, 255, DXText.TempDmgDef.Alpha );
		dxDrawText( DXText.TempDmgDef.Text, DXText.TempDmgDef.Left, DXText.TempDmgDef.Top, DXText.TempDmgDef.Right, DXText.TempDmgDef.Bottom, DXText.TempDmgDef.Color, DXText.TempDmgDef.Scale, DXText.TempDmgDef.Font, DXText.TempDmgDef.AlignX, DXText.TempDmgDef.AlignY, DXText.TempDmgDef.Clip, DXText.TempDmgDef.WordBreak, DXText.TempDmgDef.PostGUI );
		DXText.TempDmgDef.Alpha = DXText.TempDmgDef.Alpha - 1;
	else Teams.DefDmg = 0 end

	if DXText.TempDmgAtt.Alpha 	 ~= 0 and Player.InRound then
		DXText.TempDmgAtt.Color = tocolor( 255, 0, 0, DXText.TempDmgAtt.Alpha );
		dxDrawText( DXText.TempDmgAtt.Text, DXText.TempDmgAtt.Left, DXText.TempDmgAtt.Top, DXText.TempDmgAtt.Right, DXText.TempDmgAtt.Bottom, DXText.TempDmgAtt.Color, DXText.TempDmgAtt.Scale, DXText.TempDmgAtt.Font, DXText.TempDmgAtt.AlignX, DXText.TempDmgAtt.AlignY, DXText.TempDmgAtt.Clip, DXText.TempDmgAtt.WordBreak, DXText.TempDmgAtt.PostGUI );
		DXText.TempDmgAtt.Alpha = DXText.TempDmgAtt.Alpha - 1;
	else Teams.AttDmg = 0 end


	dxDrawText( DXText.Score.Attackers.Text, DXText.Score.Attackers.Left, DXText.Score.Attackers.Top, DXText.Score.Attackers.Right, DXText.Score.Attackers.Bottom, DXText.Score.Attackers.Color, DXText.Score.Attackers.Scale, DXText.Score.Attackers.Font, DXText.Score.Attackers.AlignX, DXText.Score.Attackers.AlignY, DXText.Score.Attackers.Clip, DXText.Score.Attackers.WordBreak, DXText.Score.Attackers.PostGUI );
	dxDrawText( DXText.Score.Defenders.Text, DXText.Score.Defenders.Left, DXText.Score.Defenders.Top, DXText.Score.Defenders.Right, DXText.Score.Defenders.Bottom, DXText.Score.Defenders.Color, DXText.Score.Defenders.Scale, DXText.Score.Defenders.Font, DXText.Score.Defenders.AlignX, DXText.Score.Defenders.AlignY, DXText.Score.Defenders.Clip, DXText.Score.Defenders.WordBreak, DXText.Score.Defenders.PostGUI );
	dxDrawText( DXText.Score.RealScore.Text, DXText.Score.RealScore.Left, DXText.Score.RealScore.Top, DXText.Score.RealScore.Right, DXText.Score.RealScore.Bottom, DXText.Score.RealScore.Color, DXText.Score.RealScore.Scale, DXText.Score.RealScore.Font, DXText.Score.RealScore.AlignX, DXText.Score.RealScore.AlignY, DXText.Score.RealScore.Clip, DXText.Score.RealScore.WordBreak, DXText.Score.RealScore.PostGUI );

	--dxDrawRectangle( DXRectangle.Score.X, DXRectangle.Score.Y, DXRectangle.Score.Width, DXRectangle.Score.Height, DXRectangle.Score.Color, DXRectangle.Score.PostGUI );

	if PlayerConfig.OrignalCtrls then
		if isPedDucked( localPlayer ) then
			setControlState( "crouch", false );
		end
		if getControlState( "up" ) or getControlState( "down" ) then
			setControlState( "left", true );
		elseif getControlState( "left" ) or getControlState( "right" ) then
			setControlState( "up", true );
		end
	end

	if getControlState( "jump" ) and getControlState( "aim_weapon" ) then
		sync();
		setControlState( "jump", false );
		setControlState( "aim_weapon", false );
	end

	for v, i in ipairs( getElementsByType( "vehicle" ) ) do
		if isElementStreamedIn( i ) then
			showElementHealthBar( localPlayer, i );
		end
	end

	toggleControl( "walk", PlayerConfig.SlowWalk );

	Player.CalculatingFPS = Player.CalculatingFPS + 1;
end

function secondUpdate( )

	setElementData( localPlayer, "FPS", Player.CalculatingFPS );
	Player.FPS = Player.CalculatingFPS;
	Player.CalculatingFPS = 0;

end


function spawn( )
	Player.CameraSpin = false;

	guiSetVisible( Labels.PanelSkins,     		false  );
	guiSetVisible( Labels.PanelName,      		false  );

	guiSetVisible( Windows.SpawnWindow,   		false  );
	guiSetVisible( Windows.SpawnPlayerWindow,	false  );

	guiSetVisible( Buttons.Spawn,   	  		false  );
	guiSetVisible( Buttons.RightSpawn,    		false  );
	guiSetVisible( Buttons.LeftSpawn,     		false  );

	showProperHudComponents( );

	showCursor( false );

	updateTeamScores( Teams.AttScore, Teams.DefScore );

	destroyElement( Player.ClassSelectPed );
	setCameraTarget( localPlayer, localPlayer );
	for v, i in ipairs( getElementsByType("player") ) do
		if isElementCollidableWith( localPlayer, source ) then
			if getPlayerTeam( source ) == getPlayerTeam( i ) then
				setElementCollidableWith( i, source, false );
			else setElementCollidableWith( i, source, true ); end
		end
 	end
	triggerServerEvent( "asignTeam", localPlayer, Player.ClassSelect );

end

function spinPlayerCamera(bX, bY, bZ, dis, toggle )


	Player.CameraSpin = toggle and true;
	if Player.CameraSpin == false then
		-- camera spin has been turned off, lets set the camera back on the player's ped.
		--setCameraMatrix(bX, bY, bZ+Player.CameraDistance, bX, bY, bZ, 0, 0);
		setCameraTarget( localPlayer, localPlayer );
		return 1;
	end
	Player.CameraIndex = Player.CameraIndex+1;
	if Player.CameraIndex == 360 then Player.CameraIndex = 0 end
	local x, y = getPointFromDistanceRotation ( bX, bY, dis, Player.CameraIndex);
	Player.CameraZ = bZ;
	Player.CameraX = bX;
	Player.CameraY = bY;
	Player.CameraDistance = dis or 50;

	setCameraMatrix(x, y, bZ+Player.CameraDistance, bX, bY, bZ, 0, 0);

	return 1;
end

function onUpdateRoundLoadText( roundtype, newtext )
	Player.RoundLoading = true;
	if newtext ~= 0 then
		playSoundFrontEnd( PlayerConfig.LoadSound );
	else
		playSoundFrontEnd( PlayerConfig.LoadEndSound );
	end

	if newtext ~= 1 then
		guiSetText( Labels.RoundLoad, roundtype .. " starting in " .. newtext .. " seconds" );
	else
		guiSetText( Labels.RoundLoad, roundtype .. " starting in " .. newtext .. " second" );
		fadeCamera( false );
	end

	if newtext == 5 then
		Sounds.Countdown = playSound( "sounds/countdown.mp3", false );
	end
	if newtext <= 5 then
		setSoundPosition( Sounds.Countdown, 5 - newtext );
		setSoundPaused( Sounds.Countdown, false );
	end

	Round.LoadTime = tonumber( newtext );

	guiSetVisible( Images.RoundEndTemplate, false );


	guiSetVisible( Labels.RoundLoad, true );

	guiSetVisible( GridLists.Vote, false );

	Player.ShowEndRound = false;
	Player.Voted 		= false;

	Teams.DefDmg		= 0;
	Teams.AttDmg		= 0;

	setElementData( localPlayer, "votedtype", nil );
	setElementData( localPlayer, "votedid",   nil );
	setElementData( localPlayer, "rowidx",    nil );

	--DXText.Score.Text = " ";


end

function roundUpdate( gametype, roundid, info )

	if info.Seconds ~= nil then
		DXText.Clock.Text				= string.format( "%d:%02d", info.Minutes, info.Seconds );

		if info.Minutes == 0 and info.Seconds == 30 then
			Sounds.SecondWarning = playSound( "sounds/endsin30seconds.mp3" );
			stopSoundLater( Sounds.SecondWarning, 5000 );
		elseif info.Minutes == 2 and info.Seconds == 0 then
			Sounds.MinuteWarning = playSound( "sounds/2minutesleft.mp3" );
			stopSoundLater( Sounds.MinuteWarning, 5000 );
		end
	end

	if info.CP ~= nil and info.CP ~= false and Round.CPTime ~= info.CP and Round.CPTime > 0 then
		DXText.CPTime.Text			= "CP Time: " .. info.CP;
		guiProgressBarSetProgress( ProgressBar.CP, 100 - ( ( info.CP / Round.CPTime ) * 100 ) );
		if not guiGetVisible( ProgressBar.CP ) and not isElement( Sounds.CPCapWarning ) then
			Sounds.CPCapWarning = playSound( "sounds/cpcapvoice.mp3" );
			stopSoundLater( Sounds.CPCapWarning, 5000 );
		end

		guiSetVisible( ProgressBar.CP, true );
		if not isElement( Sounds.CP ) and info.CP <= 10 then
			Sounds.CP = playSound( "sounds/cp.mp3", true );
		end
	else
		if isElement( Sounds.CP ) then
			-- make SURE that it exists, though this shouldn't be called if it doesn't exist!
			stopSound( Sounds.CP );
		end
		DXText.CPTime.Text			= " ";
		guiSetVisible( ProgressBar.CP, false );
	end


	local r, g, b						= getTeamColor( Teams.Attackers );
	local a                         	= 255;
	local col 							= tocolor( r, g, b, a );

	DXText.AttackersRoundHealth.Text 	= tostring( info.AttHP );
	DXText.AttackersRoundHealth.Color	= col;

	DXText.AttackersRoundPlayers.Text 	= info.AttPlayers .. "/" .. countPlayersInTeam( Teams.Attackers );
	DXText.AttackersRoundPlayers.Color	= col;

	DXText.AttackersRound.Text			= tostring( getTeamName( Teams.Attackers ) );
	DXText.AttackersRound.Color 		= col;
	DXText.TempDamageAtt.Color     		= col;


	r, g, b              	    		= getTeamColor( Teams.Defenders );
	a                               	= 255
	col      							= tocolor( r, g, b, a );

	DXText.DefendersRoundHealth.Text 	= tostring( info.DefHP );
	DXText.DefendersRoundHealth.Color	= col;

	DXText.DefendersRoundPlayers.Text 	= info.DefPlayers .. "/" .. countPlayersInTeam( Teams.Defenders );
	DXText.DefendersRoundPlayers.Color	= col;

	DXText.DefendersRound.Text			= tostring( getTeamName( Teams.Defenders ) );
	DXText.DefendersRound.Color 		= col;
	DXText.TempDamageDef.Color      	= col;


end

function onClientPickWeapons( button, state )
	if button == "left" then
		local wep1, wep2;
		if guiGridListGetSelectedItem( GridLists.Gunmenu1 ) ~= -1 or guiGridListGetSelectedItem( GridLists.Gunmenu1 ) ~= false then
			wep1 = guiGridListGetItemText( GridLists.Gunmenu1, guiGridListGetSelectedItem( GridLists.Gunmenu1 ), 1 );
		end
		if guiGridListGetSelectedItem( GridLists.Gunmenu2 ) ~= -1 or guiGridListGetSelectedItem( GridLists.Gunmenu2 ) ~= false then
			wep2 = guiGridListGetItemText( GridLists.Gunmenu2, guiGridListGetSelectedItem( GridLists.Gunmenu2 ), 1 );
		end
		-- we give the weapons later in the server event.


		if wep1 == nil then wep1 = 0 end
		if wep2 == nil then wep2 = 0 end

		if(type(wep1) == "boolean" or type(wep2) == "boolean") then
			wep1, wep2 = 0, 0;
		end


		wep1, wep2 = getWeaponIDFromName( wep1 ), getWeaponIDFromName( wep2 );
		if wep1 ~= 0 and getSlotFromWeapon(wep1) == getSlotFromWeapon(wep2) then
			return outputChatBox(COLOR_RED .. "Error " .. COLOR_WHITE .. "You've picked weapons of the same slot! (" .. getWeaponNameFromID( wep1 ) .. ", " .. getWeaponNameFromID( wep2 ) .. ")", 255, 255, 255, true );
		end

		guiSetVisible( Windows.Gunmenu, false );
		showCursor( false );
		toggleAllControls( true );

		triggerServerEvent( "onPlayerPickWeapons", localPlayer, wep1, wep2);
	end
end

function getPointFromDistanceRotation ( x, y, dist, angle )
    --Function made by "robhol"
    local a = math.rad ( 90 + angle )
    local dx = math.cos ( a ) * dist
    local dy = math.sin ( a ) * dist
    return x + dx, y + dy
end

function guiSpawnUpdate( players, skin, wins, losses, team, attteam, defteam, time )

	Teams.Attackers = attteam;
	Teams.Defenders = defteam;

	Round.CPTime    = time;

	guiSetText   ( Labels.PanelPlayers, "Players: " .. players  );
	guiSetText   ( Labels.PanelSkins,   "Skin: " 	.. skin     );
	guiSetText   ( Labels.PanelWins,    "Wins: "    .. wins     );
	guiSetText   ( Labels.PanelLosses,  "Losses: "  .. losses   );
	if team ~= nil then
		guiSetText   ( Labels.PanelName,    getTeamName( team ) );
		guiLabelSetColor( Labels.PanelName, getTeamColor( team ) );
	else
		guiSetText   ( Labels.PanelName,    "Auto-Assign" );
		guiLabelSetColor( Labels.PanelName, 255, 255, 255 );
	end

	guiSetVisible( Windows.SpawnPlayerWindow,	true  );

	local players = getElementsByType( "player" );
	local playerz = 0;
	for v, i in ipairs( players ) do
		if getPlayerTeam( i ) == team then
			playerz = playerz + 1;
			if playerz < 20 then
				guiSetText( Labels.PlayerList,  guiGetText( Labels.PlayerList ) .. "\n " .. getPlayerName( i ) );
			elseif playerz > 20 then
				guiSetText( Labels.PlayerList2, guiGetText( Labels.PlayerList ) .. "\n " .. getPlayerName( i ) );
			end
		end
	end

	guiSetVisible( Labels.PanelSkins,     		true  );
	guiSetVisible( Labels.PanelName,      		true  );

	guiSetVisible( Windows.SpawnWindow,   		true  );

	guiSetVisible( Buttons.Spawn,   	  		true  );
	guiSetVisible( Buttons.RightSpawn,    		true  );
	guiSetVisible( Buttons.LeftSpawn,     		true  );

	local r, g, b		  			= getTeamColor( Teams.Attackers );
	local a               			= 255;
	DXText.Score.Attackers.Color	= tocolor( r, g, b, a );

	r, g, b 						= getTeamColor( Teams.Defenders );
	a								= 255;
	DXText.Score.Defenders.Color	= tocolor( r, g, b, a );

	if isElement( Player.ClassSelectPed ) and getElementType( Player.ClassSelectPed ) == "ped" then
		destroyElement( Player.ClassSelectPed );
	end

	Player.ClassSelectPed = createPed( skin, 1382.9501953125, 2184.287109375, 11.0234375, 132.28564453125 );
	--setPedOnFire( Player.ClassSelectPed, true );
	setElementFrozen( Player.ClassSelectPed, true );
	setElementDimension( Player.ClassSelectPed, getElementDimension( localPlayer ) );
	--setElementRotation( Player.ClassSelectPed, 0.0, 0.0, 132.28564453125 );

	setElementModel( Player.ClassSelectPed, skin );
	spinPlayerCamera( 1382.9501953125, 2184.287109375, 11.0234375, 2, true );

	showCursor( true );

end

function loadFinish( attTeam, defTeam, cptime, weapons )
	if Player.RoundLoading then
		fadeCamera( true, 2.0 );
		spinPlayerCamera( 0, 0, 0, 0, false );

		guiSetVisible( Labels.RoundLoad, false );

		toggleAllControls( true );

		setElementFrozen( localPlayer, false );

		setCameraTarget( localPlayer, localPlayer );

		Player.RoundLoading = false;
		Player.InRound       = true;

		Teams.Attackers = attTeam;
		Teams.Defenders = defTeam;

		Round.CPTime = cptime;

		guiSetVisible( Images.InRoundGUIBg,   		true   );
		--guiSetVisible( Images.InRoundGUIHeartAtt,   true   );
		--guiSetVisible( Images.InRoundGUIHeartDef,   true   );


		showGunMenu( weapons );

		for v, i in ipairs( getElementsByType( "player" ) ) do
			setElementCollidableWith( localPlayer, i, false );
		end

		--roundUpdate( nil );
	end
end

function showGunMenu( weapons )

	-- This is code for when people are /add'ed to the round --
	Player.InRound = true;
	guiSetVisible( Images.InRoundGUIBg,   		true   );
	-- end /add code --


	guiGridListClear( GridLists.Gunmenu1 );
	guiGridListClear( GridLists.Gunmenu2 );
	for i, v in ipairs( weapons[1] ) do
		guiGridListSetItemText ( GridLists.Gunmenu1, guiGridListAddRow ( GridLists.Gunmenu1 ), 1, tostring( getWeaponNameFromID( v ) ), false, false );
	end

	for i, v in ipairs( weapons[2] ) do
		guiGridListSetItemText ( GridLists.Gunmenu2, guiGridListAddRow ( GridLists.Gunmenu2 ), 1, tostring( getWeaponNameFromID( v ) ), false, false );
	end

	guiSetVisible   ( Windows.Gunmenu,	true   );
	showCursor( true );
end

function endRound( roundplayers, lost, attwins, defwins )


	if Player.InRound then
		setGameSpeed( 0.0 );
	end

	Player.RoundLoading         = false;
	Player.InMenu				= false;
	Player.InRound              = false;

	hideRoundGUI( );

	guiSetVisible( Images.RoundEndTemplate, true );

	setTimer( function ( )
		loadEndRoundDxText( roundplayers );
		Player.ShowEndRound		= true;

		guiSetVisible( Images.RoundEndTemplate, true );
	end,
    500,
	1 );
	-- this is in a timer form to ake sure all the setElementData for kills/damage etc is all synced correctly on all clients

	if isElement( Sounds.CP ) then
		stopSound( Sounds.CP );
	end
	if isElement( Sounds.Countdown ) then
		stopSound( Sounds.CP );
	end

	showCursor( false );

	Timers.SpeedNorm = setTimer( normalizeSpeed, 50, 101 );

	local winner;
	if lost == Teams.Attackers then
		winner = Teams.Defenders;
	elseif lost == Teams.Defenders then
		winner = Teams.Attackers;
	end

	if getPlayerTeam( localPlayer ) == lost then
		Sounds.Loss = playSound( "sounds/loss.mp3" );
		stopSoundLater( Sounds.Loss, 10000 );
	elseif getPlayerTeam( localPlayer ) == winner then
		Sounds.Victory = playSound( "sounds/victory.mp3" );
		stopSoundLater( Sounds.Victory, 10000 );
	end

	local team = getPlayerTeam( localPlayer );
	for v, i in ipairs( getElementsByType( "player" ) ) do
		if getPlayerTeam( i ) ~= team then
			setElementCollidableWith( localPlayer, i, true );
		end
	end

	updateTeamScores( attwins, defwins );
end

function hideRoundGUI( )
	guiSetVisible( ProgressBar.CP,      false );
	guiSetVisible( Windows.Gunmenu,     false );
	guiSetVisible( Images.InRoundGUIBg, false );

	DXText.DefendersRoundHealth.Text  = " ";
	DXText.AttackersRoundHealth.Text  = " ";
	DXText.AttackersRoundPlayers.Text = " ";
	DXText.DefendersRoundPlayers.Text = " ";
	DXText.AttackersRoundHealth.Text  = " ";
	DXText.DefendersRoundHealth.Text  = " ";


end

function onPlayerPressEnter( key, keystate )
	if Player.ShowEndRound == true then
		Player.ShowEndRound = false;
		guiSetVisible( Images.RoundEndTemplate, false );
	end
end



function roundVariableReset( )
	Player.RoundLoading          = false;
	Player.InMenu				= false;
	Player.InRound               = false;

	guiSetVisible( Windows.Gunmenu, false );

	--hideRoundGUI( );
end

function normalizeSpeed( )
	guiSetVisible( ProgressBar.CP,      false );
	guiSetVisible( Windows.Gunmenu,     false );
	guiSetVisible( Images.InRoundGUIBg, false );

	DXText.DefendersRoundHealth.Text  = " ";
	DXText.AttackersRoundHealth.Text  = " ";
	DXText.AttackersRoundPlayers.Text = " ";
	DXText.DefendersRoundPlayers.Text = " ";

	setGameSpeed( tonumber( getGameSpeed( ) + 0.01 ) );
	if getGameSpeed( ) > 1.0 then
		setGameSpeed( 1.0 );
	end
end

function updateSpawnGui( teamindex )
	local team = teamIndexToTeam( teamindex );

	triggerServerEvent( "getSpawnGuiInformation", localPlayer, team );

end

function loadPlayerConfig( )
	Player.CameraIndex 				= 0;
	Player.CameraX 					= 0;
	Player.CameraY 					= 0;
	Player.CameraZ 					= 0;
	Player.ClassSelect    	    	= 0;
	Player.CameraDistance 			= 0;
	Player.ClassSelectPed       	= 0;
	Player.RecentDmgDealt       	= 0;
	Player.RecentDmgTaken       	= 0;
	Player.RecentPlayerDealt		= 0;
	Player.RecentPlayerTaken		= 0;
	Player.FPS						= 0;
	Player.CalculatingFPS			= 0;
	Player.PlayersSpecing			= 0;
	Player.Spectating				= 0;

	Player.Voted					= false;
	Player.CameraSpin           	= false;
	Player.RoundLoading         	= false;
	Player.InRound              	= false;
	Player.InMenu					= false;
	Player.ShowEndRound				= false;

	-- Ok, so we need to check if the player has edited his cfg file for some cfg options.

	local root = createCfg( );

	makeSureKeysExist( root );

	local cfg = xmlFindChild( root, "cfg", 0 );


	PlayerConfig.AmbientSound		= split   ( xmlNodeGetValue( xmlFindChild( cfg, "Ambient",      	0 ) ), ", " );
	PlayerConfig.HeatHaze       	= split   ( xmlNodeGetValue( xmlFindChild( cfg, "HeatHaze",     	0 ) ), ", " );
	PlayerConfig.Hud				= split   ( xmlNodeGetValue( xmlFindChild( cfg, "Hud",     			0 ) ), ", " );

	PlayerConfig.Fog				= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "Fog",          	0 ) ) );
	PlayerConfig.LoadSound      	= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "LoadSound",    	0 ) ) );
	PlayerConfig.LoadEndSound   	= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "LoadEndSound", 	0 ) ) );
	PlayerConfig.Blur				= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "Blur", 			0 ) ) );
	PlayerConfig.MaxUpload			= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "MaxUpload", 		0 ) ) );
	PlayerConfig.RoundImageAlpha	= tonumber( xmlNodeGetValue( xmlFindChild( cfg, "RoundImageAlpha",  0 ) ) );

	PlayerConfig.SlowWalk			= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "SlowWalk", 		0 ) ) );
	PlayerConfig.OrignalCtrls		= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "OrignalCtrls", 	0 ) ) );
	PlayerConfig.InteriorSounds		= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "InteriorSounds", 	0 ) ) );
	PlayerConfig.Clouds				= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "Clouds", 			0 ) ) );
	PlayerConfig.Birds				= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "Birds", 			0 ) ) );
	PlayerConfig.bikeFallOff		= tobool  ( xmlNodeGetValue( xmlFindChild( cfg, "bikeFallOff", 		0 ) ) );


	PlayerConfig.WorldProperties	= { true,     false,     false,       false }; -- don't allow editing of these, so not saved in XML.
								--      ^hovercars  ^aircars,  ^extrabunny   ^extrajump

	Teams.AttScore					= 0;
	Teams.DefScore					= 0;
	Teams.DefDmg					= 0;
	Teams.AttDmg					= 0;

	Round.CPTime 					= 0;
	Round.EndRoundDXTextPlayers 	= nil;
	Round.LoadTime					= 0;

	Sounds.CP						= 0;
	Sounds.Countdown				= 0;
	Sounds.HitSound					= 0;
	Sounds.CPCapWarning				= 0;
	Sounds.MinuteWarning			= 0;
	Sounds.SecondWarning			= 0;
	Sounds.Loss						= 0;
	Sounds.Victory					= 0;
	Sounds.Paused					= 0;

	fadeCamera		  		 ( true 				  		);
	setHeatHaze		  		 ( PlayerConfig.HeatHaze[1], PlayerConfig.HeatHaze[2], PlayerConfig.HeatHaze[3], PlayerConfig.HeatHaze[4], PlayerConfig.HeatHaze[5], PlayerConfig.HeatHaze[6], PlayerConfig.HeatHaze[7], PlayerConfig.HeatHaze[8], tobool( PlayerConfig.HeatHaze[9] ) );
	setBlurLevel	  		 ( PlayerConfig.Blur 	  		);
	setInteriorSoundsEnabled ( PlayerConfig.InteriorSounds 	);
	setCloudsEnabled		 ( PlayerConfig.Clouds			);

	toggleControl( "walk", PlayerConfig.SlowWalk ); -- it also re-sets this control in onClientRender

	setWorldSpecialPropertyEnabled( "hovercars",  PlayerConfig.WorldProperties[1] );
	setWorldSpecialPropertyEnabled( "aircars",    PlayerConfig.WorldProperties[2] );
	setWorldSpecialPropertyEnabled( "extrabunny", PlayerConfig.WorldProperties[3] );
	setWorldSpecialPropertyEnabled( "extrajump",  PlayerConfig.WorldProperties[4] );

	setAmbientSoundEnabled( "general", tobool( PlayerConfig.AmbientSound[1] ) );
	setAmbientSoundEnabled( "gunfire", tobool( PlayerConfig.AmbientSound[2] ) );

	setElementData( localPlayer, "Upload", PlayerConfig.MaxUpload );

	setFogDistance( PlayerConfig.Fog );

	setBirdsEnabled( PlayerConfig.Birds );

	guiSetAlpha( Images.InRoundGUIBg, PlayerConfig.RoundImageAlpha );

	setPedCanBeKnockedOffBike( localPlayer, PlayerConfig.bikeFallOff );

end

function makeSureKeysExist( root )
	-- Purpose: make sure we have all the client-sided .cfg needed so no errors will occur while loading a non-existant xmlnode

	local cfg = xmlFindChild( root, "cfg", 0 );

	if cfg == false then
		cfg = xmlCreateChild( root, "newroot" );
		xmlNodeSetName( cfg, "cfg" );
	end

	if xmlFindChild( cfg, "Ambient", 0 ) == false then

		local AmbientSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( AmbientSound, "Ambient" );
		xmlNodeSetValue( AmbientSound, "false, false" );

	end

	if xmlFindChild( cfg, "Fog", 0 ) == false then

		local Fog = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Fog, "Fog" );
		xmlNodeSetValue( Fog, "200" );

	end

	if xmlFindChild( cfg, "LoadSound", 0 ) == false then

		local LoadSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LoadSound, "LoadSound" );
		xmlNodeSetValue( LoadSound, "44" );

	end

	if xmlFindChild( cfg, "LoadEndSound", 0 ) == false then

		local LoadEndSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LoadEndSound, "LoadEndSound" );
		xmlNodeSetValue( LoadEndSound, "45" );

	end

	if xmlFindChild( cfg, "SlowWalk", 0 ) == false then

		local SlowWalk = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( SlowWalk, "SlowWalk" );
		xmlNodeSetValue( SlowWalk, "false" );

	end

	if xmlFindChild( cfg, "HeatHaze", 0 ) == false then

		local HeatHaze = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( HeatHaze, "HeatHaze" );
		xmlNodeSetValue( HeatHaze, "0, 0, 0, 0, 0, 0, 0, 0, false" );

	end

	if xmlFindChild( cfg, "Blur", 0 ) == false then

		local Blur = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Blur, "Blur" );
		xmlNodeSetValue( Blur, "0" );

	end

	if xmlFindChild( cfg, "OrignalCtrls", 0 ) == false then

		local OrignalCtrls = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( OrignalCtrls, "OrignalCtrls" );
		xmlNodeSetValue( OrignalCtrls, "true" );

	end

	if xmlFindChild( cfg, "InteriorSounds", 0 ) == false then

		local InteriorSounds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( InteriorSounds, "InteriorSounds" );
		xmlNodeSetValue( InteriorSounds, "false" );

	end

	if xmlFindChild( cfg, "Clouds", 0 ) == false then

		local Clouds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Clouds, "Clouds" );
		xmlNodeSetValue( Clouds, "false" );

	end

	if xmlFindChild( cfg, "Hud", 0 ) == false then

		local Hud = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Hud, "Hud" );
		xmlNodeSetValue( Hud, "true, false, true, true, false, true, false, true, false, true, true, true, true" );

	end

	if xmlFindChild( cfg, "MaxUpload", 0 ) == false then

		local upload = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( upload, "MaxUpload" );
		xmlNodeSetValue( upload, "50000" );

	end

	if xmlFindChild( cfg, "Birds", 0 ) == false then

		local Birds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Birds, "Birds" );
		xmlNodeSetValue( Birds, "false" );

	end

	if xmlFindChild( cfg, "RoundImageAlpha", 0 ) == false then

		local RoundImageAlpha = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( RoundImageAlpha, "RoundImageAlpha" );
		xmlNodeSetValue( RoundImageAlpha, "0.75" );

	end

	if xmlFindChild( cfg, "bikeFallOff", 0 ) == false then

		local bikeFallOff = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( bikeFallOff, "bikeFallOff" );
		xmlNodeSetValue( bikeFallOff, "false" );

	end

	xmlSaveFile( root );

end

function createCfg( )

	local root;
	if not fileExists( "cfg_main.xml" ) then
		root = xmlCreateFile( "cfg_main.xml", "root" );

		local cfg = xmlCreateChild( root, "newroot" );
		xmlNodeSetName( cfg, "cfg" );

		local AmbientSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( AmbientSound, "Ambient" );
		xmlNodeSetValue( AmbientSound, "false, false" );

		local Fog = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Fog, "Fog" );
		xmlNodeSetValue( Fog, "200" );

		local LoadSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LoadSound, "LoadSound" );
		xmlNodeSetValue( LoadSound, "44" );

		local LoadEndSound = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( LoadEndSound, "LoadEndSound" );
		xmlNodeSetValue( LoadEndSound, "45" );

		local SlowWalk = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( SlowWalk, "SlowWalk" );
		xmlNodeSetValue( SlowWalk, "false" );

		local HeatHaze = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( HeatHaze, "HeatHaze" );
		xmlNodeSetValue( HeatHaze, "0, 0, 0, 0, 0, 0, 0, 0, false" );

		local Blur = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Blur, "Blur" );
		xmlNodeSetValue( Blur, "0" );

		local OrignalCtrls = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( OrignalCtrls, "OrignalCtrls" );
		xmlNodeSetValue( OrignalCtrls, "true" );

		local InteriorSounds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( InteriorSounds, "InteriorSounds" );
		xmlNodeSetValue( InteriorSounds, "false" );

		local Clouds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Clouds, "Clouds" );
		xmlNodeSetValue( Clouds, "false" );

		local Hud = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Hud, "Hud" );
		xmlNodeSetValue( Hud, "true, false, true, true, false, true, false, true, false, true, true, true, true" );

		local upload = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( upload, "MaxUpload" );
		xmlNodeSetValue( upload, "50000" );

		local Birds = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( Birds, "Birds" );
		xmlNodeSetValue( Birds, "false" );

		local RoundImageAlpha = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( RoundImageAlpha, "RoundImageAlpha" );
		xmlNodeSetValue( RoundImageAlpha, "0.75" );

		local bikeFallOff = xmlCreateChild( cfg, "newchild" );
		xmlNodeSetName( bikeFallOff, "bikeFallOff" );
		xmlNodeSetValue( bikeFallOff, "false" );

		--[[local WorldProperties = xmlCreateChild( cfg, "newchild" );  -- Removed due to abuse.
		xmlNodeSetName( WorldProperties, "WorldProperties" );
		xmlNodeSetValue( WorldProperties, "true, false, false, false" );]]

		xmlSaveFile( root );
	else
		root = xmlLoadFile( "cfg_main.xml" );
	end

	return root;

end

function showProperHudComponents( )

	showPlayerHudComponent( "all", true );

	showPlayerHudComponent( "ammo", 		tobool( PlayerConfig.Hud[1] ) );
	showPlayerHudComponent( "area_name", 	tobool( PlayerConfig.Hud[2] ) );
	showPlayerHudComponent( "armour", 		tobool( PlayerConfig.Hud[3] ) );
	showPlayerHudComponent( "breath", 		tobool( PlayerConfig.Hud[4] ) );
	showPlayerHudComponent( "clock", 		tobool( PlayerConfig.Hud[5] ) );
	showPlayerHudComponent( "health", 		tobool( PlayerConfig.Hud[6] ) );
	showPlayerHudComponent( "money", 		tobool( PlayerConfig.Hud[7] ) );
	showPlayerHudComponent( "radar", 		tobool( PlayerConfig.Hud[8] ) );
	showPlayerHudComponent( "vehicle_name", tobool( PlayerConfig.Hud[9] ) );
	showPlayerHudComponent( "weapon", 		tobool( PlayerConfig.Hud[10] ) );
	showPlayerHudComponent( "radio", 		tobool( PlayerConfig.Hud[11] ) );
	showPlayerHudComponent( "wanted", 		tobool( PlayerConfig.Hud[12] ) );
	showPlayerHudComponent( "crosshair", 	tobool( PlayerConfig.Hud[13] ) );

end

function showElementHealthBar( player, element )

	local Width, Height = guiGetScreenSize( );

	local x_, y_, z = getElementPosition( element );
	local x2, y2, z2 = getPedBonePosition( player, 2 );

	if ( isElementOnScreen( element ) and isLineOfSightClear( x_, y_, z, x2, y2, z2, true, true, false, true, false ) and getDistanceBetweenPoints3D( x_, y_, z, x2, y2, z2 ) < 50 ) or getPedOccupiedVehicle( player ) == element then
		local x, y = getScreenFromWorldPosition( x_, y_, z );
		if x then
			if  DXRectangle.HealthBarBg						== nil then
				DXRectangle.HealthBarBg						= {};
				DXRectangle.HealthBar						= {};
			end
			if  DXRectangle.HealthBarBg[element] 			== nil then
				DXRectangle.HealthBarBg[element] 			= {};

				DXRectangle.HealthBarBg[element].Width		= 100;
				DXRectangle.HealthBarBg[element].Height		= 10;
				DXRectangle.HealthBarBg[element].Color		= tocolor( 0, 0, 0, 120 );
				DXRectangle.HealthBarBg[element].PostGUI 	= false;


				DXRectangle.HealthBar[element] 				= {};

				DXRectangle.HealthBar[element].Height		= 6;
				DXRectangle.HealthBar[element].Color		= tocolor( 0, 255, 0, 100 );
				DXRectangle.HealthBar[element].PostGUI 		= true;

				-- credits to 50p for health bar positions.
			end

			DXRectangle.HealthBar[element].Width			= ( getElementHealth( element ) / 10 ) - 1;

			DXRectangle.HealthBarBg[element].X 				= x - 30;
			DXRectangle.HealthBarBg[element].Y 				= y - 20;
			DXRectangle.HealthBar[element].X 				= x - 28;
			DXRectangle.HealthBar[element].Y 				= y - 18;

			dxDrawRectangle( DXRectangle.HealthBarBg[element].X, DXRectangle.HealthBarBg[element].Y, DXRectangle.HealthBarBg[element].Width, DXRectangle.HealthBarBg[element].Height, DXRectangle.HealthBarBg[element].Color, DXRectangle.HealthBarBg[element].PostGUI );
			dxDrawRectangle( DXRectangle.HealthBar[element].X, DXRectangle.HealthBar[element].Y, DXRectangle.HealthBar[element].Width, DXRectangle.HealthBar[element].Height, DXRectangle.HealthBar[element].Color, DXRectangle.HealthBar[element].PostGUI );
		end
	end
end

function tobool(v)
    return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

function teamIndexToTeam( teamindex )
	if 		teamindex == 0 then return "Auto-Assign"
	elseif  teamindex == 1 then return "Attackers"
	elseif 	teamindex == 2 then return "Defenders"
	else return nil end
end

function round(num)
	if not isNumeric( num ) then
		outputDebugString( "round() tried to convert '" .. num .. "' to an integer and failed.", 1 );
		return;
	end
	return math.floor( tonumber( num ) );
end

function isNumeric(a)
	if tonumber(a) ~= nil then
		return true;
	else return false end
end

function showCredits( playerSource, cmd, ... )
	guiSetVisible( Memos.Credits,   true );
	guiSetVisible( Buttons.Credits, true );

	showCursor( true );
end

function onCreditsClose( button )
	if button == "left" then
		guiSetVisible( Memos.Credits,   false );
		guiSetVisible( Buttons.Credits, false );

		showCursor( false );
	end
end


function playerDeath( killer, weapon, bodypart )
	if Player.InRound and isElement( source ) then
		setElementData( source, "round.health", "Dead" );
		if isElement( killer ) then
			setElementData( killer, "round.dmg", round( getElementData( killer, "round.dmg" ) + getElementData( source, "Health", false ) ) );
		end
	end
	triggerEvent("showDamageGui", source, killer, weapon, bodypart, getElementData( source, "Health", false ) );
end

function updateGuiText( )
	if guiCheckBoxGetSelected( Checkboxes.Spec ) and Player.Spectating ~= nil then
		local speed;
		if not isPedInVehicle( Player.Spectating ) then
			speed = getElementSpeed( Player.Spectating );
		else
			speed = getElementSpeed( getPedOccupiedVehicle( Player.Spectating ) );
		end
		guiSetText( Labels.SpecInfo, "Team: " .. getTeamName( getPlayerTeam( Player.Spectating ) ) .. "\nFPS: " .. Player.FPS .. "\nHealth: " .. round( getElementHealth( Player.Spectating ) ) .. "\nArmor: " .. round( getPedArmor( Player.Spectating ) ) .. "\nSpeed: " .. round( speed ) .. " km/h" );

		guiSetText( Labels.SpecWeps, "" );
		local wep;
		for i=1, 11 do
			wep = getPedWeapon( Player.Spectating, i );
			if wep ~= 0 then
				guiSetText( Labels.SpecWeps, guiGetText( Labels.SpecWeps ) .. getWeaponNameFromID( wep ) ..  " (" .. getPedTotalAmmo ( Player.Spectating, i ) .. ") (" .. getPedAmmoInClip( Player.Spectating, i ) .. ")\n" );
			end
		end
		showPlayerHudComponent( "all", false );
	elseif isTimer( Timers.Spec ) then
		showProperHudComponents( );
		killTimer( Timers.Spec );
	end
end

function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.61 * 100
		end
	else
		return false
	end
end

function specGuiShow( type, playerspecing )

	if type == 1 then
		guiSetVisible( Windows.Spec, true );
		Timers.Spec	= setTimer( updateGuiText, 500, 0 );
		Player.Spectating = playerspecing;
		updateGuiText( );
	elseif type == 2 then
		Player.PlayersSpecing = Player.PlayersSpecing + 1;
		if Player.PlayersSpecing == 1 then
			guiSetText( Labels.SpecingYou, "Spectating you\n - " .. getPlayerName( playerspecing ) );
			guiSetVisible( Labels.SpecingYou, true );
		else guiSetText( Labels.SpecingYou, guiGetText( Labels.SpecingYou ) .. "\n - " .. getPlayerName( playerspecing ) ) end
	end

end

function hideGuiShow( type )
	if type == 1 then
		if Player.Spectating ~= nil then
			guiSetVisible( Windows.Spec, false );
			Player.Spectating = nil;
		end
	elseif type == 2 then
		if Player.PlayersSpecing-1 ~= 0 then
			Player.PlayersSpecing = Player.PlayersSpecing - 1;
			guiSetText( Labels.SpecingYou, "Spectating you" );
			for v, i in ipairs( getElementsByType( "player" ) ) do
				if getElementData( i, "spectating") == localPlayer then
					guiSetText( Labels.SpecingYou, guiGetText( Labels.SpecingYou ) .. "\n - " .. getPlayerName( i ) );
				end
			end
		else guiSetVisible( Labels.SpecingYou, false ) end
	end
end

function startVote( cmd, gametype, id )

	setElementData( localPlayer, "votedtype", gametype );
	setElementData( localPlayer, "votedid",   id	   );

	showVotedGui( gametype, id );

	triggerServerEvent( "showAllVoteGui", getRootElement( ) );

-- Gridlists.Vote
end

function showVotedGui( gametype, id )

	guiGridListClear( GridLists.Vote );

	for v, i in ipairs( getElementsByType( "player" ) ) do
		local gametype, id = getElementData( i, "votedtype" ), getElementData( i, "votedid" );

		if gametype ~= nil and id ~= nil then

			local row = guiGridListAddRow( GridLists.Vote );

			guiGridListSetItemText( GridLists.Vote, row, 1, gametype .. "-" .. id, false, false );

			castVote( tostring( row + 1 ), "down" );
		end
	end

	guiSetVisible( GridLists.Vote, true );

end

function castVote( keystr, state, ... )

	local rowidx = tonumber( keystr ) - 1;

	if guiGridListGetRowCount( GridLists.Vote ) >= rowidx and Player.Voted == false then
		guiGridListSetSelectedItem( GridLists.Vote, rowidx, 1, false );
		local votes = 0, data;
		for i=0, rowidx do
			data = getElementData( localPlayer, "rowidx" );
			if not data then data = 0; end
			if tonumber(data) == rowidx then
				setElementData( localPlayer, "rowidx", data + 1 );
			end
		end

		guiGridListSetItemText( GridLists.Vote, rowidx, 2, tostring( data ), false, true );

		Player.Voted = true;

		local players = getElementsByType( "player" );

		for v, i in ipairs( players ) do
			if getElementData( i, "rowidx" ) then
				votes = votes + 1;
				if votes > #players / 2 then
					triggerServerEvent( "startRound", localPlayer, getElementData( localPlayer, "votedtype" ), getElementData( localPlayer, "votedid" ) ); --start base/arena
				end
			end
		end
	end
end

function updateTeamScores( attscore, defscore )
	Teams.AttScore, Teams.DefScore = attscore, defscore;

	DXText.Score.Attackers.Text  	= getTeamName( Teams.Attackers );
	DXText.Score.Defenders.Text		= getTeamName( Teams.Defenders );

	DXText.Score.RealScore.Text		= Teams.AttScore .. " - " .. Teams.DefScore;

	local r, g, b		  			= getTeamColor( Teams.Attackers );
	local a               			= 255;
	DXText.Score.Attackers.Color	= tocolor( r, g, b, a );

	r, g, b 						= getTeamColor( Teams.Defenders );
	a								= 255;
	DXText.Score.Defenders.Color	= tocolor( r, g, b, a );


end

function stopSoundLater( sound, interval )
	setTimer(
		function()
			stopSound( sound );
		end,
		interval,
		1 );
end

function roundPaused( )

	fadeCamera( false, 2 );
	guiSetVisible( Images.Paused, true );

end

function roundunPaused( )

	fadeCamera( true, 2 );
	guiSetVisible( Images.Paused, false );

end

function onVehicleEntered( )
	-- source = vehicle created.

	for v, i in ipairs( getElementsByType( "player" ) ) do
		setElementCollidableWith( source, i, false );
	end
	for v, i in ipairs( getElementsByType( "vehicle" ) ) do
		setElementCollidableWith( source, i, false );
	end
end

function onVehicleExit( )
	-- source = vehicle created.

	for v, i in ipairs( getElementsByType( "player" ) ) do
		setElementCollidableWith( source, i, true );
	end
	for v, i in ipairs( getElementsByType( "vehicle" ) ) do
		setElementCollidableWith( source, i, true );
	end
end

function vehicleCollision( element )
	local theType = type( element );
	if( theType == "player" or theType == "vehicle" ) then
		-- okay, the collidable with stuff didn't sync previously.
		-- maybe they connected after the vehicle was entered?
		-- lets loop through and make sure its synced for all players
		for v, i in ipairs( getElementsByType( "player" ) ) do
			setElementCollidableWith( source, i, false );
		end
		for v, i in ipairs( getElementsByType( "vehicle" ) ) do
			setElementCollidableWith( source, i, false );
		end
	end
end

function isPedOnFoot( element )

	return not isPedInVehicle( element ) and not isPedDead( element );

end
function sync( )
	local vars = {};

	vars.ar = getPedArmor( localPlayer );
	vars.hp = getElementHealth( localPlayer );

	vars.skin = getElementModel( localPlayer );

	vars.interior = getElementInterior( localPlayer );

	vars.frozen = isElementFrozen( localPlayer );
	vars.team = getPlayerTeam( localPlayer );
	vars.wlevel = getPlayerWantedLevel( localPlayer );

	vars.dimension = getElementDimension( localPlayer );

	vars.money = getPlayerMoney( localPlayer );

	vars.choking = isPedChoking( localPlayer );
	vars.fire = isPedOnFire( localPlayer );
	vars.headless = isPedHeadless( localPlayer );

	vars.orig = getPedWeaponSlot( localPlayer );

	vars.weps = {};

	vars.ammo = {};

	for i=1, 11 do
		local wep = getPedWeapon( localPlayer, i );
		if wep ~= 0 then
			vars.weps[i] = wep;
			vars.ammo[i] = getPedTotalAmmo( localPlayer, i );
		end
	end

	vars.x, vars.y, vars.z = getElementPosition( localPlayer );
	vars.vx, vars.vy, vars.vz = getElementVelocity( localPlayer );
	vars.rx, vars.ry, vars.rz = getElementRotation( localPlayer );

	if Player.CanSync ~= false then
		triggerServerEvent( "finishSyncing", localPlayer, vars);
	end

	Player.CanSync = false;

	setTimer( setCanSync, 1000, 1 );

end

function setCanSync( )
	Player.CanSync = true;
end


addCommandHandler( "sync", 	  sync		  );
addCommandHandler( "s", 	  sync		  );
addCommandHandler( "rsp", 	  sync		  );
addCommandHandler( "vote",    startVote   );
addCommandHandler( "credits", showCredits );

addEvent( "updateRoundLoadText", true );
addEvent( "roundLoadUpdate", 	 true );
addEvent( "guiSpawnUpdate",    	 true );
addEvent( "roundLoadFinish",     true );
addEvent( "roundUpdate",         true );
addEvent( "onRoundEnd",          true );
addEvent( "resetRoundVariables", true );
addEvent( "showDamageGui", 		 true );
addEvent( "showGunMenu",		 true );
addEvent( "showSpecGui",		 true );
addEvent( "hideSpecGui",		 true );
addEvent( "votedGui",			 true );
addEvent( "showTheProperHud",    true );
addEvent( "roundPaused",    	 true );
addEvent( "roundunPaused",    	 true );
addEvent( "updateTeamScore",   	 true );
addEvent( "onVehicleCreated",    true );

addEventHandler( "onClientPreRender",      		getRootElement( ), 						   		clientPreRender 	  	);
addEventHandler( "onClientRender",         		getRootElement( ),                          	clientRender          	);
addEventHandler( "onClientPlayerWasted",   		getRootElement( ),                          	playerDeath           	);
addEventHandler( "onClientVehicleCollision", 	getRootElement( ),								vehicleCollision		);

addEventHandler( "roundLoadUpdate",        		getRootElement( ), 						   		spinPlayerCamera	  	);
addEventHandler( "updateRoundLoadText",    		getRootElement( ), 						  		onUpdateRoundLoadText 	);
addEventHandler( "guiSpawnUpdate", 	   	   		getRootElement( ), 						   		guiSpawnUpdate 	  	  	);
addEventHandler( "roundLoadFinish",        		getRootElement( ),                          	loadFinish            	);
addEventHandler( "roundUpdate",            		getRootElement( ),                          	roundUpdate           	);
addEventHandler( "onRoundEnd",             		getRootElement( ),                          	endRound             	);
addEventHandler( "resetRoundVariables",    		getRootElement( ),                          	roundVariableReset    	);
addEventHandler( "showDamageGui",          		getRootElement( ),                          	damageGui			  	);
addEventHandler( "showGunMenu",            		getRootElement( ),						   		showGunMenu			  	);
addEventHandler( "showSpecGui",            		getRootElement( ),						   		specGuiShow			  	);
addEventHandler( "hideSpecGui",            		getRootElement( ),						   		hideGuiShow			  	);
addEventHandler( "showTheProperHud",       		getRootElement( ),                              showProperHudComponents );
addEventHandler( "votedGui",			   		getRootElement( ),						   		showVotedGui		  	);
addEventHandler( "roundPaused",	   		   		getRootElement( ),						   		roundPaused			  	);
addEventHandler( "roundunPaused",	   	   		getRootElement( ),						   		roundunPaused		  	);
addEventHandler( "updateTeamScore",	   	   		getRootElement( ),						   		updateTeamScores	  	);
addEventHandler( "onClientVehicleEnter",   		getRootElement( ),                              onVehicleEntered		);
addEventHandler( "onClientVehicleExit",   		getRootElement( ),                              onVehicleExit			);
addEventHandler( "onClientResourceStart",  		getResourceRootElement( getThisResource( ) ),  	clientScriptLoad	  	);


bindKey ( "enter",  "down", onPlayerPressEnter );
bindKey ( "mouse1", "down", onPlayerPressEnter );

bindKey ( "1", "down", castVote );
bindKey ( "2", "down", castVote );
bindKey ( "3", "down", castVote );
bindKey ( "4", "down", castVote );
bindKey ( "5", "down", castVote );
bindKey ( "6", "down", castVote );
bindKey ( "7", "down", castVote );
bindKey ( "8", "down", castVote );
bindKey ( "9", "down", castVote );
