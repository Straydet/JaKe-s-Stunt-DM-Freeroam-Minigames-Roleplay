/*

						  ( FunGaming Stunt/Freeroam )
					JaKe's Stunt/DM/Freeroam/Minigames/Roleplay
								by Jake Hero
						Scripted on November 22, 2014
						          (Build 1)

//SCRIPTED FROM SCRATCH

Changelog for Build 1:
• Fungaming: Checkpoint System (from FunGaming - scripted by Jake Hero, improved)
• Improved the colors for the player.
• The script is completely neat and better than FunGaming.
• FunGaming: Converted from YSI to SQLite.
• Scripted Admin System, NEAT!
• Fungaming: VIP System converted to one rank instead of three.
• Helper System implemented.
• Two message system, One for players and two for helpers and admins.
• Fungaming: More improved and better Money Bag system, Fixed bugs (by TheKiller, improved by Jake)
• Removed cookies sytem.
• Premium Points implemented, They can be obtained from events, given by an admin or donate $2 or more to get PP.
//PP is spent on expensive, high end quality stuffs such as Jetpack and more.
• Fungaming: Added more better and accurate vehicle spawn system.
• Fungaming: Fixed the god mode system.
• Implemented more, better and accurate stunts, parkours and others maps.
• Fungaming: Fixed boosting and nos when holding, It now gives you unlimited until you released the KEY_FIRE.
• Fungaming: Instead of symbol, The Admin and VIP chat has been transformed to a command.
• Timestamp system for the VIP System.
• Transformed the /skin to a selecting textdraw.
• Improved /stats - Added 'Premium Inventory' system.
• Improved admin duty system.
• Unique things added.
• Description System implemented.
• Math System by Zezombia and modified by JaKe.
• Accurate and trustable Server Statistics System (/serverstats)
// Anti Weapon Hack was implemented on BETA 1 and was removed prioer due to bug.
• Anti Ban Evading System improved.
• More improved and more accurate Private Messaging System.
• Unique Teleport Textdraw.
• Fungaming: Added new checkpoints and moneybag locations.
• Punishment Timer is now more accurate than ever before!
• Fixed most of the mess in the script, Made it more accurate and stuffs.
• Added more vehicles around the teleport locations.
• Accurate Anti-Server Ad (Website Ad)
• Unique Jail-Duel Map for /jail and /duel (Credits to andrewgrob)
• Modified version of a_zone of Cueball (Credits to Cueball and JaKe for modification.)
//BETA: We had Find the Rhino previously / Find the Bullet which was removed.
• House System (Unreleased version of JakHouse.)
• Spectate System (Based upon ladmin)
• Duel System implemented (Credits to Sneaky and modified by JaKe)
• Minigun Deathmatch by Mike (SAMP Tester, Modified by JaKe)
• Sniper Deathmatch by Mike (SAMP Tester, Modified by JaKe)
• Player Record System, Credits to Roach (Modified by JaKe)
• Built-In Animation System, Credits goes to JaKe (based upon gl_action.pwn of SAMP Package)
• Horseshoe System, Credits goes to JaKe.
• Built-In Away from Keyboard System, Credits goes to JaKe.
• Shop added, Credits goes to JaKe.
• Patch fixes for the BETA 1.
• Anti Bike Fall System, Credits to Zezombia.
• Vehicle Restrictions for Vehicle Spawning (Rhinos and others are forbidden for non-admins)
• RC Entering/Exiting System, Credits to Hiddos and Credits to JaKe for modification.
• Random Messages implemented, Credits to JaKe.
• Audio Stream availability on the script, Credits to JaKe.
• Christmas Features has been added, toggable - Credits to JaKe.
• Save Skin system has been implemented (Again based of from ladmin)
• Radio System, Credits to BlueRey.
• Don't Get Wet minigame by iMonk3y, Heavily modified by JaKe.
• Open Freeroam Roleplay Mode, Credits to JaKe.

*/

//============================================================================//
//                                                                            //
//============================================================================//

//Includes

#include        				<a_samp>
#include                        <zcmd>
#include                        <sscanf2>
#include                        <foreach>
#include                        <streamer>
#include                        <dini>

//Pragmas
#pragma                         dynamic                     9450

//Native

native WP_Hash(buffer[], len, const str[]); //Y_Less' Whirlpool

//Macro

//Credits to Darren - Y_Less / Darren's method converting negative to postive and vice versa
#define abs(%1) \
        (((%1) < 0) ? (-(%1)) : ((%1)))

#define LoginCheck(%1) if(User[%1][accountLogged] == false) return SendClientMessage(%1, -1, "» "red"You must be logged in to use this command.")
#define SpawnCheck(%1) if(GetPlayerState(%1) != 1 && GetPlayerState(%1) != 2 && GetPlayerState(%1) != 3) return SendClientMessage(%1, -1, "» "red"You cannot use this command whilist you are not spawned.")
#define PassengerCheck(%1) if(GetPlayerState(%1) == PLAYER_STATE_PASSENGER) return SendClientMessage(%1, -1, "» "red"You cannot use this command while you are riding in a vehicle as a passenger.")

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define MoneyBagDelay(%1,%2,%3,%4) (%1*3600000)+(%2*60000)+(%3*1000)+%4
#define MoneyBagCash ((random(30)+20)*10000)
#define MB_DELAY MoneyBagDelay(0, 6, 0, 0)

#define Loop(%0,%1) for(new %0 = 0; %0 != %1; %0++)

#define db_query_set(%0,%1,%2,%3)\
                do\
                {\
                        format(%1, sizeof(%1), (%2), %3);\
                        db_free_result(db_query(%0, %1));\
                }\
                while ( False )

#define db_query_get(%0,%1,%2,%3)\
                do\
                {\
                        format(%1, sizeof(%1), "SELECT `%s` FROM `records`", %3);\
                        db_get_field(db_query(%0, %1), 0, %2, sizeof(%2) );\
                        db_free_result(db_query(%0, %1));\
                }\
                while ( False )

// File Path

#define             			HOUSE_PATH                  "server/data/houses/house_%d.ini"
#define             			USER_PATH                   "server/data/user/%s.ini"

// Configuartions

#define                         CHRISTMAS_SPIRIT            false
//If false, disables all the christmas features.

#if CHRISTMAS_SPIRIT == true
	#define 					MAX_SNOW_OBJECTS   			8
	#define 					UPDATE_INTERVAL     		750
#endif

#define             			MAX_HOUSE_NAME              256
#define             			MAX_HOUSES                  350

#define             			FREEZE_LOAD                 true
//If enable, Freezes you once entered the house, freezes you aswell once exited the house
//The freeze lifts off in 5 seconds, depends on FREEZE_TIME

#define             			FREEZE_TIME                 4   //In seconds

#define             			FORCE_SPAWNHOME             false
//Once the FORCE_SPAWNHOME is set to true, a timer will be run for 2.5 seconds when you spawn.
//Once that timer is called, Player will be forced spawn in his home if he has the spawn settings on.
//This define is created as the spawnhome feature we had doesn't work, as instead of spawning at home, it spawns at the gamemode's spawnpoint.

//You can change this [Just make sure you know what you are doing].

#define             			SALE_PICKUP                 1273
#define             			NOTSALE_PICKUP              1272
#define 						NOTSALE_ICON         		32
#define 						SALE_ICON            		31

#define             			STREAM_DISTANCES            100.0
//Do not make it higher, or else it will conflict with the other stream objects etc.

#define 						ADMIN_SPEC_TYPE_NONE 		0
#define 						ADMIN_SPEC_TYPE_PLAYER 		1
#define 						ADMIN_SPEC_TYPE_VEHICLE 	2

#define                         VERSION                     "JaKe (Build 1)"
#define                         S_V                         "0.3z"
#define                         S_H         				"["#S_V"] JaKe's FuN Server <Multiple Modes> (b1)"

#define                         _DB_                        "server/data/users/user.db"
#define                         _LOG_                       "server/data/logs/"

#define                         GM_TIMERS                   100
#define 						MAX_ZONE_NAME 				28

#define 						COLOR_ME	 				0xC2A2DAAA
#define 						COLOR_OOC 					0xE0FFFFAA
#define 						COLOR_GRAD1 				0xB4B5B7FF
#define 						COLOR_GRAD2 				0xBFC0C2FF
#define 						COLOR_GRAD3 				0xCBCCCEFF
#define 						COLOR_GRAD4 				0xD8D8D8FF
#define 						COLOR_GRAD5 				0xE3E3E3FF
#define 						COLOR_GRAD6 				0xF0F0F0FF
#define 						COLOR_RED               	0xFF0000FF
#define 						COLOR_GREEN 				0x33AA33AA
#define 						COLOR_YELLOW            	0xFFFF00FF
#define 						COLOR_GREY         		 	0xAFAFAFAA
#define 						COLOR_ORANGE        		0xFF8000C8
#define 						COLOR_LIGHTBLUE         	0x33CCFFAA
#define 						COLOR_LIGHTRED         		0xFF6347AA
#define 						COLOR_NEWB	         		0x7DAEFFAA
#define 						COLOR_PURPLE            	0xD526D9FF
#define 						COLOR_LIGHTGREEN        	0x00FF00FF
#define 						COLOR_PINK              	0xFF80FFFF
#define 						COLOR_WHITE         		0xFFFFFFFF

#define                         purple                      "{D526D9}"
#define                         lightgreen                  "{00FF00}"
#define                         pink                        "{FF80FF}"
#define 						green                   	"{33AA33}"
#define 						red                     	"{FF0000}"
#define 						yellow                  	"{FFFF00}"
#define 						white                   	"{FFFFFF}"
#define                 		grey                        "{AFAFAF}"
#define                         newb                        "{7DAEFF}"
#define                         orange                      "{FF8000}"
#define                         lightred                    "{FF6347}"
#define                         lightblue                   "{33CCFF}"

#define                         N                           69
#define                         DIALOG_REGISTER             N+1
#define                         DIALOG_LOGIN                N+2
#define                         DIALOG_CMDS                 N+3
#define                         DIALOG_TELE                 N+4
#define                         DIALOG_PPSHOP               N+5
#define                         DIALOG_ACMDS                N+6
#define                         DIALOG_HCMDS                N+7
#define                         DIALOG_PCMDS                N+8
#define                         DIALOG_NAME                 N+9
#define                         DIALOG_PRCMDS               N+10
#define                         DIALOG_COLORS               N+11
#define             			DIALOG_HNAME                N+12
#define             			DIALOG_HPRICE               N+13
#define              			DIALOG_HSTOREC              N+14
#define             			DIALOG_WCASH                N+15
#define             			DIALOG_HSTORE               N+16
#define             			DIALOG_HWORLD               N+17
#define             			DIALOG_HINTERIOR            N+18
#define             			DIALOG_HSPAWN               N+19
#define             			DIALOG_HMENU                N+20
#define                         DIALOG_SHOP                 N+21
#define                         DIALOG_NAME2                N+22
#define                         DIALOG_RADIOS               N+23
#define                         DIALOG_MUSICS               N+24

#define isodd(%1) \
	((%1) & 0x01)

#define iseven(%1) \
	(!isodd((%1)))

#define 						ALL_PLAYERS 				100
#define 						MAX_SLOTS 					54

//Forwards
forward                         Wait();
forward                         Maths();
forward                         EndMaths();
forward                         Anticheat();
forward                         Checkpoint();
forward                         BeginReaction();
forward                         BeginMaths();
forward                         Reactions();
forward 						EndReactions();
forward 						MoneyBag();
forward                         Heartbeat();
forward                         GamePlay(playerid);
forward                         UpdatePlayer();
forward 						SpeedUp(object, Float:x, Float:y, Float:z);
forward 						RespawnPlayer(player);
forward 						MinigameWinner(player);
forward 						MinigameCountdown();
forward 						MinigameUpdate();
forward 						EndMinigame();

//Variables

new radiolist[][][] =
{
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=9815", "Reggae"},
    {"http://europafm.radio.fr/", "Europe FM"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=35999", "Rock International FM"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=108251", "Dubstep FM"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=1377200", "Electronic"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=429606", "HardStyle"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=32999", "R&B"},
    {"http://yp.shoutcast.com/sbin/tunein-station.pls?id=3093517", "Gay FM"},
    {"http://83.169.60.42:80","DEFJAY"}
};

#if CHRISTMAS_SPIRIT == true
	new bool:snowOn[MAX_PLAYERS char],
			snowObject[MAX_PLAYERS][MAX_SNOW_OBJECTS],
			updateTimer[MAX_PLAYERS char]
	;
#endif

new bool:Minigamer_[ALL_PLAYERS char];
new bool:VIEW_FROM_ABOVE;
new inProgress, uTimer;
new Objects_[1][MAX_SLOTS];
new pWeaponData[ALL_PLAYERS][13];
new pSavedAmmo[ALL_PLAYERS][13];
new Float:pCoords[ALL_PLAYERS][3];
new pInterior[ALL_PLAYERS];

new Iterator:_Minigamer<MAX_SLOTS>;
new Iterator:_Objects<MAX_SLOTS>;

new pReadyText[4][64] =
{
	"~n~ ~n~ ~n~ ~y~stand by...",
	"~n~ ~n~ ~n~ ~y~get Ready!",
	"~n~ ~n~ ~n~ ~y~are you ready?",
	"~n~ ~n~ ~n~ ~y~ready to get wet?"
};

new pFellOffText[5][28] =
{
	"~n~ ~r~hosed",
	"~n~ ~r~all wet",
	"~n~ ~r~no swimming",
	"~n~ ~r~you're drowning!",
	"~n~ ~r~water... baaad!"
};

new Float:gCoords[MAX_SLOTS][3] = {

	{ -5309.198120,-199.052383,22.593704 },
	{ -5309.198120,-195.786071,22.593704 },
	{ -5309.198120,-192.510620,22.593704 },
	{ -5309.198120,-189.250564,22.593704 },
	{ -5309.198120,-185.987960,22.593704 },
	{ -5309.198120,-182.727081,22.593704 },
	{ -5309.198120,-179.463394,22.593704 },
	{ -5309.198120,-176.205261,22.593704 },
	{ -5304.841796,-176.205261,22.593704 },
	{ -5304.841796,-179.468795,22.593704 },
	{ -5304.841796,-182.737884,22.593704 },
	{ -5304.841796,-185.989654,22.593704 },
	{ -5304.841796,-189.259185,22.593704 },
	{ -5304.841796,-192.518615,22.593704 },
	{ -5304.841796,-195.785491,22.593704 },
	{ -5304.841796,-199.054733,22.593704 },
	{ -5300.489990,-199.054733,22.593704 },
	{ -5300.489990,-195.782165,22.593704 },
	{ -5300.489990,-192.531250,22.593704 },
	{ -5300.489990,-189.274765,22.593704 },
	{ -5300.489990,-186.003005,22.593704 },
	{ -5300.489990,-182.735229,22.593704 },
	{ -5300.489990,-179.471069,22.593704 },
	{ -5300.489990,-176.208007,22.593704 },
	{ -5296.138061,-176.208007,22.593704 },
	{ -5296.138061,-179.479248,22.593704 },
	{ -5296.138061,-182.744735,22.593704 },
	{ -5296.138061,-186.002944,22.593704 },
	{ -5296.138061,-189.274505,22.593704 },
	{ -5296.138061,-192.533691,22.593704 },
	{ -5296.138061,-195.788970,22.593704 },
	{ -5296.138061,-199.048782,22.593704 },
	{ -5291.776000,-199.050140,22.593704 },
	{ -5291.776000,-195.790634,22.593704 },
	{ -5291.776000,-192.542922,22.593704 },
	{ -5291.776000,-189.277542,22.593704 },
	{ -5291.776000,-186.013275,22.593704 },
	{ -5291.776000,-182.742355,22.593704 },
	{ -5291.776000,-179.475021,22.593704 },
	{ -5291.776000,-176.215805,22.593704 },
	{ -5287.432250,-176.215805,22.593704 },
	{ -5287.432250,-179.485168,22.593704 },
	{ -5287.432250,-182.739608,22.593704 },
	{ -5287.432250,-186.016723,22.593704 },
	{ -5287.432250,-189.277816,22.593704 },
	{ -5287.432250,-192.539001,22.593704 },
	{ -5287.432250,-195.796325,22.593704 },
	{ -5287.432250,-199.053771,22.593704 },
	{ -5287.431274,-202.320648,22.593704 },
	{ -5291.781616,-202.320648,22.593704 },
	{ -5296.136718,-202.320648,22.593704 },
	{ -5300.493652,-202.320648,22.593704 },
	{ -5304.848876,-202.320648,22.593704 },
	{ -5309.201660,-202.320648,22.593704 }
};

new Act[MAX_PLAYERS];
new InCar[MAX_PLAYERS];
new WhatCar[MAX_PLAYERS];

new g_Reason[MAX_PLAYERS][128];
new g_AFK[MAX_PLAYERS];

enum Horses
{
	Float:hx,
	Float:hy,
	Float:hz,
	order,
	hpickup
}
new hcord[][Horses] =
{
	{2011.8767,1544.7483,9.4787,0,0},
	{2323.7659,1283.2438,97.5738,2,1},
	{1432.0463,2751.2932,19.5234,3,2},
	{-144.1049,1231.6788,26.2031,4,3},
	{-688.2123,938.3978,13.6328,5,4},
	{-1531.5845,687.4770,133.0514,6,5},
	{-1746.0385,528.1078,33.6328,7,6},
	{-2342.2903,-163.5137,41.6406,8,7},
	{-2397.8435,-246.5068,35.6401,9,8},
	{-2758.2698,-417.5380,7.0309,10,9},
	{-2173.6699,-2366.3496,30.6250,11,10},
	{-1911.3087,-2586.6506,57.0643,12,11},
	{-328.0322,-2130.3245,30.5606,13,12},
	{-345.5536,-1854.0347,-4.9475,14,13},
	{-262.8691,-1638.6805,11.6048,15,14},
	{-369.4187,-1417.4979,25.7266,16,15},
	{141.8222,-1475.9114,28.5270,17,16},
	{388.8241,-1751.6829,20.4459,18,17},
	{389.8570,-2033.2495,7.8359,19,18},
	{715.2880,-1625.7753,2.4297,20,19},
	{1407.0277,-1408.5634,14.2031,21,20},
	{1966.0477,-1205.1957,16.5903,22,21},
	{2113.9241,-1498.7046,10.4219,23,22},
	{1851.5220,-1488.1444,8.8421,24,23},
	{2064.7339,-1585.3751,13.4830,25,24},
	{2431.4189,-2420.6155,13.1867,26,25},
	{2798.5327,-2393.7683,13.9560,27,26},
	{984.4499,2562.9263,10.7498,28,27},
	{490.8186,1309.3688,10.0656,29,28},
	{-425.7174,1390.5726,15.1472,30,29}
};

new
    Iterator:ON_Player< MAX_PLAYERS >,
    s_Name[ MAX_PLAYER_NAME ] = "N/A",
    i_Number[ 3 ] = "0",
    s_Date[ 100 ] = "2012.12.12",
    s_Hour[ 100 ] = "00:00"
;

stock
   bool:False = false
;

new bool:HeadShot[MAX_PLAYERS];

new started;
new answer;
new answered;

new LastPM[MAX_PLAYERS];
new ipDetect[MAX_PLAYERS];

new sniper_, minigun_, rp_;
new timers[GM_TIMERS];

new
	Characters[][] =
	{
	    "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M",
	    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y",
	    "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	    "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
	    "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
	},
	Chars[17] = "";

new end_reaction = 0;

new AutoMessages[][] =
{
	"Help the server by donating a dollar, You'll receive VIPs or PPs after donating.",
	"Welcome to our newly developed server, Own and scripted by our infamous JaKe Hero.",
	"Report a player and get a reward! If proven they have broke something in the rules and regulations.",
	"We are current handpicking administrators and helpers for our server's beta testing.",
	"We have a zero tolerancy rule for server advertising and hacking.",
	"This is a freeroam server, Free to do whatever you want, as long as it isn't breaking the rules and regulations.",
	"Please remember to send all donations if you would like to keep us alive.",
	"Do you have questions and other stuffs? Simply /ask and our Server Helpers will help you out."
};

stock
	g_GotInvitedToDuel[MAX_PLAYERS],
	g_HasInvitedToDuel[MAX_PLAYERS],
	g_IsPlayerDueling[MAX_PLAYERS],
	g_DuelCountDown[MAX_PLAYERS],
	g_Weapon,
	g_DuelTimer[MAX_PLAYERS],
	g_DuelInProgress,
	g_DuelingID1,
	g_DuelingID2;

enum PlayerSpawnInfo
{
	Float:PlayerX,
	Float:PlayerY,
	Float:PlayerZ,
	Float:PlayerAngle
}

new Float:gRandomSpawns[][PlayerSpawnInfo] =
{
	{2544.5032,	2805.8840,	19.9922,	257.5800},
	{2556.2554,	2832.5313,	19.9922,	1.9000},
	{2561.9175,	2848.5532,	19.9922,	256.6609},
	{2613.9866,	2848.4475,	19.9922,	102.2487},
	{2611.5500,	2845.7542,	16.7020,	87.5428},
	{2545.9243,	2839.1824,	10.8203,	176.2378},
	{2647.6553,	2805.0278,	10.8203,	285.1536},
	{2672.9387,	2800.3374,	10.8203,	60.4288},
	{2672.8306,	2792.1057,	10.8203,	121.8451},
	{2647.7834,	2697.5884,	19.3222,	353.1684},
	{2654.5427,	2720.3474,	19.3222,	303.5359},
	{2653.2063,	2738.2432,	19.3222,	342.1389},
	{2641.1350,	2703.2019,	25.8222,	191.6982},
	{2599.1304,	2700.7249,	25.8222,	76.3487},
	{2606.1384,	2721.5237,	25.8222,	261.2564},
	{2597.3745,	2748.0884,	23.8222,	273.2050},
	{2595.0657,	2776.6729,	23.8222,	254.3630},
	{2601.3640,	2777.8101,	23.8222,	253.4439},
	{2584.3940,	2825.1748,	27.8203,	244.5475},
	{2631.8110,	2834.2593,	40.3281,	213.2975},
	{2632.2852,	2834.9390,	122.9219,	197.6725},
	{2646.1997,	2817.7070,	36.3222,	182.0474},
	{2685.8875,	2816.6575,	36.3222,	129.9525},
	{2691.1233,	2787.7883,	59.0212,	208.0777},
	{2717.8071,	2771.3464,	74.8281,	72.3429},
	{2695.2622,	2699.5488,	22.9472,	66.3686},
	{2688.8206,	2689.0039,	28.1563,	14.8979},
	{2655.0229,	2650.6807,	36.9154,	341.8097},
	{2570.4668,	2701.2876,	22.9507,	204.0154},
	{2498.9915,	2704.6204,	10.9844,	168.9241},
	{2524.1584,	2743.3735,	10.9917,	150.3771},
	{2498.3167,	2782.3357,	10.8203,	251.7015},
	{2504.5142,	2805.9763,	14.8222,	108.6137},
	{2522.2144,	2814.7087,	24.9536,	265.9478},
	{2510.6292,	2849.6384,	14.8222,	191.4991},
	{2618.2646,	2720.8005,	36.5386,	346.6828},
	{2690.9980,	2741.9060,	19.0722,	91.6099}
};
new Float:gRandomSpawns2[][PlayerSpawnInfo] =
{
	{2544.5032,	2805.8840,	19.9922,	257.5800},
	{2556.2554,	2832.5313,	19.9922,	1.9000},
	{2561.9175,	2848.5532,	19.9922,	256.6609},
	{2613.9866,	2848.4475,	19.9922,	102.2487},
	{2611.5500,	2845.7542,	16.7020,	87.5428},
	{2545.9243,	2839.1824,	10.8203,	176.2378},
	{2647.6553,	2805.0278,	10.8203,	285.1536},
	{2672.9387,	2800.3374,	10.8203,	60.4288},
	{2672.8306,	2792.1057,	10.8203,	121.8451},
	{2647.7834,	2697.5884,	19.3222,	353.1684},
	{2654.5427,	2720.3474,	19.3222,	303.5359},
	{2653.2063,	2738.2432,	19.3222,	342.1389},
	{2641.1350,	2703.2019,	25.8222,	191.6982},
	{2599.1304,	2700.7249,	25.8222,	76.3487},
	{2606.1384,	2721.5237,	25.8222,	261.2564},
	{2597.3745,	2748.0884,	23.8222,	273.2050},
	{2595.0657,	2776.6729,	23.8222,	254.3630},
	{2601.3640,	2777.8101,	23.8222,	253.4439},
	{2584.3940,	2825.1748,	27.8203,	244.5475},
	{2631.8110,	2834.2593,	40.3281,	213.2975},
	{2632.2852,	2834.9390,	122.9219,	197.6725},
	{2646.1997,	2817.7070,	36.3222,	182.0474},
	{2685.8875,	2816.6575,	36.3222,	129.9525},
	{2691.1233,	2787.7883,	59.0212,	208.0777},
	{2717.8071,	2771.3464,	74.8281,	72.3429},
	{2695.2622,	2699.5488,	22.9472,	66.3686},
	{2688.8206,	2689.0039,	28.1563,	14.8979},
	{2655.0229,	2650.6807,	36.9154,	341.8097},
	{2570.4668,	2701.2876,	22.9507,	204.0154},
	{2498.9915,	2704.6204,	10.9844,	168.9241},
	{2524.1584,	2743.3735,	10.9917,	150.3771},
	{2498.3167,	2782.3357,	10.8203,	251.7015},
	{2504.5142,	2805.9763,	14.8222,	108.6137},
	{2522.2144,	2814.7087,	24.9536,	265.9478},
	{2510.6292,	2849.6384,	14.8222,	191.4991},
	{2618.2646,	2720.8005,	36.5386,	346.6828},
	{2690.9980,	2741.9060,	19.0722,	91.6099}
};

enum PickupSpawnInfo
{
	Float:PickupX,
	Float:PickupY,
	Float:PickupZ
}

new Float:gMinigunPickups[][PickupSpawnInfo] =
{
	{2629.6345,	2732.8936,	36.5386},
	{2635.4575,	2767.9346,	25.8222},
	{2685.5012,	2746.6240,	20.3222},
	{2668.6201,	2767.9753,	17.6896},
	{2553.7502,	2754.9238,	10.8203},
	{2524.9805,	2817.3428,	10.8203},
	{2564.5159,	2823.4812,	12.7568},
	{2594.1836,	2821.1226,	12.7647},
	{2601.4983,	2769.2195,	25.8222}
};

new Float:gParachutePickups[][PickupSpawnInfo] =
{
	{2632.7573,	2829.8999,	64.3359},
	{2632.3562,	2829.9094,	94.0156},
	{2632.3701,	2829.7065,	122.9219},
	{2719.7905,	2775.7646,	74.8281}
};

new Float:gMinigunPickups2[][PickupSpawnInfo] =
{
	{2629.6345,	2732.8936,	36.5386},
	{2635.4575,	2767.9346,	25.8222},
	{2685.5012,	2746.6240,	20.3222},
	{2668.6201,	2767.9753,	17.6896},
	{2553.7502,	2754.9238,	10.8203},
	{2524.9805,	2817.3428,	10.8203},
	{2564.5159,	2823.4812,	12.7568},
	{2594.1836,	2821.1226,	12.7647},
	{2601.4983,	2769.2195,	25.8222}
};

new Float:gParachutePickups2[][PickupSpawnInfo] =
{
	{2632.7573,	2829.8999,	64.3359},
	{2632.3562,	2829.9094,	94.0156},
	{2632.3701,	2829.7065,	122.9219},
	{2719.7905,	2775.7646,	74.8281}
};

enum ServerInfo
{
	opening_date[6],
	first_person[256],
	last_person[256],
	when_person[256],
	last_bperson[256],
	last_bwho[256],
	bannedac,
	last_bwhen[256],
	thumbsup,
	thumbsdown
};
new sInfo[ServerInfo];

new _RP[MAX_PLAYERS];

enum HouseInfo
{
    hName[MAX_HOUSE_NAME],
    hOwner[256],
    hIName[256],
    hPrice,
    hSale,
    hInterior,
    hWorld,
    hLocked,
    Float:hEnterPos[4],
    Float:hPickupP[3],
    Float:ExitCPPos[3],
    hMapIcon,
    hPickup,
    hCP,
    hLevel,
    Text3D:hLabel,
    MoneyStore,
    hNotes[256]
};

enum InteriorInfo
{
	Name[128],
	Float:SpawnPointX,
	Float:SpawnPointY,
	Float:SpawnPointZ,
	Float:SpawnPointA,
	Float:ExitPointX,
	Float:ExitPointY,
	Float:ExitPointZ,
	i_Int,
	i_Price,
	Notes[128]
};

enum HousePInfo
{
	OwnedHouses,
	Float:p_SpawnPoint[4],
	p_Interior,
	p_Spawn
};

//Interior Lists
new intInfo[][InteriorInfo] =
{
	{"Unused House", 2324.3469, -1145.8812, 1050.7101, 359.6399, 2324.4570, -1148.8044, 1050.7101, 12, 1500000, "No bugs/glitches found"},
	{"House #1", 235.3069, 1190.0491, 1080.2578, 359.9533, 235.3969, 1187.6935, 1080.2578, 3, 1000000, "No bugs/glitches found"},
	{"House #2", 222.9837, 1239.8391, 1082.1406, 92.7009, 225.8877, 1240.0209, 1082.1406, 2, 1000000, "No bugs/glitches found"},
	{"House #3", 223.3313, 1290.3979, 1082.1328, 0.2667, 223.3452, 1287.8087, 1082.1406, 1, 950000, "No bugs/glitches found"},
	{"House #4", 225.7910, 1025.7743, 1084.0078, 0.2900, 225.6310, 1022.4800, 1084.0146, 7, 2950000, "No bugs/glitches found"},
	{"House #5", 295.1922, 1475.5353, 1080.2578, 3.4232, 295.2854, 1473.0117, 1080.2578, 15, 980000, "No bugs/glitches found"},
	{"House #6", 2265.8953, -1210.4926, 1049.0234, 88.7521, 2269.4565, -1210.4597, 1047.5625, 10, 1000000, "No bugs/glitches found"},
	{"Ryder's House", 2463.5032, -1698.1881, 1013.5078, 89.8337, 2466.9146, -1698.2842, 1013.5078, 2, 3000000, "Some floors of the interior are bugged."},
	{"Sweet's House", 2530.1094, -1679.2772, 1015.4986, 359.6395, 2525.2393, -1679.3699, 1015.4986, 1, 3500000, "Some floors/walls of the interior are bugged."},
	{"Crack Den", 317.9371, 1118.0695, 1083.8828, 1.3314, 318.5647, 1115.5923, 1083.8828, 5, 3200000, "No bugs/glitches found"},
	{"Carl Johnson's House", 2496.0076, -1695.8928, 1014.7422, 181.1864, 2495.9934, -1692.9742, 1014.7422, 3, 4500000, "No bugs/glitches found"},
	{"Maddog's Crib (HUGE)", 1298.9324, -793.3831, 1084.0078, 0.4147, 1298.9706, -795.9689, 1084.0078, 5, 5500000, "No bugs/glitches found"},
	{"Santa Maria Beach House", 2365.0667, -1131.3645, 1050.8750, 0.1014, 2365.3577, -1134.2891, 1050.8750, 8, 1200000, "No bugs/glitches found"}
	//{House Name[], Float:sX, Float:sY, Float:sZ, Float:sA, Float:eX, Float:eY, Float:eZ, interior, price, notes[]}
};

new hInfo[MAX_HOUSES][HouseInfo];
new jpInfo[MAX_PLAYERS][HousePInfo];

new Possaved[MAX_PLAYERS];

new h_Loaded = 0;
new h_ID[MAX_PLAYERS];
new h_Inside[MAX_PLAYERS];
new h_Selection[MAX_PLAYERS];
new h_Selected[MAX_PLAYERS];

enum cpinfo
{
    Float:XPOS,
    Float:YPOS,
    Float:ZPOS,
    Positions[128],
    Previous_Winner[24],
	CP_Found
};

new Float:CPSPAWN[][cpinfo] =
{
	{-2638.6641, 1414.7101, 23.8984, "Jizzy's Crib"},
	{2022.8326, 1544.3042, 10.3715, "LV Pirate Ship"},
	{1589.4285, -1315.4088, 17.0823, "Los Santos Downtown"}
};

new GameTimer[MAX_PLAYERS];

new totalmaps;

enum mbinfo
{
    Float:mXPOS,
    Float:mYPOS,
    Float:mZPOS,
    mPosition[100]
};
new Float:MoneyBagPos[3], MoneyBagFound=1, MoneyBagPickup, MoneyBagLocation[128];
new pVehicle[MAX_PLAYERS];

new g_time[MAX_PLAYERS][3];

enum SAZONE_MAIN { //Betamaster
		SAZONE_NAME[28],
		Float:SAZONE_AREA[6]
};

static const gSAZones[][SAZONE_MAIN] = {  // Majority of names and area coordinates adopted from Mabako's 'Zones Script' v0.2
	//	NAME                            AREA (Xmin,Ymin,Zmin,Xmax,Ymax,Zmax)
	{"The Big Ear",	                {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
	{"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
	{"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
	{"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
	{"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
	{"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
	{"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
	{"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
	{"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
	{"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
	{"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
	{"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
	{"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
	{"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
	{"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
	{"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
	{"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
	{"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
	{"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
	{"Blackfield Intersection",     {1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
	{"Blackfield Intersection",     {1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
	{"Blackfield Intersection",     {1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
	{"Blackfield Intersection",     {1375.60,823.20,-89.00,1457.30,919.40,110.90}},
	{"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
	{"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
	{"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
	{"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
	{"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
	{"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
	{"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
	{"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
	{"Come-A-Lot",                  {2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
	{"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
	{"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
	{"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
	{"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
	{"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
	{"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
	{"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
	{"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
	{"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
	{"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
	{"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
	{"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
	{"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
	{"Downtown",                    {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
	{"Downtown",                    {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
	{"Downtown",                    {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
	{"Downtown",                    {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
	{"Downtown",                    {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
	{"Downtown",                    {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
	{"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
	{"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
	{"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
	{"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
	{"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
	{"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
	{"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
	{"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
	{"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
	{"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
	{"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
	{"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
	{"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
	{"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
	{"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
	{"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
	{"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
	{"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
	{"Easter Bay Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
	{"Easter Bay Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
	{"Easter Bay Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
	{"Easter Bay Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
	{"Easter Bay Chemicals",        {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
	{"Easter Bay Chemicals",        {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
	{"El Castillo del Diablo",      {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
	{"El Castillo del Diablo",      {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
	{"El Castillo del Diablo",      {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
	{"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
	{"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
	{"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
	{"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
	{"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
	{"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
	{"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
	{"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
	{"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
	{"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
	{"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
	{"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
	{"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
	{"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
	{"Flint Intersection",          {-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
	{"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
	{"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
	{"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
	{"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
	{"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
	{"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
	{"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
	{"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
	{"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
	{"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
	{"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
	{"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
	{"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
	{"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
	{"Glen Park",                   {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
	{"Glen Park",                   {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
	{"Glen Park",                   {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
	{"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
	{"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
	{"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
	{"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
	{"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
	{"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
	{"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
	{"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
	{"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
	{"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
	{"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
	{"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
	{"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
	{"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
	{"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
	{"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
	{"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
	{"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
	{"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
	{"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
	{"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
	{"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
	{"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
	{"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
	{"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
	{"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
	{"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
	{"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
	{"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
	{"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
	{"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
	{"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
	{"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
	{"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
	{"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
	{"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
	{"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
	{"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
	{"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
	{"K.A.C.C. Military Fuels",     {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
	{"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
	{"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
	{"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
	{"King's",                      {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
	{"King's",                      {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
	{"King's",                      {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
	{"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
	{"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
	{"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
	{"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
	{"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
	{"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
	{"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
	{"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
	{"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
	{"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
	{"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
	{"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
	{"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
	{"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
	{"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
	{"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
	{"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
	{"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
	{"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
	{"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
	{"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
	{"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
	{"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
	{"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
	{"Little Mexico",               {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
	{"Little Mexico",               {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
	{"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
	{"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
	{"Los Santos International",    {1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
	{"Los Santos International",    {1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
	{"Los Santos International",    {1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
	{"Los Santos International",    {1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
	{"Los Santos International",    {1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
	{"Los Santos International",    {2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
	{"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
	{"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
	{"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
	{"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
	{"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
	{"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
	{"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
	{"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
	{"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
	{"Missionary Hill",             {-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
	{"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
	{"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
	{"Montgomery Intersection",     {1546.60,208.10,0.00,1745.80,347.40,200.00}},
	{"Montgomery Intersection",     {1582.40,347.40,0.00,1664.60,401.70,200.00}},
	{"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
	{"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
	{"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
	{"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
	{"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
	{"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
	{"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
	{"Mulholland",                  {687.80,-860.60,-89.00,911.80,-768.00,110.90}},
	{"Mulholland",                  {737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
	{"Mulholland",                  {1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
	{"Mulholland",                  {952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
	{"Mulholland",                  {911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
	{"Mulholland",                  {861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
	{"Mulholland Intersection",     {1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
	{"North Rock",                  {2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
	{"Ocean Docks",                 {2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
	{"Ocean Docks",                 {2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
	{"Ocean Docks",                 {2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
	{"Ocean Docks",                 {2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
	{"Ocean Docks",                 {2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
	{"Ocean Docks",                 {2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
	{"Ocean Docks",                 {2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
	{"Ocean Flats",                 {-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
	{"Octane Springs",              {338.60,1228.50,0.00,664.30,1655.00,200.00}},
	{"Old Venturas Strip",          {2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
	{"Palisades",                   {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
	{"Palomino Creek",              {2160.20,-149.00,0.00,2576.90,228.30,200.00}},
	{"Paradiso",                    {-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
	{"Pershing Square",             {1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
	{"Pilgrim",                     {2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
	{"Pilgrim",                     {2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
	{"Pilson Intersection",         {1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
	{"Pirates in Men's Pants",      {1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
	{"Playa del Seville",           {2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
	{"Prickle Pine",                {1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
	{"Prickle Pine",                {1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
	{"Prickle Pine",                {1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
	{"Prickle Pine",                {1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
	{"Queens",                      {-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
	{"Queens",                      {-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
	{"Queens",                      {-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
	{"Randolph Industrial Estate",  {1558.00,596.30,-89.00,1823.00,823.20,110.90}},
	{"Redsands East",               {1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
	{"Redsands East",               {1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
	{"Redsands East",               {1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
	{"Redsands West",               {1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
	{"Redsands West",               {1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
	{"Redsands West",               {1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
	{"Redsands West",               {1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
	{"Regular Tom",                 {-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
	{"Richman",                     {647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
	{"Richman",                     {647.50,-954.60,-89.00,768.60,-860.60,110.90}},
	{"Richman",                     {225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
	{"Richman",                     {225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
	{"Richman",                     {72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
	{"Richman",                     {72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
	{"Richman",                     {321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
	{"Richman",                     {321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
	{"Richman",                     {321.30,-860.60,-89.00,687.80,-768.00,110.90}},
	{"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
	{"Robada Intersection",         {-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
	{"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
	{"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
	{"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
	{"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
	{"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
	{"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
	{"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
	{"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
	{"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
	{"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
	{"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
	{"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
	{"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
	{"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
	{"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
	{"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
	{"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
	{"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
	{"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
	{"Santa Flora",                 {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
	{"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
	{"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
	{"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
	{"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
	{"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
	{"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
	{"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
	{"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
	{"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
	{"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
	{"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
	{"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
	{"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
	{"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
	{"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
	{"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
	{"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
	{"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
	{"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
	{"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
	{"The Four Dragons Casino",     {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
	{"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
	{"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
	{"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
	{"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
	{"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
	{"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
	{"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
	{"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
	{"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
	{"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
	{"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
	{"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
	{"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
	{"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
	{"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
	{"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
	{"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
	{"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
	{"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
	{"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
	{"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
	{"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
	{"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
	{"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
	{"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
	{"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
	{"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
	{"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
	{"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
	{"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
	{"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
	{"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
	{"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
	{"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
	{"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
	{"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
	// Main Zones
	{"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
	{"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
	{"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
	{"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
	{"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
	{"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
	{"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
	{"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
	{"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};

new Float:MBSPAWN[][mbinfo] =
{
	{1856.8026, -1454.9489, 28.7969, "Skate Park"},
	{1918.8652, -1354.9019, 23.3599, "Skate Park"},
	{1976.4802, -1373.0173, 35.2584, "Skate Park"},
	{-1210.5745, -102.0945, 14.1440, "SF Airport"},
	{-2238.3774, -1744.0116, 480.8426, "Chilliad"},
	{-2659.6348, 1529.5637, 54.9022, "SF Park"},
	{403.6271, 2477.5967, 33.5324, "Abandoned Airport"},
	{422.4438, 2501.4622, 16.4844, "Abandoned Airport"},
	{-321.7193, 1307.7490, 53.6643, "Drift Place 1"},
	{1952.6104, -2262.6250, 13.5469, "LS Airport"},
	{2014.5839, -2493.8013, 48.2151, "LS Airport"}
};

new VehicleName[212][] = {
    {"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
    {"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
    {"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
    {"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
    {"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
    {"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
    {"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
    {"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
    {"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
    {"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
    {"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
    {"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
    {"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
    {"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
    {"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
    {"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
    {"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
    {"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
    {"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
    {"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
    {"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
    {"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
    {"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
    {"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
    {"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
    {"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
    {"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
    {"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
    {"Utility Trailer"}
};

new Colors[] =
{
	0xD526D9FF,
	0x00FF00FF,
	0xFF80FFFF,
	0x33CCFFAA,
	0xAFAFAFAA,
	0xFFFFFFFF,
	0xFF8000FF,
	0xFFFF00FF,
	0x0080FFC8,
	0xFF0000FF,
    0x00FF00FF,
    0x800000FF,
	0xFF00FFFF,
    0xEE82EEFF,
    0xF5DEB3FF,
    0xC0C0C0FF,
    0xFF4500FF,
    0x808000FF,
    0xFFD700FF,
    0x00FFFFFF
};

new Float:jailspawn[][4] =
{
	{280.1370,2094.0715,26.1486,91.2980},
	{269.9662,2094.1196,26.1486,89.7313},
	{258.6675,2093.9829,26.1486,89.7313},
	{258.5696,2098.7854,23.0486,289.6399},
	{277.8738,2113.4116,23.0486,127.6685},
	{268.6160,2105.7759,23.0486,271.4665}
};

enum PlayerInfo
{
    accountID,
    accountName[24],
    accountCName,
    accountCWait,
    accountIP[20],
    accountPassword[129],
    accountAdmin,
    accountKills,
    accountDeaths,
    accountScore,
    accountCash,
    accountHelper,
    bool: accountLogged,
	WarnLog,
	accountDate[150],
	accountPP,
	accountJP,
	accountVIP,
	ExpirationVIP,
	accountBrake,
	accountGame[3],
	accountReact,
	accountCP,
	accountWarn,
	accountMath,
	accountMB,
	accountNoB,
	accountDescp[100],
	accountMuted,
	accountMuteSec,
	accountCMuted,
	accountCMuteSec,
	accountJail,
	accountJailSec,
	SpecID,
	SpecType,
	Rated,
	accountHS,
	accountSkin,
	accountUse,
	accountWet
};

new SpecInt[MAX_PLAYERS][2];
new Float:SpecPos[MAX_PLAYERS][4];
new User[MAX_PLAYERS][PlayerInfo];
new horse[30];

new ToggleAdmin[MAX_PLAYERS];
new AdminDuty[MAX_PLAYERS];

new Float:cppos[3];
new cp_reward;
new current_cp;
new DB:Database;
new begin_react = 0;
new money_times = 0;

new money_anti[MAX_PLAYERS];

new pickup[50];

new g_DM[MAX_PLAYERS];

new PlayerText:Textdraw0;
new PlayerText:Textdraw8;
new PlayerText:Textdraw9;
//Loading mSelection under the textdraw so no problems will happen.
#include                        <mSelection>
new skinlist = mS_INVALID_LISTID;
new Text:Textdraw1;
new Text:Textdraw2;
new Text:Textdraw3;
new Text:Textdraw10;

//Teleport Textdraws

new Text:Textdraw4;
new Text:Textdraw5;
new Text:Textdraw6;
new Text:Textdraw7;

new freezeme[MAX_PLAYERS];
new reportmsg[4][350];
new teleportmsg[4][150];

//============================================================================//
//  Code Starts Here    //
//============================================================================//

main()
{
	print("\n");
	print("**********************************************");
	print("JaKe's Stunt/DM/Freeroam/Minigames/Roleplay");
	print("created by Jake Hero");
	print("Server has been started.");
	print("**********************************************");
	print("\n");
}

public MinigameCountdown( )
{
	if( Iter_Count(_Minigamer) < 2 ) //End minigame if there aren't enough sign ups
	{
		SendClientMessageToAll( COLOR_RED, "There wasn't enough players to start Don't Get Wet minigame." );
		foreach(_Minigamer, i) Minigamer_{ i } = false;
		return EndMinigame( );
	}
	if( inProgress != 2 )
	{
	    new spot;
		foreach(_Minigamer, i )
		{
     		GetPlayerPos( i, pCoords[i][0], pCoords[i][1], pCoords[i][2]);
     		pInterior[i] = GetPlayerInterior( i );
     		for( new a; a < 13; a++ )
			{
		      	GetPlayerWeaponData( i, a, pWeaponData[i][a], pSavedAmmo[i][a] );
  			}
			ResetPlayerWeapons( i );
			SetPlayerInterior( i, 0 );
			spot = Iter_Random(_Objects);
     		GameTextForPlayer( i, pReadyText[ random( sizeof( pReadyText ) ) ], 2050, 3 );
     		Iter_Remove(_Objects, spot );
     		SetPlayerCameraPos( i, -5298.4814,-218.4391,42.1386);
     		SetPlayerCameraLookAt( i, -5298.1616,-189.6903,23.6564);
     		TogglePlayerControllable( i, false );
			SetPlayerPos( i, gCoords[spot][0], gCoords[spot][1], gCoords[spot][2] +0.5 );
		}
		Iter_Clear(_Objects);
		for( new i; i < MAX_SLOTS; i++ ) Iter_Add(_Objects, i );
		SetTimer( "MinigameCountdown", 2000, 0 );
		inProgress = 2;
	}
	else
	{
		foreach(_Minigamer, i )
		{
		    if(!VIEW_FROM_ABOVE)
			SetCameraBehindPlayer( i );
			PlayerPlaySound( i, 1057, 0.0, 0.0, 0.0 );
			TogglePlayerControllable( i, true );
		}
		uTimer = SetTimer( "MinigameUpdate", 2500, 1 );
	}
	return 1;
}

public MinigameUpdate( )
{
	if( Iter_Count(_Minigamer) < 1 ) return EndMinigame( );

	new str[128], Float:playerx, Float:playery, Float:playerz[ALL_PLAYERS];
	foreach(_Minigamer, i )
	{
		GetPlayerPos( i, playerx, playery, playerz[i] );
		if( playerz[i] < 2.0 ) //Checks if player is in the water
		{
			format( str, sizeof( str ), "[DGW] "white"%s has dropped out of Don't Get Wet minigame, rank %d", GetName( i ), Iter_Count(_Minigamer) );
			SendClientMessageToAll( COLOR_RED, str );
			GameTextForPlayer( i, pFellOffText[ random( sizeof( pFellOffText ) ) ], 2500, 3 );
			Iter_Remove(_Minigamer, i );
			Minigamer_{ i } = false;
			RespawnPlayer( i );
		}
	}
	if( Iter_Count(_Minigamer) < 2 )
	{
 		foreach(_Minigamer, i ) MinigameWinner( i );
	}
 	new objectid, Float:ObjectX, Float:ObjectY, Float:ObjectZ;

 	objectid = Iter_Random(_Objects);
	GetObjectPos( Objects_[0][objectid], ObjectX, ObjectY, ObjectZ );
	SetTimerEx("SpeedUp", 500, 0, "ifff", objectid, ObjectX, ObjectY, ObjectZ);
	MoveObject( Objects_[0][objectid], ObjectX, ObjectY, ObjectZ -5, 1 );
    Iter_Remove(_Objects, objectid);
	return 1;
}

public SpeedUp( object, Float:x, Float:y, Float:z )
{
	MoveObject( Objects_[0][object], x, y, z -150, 20 );

	foreach(_Minigamer, i ) PlayerPlaySound( i, 1039, 0.0, 0.0, 0.0 );
}

public EndMinigame( )
{
	for( new i; i < MAX_SLOTS; i++ )
 	{
 	    DestroyObject( Objects_[0][i] );
 	}
 	inProgress = 0;
	Iter_Clear(_Objects);
	Iter_Clear(_Minigamer);
	KillTimer( uTimer );
	return 1;
}

public MinigameWinner( player )
{
	new str[128];
	User[player][accountWet] ++;
	format( str, sizeof( str ), "[DGW] "white"%s has won Don't Get Wet minigame!", GetName( player ) );
	SendClientMessageToAll( COLOR_RED, str );
 	GivePlayerMoney( player, 6000 );
 	SetPlayerScore( player, GetPlayerScore(player) + 2 );
 	Minigamer_{ player } = false;
	Iter_Remove(_Minigamer, player);
	SetTimerEx( "RespawnPlayer", 1400, 0, "i", player );
	SetTimer( "EndMinigame", 1700, 0);
}

public RespawnPlayer ( player )
{
	for( new i = 12; i > -1; i-- )
	{
		GivePlayerWeapon( player, pWeaponData[player][i], pSavedAmmo[player][i] );
	}
	SetPlayerPos( player, pCoords[player][0], pCoords[player][1], pCoords[player][2] );
   	SetPlayerInterior( player, pInterior[player] );
   	SetCameraBehindPlayer( player );
}

public Wait()
{
	foreach(new i : Player)
	{
	    if(User[i][accountCWait] >= 1)
	    {
			User[i][accountCWait] --; //Reduced the waiting.
	    }
	}
}

public OnGameModeInit()
{
	g_DuelingID1 = -1;
	g_DuelingID2 = -1;
	for(new i=0; i<MAX_HOUSES; i++)
	{
	    if(fexist(HousePath(i)))
	    {
	        LoadHouse(i);
	        h_Loaded ++;
	    }
	}

	printf("... Houses loaded by JakHouse [%d houses out of %d]", h_Loaded, MAX_HOUSES);
	#if CHRISTMAS_SPIRIT == true
	    print("... Merry Christmas and a Happy New Year, 2014 from JaKe's server ...!");
	#endif

	UsePlayerPedAnims();    //Uses the CJ animations.

	getdate(sInfo[opening_date][0], sInfo[opening_date][1], sInfo[opening_date][2]);
	gettime(sInfo[opening_date][3], sInfo[opening_date][4], sInfo[opening_date][5]);

	Clear_CP();
	loaddb();
	LoadRec();
	loadtd();
	loadobjects();
	loadvehicles();
	load_spawn();
	load_config();
	EnableStuntBonusForAll(0);
	ShowNameTags(1);
	SetWorldTime(0);
	SetWeather(10);

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);

	for(new x; x<MAX_VEHICLES; x++)
	{
		SetVehicleNumberPlate(x, ""green"JaKe");
	}
	for(new i=0; i<GM_TIMERS; i++)
	{
	    KillTimer(timers[i]);
	}

	timers[0] = SetTimer("Checkpoint", 1000*60*4, true);
	timers[1] = SetTimer("Reactions", 1000*60*5, true);
	timers[3] = SetTimer("MoneyBag", MB_DELAY, true);
	timers[4] = SetTimer("Heartbeat", 1000, true);
	timers[5] = SetTimer("Anticheat", 2300, true);
	timers[6] = SetTimer("Wait", 1000*60*60, true);
	timers[7] = SetTimer("Maths", 1000*60*6, true);
	timers[9] = SetTimer("UpdatePlayer", 100, true);
	timers[10] = SetTimer("AutoMessage", 1000*60*5, true);

	SetGameModeText("Stunt-DM-Freeroam-MG-RP");
	SendRconCommand("mapname "VERSION"");
	SendRconCommand("hostname "S_H"");
	
	for(new i=0; i<300; i++)
	{
	    if(i!=74)
	    {
			AddPlayerClass(i, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		}
	}
	
	new i, j;
	for(i = 0, j = sizeof(gMinigunPickups); i < j; i++)
	{
		AddStaticPickup(362, 15, gMinigunPickups[i][PickupX], gMinigunPickups[i][PickupY], gMinigunPickups[i][PickupZ], 67);
	}
	for (i = 0, j = sizeof(gParachutePickups); i < j; i++)
	{
		AddStaticPickup(371, 15, gParachutePickups[i][PickupX], gParachutePickups[i][PickupY], gParachutePickups[i][PickupZ], 67);
	}
	for (i = 0, j = sizeof(gMinigunPickups2); i < j; i++)
	{
		AddStaticPickup(358, 15,
			gMinigunPickups2[i][PickupX],
			gMinigunPickups2[i][PickupY],
			gMinigunPickups2[i][PickupZ],
			68);
	}
	for (i = 0, j = sizeof(gParachutePickups2); i < j; i++)
	{
		AddStaticPickup(371, 15,
			gParachutePickups2[i][PickupX],
			gParachutePickups2[i][PickupY],
			gParachutePickups2[i][PickupZ],
			68);
	}
	return 1;
}

public OnGameModeExit()
{
    if( inProgress > 0 ) EndMinigame( );
	savestatistics();
	for(new i=0; i<GM_TIMERS; i++)
	{
	    KillTimer(timers[i]);
	}
	closedb();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	#if CHRISTMAS_SPIRIT == false
		PlayerPlaySound(playerid, 1185, 2116.0205, 2143.3225, 10.8203);
	#else
	    if(GetPVarInt(playerid, "_christmas_") == 0)
	    {
	    	SetPVarInt(playerid, "_christmas_", 1);
	    	PlayAudioStreamForPlayer(playerid, "http://tms-server.comyr.com/creed/christmas.mp3");
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "Merry XMas to you all, Brought you by JaKe's server, Enjoy the sweet class selection music!");
		}
	#endif
	
	if(User[playerid][accountUse] == 1)
	{
	    #if CHRISTMAS_SPIRIT == true
	        SetPVarInt(playerid, "_christmas_", 0);
	        StopAudioStreamForPlayer(playerid);
	    #endif
	    
	    SetSpawnInfo(playerid, 255, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
	    
	    SendClientMessage(playerid, -1, "Class selection has been skipped, You have your saved skin settings used on.");
	    SendClientMessage(playerid, -1, "Please type, /dontuseskin if you wanna disable this feature.");
	}
	
    SetPlayerPos(playerid, 2116.0205, 2143.3225, 10.8203);
    SetPlayerFacingAngle(playerid, 89.6528);
    SetPlayerCameraLookAt(playerid, 2116.0205, 2143.3225, 10.8203);
    SetPlayerCameraPos(playerid, 2116.0205 + (5 * floatsin(-89.6528, degrees)), 2143.3225 + (5 * floatcos(-89.6528, degrees)), 10.8203);
	return 1;
}

public Maths()
{
    new string[256], addsubtext1[10], addsubtext2[10];

    new temp1;

    new number1 = random(100);
    new number2 = random(100);
    new number3 = random(100);
    new addsubnumb1 = random(2);
    new addsubnumb2 = random(2);
    
    started = 1;

    if(addsubnumb1 == 0)
    {
        format(addsubtext1, sizeof(addsubtext1), "-");
        temp1 = number1 - number2;
    }
    else if(addsubnumb1 == 1)
    {
        format(addsubtext1, sizeof(addsubtext1), "+");
        temp1 = number1 + number2;
    }

    if(addsubnumb2 == 0)
    {
        format(addsubtext2, sizeof(addsubtext2), "-");
        answer = temp1 - number3;
    }
    else if(addsubnumb2 == 1)
    {
        format(addsubtext2, sizeof(addsubtext2), "+");
        answer = temp1 + number3;
    }

    format(string, sizeof(string), "[MATH] "white"Math quiz has been started, First one to answer "grey"%d%s%d%s%d "white"wins $4000 + 5 score.", number1, addsubtext1, number2, addsubtext2, number3);
    SendClientMessageToAll(COLOR_YELLOW, string);

    answered = 0;

	timers[8] = SetTimer("EndMaths", 1000*30, false);
    return 1;
}

public EndMaths()
{
	if(answered == 0)
	{
		new string[150];
		format(string, 150, "[MATH] "white"No one wins the math quiz, The answer is "grey"%d"white" another one will start in 6 minutes.", answer);
	    SendClientMessageToAll(COLOR_RED, string);
		answered = 0;
		answer = 0;
		started = 0;
		KillTimer(timers[8]);
	}
	else
	{
		answered = 0;
		answer = 0;
		started = 0;
		KillTimer(timers[8]);
	}
	return 1;
}

public BeginReaction()
{
	KillTimer(timers[2]);
	Reactions();
	return 1;
}

public MoneyBag()
{
    new string[256];
    if(MoneyBagFound != 1)
    {
        money_times ++;
        if(money_times <= 2)
        {
	        format(string, sizeof(string), "[MONEYBAG] The "green"money bag "white"hasn't been found yet, It's still in the location \""red"%s"white"\"", MoneyBagLocation);
	        SendClientMessageToAll(-1, string);
		}
        else if(money_times == 3)
        {
	        format(string, sizeof(string), "[MONEYBAG] The "green"money bag "white"at \""red"%s"white"\" has been replaced by a new one.", MoneyBagLocation);
	        SendClientMessageToAll(-1, string);

			DestroyDynamicPickup(MoneyBagPickup);
			money_times = 0;
	        MoneyBagFound = 0;
	        new randombag = random(sizeof(MBSPAWN));
	        MoneyBagPos[0] = MBSPAWN[randombag][mXPOS];
	        MoneyBagPos[1] = MBSPAWN[randombag][mYPOS];
	        MoneyBagPos[2] = MBSPAWN[randombag][mZPOS];
	        format(MoneyBagLocation, sizeof(MoneyBagLocation), "%s", MBSPAWN[randombag][mPosition]);
	        format(string, sizeof(string), "[MONEYBAG] A "green"moneybag "white"has been placed at \""red"%s"white"\" the first one to get it wins a money and 20 scores.", MoneyBagLocation);
	    	SendClientMessageToAll(-1, string);
	        MoneyBagPickup = CreateDynamicPickup(1550, 2, MoneyBagPos[0], MoneyBagPos[1], MoneyBagPos[2], -1, -1, -1);
        }
    }
    else if(MoneyBagFound != 0)
    {
    	DestroyDynamicPickup(MoneyBagPickup);
        MoneyBagFound = 0;
        money_times = 0;
        new randombag = random(sizeof(MBSPAWN));
        MoneyBagPos[0] = MBSPAWN[randombag][mXPOS];
        MoneyBagPos[1] = MBSPAWN[randombag][mYPOS];
        MoneyBagPos[2] = MBSPAWN[randombag][mZPOS];
        format(MoneyBagLocation, sizeof(MoneyBagLocation), "%s", MBSPAWN[randombag][mPosition]);
        format(string, sizeof(string), "[MONEYBAG] A "green"moneybag "white"has been placed at \""red"%s"white"\" the first one to get it wins a money and 20 scores.", MoneyBagLocation);
    	SendClientMessageToAll(-1, string);
        MoneyBagPickup = CreateDynamicPickup(1550, 2, MoneyBagPos[0], MoneyBagPos[1], MoneyBagPos[2], -1, -1, -1);
    }
    return 1;
}

public Reactions()
{
	new string[200];

    new xLength = (10);
    format(Chars, sizeof(Chars), "");
    Loop(x, xLength) format(Chars, sizeof(Chars), "%s%s", Chars, Characters[random(sizeof(Characters))][0]);
    format(string, sizeof(string), ""red"[CONTEST] "white"Who first types \""grey"%s\" "white"wins "green"$3000 + 5 scores", Chars);
    SendClientMessageToAll(-1, string);
	end_reaction = 1;
	begin_react = 1;
	timers[2] = SetTimer("EndReactions", 1000*30, false);
    return 1;
}

public EndReactions()
{
    SendClientMessageToAll(COLOR_RED, "[CONTEST] "white"No one wins the contest, another one will start in "grey"5 minutes.");
	end_reaction = 0;
	begin_react = 0;
	KillTimer(timers[2]);
	return 1;
}

public BeginMaths()
{
	KillTimer(timers[8]);
	Maths();
	return 1;
}

public Checkpoint()
{
	new string[150];

	new randomcp = random(sizeof(CPSPAWN));
	cppos[0] = CPSPAWN[randomcp][XPOS];
	cppos[1] = CPSPAWN[randomcp][YPOS];
	cppos[2] = CPSPAWN[randomcp][ZPOS];
	
	if(current_cp != -1)
	{
		if(CPSPAWN[current_cp][CP_Found] == 0)
		{
		    SendClientMessageToAll(-1, "» "red"None of the players found the hidden checkpoint, It has been replaced by a new one.");
		}
		else
		{
			format(string, sizeof(string), "» "green"%s "white"is the previous player who found the "red"hidden checkpoint "white"in "yellow"%s.", CPSPAWN[current_cp][Previous_Winner], CPSPAWN[current_cp][Positions]);
			SendClientMessageToAll(-1, string);
		}
		CPSPAWN[current_cp][CP_Found] = 0;
		format(CPSPAWN[current_cp][Previous_Winner], 24, "None");
	}
	
	current_cp = randomcp;
	
	format(string, sizeof string, "%s", CPSPAWN[randomcp][Positions]);
	new string2[200];
	format(string2, sizeof(string2), "[CHECKPOINT] A new "red"checkpoint "white"has been created in "yellow"%s "white"go find for it and get a reward!", string);
	SendClientMessageToAll(-1, string2);

	DestroyDynamicCP(cp_reward);

	cp_reward = CreateDynamicCP(cppos[0], cppos[1], cppos[2], 7.0, 0, 0, -1, 50.0);
	return 1;
}

public OnPlayerConnect(playerid)
{
	#if CHRISTMAS_SPIRIT == true
		CreateSnow(playerid);
	#endif
	_RP[playerid] = 0;
	Act[playerid] = 1;
	g_AFK[playerid] = 0;
	format(g_Reason[playerid], 128, "None of your business.");
	HeadShot[playerid] = false;
	g_DM[playerid] = 0;
    g_GotInvitedToDuel[playerid] = 0;
    g_HasInvitedToDuel[playerid] = 0;
    g_IsPlayerDueling[playerid]  = 0;
	LastPM[playerid] = INVALID_PLAYER_ID;
	User[playerid][SpecID] = INVALID_PLAYER_ID;
	ipDetect[playerid] = 0;
	KillTimer(freezeme[playerid]);

	new color = random(sizeof(Colors));
	SetPlayerColor(playerid, Colors[color]);

	ResetPlayerCash(playerid);

	pVehicle[playerid] = -1;
	ToggleAdmin[playerid] = 1;
	AdminDuty[playerid] = 0;

	Clear_Chat(playerid);
	load_pp(playerid);

	SetPVarInt(playerid, "Textdraw4Me", 1);

	TextDrawShowForPlayer(playerid, Textdraw1);
	TextDrawShowForPlayer(playerid, Textdraw2);
	TextDrawShowForPlayer(playerid, Textdraw3);

	PreloadAnimLib(playerid,"BOMBER");
	PreloadAnimLib(playerid,"RAPPING");
	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"SMOKING");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"ON_LOOKERS");
	PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");

	for(new x; x < _: PlayerInfo; ++x ) User[playerid][PlayerInfo: x] = 0;

    GetPlayerName(playerid, User[playerid][accountName], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, User[playerid][accountIP], 20);

	new
		bQuery[600],
		reason[128],
		admin[128],
		string[256],
		when[128],
	    DBResult:jResult
	;
	format(bQuery, 600, "SELECT * FROM `bans` WHERE `username` = '%s'", GetName(playerid));
	jResult = db_query(Database, bQuery);

	if(db_num_rows(jResult))
	{
	    db_get_field_assoc(jResult, "banby", admin, 128);
	    db_get_field_assoc(jResult, "banreason", reason, 128);
	    db_get_field_assoc(jResult, "banwhen", when, 128);

		format(string, sizeof(string), "%s has connected to the server, Got kicked for being banned.", GetName(playerid));
		Log("finn.txt", string);

		AddBan(User[playerid][accountIP], 1);

		ShowBan(playerid, admin, reason, when);
		
		KickDelay(playerid);
	    return 1;
	}
	db_free_result(jResult);
	
	if(CheckBan(User[playerid][accountIP]) == 1)
	{
	    SendClientMessage(playerid, -1, "If you think this is bugged try to relog, or contact a high ranking admin about this issue.");
	    SendClientMessage(playerid, COLOR_RED, "[BANNED] "white"You are banned from this server, Server has matched your IP from one of our banned IP.");

		format(string, sizeof(string), "%s has connected to the server, Got banned having a matched ip from ban.cfg", GetName(playerid));
		Log("finn.txt", string);

		KickDelay(playerid);
		return 1;
	}

	h_ID[playerid] = -1;
	h_Inside[playerid] = -1;
	h_Selection[playerid] = 0;
	h_Selected[playerid] = -1;

	if(!fexist(PlayerPath(playerid)))
	{
		jpInfo[playerid][OwnedHouses] = 0;
		jpInfo[playerid][p_SpawnPoint][0] = 0.0;
		jpInfo[playerid][p_SpawnPoint][1] = 0.0;
		jpInfo[playerid][p_SpawnPoint][2] = 0.0;
		jpInfo[playerid][p_SpawnPoint][3] = 0.0;
		jpInfo[playerid][p_Interior] = 0;
		jpInfo[playerid][p_Spawn] = 0;

		dini_Create(PlayerPath(playerid));

		Player_Save(playerid);
		Player_Load(playerid);
	}
	else
	{
	    Player_Load(playerid);
	}
	
	SendDeathMessage(-1, playerid, 200);
	
	SendClientMessage(playerid, COLOR_YELLOW, "--------------------------------------------------------------------------------------------------");
	SendClientMessage(playerid, -1, "Welcome to JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.");
	SendClientMessage(playerid, -1, "by JaKe Hero, We are a new community in San Andreas Multiplayer.");
	SendClientMessage(playerid, -1, "Do you need help? Simply /ask and our staff will help you out.");
	SendClientMessage(playerid, -1, "Refer to /commands for the commands and /help for more info.");
	SendClientMessage(playerid, COLOR_YELLOW, "--------------------------------------------------------------------------------------------------");
	SendClientMessage(playerid, -1, "» "red"Choose your skin to play with inside the server.");
	SendClientMessage(playerid, COLOR_GREEN, "Rate the server by doing so, /rate, Thank you.");
	SendClientMessage(playerid, COLOR_RED, "Major bugs of the server has been fixed, New features has been implemented.");
	SendClientMessage(playerid, -1, "Hey Roleplay Players out there, a Roleplay Mode has been implemented, Have fun!");
	#if CHRISTMAS_SPIRIT == true
	    SetPVarInt(playerid, "_christmas_", 1);
		PlayAudioStreamForPlayer(playerid, "http://tms-server.comyr.com/creed/christmas.mp3");
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "Merry XMas to you all, Brought you by JaKe's server, Enjoy the sweet class selection music!");
	#endif

    Iter_Add(ON_Player, playerid);
    SetTimerEx("PlayerRecord", 2000, false, "i", playerid);
	GameTimer[playerid] = SetTimerEx("GamePlay", 1000, true, "d", playerid);

    new
        Query[600],
        DBResult: Result,
        storedip[71],
        ip[20]
    ;
    GetPlayerIp(playerid, ip, 20);
    format(Query, sizeof(Query), "SELECT `password`, `IP` FROM `users` WHERE `username` = '%s'", DB_Escape(User[playerid][accountName]));
    Result = db_query(Database, Query);
    if(db_num_rows(Result))
    {
		db_get_field_assoc(Result, "IP", storedip, 20);
        db_get_field_assoc(Result, "password", User[playerid][accountPassword], 129);
		if((!strcmp(ip, storedip, true)))
        {
            LoginPlayer(playerid);
            LoginPremium(playerid);
        }
		else
		{
        	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", ""grey"Welcome back to JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.\nYour account exists on our database, Please insert your account's password below.\n\nTIPS: If you do not own the account, Please /q and use another username.", "Login", "Quit");
		}
	}
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", ""grey"Welcome to the JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.\nYour account doesn't exist on our database, Please insert your password below.\n\nTIPS: Make the password long so no one can hack it.", "Register", "Quit");
	}
	db_free_result(Result);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new string[250];
    Iter_Remove(ON_Player, playerid);

	if( Minigamer_{ playerid } == true )
	{
		if( inProgress > 1 )
		{
   			format( string, sizeof string, "[DGW] {%06x}%s "white"has dropped out of "red"Don't Get Wet minigame, "white"rank "grey"%d", GetPlayerColor(playerid) >>> 8, GetName( playerid ), Iter_Count(_Minigamer) );
			SendClientMessageToAll( -1, string );
			Iter_Remove(_Minigamer, playerid );
			Minigamer_{ playerid } = false;
			if( Iter_Count(_Minigamer) < 2 )
			{
			    foreach(_Minigamer, i) MinigameWinner( i );
			}
		}
		else
		{
		    Iter_Remove(_Minigamer, playerid);
			Minigamer_{ playerid } = false;
		}
	}

	#if CHRISTMAS_SPIRIT == true
        if(snowOn{playerid})
        {
            for(new i = 0; i < MAX_SNOW_OBJECTS; i++)
            {
				DestroyDynamicObject(snowObject[playerid][i]);
			}
            snowOn{playerid} = false;
            KillTimer(updateTimer{playerid});
        }
	#endif

    if(playerid == g_DuelingID1)
    {
        GivePlayerCash(g_DuelingID2, 4000);
        SetPlayerScore(g_DuelingID2, GetPlayerScore(g_DuelingID2) + 3);
        g_DuelInProgress = 0;
        format(string, 250, "[DUEL] {%06x}%s "white"won the duel against {%06x}%s "white"he/she won "green"$4000 + 3 score", GetPlayerColor(g_DuelingID2) >>> 8, GetName(g_DuelingID2), GetPlayerColor(playerid) >>> 8, GetName(playerid));
        SendClientMessageToAll(COLOR_LIGHTBLUE, string);
        SendClientMessage(g_DuelingID2, COLOR_GREEN, "You won $4000 and 3 scores from a duel against a player.");

	    ResetPlayerWeapons(g_DuelingID2);
		SpawnPlayer(g_DuelingID2);
        g_GotInvitedToDuel[playerid] = 0;g_HasInvitedToDuel[playerid] = 0;g_IsPlayerDueling[playerid]  = 0;
        g_DuelingID1 = -1;
        g_DuelingID2 = -1;
    }
    if(playerid == g_DuelingID2)
    {
        GivePlayerCash(g_DuelingID1, 4000);
        SetPlayerScore(g_DuelingID1, GetPlayerScore(g_DuelingID1) + 3);
        g_DuelInProgress = 0;
        format(string, 250, "[DUEL] {%06x}%s "white"won the duel against {%06x}%s "white"he/she won "green"$4000 + 3 score", GetPlayerColor(g_DuelingID1) >>> 8, GetName(g_DuelingID1), GetPlayerColor(playerid) >>> 8, GetName(playerid));
        SendClientMessageToAll(COLOR_LIGHTBLUE, string);
        SendClientMessage(g_DuelingID1, COLOR_GREEN, "You won $4000 and 3 scores from a duel against a player.");

        ResetPlayerWeapons(g_DuelingID1);
		SpawnPlayer(g_DuelingID1);
        g_GotInvitedToDuel[playerid] = 0;g_HasInvitedToDuel[playerid] = 0;g_IsPlayerDueling[playerid]  = 0;
        g_DuelingID1 = -1;
        g_DuelingID2 = -1;
    }

	if(g_DM[playerid] >= 1)
	{
	    LeaveDM(playerid, "Left the Server");
	    g_DM[playerid] = 0;
	}
	if(_RP[playerid] >= 1)
	{
	    LeaveRP(playerid, "Left the Server");
	    _RP[playerid] = 0;
	}

	PlayerTextDrawHide(playerid, Textdraw0);
	PlayerTextDrawHide(playerid, Textdraw8);
	TextDrawHideForPlayer(playerid, Textdraw1);
	TextDrawHideForPlayer(playerid, Textdraw2);
	TextDrawHideForPlayer(playerid, Textdraw3);
	TextDrawHideForPlayer(playerid, Textdraw4);
	TextDrawHideForPlayer(playerid, Textdraw5);
	TextDrawHideForPlayer(playerid, Textdraw6);
	TextDrawHideForPlayer(playerid, Textdraw7);
	unloadpp(playerid);

	h_ID[playerid] = -1;
	h_Inside[playerid] = -1;
	h_Selection[playerid] = 0;
	h_Selected[playerid] = -1;

	if(fexist(PlayerPath(playerid))) Player_Save(playerid);

	SendDeathMessage(-1, playerid, 201);

    if(pVehicle[playerid] != -1)
    {
        foreach(new i : Player)
        {
        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
		}
    }
	DestroyVehicle(pVehicle[playerid]);

	KillTimer(GameTimer[playerid]);

	for(new x=0; x<MAX_PLAYERS; x++)
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid)
   		   	AdvanceSpectate(x);

    if(User[playerid][accountLogged] == true)
    {
		SaveData(playerid);
		SavePremium(playerid);
    }
	return 1;
}

#if CHRISTMAS_SPIRIT == true
	forward UpdateSnow(playerid);
	public UpdateSnow(playerid)
	{
	    if(!snowOn{playerid}) return 0;
	    new Float:pPos[3];
	    GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	    for(new i = 0; i < MAX_SNOW_OBJECTS; i++) SetDynamicObjectPos(snowObject[playerid][i], pPos[0] + random(25), pPos[1] + random(25), pPos[2] - 5 + random(10));
	    return 1;
	}
#endif

forward AutoMessage();
public AutoMessage()
{
	new string[250];
	format(string, sizeof(string), "[SERVER] "white"%s", AutoMessages[random(sizeof(AutoMessages))]);
	SendClientMessageToAll(COLOR_LIGHTBLUE, string);
	return 1;
}

public GamePlay(playerid)
{
	new string[200];

	if(User[playerid][accountLogged] == true)
	{
 		if(User[playerid][accountGame][2] == 0 && User[playerid][accountGame][1] == 10 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
			SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
 		else if(User[playerid][accountGame][2] == 0 && User[playerid][accountGame][1] == 30 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
 		else if(User[playerid][accountGame][2] == 0 && User[playerid][accountGame][1] == 50 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 10);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
 		else if(User[playerid][accountGame][2] >= 1 && User[playerid][accountGame][1] == 0 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
			SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
		else if(User[playerid][accountGame][2] >= 1 && User[playerid][accountGame][1] == 10 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
		else if(User[playerid][accountGame][2] >= 1 && User[playerid][accountGame][1] == 30 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
		    SendClientMessage(playerid, -1, "You have received "green"3 scores "white"for playing long enough in the server.");
		}
		else if(User[playerid][accountGame][2] >= 1 && User[playerid][accountGame][1] == 50 && User[playerid][accountGame][0] == 0)
		{
			format(string, sizeof(string), "[NOTIFY] "white"You have been in the server for "grey"%d "white"hours, "grey"%d "white"minutes and "grey"%d "white"seconds.", User[playerid][accountGame][2], User[playerid][accountGame][1], User[playerid][accountGame][0]);
			SendClientMessage(playerid, COLOR_RED, string);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 10);
		    SendClientMessage(playerid, -1, "You have received "green"10 scores "white"for playing long enough in the server.");
		}

		User[playerid][accountGame][0] += 1;
		if(User[playerid][accountGame][0] == 60)
		{
	        User[playerid][accountGame][0] = 0;
	        User[playerid][accountGame][1] += 1;
	        if(User[playerid][accountGame][1] >= 59 && User[playerid][accountGame][0] == 0)
	        {
	            User[playerid][accountGame][1] = 0;
	            User[playerid][accountGame][2] += 1;
	        }
		}

		g_time[playerid][0] += 1;
		if(g_time[playerid][0] == 60)
		{
	        g_time[playerid][0] = 0;
	        g_time[playerid][1] += 1;
	        if(g_time[playerid][1] == 59 && g_time[playerid][0] == 0)
	        {
	            g_time[playerid][1] = 0;
	            g_time[playerid][2] += 1;
	        }
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	new string[250];

	StopAudioStreamForPlayer(playerid);

	HeadShot[playerid] = false;

	PreloadAnimLib(playerid,"BOMBER");
	PreloadAnimLib(playerid,"RAPPING");
	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"SMOKING");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"ON_LOOKERS");
	PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");

	if(GetPVarInt(playerid, "Textdraw4Me") == 1)
	{
		PlayerTextDrawShow(playerid, Textdraw0);
		TextDrawShowForPlayer(playerid, Textdraw4);
		TextDrawShowForPlayer(playerid, Textdraw5);
		TextDrawShowForPlayer(playerid, Textdraw6);
		TextDrawShowForPlayer(playerid, Textdraw7);
		PlayerTextDrawShow(playerid, Textdraw9);
		TextDrawShowForPlayer(playerid, Textdraw10);
	}

	if(User[playerid][accountUse] == 1)
	{
    	SetPlayerSkin(playerid, User[playerid][accountSkin]);
	}

	SetCameraBehindPlayer(playerid);
	PlayerPlaySound(playerid, 1186, 2116.0205, 2143.3225, 10.8203);

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, -2629.9939, 1402.4919, 7.0994);
    SetPlayerFacingAngle(playerid, 253.5358);
    
    if(User[playerid][accountJail] == 0)
    {
        if(g_DM[playerid] == 0)
        {
			if(jpInfo[playerid][p_Spawn] == 1)
			{
			    #if FREEZE_LOAD == true
			        House_Load(playerid);
				#endif

			    SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] "white"Spawned at your house.");

				#if FORCE_SPAWNHOME == true
				SetTimerEx("JakSpawnHome", 2500, false, "d", playerid);
				SendClientMessage(playerid, -1, "Force respawning to your house...");
				#else
			    SetPlayerInterior(playerid, jpInfo[playerid][p_Interior]);
			    SetPlayerPos(playerid, jpInfo[playerid][p_SpawnPoint][0], jpInfo[playerid][p_SpawnPoint][1], jpInfo[playerid][p_SpawnPoint][2]);
			    SetPlayerFacingAngle(playerid, jpInfo[playerid][p_SpawnPoint][3]);
				#endif
			}
		}
		else if(g_DM[playerid] == 1)
		{
		    ResetPlayerWeapons(playerid);
		    SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have spawned at Minigun Arena: "white"/leavedm to leave the arena.");
		    MinigunSpawn(playerid);
		}
		else if(g_DM[playerid] == 2)
		{
		    ResetPlayerWeapons(playerid);
		    SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have spawned at Sniper Arena: "white"/leavedm to leave the arena.");
		    SniperSpawn(playerid);
		}
    }
    
    if(User[playerid][accountJail] == 1)
    {
        LoadPlayer(playerid);
		new rand = random(sizeof(jailspawn));
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 69);
	    SetPlayerPos(playerid, jailspawn[rand][0], jailspawn[rand][1], jailspawn[rand][2]);
	    SetPlayerFacingAngle(playerid, jailspawn[rand][3]);

	    format(string, 200, "[PUNISHMENT] "white"You have been placed in the jail for "grey"%d "white"seconds.", User[playerid][accountJailSec]);
	    SendClientMessage(playerid, COLOR_RED, string);
    }
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
	new string[250];
	new weaponName[32];
    GetWeaponName(weaponid, weaponName, sizeof (weaponName));
    if(issuerid != INVALID_PLAYER_ID)
    {
        if(weaponid >= 22 && weaponid <= 34)
        {
            if(GetPVarInt(playerid, "GodMode") == 0)
            {
	            if(bodypart == 9)
	            {
	                if(HeadShot[playerid] == false)
	                {
						format(string, sizeof(string), "[HEADSHOT] "white"%s has hit you in the head with %s", GetName(issuerid), weaponName);
						SendClientMessage(playerid, COLOR_RED, string);
						format(string, sizeof(string), "[HEADSHOT] "white"You have hit Player %s in the head using %s.", GetName(playerid), weaponName);
						SendClientMessage(issuerid, COLOR_RED, string);
						GameTextForPlayer(playerid, "~r~Headshot!", 3000, 3);
						GameTextForPlayer(issuerid, "~r~Headshot!", 3000, 3);
				        SetPlayerHealth(playerid, 0.0);
				        HeadShot[playerid] = true;
					}
				}
			}
		}
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[250];

	User[playerid][accountDeaths] ++;
	if(killerid != INVALID_PLAYER_ID)
	{
		User[killerid][accountKills] ++;
		SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
		GivePlayerCash(playerid, 1000);
	}

	for(new x=0; x<MAX_PLAYERS; x++)
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid)
   		   	AdvanceSpectate(x);

	PlayerTextDrawHide(playerid, Textdraw9);

	SendDeathMessage(killerid, playerid, reason);
	
    new
        sString[250],
        Float:Health,
        Float:Armor;

	if( Minigamer_{ playerid } == true )
	{
		if( inProgress > 1 )
		{
   			format( string, sizeof string, "[DGW] {%06x}%s "white"has dropped out of "red"Don't Get Wet minigame, "white"rank "grey"%d", GetPlayerColor(playerid) >>> 8, GetName( playerid ), Iter_Count(_Minigamer));
			SendClientMessageToAll( -1, string );
			Iter_Remove(_Minigamer, playerid );
			Minigamer_{ playerid } = false;
			if( Iter_Count(_Minigamer) < 2 )
			{
			    foreach(_Minigamer, i) MinigameWinner( i );
			}
		}
		else
		{
			SendClientMessage( playerid, COLOR_GREY, "Your sign up for Don't Get Wet minigame has been cancelled." );
			Iter_Remove(_Minigamer, playerid );
			Minigamer_{ playerid } = false;
		}
	}

	if(killerid == INVALID_PLAYER_ID)
	{
	    if(g_IsPlayerDueling[playerid] == 1)
	    {
			if(playerid == g_DuelingID1) { }
			else
			{
		        format(sString, 250, "[DUEL] "white"%s won the duel against %s "green"he/she won $4000 + 3 score, "white"%s died his/her own.", GetName(g_DuelingID1), GetName(playerid), GetName(playerid));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sString);
		        SendClientMessage(g_DuelingID1, COLOR_GREEN, "You won $4000 and 3 scores from a duel against a player.");
				SetPlayerScore(g_DuelingID1, GetPlayerScore(g_DuelingID1) + 3);
				GivePlayerCash(g_DuelingID1, 4000);

		        g_GotInvitedToDuel[playerid] = 0;g_HasInvitedToDuel[playerid] = 0;g_IsPlayerDueling[playerid]  = 0;
		        g_GotInvitedToDuel[g_DuelingID1] = 0;g_HasInvitedToDuel[g_DuelingID1] = 0;g_IsPlayerDueling[g_DuelingID1]  = 0;
		        g_DuelInProgress = 0;
		        
		        ResetPlayerWeapons(g_DuelingID1);
				SpawnPlayer(g_DuelingID1);
		        g_DuelingID1 = -1;
		        g_DuelingID2 = -1;
			}
			if(playerid == g_DuelingID2) { }
			else
			{
		        format(sString, 250, "[DUEL] "white"%s won the duel against %s "green"he/she won $4000 + 3 score, "white"%s died his/her own.", GetName(g_DuelingID2), GetName(playerid), GetName(playerid));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sString);
		        SendClientMessage(g_DuelingID2, COLOR_GREEN, "You won $4000 and 3 scores from a duel against a player.");
				SetPlayerScore(g_DuelingID1, GetPlayerScore(g_DuelingID2) + 3);
				GivePlayerCash(g_DuelingID2, 4000);

		        g_GotInvitedToDuel[playerid] = 0;g_HasInvitedToDuel[playerid] = 0;g_IsPlayerDueling[playerid]  = 0;
		        g_GotInvitedToDuel[g_DuelingID2] = 0;g_HasInvitedToDuel[g_DuelingID2] = 0;g_IsPlayerDueling[g_DuelingID2]  = 0;
		        g_DuelInProgress = 0;

		        ResetPlayerWeapons(g_DuelingID2);
				SpawnPlayer(g_DuelingID2);
		        g_DuelingID1 = -1;
		        g_DuelingID2 = -1;
			}
	    }
	}
    if(g_IsPlayerDueling[playerid] == 1 && g_IsPlayerDueling[killerid] == 1)
    {
        GetPlayerHealth(killerid, Health);
        GetPlayerArmour(killerid, Armor);

        format(sString, 250, "[DUEL] "white"%s won the duel against %s "green"he/she won $4000 + 3 score "white"and has %.2f health and %.2f armor left!", GetName(killerid), GetName(playerid), Health, Armor);
        SendClientMessageToAll(COLOR_LIGHTBLUE, sString);
        SendClientMessage(killerid, COLOR_GREEN, "You won $4000 and 3 scores from a duel against a player.");
		SetPlayerScore(killerid, GetPlayerScore(killerid) + 3);
		GivePlayerCash(killerid, 4000);

        g_GotInvitedToDuel[playerid] = 0;g_HasInvitedToDuel[playerid] = 0;g_IsPlayerDueling[playerid]  = 0;
        g_GotInvitedToDuel[killerid] = 0;g_HasInvitedToDuel[killerid] = 0;g_IsPlayerDueling[killerid]  = 0;
        g_DuelInProgress = 0;
        g_DuelingID1 = -1;
        g_DuelingID2 = -1;

        ResetPlayerWeapons(killerid);
		SpawnPlayer(killerid);
    }
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	foreach(new i : Player)
	{
	    if(vehicleid == pVehicle[i])
	    {
			DestroyVehicle(pVehicle[i]);
			pVehicle[i] = -1;
	    }
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new string[250];

	if(strfind(text, ":", true) != -1) {
		new
			i_numcount,
			i_period,
			i_pos;

		while(text[i_pos]) {
			if('0' <= text[i_pos] <= '9') i_numcount++;
			else if(text[i_pos] == '.') i_period++;
			i_pos++;
		}
		if(i_numcount >= 8 && i_period >= 3)
		{
		    ipDetect[playerid] ++;
		    if(ipDetect[playerid] == 4)
		    {
				new	ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years;

				gettime(ban_hr, ban_min, ban_sec);
				getdate(ban_years, ban_month, ban_days);
				new when[128];
				format(when, 128, "%02d/%02d/%d %02d:%02d:%02d", ban_month, ban_days, ban_years, ban_hr, ban_min, ban_sec);

				Clear_Chat(playerid);

                format(string, sizeof(string), "[ANTICHEAT] "white"%s has been banned for attempted Server Ad by Finn (Anticheat)", GetName(playerid));
                SendClientMessageToAll(COLOR_RED, string);
                format(string, sizeof(string), "» "red"Player %s (ID: %d) has been banned for attempted Server Ad by Finn The Anticheat, IP %s.", GetName(playerid), playerid, User[playerid][accountIP]);
				foreach(new i : Player)
				{
				    if(User[i][accountLogged] == true)
				    {
				        if(User[i][accountAdmin] >= 1)
				        {
				            SendClientMessage(i, COLOR_RED, string);
				        }
				    }
				}
                format(string, sizeof(string), "[ANTICHEAT] %s has been banned for attempted Server Ad by Finn (Anticheat) - (BannedPlayer IP %s)", GetName(playerid), User[playerid][accountIP]);
                Log("finn.txt", string);

			    format(sInfo[last_bperson], 256, "%s", GetName(playerid));
			    format(sInfo[last_bwho], 256, "Finn (Anticheat)");
			    sInfo[bannedac] ++;
			    savestatistics();

				BanAcc(playerid, "Finn (AC)", "Server Advertisement");
				AddBan(User[playerid][accountIP], 1);
				ShowBan(playerid, "Finn (AC)", "Server Advertisement", when);
				KickDelay(playerid);
		        return 0;
		    }
			format(string, sizeof(string), "[FINN ALERT] "white"%s may be server advertising: '%s'.", GetName(playerid), text);
			foreach(new i : Player)
			{
			    if(User[i][accountLogged] == true)
			    {
			        if(User[i][accountAdmin] >= 1)
			        {
			            SendClientMessage(i, COLOR_RED, string);
			        }
			    }
			}
			SendClientMessage(playerid, -1, "Our anticheat Finn has detected something, Please hold on for a second.");
			return 0;
		}
	}
	
	if(User[playerid][accountMuted] == 1)
	{
	    format(string, sizeof(string), "» "orange"You are still muted, You can talk after "grey"%d "orange"seconds.", User[playerid][accountMuteSec]);
	    SendClientMessage(playerid, -1, string);
	    return 0;
	}

	if(!strcmp(Chars, text, false) && end_reaction == 1)
	{
	    format(string, sizeof(string), ""red"[CONTEST] {%06x}%s(%d) "white"won the contest and received "green"$3000 + 5 score", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid);
	    SendClientMessageToAll(-1, string);
	    GivePlayerCash(playerid, 3000);
	    
	    User[playerid][accountReact]++;
	    
	    SetPlayerScore(playerid, GetPlayerScore(playerid) + 5);
	    format(Chars, sizeof Chars, "");
	    end_reaction = 0;
	    KillTimer(timers[2]);
	    return 0;
	}
	
	if(_RP[playerid] == 0)
	{
		if(AdminDuty[playerid] == 0)
		{
		    if(User[playerid][accountVIP] == 1 && User[playerid][accountAdmin] == 0 && User[playerid][accountHelper] == 0)
		    {
			    format(string, sizeof(string), "{%06x}%s: "white"[%d] "newb"%s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);
			    SendClientMessageToAll(playerid, string);
		    }
			else if(User[playerid][accountVIP] == 1 && User[playerid][accountAdmin] >= 1 || User[playerid][accountHelper] == 1)
			{
			    format(string, sizeof(string), "{%06x}%s: "white"[%d] "grey"%s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);
			    SendClientMessageToAll(playerid, string);
			}
			else if(User[playerid][accountVIP] == 0 && User[playerid][accountAdmin] >= 1 || User[playerid][accountHelper] == 1)
			{
			    format(string, sizeof(string), "{%06x}%s: "white"[%d] "grey"%s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);
			    SendClientMessageToAll(playerid, string);
			}
			else
			{
			    format(string, sizeof(string), "{%06x}%s: "white"[%d] %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, text);
			    SendClientMessageToAll(playerid, string);
			}

		    format(string, sizeof(string), "%s", text);
		    SetPlayerChatBubble(playerid, string, COLOR_GREY, 50.0, 1000*10);
		}
		else
		{
		    new ranks[90];

			switch(User[playerid][accountAdmin])
			{
			    case 1: ranks = "Moderator";
			    case 2: ranks = "Admin";
			    case 3: ranks = "Head Admin";
			    case 4: ranks = "Manager";
			    case 5: ranks = "Owner";
			}

		    format(string, sizeof(string), "%s: "white"%s", ranks, text);
		    SendPlayerMessage(COLOR_RED, string);
		    format(string, sizeof(string), "%s: "white"%s", GetName(playerid), text);
		    SendAMessage(COLOR_RED, string);
		}
	}
	else
	{
	    format(string, sizeof(string), "[RP] %s says: %s", GetName(playerid), text);
	    ProxDetector(20.0, playerid, string,COLOR_GRAD5,COLOR_GRAD4,COLOR_GRAD3,COLOR_GRAD2,COLOR_GRAD1);
	}
	return 0;
}

public Anticheat()
{
	foreach(new i : Player)
	{
		if(money_anti[i] != GetPlayerMoney(i))
		{
			ResetPlayerMoney(i);
			GivePlayerMoney(i, money_anti[i]);
		}
	}
	return 1;
}

//============================================================================//
//  ZCMD    //
//============================================================================//

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success)
	{
        new
            string[256], output1[50], output2[50]
		;
		sscanf(cmdtext, "p< >s[50]s[50]", output1, output2);
        format(string, sizeof(string), ""lightblue"SERVER: "white"The command '"lightred"%s"white"' doesn't exist, Please refer to "grey"/commands "white"or "grey"/help", output1);
        SendClientMessage(playerid, -1, string);
	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	new string[200];

	if(User[playerid][accountCMuted] == 1)
	{
	    format(string, sizeof(string), "» "orange"You are still muted, You can use all the commands after "grey"%d "orange"seconds.", User[playerid][accountCMuteSec]);
	    SendClientMessage(playerid, -1, string);
	    return 0;
	}

	if(strfind(cmdtext, ":", true) != -1)
	{

		new
			i_numcount,
			i_period,
			i_pos;

		while(cmdtext[i_pos]) {
			if('0' <= cmdtext[i_pos] <= '9') i_numcount++;
			else if(cmdtext[i_pos] == '.') i_period++;
			i_pos++;
		}
		if(i_numcount >= 8 && i_period >= 3)
		{
		    ipDetect[playerid] ++;
		    if(ipDetect[playerid] == 4)
		    {
				new	ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years;

				gettime(ban_hr, ban_min, ban_sec);
				getdate(ban_years, ban_month, ban_days);
				new when[128];
				format(when, 128, "%02d/%02d/%d %02d:%02d:%02d", ban_month, ban_days, ban_years, ban_hr, ban_min, ban_sec);

				Clear_Chat(playerid);

                format(string, sizeof(string), "[ANTICHEAT] "white"%s has been banned for attempted Server Ad by Finn (Anticheat)", GetName(playerid));
                SendClientMessageToAll(COLOR_RED, string);
                format(string, sizeof(string), "» "red"Player %s (ID: %d) has been banned for attempted Server Ad by Finn The Anticheat, IP %s.", GetName(playerid), playerid, User[playerid][accountIP]);
				foreach(new i : Player)
				{
				    if(User[i][accountLogged] == true)
				    {
				        if(User[i][accountAdmin] >= 1)
				        {
				            SendClientMessage(i, COLOR_RED, string);
				        }
				    }
				}
                format(string, sizeof(string), "[ANTICHEAT] %s has been banned for attempted Server Ad by Finn (Anticheat) - (BannedPlayer IP %s)", GetName(playerid), User[playerid][accountIP]);
                Log("finn.txt", string);

			    format(sInfo[last_bperson], 256, "%s", GetName(playerid));
			    format(sInfo[last_bwho], 256, "Finn (Anticheat)");
			    sInfo[bannedac] ++;
			    savestatistics();

				BanAcc(playerid, "Finn (AC)", "Server Advertisement");
				AddBan(User[playerid][accountIP], 1);
				ShowBan(playerid, "Finn (AC)", "Server Advertisement", when);
				KickDelay(playerid);
		        return 0;
		    }
			format(string, sizeof(string), "[FINN ALERT] "white"%s may be server advertising: '%s'.", GetName(playerid), cmdtext);
			foreach(new i : Player)
			{
			    if(User[i][accountLogged] == true)
			    {
			        if(User[i][accountAdmin] >= 1)
			        {
			            SendClientMessage(i, COLOR_RED, string);
			        }
			    }
			}
			SendClientMessage(playerid, -1, "Our anticheat Finn has detected something, Please hold on for a second.");
			return 0;
		}
	}

    format(string, sizeof(string), "*** %s(%d) : '%s'", GetName(playerid), playerid, cmdtext);
    foreach(new i : Player)
    {
        if(User[i][accountAdmin] >= 1 && User[i][accountAdmin] > User[playerid][accountAdmin] && i != playerid)
        {
            SendClientMessage(i, COLOR_GREY, string);
        }
    }
	return 1;
}

CMD:rules(playerid, params[])
{
	new string[1400];
	strcat(string, ""red"");
	strcat(string, "Server Rules, Follow the /rules otherwise face the consequences.\n\n");
	strcat(string, ""grey"");
	strcat(string, "• You are not allowed to use hacks, and third party modifications.\n");
	strcat(string, "• You may not do UNRP stuffs on RP world, You may light RP though (E.G. /me eats the food)\n");
	strcat(string, "• You may not AFK at the Spawn Points.\n");
	strcat(string, "• Exploiting bugs / hidden commands aren't allowed, You may get banned, depending on the situation.\n");
	strcat(string, "• Advertising other stuffs aren't allowed.\n");
	strcat(string, "• We do not allow players who are power hungry, We instantly banned these players.\n");
	strcat(string, "• Giving away / trading / selling accounts are highly forbidden.\n");
	strcat(string, "• Abusing the script commands aren't allowed.\n");
	strcat(string, "• Insulting the server, the players or in any type of insult is forbidden.");
	strcat(string, ""lightblue"");
	strcat(string, "\n\n");
	strcat(string, "Admins may choose their own punishment, depending on the situations (E.G. trolling - Kick or Jail).");
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Server Rules", string, "Close", "");
	return 1;
}

CMD:o(playerid, params[])
{
	if(_RP[playerid] == 0) return SendClientMessage(playerid, -1, "This command isn't available, Unless you are in Roleplay World.");

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /o [ooc chat]");

	new string[128];
	format(string, sizeof(string), "(( [RP] %s [%d]: %s ))", GetName(playerid), playerid, params);
	SendClientMessageToAll(COLOR_OOC, string);
	return 1;
}

//Modified version.
CMD:startwet(playerid, params[])
{
	if(inProgress < 1)
	{
	    VIEW_FROM_ABOVE = true;

		new string[128];
		Minigamer_{ playerid } = true;
		Iter_Add(_Minigamer, playerid);
		format( string, sizeof( string ), "[MINIGAME] "white"%s has started the Don't Get Wet minigame, it will start in 20 seconds. Type /getwet to join!", GetName(playerid) );
		SendClientMessageToAll( COLOR_RED, string );
		SetTimer( "MinigameCountdown", 20000, 0 );
		for( new i; i < MAX_SLOTS; i++ )
	    {
	        //The object (window) is only visible from one side
			Objects_[0][i] = CreateDynamicObject( 1649, gCoords[i][0], gCoords[i][1], gCoords[i][2], -90.000000, 0.000000, 0.000000, -1, -1, -1, 150.0, 150.0 );

			Iter_Add(_Objects, i);
	    }
	    inProgress = 1;
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "A player has already started the minigame.");
	}
	return 1;
}

CMD:getwet(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	if( Minigamer_{ playerid } != false )
		return SendClientMessage( playerid, COLOR_RED, "You have already signed up for Don't Get Wet minigame." );
	else if( inProgress > 1 )
		return SendClientMessage( playerid, COLOR_RED, "Don't Get Wet minigame is currently in progress, please wait." );
	else if( Iter_Count(_Minigamer) > MAX_SLOTS-1 )
		return SendClientMessage( playerid, COLOR_RED, "Don't Get Wet minigame is already full. Please wait untill it ends." );
    if( inProgress < 1 )
    {
        /*
        Modified version remember?, Commented the original code.
        Note, Once you enable it lots of bugs will show up on other regions/script of the Don't Get Wet code.
        
	    if( strcmp( params, "1", true ) == 0 )
	    VIEW_FROM_ABOVE = true;
	    else if( strcmp( params, "2", true ) == 0 )
		VIEW_FROM_ABOVE = false;
	    else return SendClientMessage( playerid, WHITE, "Use: /getwet [1 or 2]" );

		new str[128];
		Minigamer_{ playerid } = true;
		Iter_Add(_Minigamer, playerid );
		format( str, sizeof( str ), "Don't Get Wet v.%i.0 "COL_RULE"minigame will start in 20 seconds. Type "COL_ORANGE"/getwet "COL_RULE"to join!", strval(params) );
		SendClientMessageToAll( ORANGE, str );
		SetTimer( "MinigameCountdown", 20000, 0 );
		for( new i; i < MAX_SLOTS; i++ )
	    {
	        //The object (window) is only visible from one side
			Objects_[0][i] = CreateObject( 1649, gCoords[i][0], gCoords[i][1], gCoords[i][2], -90.000000, 0.000000, 0.000000, 150.0 );
			if(!VIEW_FROM_ABOVE) //In case /getwet 2, we need to multiply number of objects and turn them around so players would be able to see them from below
			Objects_[1][i] = CreateObject( 1649, gCoords[i][0], gCoords[i][1], gCoords[i][2], -270.000000, 0.000000, 0.000000, 150.0 );
			Iter_Add(_Objects, i );
	    }
	    inProgress = 1;
	    */
	    
	    SendClientMessage(playerid, -1, "No Don't Get Wet minigame started at the moment, /startwet.");
    }
    else
    {
    	Minigamer_{ playerid } = true;
 		Iter_Add(_Minigamer, playerid);
		SendClientMessage( playerid, COLOR_YELLOW, "You have signed up for Don't Get Wet minigame." );
	}
	return 1;
}

CMD:musics(playerid, params[])
{
	SpawnCheck(playerid);
	ShowPlayerDialog(playerid, DIALOG_MUSICS, DIALOG_STYLE_LIST, ""lightred"Pre-made Musics", "You're my number one by S Club 7\nChristmas Song\nThe Fox by Ylvis\nRude by MAGIC!\nTrumpets by Jason DeRulo\nProblem by Ariana Grande ft. Iggy Azalea\nBoombastic by Shaggy\nThousand Years by Christina Perri\nTalk to JaKe if you wanna add your music here.", "Choose", "Cancel");
	return 1;
}

CMD:radios(playerid, params[])
{
	SpawnCheck(playerid);
	new list[500];
	for(new i; i <= sizeof(radiolist); i++)
	{
	    if(i == sizeof(radiolist)) format(list, 500,"%s\n", list);
	    else format(list, 500, "%s\n%d. %s",list, i+1, radiolist[i][1]);
	}
	ShowPlayerDialog(playerid, DIALOG_RADIOS, DIALOG_STYLE_LIST, ""lightred"Online Radio Stations", list, "Play", "Close");
	return 1;
}

CMD:moff(playerid, params[])
{
	SpawnCheck(playerid);
	StopAudioStreamForPlayer(playerid);
	SendClientMessage(playerid, COLOR_RED, "* Audio streams that are currently playing has been stopped.");
	SendClientMessage(playerid, -1, "* If you wanna hear the normal GTA SA Radio Stations, Exit and Enter the vehicle again.");
	return 1;
}

CMD:kill(playerid, params[])
{
	SpawnCheck(playerid);
	if(g_AFK[playerid] == 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while AFK.");
	if(GetPVarInt(playerid, "GodMode") == 1)
	{
		SetPVarInt(playerid, "GodMode", 0);
		SetPlayerHealth(playerid, 0.0);
	}
	else
	{
		SetPlayerHealth(playerid, 0.0);
	}
	
	SendClientMessage(playerid, COLOR_RED, "You have commited suicide.");
	return 1;
}

CMD:saveskin(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	new string[150], SkinID;
	if(sscanf(params, "i", SkinID)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /saveskin [skinid(0-299)]");
	if(SkinID < 0 || SkinID == 74 || SkinID > 299) return SendClientMessage(playerid, -1, "» "red"Invalid skinID.");
 	format(string, sizeof(string), "You have successfully saved this skin (ID %d)", SkinID);
 	SendClientMessage(playerid, COLOR_YELLOW, string);
	SendClientMessage(playerid, -1, "Type: /useskin to use this skin when you spawn or /dontuseskin to stop using skin");
	User[playerid][accountSkin] = SkinID, User[playerid][accountUse] = 1;
	SetPlayerSkin(playerid, SkinID);
	return 1;
}

CMD:useskin(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
    User[playerid][accountUse] = 1;
    SetPlayerSkin(playerid, User[playerid][accountSkin]);
	SendClientMessage(playerid, COLOR_YELLOW, "Skin now in use.");
	return 1;
}

CMD:dontuseskin(playerid, params[])
{
	LoginCheck(playerid);
    User[playerid][accountUse] = 0;
	SendClientMessage(playerid, COLOR_YELLOW, "Skin will no longer be used.");
	return 1;
}

#if CHRISTMAS_SPIRIT == true
	CMD:snow(playerid, params[])
	{
	    if(snowOn{playerid})
	    {
	        DeleteSnow(playerid);
	        SendClientMessage(playerid, COLOR_RED, "[SNOW] "white"It's not snowing anymore now.");
	    }
	    else
	    {
	        CreateSnow(playerid);
	        SendClientMessage(playerid, COLOR_RED, "[SNOW] "white"Let it snow, let it snow, let it snow!");
	    }
	    return 1;
	}
#endif

CMD:spos(playerid, params[])
{
	SpawnCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}
	new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPVarFloat(playerid, "X", x);
    SetPVarFloat(playerid, "Y", y);
    SetPVarFloat(playerid, "Z", z);
    SetPVarInt(playerid, "Int", GetPlayerInterior(playerid));
    SetPVarInt(playerid, "Vir", GetPlayerVirtualWorld(playerid));
    SendClientMessage(playerid, COLOR_LIGHTBLUE, "[POSITION] "white"You have saved your current position, /lpos to load it.");
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	if(Possaved[playerid] == 0)
    {
	    Possaved[playerid] = 1;
	}
	return 1;
}

CMD:lpos(playerid, params[])
{
	SpawnCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}
	if(Possaved[playerid] == 1)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
		    SetPlayerInterior(playerid, GetPVarInt(playerid, "Int"));
		    SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "Vir"));
			SetPlayerPos(playerid, GetPVarFloat(playerid,"X"), GetPVarFloat(playerid,"Y"), GetPVarFloat(playerid,"Z"));
		}
		else if(IsPlayerInAnyVehicle(playerid))
		{
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPVarInt(playerid, "Int"));
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPVarInt(playerid, "Vir"));
			SetVehiclePos(GetPlayerVehicleID(playerid), GetPVarFloat(playerid,"X"), GetPVarFloat(playerid,"Y"), GetPVarFloat(playerid,"Z"));
		}
		SendClientMessage(playerid, COLOR_LIGHTBLUE,  "[POSITION] "white"You have teleported to your saved position.");
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	}
    else SendClientMessage(playerid, -1, "» "red"You didn't saved any positions, /spos first!");
	return 1;
}

CMD:myw(playerid, params[])
{
	new weather, string[128];
	SpawnCheck(playerid);
	if(sscanf(params, "i", weather)) return SendClientMessage(playerid, COLOR_RED, "USAGE: (/myw)eather [0 - 45]");
	if(weather < 0 || weather > 45) return SendClientMessage(playerid, -1, "» "red"Invalid WeatherID! <0 - 45>");
	SetPlayerWeather(playerid, weather);
	format(string, sizeof(string), "[WEATHER] "white"You changed your weather to \"%d\"", weather);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	return 1;
}
CMD:myweather(playerid, params[]) return cmd_myw(playerid, params);

CMD:mytime(playerid, params[])
{
	new time, string[128];
	SpawnCheck(playerid);
	if(sscanf(params, "i", time)) return SendClientMessage(playerid, COLOR_RED, "USAGE: (/myt)ime [0 - 23]");
	if(time < 0 || time > 23) return SendClientMessage(playerid, -1, "» "red"Invalid Time! <0 - 23>");
	format(string, sizeof(string), "[TIME] "white"You changed your time to \"%02d:00\"", time);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	SetPlayerTime(playerid, time, 0);
	return 1;
}
CMD:myt(playerid, params[]) return cmd_mytime(playerid, params);

CMD:af(playerid, params[])
{
	SpawnCheck(playerid);
	if(Act[playerid] == 0)
	{
        Act[playerid] = 1;
        GameTextForPlayer(playerid, "~w~Anti fall off bike is now ~g~on", 5000, 5);
        SendClientMessage(playerid, COLOR_RED, "[ANTIFALL] "white"Anti fall off bike is now "green"on.");
	}
	else if(Act[playerid] == 1)
	{
        Act[playerid] = 0;
        GameTextForPlayer(playerid, "~w~Anti fall off bike is now ~r~off", 5000, 5);
        SendClientMessage(playerid, COLOR_RED, "[ANTIFALL] "white"Anti fall off bike is now "red"off.");
	}
	return 1;
}

CMD:low(playerid, params[]) {
	return cmd_l(playerid, params);
}

CMD:l(playerid, params[])
{
	if(_RP[playerid] == 0) return SendClientMessage(playerid, -1, "This command isn't available, Unless you are in Roleplay World.");

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: (/l)ow [close chat]");

	new string[128];
	format(string, sizeof(string), "%s says quietly: %s", GetName(playerid), params);
	ProxDetector(20.0, playerid, string,COLOR_GRAD5,COLOR_GRAD4,COLOR_GRAD3,COLOR_GRAD2,COLOR_GRAD1);
	format(string, sizeof(string), "(quietly) %s", params);
	SetPlayerChatBubble(playerid, string, COLOR_WHITE, 5.0, 5000);
	return 1;
}

CMD:shout(playerid, params[]) {
	return cmd_shout(playerid, params);
}

CMD:s(playerid, params[])
{
	if(_RP[playerid] == 0) return SendClientMessage(playerid, -1, "This command isn't available, Unless you are in Roleplay World.");

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: (/s)hout [shout chat]");

	new string[128];
	format(string, sizeof(string), "(shouts) %s", params);
	SetPlayerChatBubble(playerid, string, COLOR_WHITE, 60.0, 5000);
	format(string, sizeof(string), "%s shouts: %s", GetName(playerid), params);
 	ProxDetector(20.0, playerid, string,COLOR_GRAD5,COLOR_GRAD4,COLOR_GRAD3,COLOR_GRAD2,COLOR_GRAD1);
	return 1;
}

CMD:b(playerid, params[])
{
	if(_RP[playerid] == 0) return SendClientMessage(playerid, -1, "This command isn't available, Unless you are in Roleplay World.");

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /b [local ooc chat]");
    new string[128];

    format(string, sizeof(string), "(( [RP] %s [%d]: %s", GetName(playerid), playerid, params);
    ProxDetector(20.0, playerid, string,COLOR_GRAD5,COLOR_GRAD4,COLOR_GRAD3,COLOR_GRAD2,COLOR_GRAD1);
	return 1;
}

CMD:do(playerid, params[])
{
	if(_RP[playerid] == 0) return SendClientMessage(playerid, -1, "This command isn't available, Unless you are in Roleplay World.");

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /do [action]");

	new string[128];
	format(string, sizeof(string), "* %s (( %s ))", params, GetName(playerid));
	ProxDetector(30.0, playerid, string, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME);
	return 1;
}

CMD:me(playerid, params[])
{
	new string[250];

	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /me [text]");
	if(_RP[playerid] == 0)
	{
		format(string, sizeof(string), "* %s %s *", GetName(playerid), params);
		SendClientMessageToAll(GetPlayerColor(playerid), string);
	}
	else
	{
		format(string, sizeof(string), "* %s %s", GetName(playerid), params);
		ProxDetector(30.0, playerid, string, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME);
	}
	return 1;
}

CMD:afks(playerid, params[])
{
	new
	    count = 0
	;

	new
	    string[256],
	    string2[3000]
	;

	strcat(string2, ""grey"");
	strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' AFK Players.\n");
	strcat(string2, ""white"");
	strcat(string2, "/afk to AFK (You'll be listed here), /afk again to head back to Playing Mode.\n\n");

    foreach (new i : Player)
    {
	    if(g_AFK[i] == 1)
	    {
	        count++;
            format(string, sizeof(string), "{%06x}%s (ID:%d) (Reason: %s)\n", GetPlayerColor(i) >>> 8, GetName(i), i, g_Reason[i]);
            strcat(string2, string);
        }
    }
    if(count == 0)
    {
        strcat(string2, ""grey"");
        strcat(string2, "No AFK players at the moment.\n");
    }

    format(string, sizeof string, ""orange"Overall AFK Players: "grey"%d\n", count);
    strcat(string2, string);

    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"AFK Players", string2, "Close", "");
	return 1;
}

CMD:afk(playerid, params[])
{
	new id = g_AFK[playerid];
	new string[150];
	new Float:x_Pos[3];
	GetPlayerPos(playerid, x_Pos[0], x_Pos[1], x_Pos[2]);
	SpawnCheck(playerid);
	if(id == 0)
	{
	    if(sscanf(params, "S(None of your business.)[128]", g_Reason[playerid])) return SendClientMessage(playerid, COLOR_RED, "USAGE: /afk [reason]");
		if(g_DM[playerid] >= 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command at this situation.");
		if(g_IsPlayerDueling[playerid] == 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command at this situation.");

		format(string, sizeof(string), "[AFK] {%06x}%s "white"is now away from his/her keyboard (/afk) [Reason: "grey"%s"white"]", GetPlayerColor(playerid) >>> 8, GetName(playerid), g_Reason[playerid]);
		SendClientMessageToAll(-1, string);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "** Please type /afk again to play again - Playing Mode. **");

		SetPlayerPos(playerid, x_Pos[0], x_Pos[1], x_Pos[2]+0.25);

		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerid)+3);
		TogglePlayerControllable(playerid, 0);
		
		g_AFK[playerid] = 1;
	}
	else if(id == 1)
	{
		format(string, sizeof(string), "[AFK] {%06x}%s "white"went back from his/her mode as Away from Keyboard.", GetPlayerColor(playerid) >>> 8, GetName(playerid));
		SendClientMessageToAll(-1, string);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "** Please type /afk again to went on AFK mode. **");

		SetPlayerPos(playerid, x_Pos[0], x_Pos[1], x_Pos[2]+0.25);

		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerid)-3);
		TogglePlayerControllable(playerid, 1);
		
		g_AFK[playerid] = 0;
	}
	return 1;
}

CMD:akill(playerid, params[])
{
	new string[128], reason[128], id;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
        if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /akill [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		if(g_AFK[id] == 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on AFK'ed player.");
		if(GetPVarInt(id, "GodMode") == 1) 
		{
			SetPVarInt(id, "GodMode", 0);
			SetPlayerHealth(id, 0.0);
		}
		else
		{
			SetPlayerHealth(id, 0.0);
		}
			
        format(string, sizeof(string), "[PUNISHMENT] "white"%s has been Admin Killed by an admin for "grey"%s", GetName(id), reason);
        SendPlayerMessage(COLOR_RED, string);
        format(string, sizeof(string), "[PUNISHMENT] "white"%s has been Admin Killed by %s for "grey"%s", GetName(id), GetName(playerid), reason);
        SendAMessage(COLOR_RED, string);
        format(string, sizeof(string), "An admin has admin-killed you for %s.", reason);
        SendClientMessage(id, COLOR_GREY, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:seths(playerid, params[])
{
	new string[150], id, h;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5)
	{
	    if(sscanf(params, "ui", id, h)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /sethshoe [playerid] [0-30]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");
	    if(h < 0 || h > 30) return SendClientMessage(playerid, -1, "» "red"Invalid Horseshoe ID!");
		User[id][accountHS] = h;
		format(string, sizeof(string), "[HORSESHOE] "white"%s's Horseshoe has been set to %d by Owner %s.", GetName(id), h, GetName(playerid));
		SendClientMessage(playerid, COLOR_GREEN, string);
		format(string, sizeof(string), "Owner %s has set your horseshoe collection to %d.", GetName(playerid), h);
		SendClientMessage(id, COLOR_GREEN, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:gotohs(playerid, params[])
{
	new string[150], id;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
	    if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /gotohorseshoe [0-29]");
	    if(id < 0 || id > 29) return SendClientMessage(playerid, -1, "» "red"Invalid Horseshoe ID!");
		if(id == 0)
		{
		    SetCameraBehindPlayer(playerid);
		    SetPlayerPos(playerid, 2011.8767, 1544.7483+3, 9.4787);
		    SetPlayerInterior(playerid, 0);
		    SetPlayerVirtualWorld(playerid, 0);
		}
		else if(id >= 1)
		{
		    SetCameraBehindPlayer(playerid);
		    SetPlayerPos(playerid, hcord[id][hx], hcord[id][hy], hcord[id][hz]);
		    SetPlayerInterior(playerid, 0);
		    SetPlayerVirtualWorld(playerid, 0);
		}
		format(string, sizeof(string), "You have been teleported to %i/30 horseshoe.", id+1);
		SendClientMessage(playerid, -1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:kickall(playerid, params[])
{
	new
	    string[200]
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		SendPlayerMessage(COLOR_RED, "[KICK] "white"Everyone has been kicked by an admin.");
		format(string, 128, "[KICK] "white"Everyone has been kicked by %s.", GetName(playerid));
		SendAMessage(COLOR_RED, string);
		format(string, 128, "Everyone has been kicked by %s.", GetName(playerid));
		Log("admin.txt", string);
	   	foreach(new i : Player)
		{
			if(i != playerid && User[playerid][accountAdmin] < User[i][accountAdmin])
			{
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				KickDelay(i);
			}
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:armourall(playerid, params[])
{
	new
	    string[200]
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
	   	foreach(new i : Player)
		{
			if(i != playerid && User[playerid][accountAdmin] < User[i][accountAdmin])
			{
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerArmour(i, 100.0);
			}
		}
		SendPlayerMessage(COLOR_RED, "[ARMOUR] "white"Everyone has received an armour from an admin.");
		format(string, 128, "[ARMOUR] "white"Everyone has received an armour from %s.", GetName(playerid));
		SendAMessage(COLOR_RED, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:healall(playerid, params[])
{
	new
	    string[200]
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
	   	foreach(new i : Player)
		{
			if(i != playerid && User[playerid][accountAdmin] < User[i][accountAdmin])
			{
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerHealth(i, 100.0);
			}
		}
		SendPlayerMessage(COLOR_RED, "[HEAL] "white"Everyone has been healed by an admin.");
		format(string, 128, "[HEAL] "white"Everyone has been healed by %s.", GetName(playerid));
		SendAMessage(COLOR_RED, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:armour(playerid, params[])
{
	new
	    string[200],
	    id
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /armour [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");

		format(string, 128, "[ARMOUR] "white"%s has been given an armour by an admin.", GetName(id));
		SendPlayerMessage(COLOR_RED, string);
		format(string, 128, "[ARMOUR] "white"%s has been given an armour by %s.", GetName(id), GetName(playerid));
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_GREEN, "An admin has given you an armour.");

	    SetPlayerArmour(id, 100.0);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:heal(playerid, params[])
{
	new
	    string[200],
	    id
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /heal [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");

		format(string, 128, "[HEAL] "white"%s has been healed by an admin.", GetName(id));
		SendPlayerMessage(COLOR_RED, string);
		format(string, 128, "[HEAL] "white"%s has been healed by %s.", GetName(id), GetName(playerid));
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_GREEN, "An admin has healed you.");

	    SetPlayerHealth(id, 100.0);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setskin(playerid, params[])
{
	new
	    string[200],
	    id,
	    skin
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
		if(sscanf(params, "ui", id, skin)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setskin [playerid] [skin(0-299)]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(skin < 0 || skin == 74 || skin > 299) return SendClientMessage(playerid, -1, "» "red"Invalid skinID.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");

		format(string, 128, "[SKIN] "white"%s's skinID has been set to %d by %s.", GetName(id), skin, GetName(playerid));
		SendAMessage(COLOR_RED, string);
        format(string, 128, "[SET] "white"An admin has set your skinID to %d.", skin);
		SendClientMessage(id, COLOR_YELLOW, string);

	    SetPlayerSkin(id, skin);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:rate(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][Rated] == 1) return SendClientMessage(playerid, COLOR_RED, "<!> You have already rated the server, You cannot rate anymore.");
	new string[256];
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /rate [good/bad]");
	if(strcmp(params, "good", true) == 0)
	{
	    sInfo[thumbsup] ++;
	    savestatistics();
	    format(string, sizeof(string), "[RATE] "white"%s has rated the server a thumbs up (Overall Thumbsup %d)", GetName(playerid), sInfo[thumbsup]);
	    SendClientMessageToAll(COLOR_GREEN, string);
	    format(string, sizeof(string), "[Rate] %s has mark the server as good, Thumbsup total %d", GetName(playerid), sInfo[thumbsup]);
		Log("rate.txt", string);
		print(string);
		User[playerid][Rated] = 1;
	}
	else if(strcmp(params, "bad", true) == 0)
	{
	    sInfo[thumbsup] ++;
	    savestatistics();
	    format(string, sizeof(string), "[RATE] "white"%s has rated the server a thumbs down (Overall Thumbsdown %d)", GetName(playerid), sInfo[thumbsdown]);
	    SendClientMessageToAll(COLOR_RED, string);
	    format(string, sizeof(string), "[Rate] %s has mark the server as bad, Thumbsup total %d", GetName(playerid), sInfo[thumbsdown]);
		Log("rate.txt", string);
		print(string);
		User[playerid][Rated] = 1;
	}
	else return SendClientMessage(playerid, COLOR_RED, "USAGE: /rate [good/bad]");
	return 1;
}

CMD:cduel(playerid, params[])
{
    if(g_HasInvitedToDuel[playerid] == 0) return SendClientMessage(playerid, -1, "» "red"You did not invite anyone to a duel.");
    SendClientMessage(playerid, COLOR_YELLOW, "You have reset your duel invite, you can now use /duel [playerid] again.");
    g_HasInvitedToDuel[playerid] = 0;
    return 1;
}

CMD:watchduel(playerid, params[])
{
	new string[140];
    if(g_DuelInProgress == 0) return SendClientMessage(playerid, -1, "» "red"There is no duel current happening.");
	format(string, 250, "Now Spectating: "white"%s vs %s Duel", GetName(g_DuelingID1), GetName(g_DuelingID2));
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	SendClientMessage(playerid, COLOR_YELLOW, "Teleport to somewhere else to leave the duel area.");

	LoadPlayer(playerid);
	new id = GetPVarInt(playerid, "GodMode");
	if(id == 0)
	{
	    cmd_god(playerid, "");
	}
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 129);
	SetPlayerPos(playerid, 264.1134, 2093.7000, 26.1486);
	SetPlayerFacingAngle(playerid, 357.6103);
	return 1;
}

CMD:duel(playerid, params[])
{
	new WeapName[32];
	new DuelID, weapon, weaponName[40];
	if(sscanf(params, "us[40]", DuelID, weaponName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel [playerid] [weaponid/name]");
	if(!isnumeric(weaponName)) weapon = GetWeaponIDFromName(weaponName); else weapon = strval(weaponName);
	if(!IsValidWeapon(weapon)) return SendClientMessage(playerid, -1, "» "red" Invalid weapon ID");
    if(g_HasInvitedToDuel[playerid] == 1) return SendClientMessage(playerid, -1, "» "red"You already invited someone to a duel! (Type, /cduel to reset your invite)");
	if(DuelID == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
    if(g_HasInvitedToDuel[DuelID] == 1) return SendClientMessage(playerid, -1, "» "red"That player is already invited to a duel!");
    if(DuelID  == playerid) return SendClientMessage(playerid, -1, "» "red"You can not duel yourself!");
	if(GetPlayerState(DuelID) != 1 && GetPlayerState(DuelID) != 2 && GetPlayerState(DuelID) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
	GetWeaponName(weapon, WeapName, 32);

    new
       tString[250];

    format(tString, sizeof(tString), "You invited %s (ID:%d) to a 1 on 1 duel, wait till %s accepts your invite, The weapon is %s(%d)", GetName(DuelID), DuelID, GetName(DuelID), WeapName, weapon);
    SendClientMessage(playerid, COLOR_YELLOW, tString);

    format(tString, sizeof(tString), "You got invited by %s (ID:%d) to a 1 on 1 duel weapon is %s(%d), type /duelaccept [playerid] to accept and start the duel. ", GetName(playerid), playerid, WeapName, weapon);
    SendClientMessage(DuelID, COLOR_YELLOW, tString);

	g_Weapon = weapon;
    g_GotInvitedToDuel[DuelID] = playerid;
    g_HasInvitedToDuel[playerid] = 1;
    return 1;
}

CMD:duelaccept(playerid, params[])
{
	new DuelID;
	if(sscanf(params, "u", DuelID)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duelaccept [playerid]");
    if(g_DuelInProgress == 1) return SendClientMessage(playerid, -1, "» "red"Another duel is in progress at the moment, wait till that duel is finished!");

    new
	    tString[250];

    if(DuelID != g_GotInvitedToDuel[playerid]) return SendClientMessage(playerid, -1, "» "red"That player did not invite you to a duel!");

    format(tString, sizeof(tString), "You accepted the duel with %s (ID:%d), duel will start in 10 seconds..", GetName(DuelID), DuelID);
    SendClientMessage(playerid, COLOR_YELLOW, tString);

    format(tString, sizeof(tString), "%s (ID:%d), accepted the duel with you, duel will start in 10 seconds..", GetName(playerid), playerid);
    SendClientMessage(DuelID, COLOR_YELLOW, tString);

    format(tString, sizeof(tString), "[DUEL] "white"Duel between %s and %s will start in "grey"10 "white"seconds (/watchduel to watch the duel)", GetName(playerid), GetName(DuelID));
    SendClientMessageToAll(COLOR_LIGHTBLUE, tString);

    InitializeDuel(playerid);
    InitializeDuelEx(DuelID);

    g_IsPlayerDueling[playerid] = 1;
    g_IsPlayerDueling[DuelID] = 1;

    g_DuelingID1 = playerid;
    g_DuelingID2 = DuelID;

    g_DuelInProgress = 1;
    return 1;
}

CMD:givemoney(playerid, params[])
{
	new
		iTargetID, iCashAmount;
	if(sscanf(params, "ui", iTargetID, iCashAmount)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /givemoney [playerid] [amount]");
	if(iTargetID == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
	if(iTargetID == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");
	if(iCashAmount <= 0) return SendClientMessage(playerid, -1, "» "red"Money shouldn't go below zero.");

	new
		szMessage[200]
	;
	if(iCashAmount > 0 && GetPlayerCash(playerid) >= iCashAmount)
	{
		GivePlayerCash(playerid, -iCashAmount);
		GivePlayerCash(iTargetID, iCashAmount);
		format(szMessage, sizeof(szMessage), "[MONEY] "white"You have sent %s(ID: %d), $%d.", GetName(iTargetID), iTargetID, iCashAmount);
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		SendClientMessage(playerid, COLOR_GREEN, szMessage);
		format(szMessage, sizeof(szMessage), "[MONEY] "white"You have recieved $%d from %s(ID: %d)", iCashAmount, GetName(playerid), playerid);
		SendClientMessage(iTargetID, COLOR_GREEN, szMessage);
		PlayerPlaySound(iTargetID, 1052, 0.0, 0.0, 0.0);
		format(szMessage, sizeof(szMessage), "[MONEY] {%06x}%s "white"gives {%06x}%s "grey"$%d "white"cash.", GetPlayerColor(playerid) >>> 8, GetName(playerid), GetPlayerColor(iTargetID) >>> 8, GetName(iTargetID), iCashAmount);
		SendClientMessageToAll(COLOR_RED, szMessage);
	}
	else
	{
		SendClientMessage(playerid, -1, "» "red"Invalid transaction amount.");
	}
	return 1;
}

CMD:buyint(playerid, params[])
{
	if(h_Selection[playerid] == 0)
	{
	    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not on Interior Selection.");
	    return 1;
	}

	new id = h_Selected[playerid], string[128], hid = h_ID[playerid];

	if(GetPlayerMoney(playerid) < intInfo[id][i_Price])
	{
	    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not have enough money to purchase this interior!");
	    SendClientMessage(playerid, COLOR_RED, "Finn: "white"I suggest you to /cancelint now.");
	    return 1;
	}

	GivePlayerCash(playerid, -intInfo[id][i_Price]);
	GameTextForPlayer(playerid, "~g~Interior Purchased!", 4500, 3);

	hInfo[hid][hEnterPos][0] = intInfo[id][SpawnPointX];
	hInfo[hid][hEnterPos][1] = intInfo[id][SpawnPointY];
	hInfo[hid][hEnterPos][2] = intInfo[id][SpawnPointZ];
	hInfo[hid][hEnterPos][3] = intInfo[id][SpawnPointA];
	hInfo[hid][ExitCPPos][0] = intInfo[id][ExitPointX];
	hInfo[hid][ExitCPPos][1] = intInfo[id][ExitPointY];
	hInfo[hid][ExitCPPos][2] = intInfo[id][ExitPointZ];
	hInfo[hid][hInterior] = intInfo[id][i_Int];
	format(hInfo[hid][hIName], 256, "%s", intInfo[id][Name]);

	jpInfo[playerid][p_SpawnPoint][0] = intInfo[id][SpawnPointX];
	jpInfo[playerid][p_SpawnPoint][1] = intInfo[id][SpawnPointY];
	jpInfo[playerid][p_SpawnPoint][2] = intInfo[id][SpawnPointZ];
	jpInfo[playerid][p_SpawnPoint][3] = intInfo[id][SpawnPointA];
	jpInfo[playerid][p_Interior] = hInfo[hid][hInterior];

	format(string, sizeof(string), "House Interior '%s' has been purchased for $%d, Your house has now had this interior.", intInfo[id][Name], intInfo[id][i_Price]);
	SendClientMessage(playerid, COLOR_GREEN, string);
	format(string, sizeof(string), "Notes left at the house for you: '%s'", intInfo[id][Notes]);
	SendClientMessage(playerid, COLOR_RED, string);
	SendClientMessage(playerid, -1, "House updated.");

	SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] "white"Your spawnpoint has been changed.");

	format(hInfo[hid][hNotes], 256, "%s", intInfo[id][Notes]);

	h_Selected[playerid] = -1;
	h_Selection[playerid] = 0;
	TogglePlayerControllable(playerid, 1);
	SetPlayerInterior(playerid, GetPVarInt(playerid, "h_Interior"));
	SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "h_World"));
	SetPlayerPos(playerid, GetPVarFloat(playerid, "h_X"), GetPVarFloat(playerid, "h_Y"), GetPVarFloat(playerid, "h_Z"));

	SaveHouse(hid);

    DestroyDynamicCP(hInfo[hid][hCP]);
    DestroyDynamicPickup(hInfo[hid][hPickup]);
    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

    LoadHouse(hid);
	return 1;
}
CMD:cancelint(playerid, params[])
{
	if(h_Selection[playerid] == 0)
	{
	    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not on Interior Selection.");
	    return 1;
	}

	h_Selection[playerid] = 0;
	h_Selected[playerid] = -1;

	SetPlayerInterior(playerid, GetPVarInt(playerid, "h_Interior"));
	SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "h_World"));
	SetPlayerPos(playerid, GetPVarFloat(playerid, "h_X"), GetPVarFloat(playerid, "h_Y"), GetPVarFloat(playerid, "h_Z"));

	SendClientMessage(playerid, -1, "You have decided not to buy the interior.");
	SendClientMessage(playerid, -1, "You've been teleported back to your position.");

	#if FREEZE_LOAD == true
	    House_Load(playerid);
	#endif
	return 1;
}

CMD:gotohouse(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}
	
	if(User[playerid][accountAdmin] >= 2)
	{
		new string[128], id;
		if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /gotohouse <houseid>");
		if(!fexist(HousePath(id))) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House Slot do not exists.");

		#if FREEZE_LOAD == true
		    House_Load(playerid);
		#endif

		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerPos(playerid, hInfo[id][hPickupP][0], hInfo[id][hPickupP][1], hInfo[id][hPickupP][2]);

		format(string, sizeof(string), "You have been successfully teleported to houseID %d (Owned by %s)", id, hInfo[id][hOwner]);
		SendClientMessage(playerid, -1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:hinteriors(playerid, params[])
{
    new string[1200];

    for(new a=0; a<sizeof(intInfo); a++)
    {
        format(string, sizeof(string), "%s%s - ID: %d\n", string, intInfo[a][Name], a);
    }
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_LIST, ""green"Interior List", string, "Close", "");
	return 1;
}

CMD:hmove(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		new
		    string[128],
		    hid,
			Float:p_Pos[3]
		;

		if(sscanf(params, "i", hid)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /hmove <houseid>");
		if(!fexist(HousePath(hid))) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House does not exists.");

		GetPlayerPos(playerid, p_Pos[0], p_Pos[1], p_Pos[2]);

		hInfo[hid][hPickupP][0] = p_Pos[0];
		hInfo[hid][hPickupP][1] = p_Pos[1];
		hInfo[hid][hPickupP][2] = p_Pos[2];

		SaveHouse(hid);

	    DestroyDynamicCP(hInfo[hid][hCP]);
	    DestroyDynamicPickup(hInfo[hid][hPickup]);
	    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
	    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

	    LoadHouse(hid);

	    format(string, sizeof(string), "[MOVE] "white"HouseID %d moved at your location.", hid);
	    SendClientMessage(playerid, COLOR_GREEN, string);
	    format(string, sizeof(string), "Location: %f, %f, %f", p_Pos[0], p_Pos[1], p_Pos[2]);
	    SendClientMessage(playerid, -1, string);

		printf("...HouseID %d moved to %f, %f, %f - JakHouse log", hid, p_Pos[0], p_Pos[1], p_Pos[2]);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:addhouse(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	if(User[playerid][accountAdmin] >= 4) 
	{
		new
		    string[250],
		    hid,
			price,
			world,
			level,
			interior,
			Float:p_Pos[3]
		;

		if(sscanf(params, "iiiii", hid, level, price, world, interior)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /addhouse <houseid> <level> <price> <world> <interiorid(0-12)>");
		if(hid < 0 || hid > MAX_HOUSES) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"Do not exceed the house limitations of JakHouse.");
		if(interior < 0 || interior > 12) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"Do not exceed the interior limitations of JakHouse.");
		if(level < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"Level Requirements shouldn't go below under 0.");
		if(fexist(HousePath(hid))) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House Slot used.");

		GetPlayerPos(playerid, p_Pos[0], p_Pos[1], p_Pos[2]);

		format(hInfo[hid][hName], 256, "None");
		format(hInfo[hid][hOwner], 256, "None");
		hInfo[hid][hLevel] = level;
		hInfo[hid][hPrice] = price;
		hInfo[hid][hSale] = 0;
		hInfo[hid][hInterior] = intInfo[interior][i_Int];
		hInfo[hid][hWorld] = world;
		hInfo[hid][hLocked] = 1;
		hInfo[hid][hEnterPos][0] = intInfo[interior][SpawnPointX];
		hInfo[hid][hEnterPos][1] = intInfo[interior][SpawnPointY];
		hInfo[hid][hEnterPos][2] = intInfo[interior][SpawnPointZ];
		hInfo[hid][hEnterPos][3] = intInfo[interior][SpawnPointA];
		hInfo[hid][hPickupP][0] = p_Pos[0];
		hInfo[hid][hPickupP][1] = p_Pos[1];
		hInfo[hid][hPickupP][2] = p_Pos[2];
		hInfo[hid][ExitCPPos][0] = intInfo[interior][ExitPointX];
		hInfo[hid][ExitCPPos][1] = intInfo[interior][ExitPointY];
		hInfo[hid][ExitCPPos][2] = intInfo[interior][ExitPointZ];
		format(hInfo[hid][hIName], 256, "%s", intInfo[interior][Name]);
		format(hInfo[hid][hNotes], 256, "None");
		hInfo[hid][MoneyStore] = 0;

		dini_Create(HousePath(hid));
		SaveHouse(hid);

	    DestroyDynamicCP(hInfo[hid][hCP]);
	    DestroyDynamicPickup(hInfo[hid][hPickup]);
	    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
	    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

	    LoadHouse(hid);

	    format(string, sizeof(string), "[HOUSE] "white"HouseID %d created, Price $%d, Level %d, Virtaul World %d", hid, price, level, world);
	    SendClientMessage(playerid, COLOR_GREEN, string);
	    format(string, sizeof(string), "House created under the interior %s (Int %d)", intInfo[interior][Name], interior);
	    SendClientMessage(playerid, -1, string);

		printf("...HouseID %d created - JakHouse log", hid);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:removehouse(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		new
		    string[128],
		    hid
		;

		if(sscanf(params, "i", hid)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /removehouse <houseid>");
		if(!fexist(HousePath(hid))) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House Slot not used.");

	    foreach(new i : Player)
	    {
	        if(strcmp(p_Name(playerid), hInfo[hid][hOwner], true) == 0)
	        {
	            jpInfo[i][OwnedHouses] = 0;
				jpInfo[i][OwnedHouses] = 0;
				jpInfo[i][p_SpawnPoint][0] = 0.0;
				jpInfo[i][p_SpawnPoint][1] = 0.0;
				jpInfo[i][p_SpawnPoint][2] = 0.0;
				jpInfo[i][p_SpawnPoint][3] = 0.0;
				jpInfo[i][p_Interior] = 0;
				jpInfo[i][p_Spawn] = 0;

	    		SendClientMessage(i, COLOR_YELLOW, "Your house has been removed by RCON Admin.");
	        }
	    }

		new file[128];
		format(file, sizeof(file), USER_PATH, hInfo[hid][hOwner]);
		dini_IntSet(file, "Houses", jpInfo[playerid][OwnedHouses]=0);
		dini_FloatSet(file, "X", jpInfo[playerid][p_SpawnPoint][0]=0.0);
		dini_FloatSet(file, "Y", jpInfo[playerid][p_SpawnPoint][1]=0.0);
		dini_FloatSet(file, "Z", jpInfo[playerid][p_SpawnPoint][2]=0.0);
		dini_FloatSet(file, "A", jpInfo[playerid][p_SpawnPoint][3]=0.0);
		dini_IntSet(file, "Interior", jpInfo[playerid][p_Interior]=0);
		dini_IntSet(file, "Spawn", jpInfo[playerid][p_Spawn]=0);

		format(hInfo[hid][hName], 256, "None");
		format(hInfo[hid][hOwner], 256, "None");
		hInfo[hid][hLevel] = 0;
		hInfo[hid][hPrice] = 0;
		hInfo[hid][hSale] = 0;
		hInfo[hid][hInterior] = 2;
		hInfo[hid][hWorld] = 0;
		hInfo[hid][hLocked] = 1;
		hInfo[hid][hEnterPos][0] = 2461.4714;
		hInfo[hid][hEnterPos][1] = -1698.2998;
		hInfo[hid][hEnterPos][2] = 1013.5078;
		hInfo[hid][hEnterPos][3] = 89.5674;
		hInfo[hid][hPickupP][0] = 0.0;
		hInfo[hid][hPickupP][1] = 0.0;
		hInfo[hid][hPickupP][2] = 0.0;
		hInfo[hid][ExitCPPos][0] = 2465.7527;
		hInfo[hid][ExitCPPos][1] = -1697.9935;
		hInfo[hid][ExitCPPos][2] = 1013.5078;
		hInfo[hid][MoneyStore] = 0;
		format(hInfo[hid][hNotes], 256, "None");

		fremove(HousePath(hid));

	    DestroyDynamicCP(hInfo[hid][hCP]);
	    DestroyDynamicPickup(hInfo[hid][hPickup]);
	    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
	    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

	    format(string, sizeof(string), "[REMOVE] "white"HouseID %d has been successfully removed.", hid);
	    SendClientMessage(playerid, COLOR_RED, string);

	    printf("...HouseID %d removed - JakHouse log", hid);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:buyhouse(playerid, params[])
{
	new
	    string[128]
	;

	new i = h_ID[playerid];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
    if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
    {
        if(hInfo[i][hSale] == 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"This house isn't for sale.");
        if(GetPlayerMoney(playerid) < hInfo[i][hPrice]) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white" You don't have enough money to buy this house!");
		if(GetPlayerScore(playerid) < hInfo[i][hLevel]) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white" You don't have enough score to buy this house!");
		if(jpInfo[playerid][OwnedHouses] == 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white" You already owned a house, You can't buy another one.");

		jpInfo[playerid][OwnedHouses] = 1;

		jpInfo[playerid][p_SpawnPoint][0] = hInfo[i][hEnterPos][0];
		jpInfo[playerid][p_SpawnPoint][1] = hInfo[i][hEnterPos][1];
		jpInfo[playerid][p_SpawnPoint][2] = hInfo[i][hEnterPos][2];
		jpInfo[playerid][p_SpawnPoint][3] = hInfo[i][hEnterPos][3];
		jpInfo[playerid][p_Interior] = hInfo[i][hInterior];

		hInfo[i][hSale] = 1;
		hInfo[i][hLocked] = 0;
		format(hInfo[i][hOwner], 256, "%s", p_Name(playerid));
        GivePlayerCash(playerid, -hInfo[i][hPrice]);
        format(string, 128, "You have bought this house for $%d.", hInfo[i][hPrice]);
        SendClientMessage(playerid, COLOR_YELLOW, string);

		SaveHouse(i);

	    DestroyDynamicCP(hInfo[i][hCP]);
	    DestroyDynamicPickup(hInfo[i][hPickup]);
	    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
	    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

	    LoadHouse(i);
    }
    else
    {
        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
    }
	return 1;
}

CMD:asellhouse(playerid, params[])
{
	new
	    string[128]
	;

	new id;
	LoginCheck(playerid);
	SpawnCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /asellhouse <houseid>");
		if(!fexist(HousePath(id))) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House Slot do not exists.");

	    format(string, 128, "You have admin-sold this house for $%d, The money wasn't given to you, given to the owner instead.", hInfo[id][hPrice]);
	    SendClientMessage(playerid, -1, string);
	    format(string, 128, "The house safe also has $%d which was given to the owner.", hInfo[id][MoneyStore]);
	    SendClientMessage(playerid, -1, string);

	    foreach(new i : Player)
	    {
	        if(strcmp(p_Name(playerid), hInfo[id][hOwner], true) == 0)
	        {
				jpInfo[i][OwnedHouses] = 0;
				jpInfo[i][p_SpawnPoint][0] = 0.0;
				jpInfo[i][p_SpawnPoint][1] = 0.0;
				jpInfo[i][p_SpawnPoint][2] = 0.0;
				jpInfo[i][p_SpawnPoint][3] = 0.0;
				jpInfo[i][p_Interior] = 0;
				jpInfo[i][p_Spawn] = 0;

	            GivePlayerCash(i, hInfo[id][hPrice]);
	    		GivePlayerCash(i, hInfo[id][MoneyStore]);
	    		format(string, sizeof(string), "You received a $%d (Including House Safe), Admin %s has sold your house.", hInfo[id][hPrice]+hInfo[id][MoneyStore], p_Name(playerid));
				//Var MoneyStore plus hPrice = Total $%d, Nothing was added if MoneyStore is 0.
				SendClientMessage(i, COLOR_YELLOW, string);
	    		SendClientMessage(playerid, COLOR_GREEN, "The owner is online, the money was received.");
	        }
	    }

		new file[128];
		format(file, sizeof(file), USER_PATH, hInfo[id][hOwner]);
		dini_IntSet(file, "Houses", jpInfo[playerid][OwnedHouses]=0);
		dini_FloatSet(file, "X", jpInfo[playerid][p_SpawnPoint][0]=0.0);
		dini_FloatSet(file, "Y", jpInfo[playerid][p_SpawnPoint][1]=0.0);
		dini_FloatSet(file, "Z", jpInfo[playerid][p_SpawnPoint][2]=0.0);
		dini_FloatSet(file, "A", jpInfo[playerid][p_SpawnPoint][3]=0.0);
		dini_IntSet(file, "Interior", jpInfo[playerid][p_Interior]=0);
		dini_IntSet(file, "Spawn", jpInfo[playerid][p_Spawn]=0);

		hInfo[id][hSale] = 0;
		hInfo[id][hLocked] = 1;
		format(hInfo[id][hOwner], 256, "None");
		format(hInfo[id][hName], 256, "None");
	    hInfo[id][MoneyStore] = 0;

		SaveHouse(id);

	    DestroyDynamicCP(hInfo[id][hCP]);
	    DestroyDynamicPickup(hInfo[id][hPickup]);
	    DestroyDynamicMapIcon(hInfo[id][hMapIcon]);
	    DestroyDynamic3DTextLabel(hInfo[id][hLabel]);

	    LoadHouse(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:sellhouse(playerid, params[])
{
	new
	    string[128]
	;

	new i = h_ID[playerid];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	if(h_Inside[playerid] == -1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
	    {
	        if(hInfo[i][hSale] == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"This house is already for sale.");
			if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
			{
				jpInfo[playerid][OwnedHouses] = 0;
				jpInfo[playerid][p_SpawnPoint][0] = 0.0;
				jpInfo[playerid][p_SpawnPoint][1] = 0.0;
				jpInfo[playerid][p_SpawnPoint][2] = 0.0;
				jpInfo[playerid][p_SpawnPoint][3] = 0.0;
				jpInfo[playerid][p_Interior] = 0;
				jpInfo[playerid][p_Spawn] = 0;

				hInfo[i][hSale] = 0;
				hInfo[i][hLocked] = 1;
				format(hInfo[i][hOwner], 256, "None");
				format(hInfo[i][hName], 256, "None");
	            GivePlayerCash(playerid, hInfo[i][hPrice]);
	            GivePlayerCash(playerid, hInfo[i][MoneyStore]);
	            format(string, 128, "You have sold this house for $%d.", hInfo[i][hPrice]);
	            SendClientMessage(playerid, COLOR_YELLOW, string);
	            format(string, 128, "You have also got $%d from your house safe.", hInfo[i][MoneyStore]);
	            SendClientMessage(playerid, -1, string);
	            hInfo[i][MoneyStore] = 0;

				SaveHouse(i);

			    DestroyDynamicCP(hInfo[i][hCP]);
			    DestroyDynamicPickup(hInfo[i][hPickup]);
			    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
			    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

			    LoadHouse(i);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	    }
	}
	else
	{
        if(hInfo[i][hSale] == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"This house is already for sale.");
		if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
		{
			jpInfo[playerid][OwnedHouses] = 0;
			jpInfo[playerid][p_SpawnPoint][0] = 0.0;
			jpInfo[playerid][p_SpawnPoint][1] = 0.0;
			jpInfo[playerid][p_SpawnPoint][2] = 0.0;
			jpInfo[playerid][p_SpawnPoint][3] = 0.0;
			jpInfo[playerid][p_Interior] = 0;
			jpInfo[playerid][p_Spawn] = 0;

			hInfo[i][hSale] = 0;
			hInfo[i][hLocked] = 1;
			format(hInfo[i][hOwner], 256, "None");
			format(hInfo[i][hName], 256, "None");
            GivePlayerCash(playerid, hInfo[i][hPrice]);
            format(string, 128, "You have sold this house for $%d.", hInfo[i][hPrice]);
            SendClientMessage(playerid, COLOR_YELLOW, string);
            GivePlayerCash(playerid, hInfo[i][MoneyStore]);
            format(string, 128, "You have also got $%d from your house safe.", hInfo[i][MoneyStore]);
            SendClientMessage(playerid, -1, string);
            hInfo[i][MoneyStore] = 0;

			SaveHouse(i);

		    DestroyDynamicCP(hInfo[i][hCP]);
		    DestroyDynamicPickup(hInfo[i][hPickup]);
		    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

		    LoadHouse(i);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
		}
	}
	return 1;
}

CMD:henter(playerid, params[])
{
	new i = h_ID[playerid];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
    if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
    {
        if(hInfo[i][hLocked] == 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"House is locked!");
		#if FREEZE_LOAD == true
		    House_Load(playerid);

			SetPlayerPos(playerid, hInfo[i][hEnterPos][0], hInfo[i][hEnterPos][1], hInfo[i][hEnterPos][2]);
			SetPlayerFacingAngle(playerid, hInfo[i][hEnterPos][3]);
			SetPlayerInterior(playerid, hInfo[i][hInterior]);
			SetPlayerVirtualWorld(playerid, hInfo[i][hWorld]);
		#else
			SetPlayerPos(playerid, hInfo[i][hEnterPos][0], hInfo[i][hEnterPos][1], hInfo[i][hEnterPos][2]);
			SetPlayerFacingAngle(playerid, hInfo[i][hEnterPos][3]);
			SetPlayerInterior(playerid, hInfo[i][hInterior]);
			SetPlayerVirtualWorld(playerid, hInfo[i][hWorld]);
		#endif

		h_Inside[playerid] = i;
    }
    else
    {
        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
    }
	return 1;
}

CMD:hlock(playerid, params[])
{
	new i = h_ID[playerid];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	if(h_Inside[playerid] == -1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
	    {
			if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
			{
			    if(hInfo[i][hLocked] == 0)
			    {
					hInfo[i][hLocked] = 1;
		            SendClientMessage(playerid, COLOR_RED, "You have locked your house.");
				}
			    else if(hInfo[i][hLocked] == 1)
			    {
					hInfo[i][hLocked] = 0;
		            SendClientMessage(playerid, COLOR_GREEN, "You have unlocked your house.");
				}

				SaveHouse(i);

			    DestroyDynamicCP(hInfo[i][hCP]);
			    DestroyDynamicPickup(hInfo[i][hPickup]);
			    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
			    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

			    LoadHouse(i);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	    }
	}
	else
	{
		if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
		{
		    if(hInfo[i][hLocked] == 0)
		    {
				hInfo[i][hLocked] = 1;
	            SendClientMessage(playerid, COLOR_RED, "You have locked your house.");
			}
		    else if(hInfo[i][hLocked] == 1)
		    {
				hInfo[i][hLocked] = 0;
	            SendClientMessage(playerid, COLOR_GREEN, "You have unlocked your house.");
			}

			SaveHouse(i);

		    DestroyDynamicCP(hInfo[i][hCP]);
		    DestroyDynamicPickup(hInfo[i][hPickup]);
		    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

		    LoadHouse(i);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
		}
	}
	return 1;
}

CMD:hnote(playerid, params[])
{
	new i = h_ID[playerid];
	new string[128], note[128];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	if(h_Inside[playerid] == -1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
	    {
			if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
			{
				if(sscanf(params, "s[128]", note)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /hnote <note>");

				format(hInfo[i][hNotes], 256, "%s", note);

				SaveHouse(i);

			    DestroyDynamicCP(hInfo[i][hCP]);
			    DestroyDynamicPickup(hInfo[i][hPickup]);
			    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
			    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

			    LoadHouse(i);

			    format(string, sizeof(string), "You have replaced the old notes with a new one: %s", note);
			    SendClientMessage(playerid, -1, string);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	    }
	}
	else
	{
		if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
		{
			if(sscanf(params, "s[128]", note)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /hnote <note>");

			format(hInfo[i][hNotes], 256, "%s", note);

			SaveHouse(i);

		    DestroyDynamicCP(hInfo[i][hCP]);
		    DestroyDynamicPickup(hInfo[i][hPickup]);
		    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

		    LoadHouse(i);

		    format(string, sizeof(string), "You have replaced the old notes with a new one: %s", note);
		    SendClientMessage(playerid, -1, string);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
		}
	}
	return 1;
}

CMD:hcnote(playerid, params[])
{
	new i = h_ID[playerid];
	new string[150];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	if(h_Inside[playerid] == -1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
	    {
			format(string, sizeof(string), "Note: %s", hInfo[i][hNotes]);
			SendClientMessage(playerid, COLOR_RED, string);
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	    }
	}
	else
	{
		format(string, sizeof(string), "Note: %s", hInfo[i][hNotes]);
		SendClientMessage(playerid, COLOR_RED, string);
	}
	return 1;
}

CMD:hmenu(playerid, params[])
{
	new i = h_ID[playerid];

	if(i == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	if(h_Inside[playerid] == -1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hPickupP][0], hInfo[i][hPickupP][1], hInfo[i][hPickupP][2]))
	    {
			if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
			{
				ShowPlayerDialog(playerid, DIALOG_HMENU, DIALOG_STYLE_LIST, ""red"House Configuration",\
				""yellow"House Name\n"green"House Price ($)\n"yellow"Store Cash ($)\n"green"Withdraw Cash ($)\n"yellow"Storage Information\n"green"Virtual World\n"yellow"Interior\n"green"Spawn at Home", "Configure", "Cancel");
			}
			else
			{
			    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You are not near any house.");
	    }
	}
	else
	{
		if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
		{
			ShowPlayerDialog(playerid, DIALOG_HMENU, DIALOG_STYLE_LIST, ""red"House Configuration",\
			""yellow"House Name\n"green"House Price ($)\n"yellow"Store Cash ($)\n"green"Withdraw Cash ($)\n"yellow"Storage Information\n"green"Virtual World\n"yellow"Interior\n"green"Spawn at Home", "Configure", "Cancel");
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "[ERROR] "white"You do not own the house.");
		}
	}
	return 1;
}

Float:GetDistance(Float: x1, Float: y1, Float: z1, Float: x2, Float: y2, Float: z2)
{
	new Float:d;
	d += floatpower(x1-x2, 2.0 );
	d += floatpower(y1-y2, 2.0 );
	d += floatpower(z1-z2, 2.0 );
	d = floatsqroot(d);
	return d;
}

CMD:hnear(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		new hcount=0;

		SendClientMessage(playerid, COLOR_RED, "* Listing all JakHouses within 35 meters of you");

		new Float:X, Float:Y, Float:Z;
		new Float:X2, Float:Y2, Float:Z2;

		GetPlayerPos(playerid, X2, Y2, Z2);

		for(new i=0; i < MAX_HOUSES; i++)
		{
	 		X = hInfo[i][hPickupP][0];
			Y = hInfo[i][hPickupP][1];
			Z = hInfo[i][hPickupP][2];
			if(IsPlayerInRangeOfPoint(playerid, 35, X, Y, Z))
			{
			    hcount++;
			    new string[128];
		    	format(string, sizeof(string), "(%d) Owned by %s - Price: $%d | %f from you", i, hInfo[i][hOwner], hInfo[i][hPrice], GetDistance(X, Y, Z, X2, Y2, Z2));
		    	SendClientMessage(playerid, COLOR_WHITE, string);
			}
		}

		if(hcount==0) return SendClientMessage(playerid, -1, "No houses found nearby you.");
		else
		{
			new str[128];
			format(str, sizeof(str), "There are "green"%d "white"houses founded on your position.", hcount);
			SendClientMessage(playerid, -1, str);
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:spec(playerid, params[])
{
	LoginCheck(playerid);

	new string[150], specplayerid;

	if(User[playerid][accountAdmin] >= 1)
	{
		if(sscanf(params, "u", specplayerid)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /spec [playerid]");
		if(User[playerid][accountAdmin] < User[specplayerid][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
        if(specplayerid == INVALID_PLAYER_ID)  return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(specplayerid == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot spectate yourself.");
		if(GetPlayerState(specplayerid) == PLAYER_STATE_SPECTATING && User[specplayerid][SpecID] != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player is spectating someone.");
		if(GetPlayerState(specplayerid) != 1 && GetPlayerState(specplayerid) != 2 && GetPlayerState(specplayerid) != 3) return SendClientMessage(playerid, -1, "» "red"Player not spawned.");
		GetPlayerPos(playerid, SpecPos[playerid][0], SpecPos[playerid][1], SpecPos[playerid][2]);
		GetPlayerFacingAngle(playerid, SpecPos[playerid][3]);
		SpecInt[playerid][0] = GetPlayerInterior(playerid);
		SpecInt[playerid][1] = GetPlayerVirtualWorld(playerid);
		StartSpectate(playerid, specplayerid);
		format(string, sizeof(string), "Now Spectating: "white"%s (ID: %d)", GetName(specplayerid), specplayerid);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:specoff(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
        if(User[playerid][SpecType] != ADMIN_SPEC_TYPE_NONE)
		{
			StopSpectate(playerid);
			SetTimerEx("PosAfterSpec", 3000, 0, "d", playerid);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "No longer spectating.");
		}
		else return SendClientMessage(playerid, -1, "» "red"You are not spectating.");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setname(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 3)
	{
		new
			string[150],
			id,
			name[24]
		;
	    if(sscanf(params, "us[24]", id, name)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setname [playerid] [new name]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none logged player.");
	    new Query[500], DBResult:Result;

	    if(strlen(name) < 4 || strlen(name) > 20) return SendClientMessage(playerid, -1, "» "red"The name length shouldn't go below four and shouldn't go above twenty.");
		if(strcmp(name, GetName(id), true) == 0) return SendClientMessage(playerid, -1, "» "red"Player's are already using this name.");
	    format(Query, sizeof(Query), "SELECT `userid` FROM `users` WHERE `username` = '%s'", name);
	    Result = db_query(Database, Query);
	    if(db_num_rows(Result)) return SendClientMessage(playerid, -1, "» "red"The name has been taken by another player.");
	    db_free_result(Result);

		format(string, 128, "[NAME] "white"%s's name has been changed to %s by an admin.", GetName(id), name);
		SendPlayerMessage(COLOR_RED, string);
		format(string, 128, "[NAME] "white"%s's name has been changed to %s by %s.", GetName(id), name, GetName(playerid));
		SendAMessage(COLOR_RED, string);

		format(string, 150, "An admin has changed your name to %s, Your statistics has been saved.", name);
		SendClientMessage(id, COLOR_YELLOW, string);

	    format(Query, sizeof(Query), "UPDATE `users` SET `username` = '%s' WHERE `username` = '%s'", name, DB_Escape(User[id][accountName]));
	    db_query(Database, Query);
		db_free_result(db_query(Database, Query));

		format(User[id][accountName], 24, "%s", name);

		SetPlayerName(id, name);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:gotoco(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 3)
	{
		new
			Float: Pos[3],
			string[128]
		;
	    if(sscanf(params, "p<,>fff", Pos[0], Pos[1], Pos[2])) return SendClientMessage(playerid, COLOR_RED, "USAGE: /gotoco [x] [y] [z]");
	    if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
	    else SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

		format(string, sizeof string, "You have teleported to %.1f %.1f %.1f", Pos[0], Pos[1], Pos[2]);
		SendClientMessage(playerid, -1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new
			id,
			string[130],
			Float:x,
			Float:y,
			Float:z
		;
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /goto [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		if(Restriction(id) == 1)
		{
			SendClientMessage(playerid, -1, "» "red"You cannot use this command at that player at the moment.");
		    return 1;
		}
		GetPlayerPos(id, x, y, z);
		SetPlayerInterior(playerid, GetPlayerInterior(id));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
		if(GetPlayerState(playerid) == 2)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), x+3, y, z);
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(id));
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(id));
		}
		else SetPlayerPos(playerid, x+2, y, z);
		format(string, sizeof(string), "[TELEPORT] "white"You have teleported to Player %s(ID: %d)", GetName(id), id);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:spawn(playerid, params[])
{
	new string[150], id;
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
	    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /spawn [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		format(string, sizeof(string), "[SPAWN] "white"%s has respawned %s.", GetName(playerid), GetName(id));
		SendAMessage(COLOR_GREY, string);
		SendClientMessage(id, COLOR_GREY, "[SPAWN] "white"An admin has respawned you.");
		format(string, sizeof(string), "[SPAWN] "white"You have respawned %s.", GetName(id));
		SendClientMessage(playerid, COLOR_GREY, string);
		
		SetPlayerPos(id, 0, 0, 0);
		SpawnPlayer(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:ip(playerid, params[])
{
	new string[150], id;
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
	    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /ip [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");

		format(string, sizeof(string), "Player %s (ID:%d) IP %s", GetName(id), id, User[id][accountIP]);
		SendClientMessage(playerid, GetPlayerColor(id), string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:respawnveh(playerid, params[])
{
	new string[150];
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 3)
	{
		SendPlayerMessage(COLOR_RED, "[RESPAWN] "white"An admin has just respawned all unoccupied vehicles.");
		format(string, sizeof(string), "[RESPAWN] "white"%s has just respawned all unoccupied vehicles.", GetName(playerid));
		SendAMessage(COLOR_RED, string);
		GameTextForAll("~n~~n~~n~~n~~n~~n~~r~Vehicles ~g~Respawned!", 3000, 3);
		for(new v = 0; v < MAX_VEHICLES; v++)
		{
			if(!VehicleOccupied(v))
			{
				SetVehicleToRespawn(v);
			}
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:fakecmd(playerid, params[])
{
	new string[150], id, cmdtext[128];
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 5)
	{
	    if(sscanf(params, "us[128]", id, cmdtext)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /fakechat [playerid] [/command]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(strfind(params, "/", false) != -1)
		{
	        CallRemoteFunction("OnPlayerCommandText", "is", id, cmdtext);

			format(string, sizeof(string), "You have fake command %s '%s'", GetName(id), cmdtext);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "%s has fake command %s with %s", GetName(playerid), GetName(id), cmdtext);
			Log("admin.txt", string);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "USAGE: /fakechat [playerid] [/command]");
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:fakechat(playerid, params[])
{
	new string[150], id, msg[128];
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 4)
	{
	    if(sscanf(params, "us[128]", id, msg)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /fakechat [playerid] [text]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");

		OnPlayerText(id, msg);
		
		format(string, sizeof(string), "You have fake chat %s '%s'", GetName(id), msg);
		SendClientMessage(playerid, COLOR_YELLOW, string);
		format(string, sizeof(string), "%s has fake chat %s with %s", GetName(playerid), GetName(id), msg);
		Log("admin.txt", string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:reports(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new
		    count = 0;

		new
		    string[256],
		    string2[3000]
		;

		strcat(string2, ""grey"");
		strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Last 4 Player Reports.\n\n");
	    for(new x=0; x<4; x++)
	    {
	        if(strcmp(reportmsg[x], " ", true) == 0) { }
	        else
	        {
		        count++;
	            format(string, sizeof(string), ""white"%s\n", reportmsg[x]);
	            strcat(string2, string);
			}
	    }
	    if(count == 0)
	    {
	        strcat(string2, ""grey"");
	        strcat(string2, ""red"No last four reports send by a player.");
	    }

	    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""newb"Reports", string2, "Close", "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:report(playerid, params[])
{
	new id, reason[128], string[350];
	if(sscanf(params, "us[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /report [playerid] [reason]");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
	if(strlen(reason) <= 4) return SendClientMessage(playerid, -1, "» "red"Reason length shouldn't go lower than four.");

	new r_hr, r_min, r_sec, r_m, r_d, r_y;
	getdate(r_y, r_m, r_d);
	gettime(r_hr, r_min, r_sec);

	reportmsg[3] = reportmsg[2];
	reportmsg[2] = reportmsg[1];
	reportmsg[1] = reportmsg[0];
	format(string, sizeof(string), "(%02d/%02d/%d - %02d:%02d:%02d) {%06x}%s(ID:%d) "white"has reported {%06x}%s(ID:%d) "white"for "grey"%s", r_m, r_d, r_y, r_hr, r_min, r_sec, GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, GetPlayerColor(id) >>> 8, GetName(id), id, reason);
	reportmsg[0] = string;
	
	format(string, sizeof(string), "[REPORT] {%06x}%s(ID:%d) "white"has reported {%06x}%s(ID:%d) "grey"%s", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, GetPlayerColor(id) >>> 8, GetName(id), id, reason);
	foreach(new i : Player)
	{
	    if(User[i][accountLogged] == true)
	    {
	        if(User[i][accountAdmin] >= 1)
	        {
	            SendClientMessage(i, COLOR_NEWB, string);
	        }
	    }
	}
	
	format(string, sizeof(string), "Your complaint against %s(ID:%d) %s has been sent to Online Admins.", GetName(id), id, reason);
	SendClientMessage(playerid, COLOR_RED, string);
	return 1;
}

CMD:jail(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new id, sec, reason[128], string[250];
		if(sscanf(params, "uiS(None)[128]", id, sec, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /jail [playerid] [seconds] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(sec < 30) return SendClientMessage(playerid, -1, "» "red"You cannot jail lower than 30 seconds.");
		if(User[id][accountJail] == 1) return SendClientMessage(playerid, -1, "» "red"Player already jailed.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		LoadPlayer(id);

		new rand = random(sizeof(jailspawn));
		SetCameraBehindPlayer(id);
		SetPlayerInterior(id, 0);
		SetPlayerVirtualWorld(id, 69);
	    SetPlayerPos(id, jailspawn[rand][0], jailspawn[rand][1], jailspawn[rand][2]);
	    SetPlayerFacingAngle(id, jailspawn[rand][3]);

		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been jailed by an admin for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), sec, reason);
		SendPlayerMessage(COLOR_RED, string);
		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been jailed by %s for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), GetName(playerid), sec, reason);
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been jailed by an Admin, Press a screenshot (F8) and make a complaint on the forums, if you want to.");

		format(string, sizeof(string), "%s has been jailed by %s (%d seconds, reason %s)", GetName(id), GetName(playerid), sec, reason);
		Log("admin.txt", string);

		User[id][accountJail] = 1, User[id][accountJailSec] = sec;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:unjail(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
		new id, reason[128], string[250];
		if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /unjail [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountJail] == 0) return SendClientMessage(playerid, -1, "» "red"Player not in jailed.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");

		format(string, sizeof(string), "[RELEASE] "white"%s has been unjailed by an admin for "grey"%s", GetName(id), reason);
		SendPlayerMessage(COLOR_GREEN, string);
		format(string, sizeof(string), "[RELEASE] "white"%s has been unjailed by %s for "grey"%s", GetName(id), GetName(playerid), reason);
		SendAMessage(COLOR_GREEN, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been released from jail by an Admin.");

		format(string, sizeof(string), "%s has been unjailed by %s for %s", GetName(id), GetName(playerid), reason);
		Log("admin.txt", string);

		User[id][accountJail] = 0, User[id][accountJailSec] = 0;
		SpawnPlayer(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setworld(playerid, params[])
{
	new string[150], id, i;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
		if(sscanf(params, "ui", id, i)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setworld [playerid] [world]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		SetPlayerVirtualWorld(id, i);
		format(string, sizeof(string), "[INTERIOR] "white"An admin has set your virtual world to "grey"%d", i);
		SendClientMessage(id, COLOR_GREEN, string);
        format(string, sizeof(string), "[INTERIOR] "white"%s virtual world has been changed by %s to %d.", GetName(id), GetName(playerid), i);
        SendAMessage(COLOR_GREEN, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setinterior(playerid, params[])
{
	new string[150], id, i;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
		if(sscanf(params, "ui", id, i)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setinterior [playerid] [interior]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		SetPlayerInterior(id, i);
		format(string, sizeof(string), "[INTERIOR] "white"An admin has set your interior to "grey"%d", i);
		SendClientMessage(id, COLOR_GREEN, string);
        format(string, sizeof(string), "[INTERIOR] "white"%s interior has been changed by %s to %d.", GetName(id), GetName(playerid), i);
        SendAMessage(COLOR_GREEN, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:disarm(playerid, params[])
{
	new string[150], id;
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /disarm [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		SendClientMessage(id, COLOR_GREEN, "[DISARM] "white"An admin has disarmed your weapon.");
        format(string, sizeof(string), "[DISARM] "white"%s's weapons has been removed by an admin.", GetName(id));
        SendPlayerMessage(COLOR_GREEN, string);
        format(string, sizeof(string), "[DISARM] "white"%s's weapons has been removed by %s.", GetName(id), GetName(playerid));
        SendAMessage(COLOR_GREEN, string);
        ResetPlayerWeapons(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:announce(playerid, params[])
{
	LoginCheck(playerid);
	new string[250];

	if(User[playerid][accountAdmin] >= 1)
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /announce [message]");

		format(string, 250, "[NOTIFICATION] "white"%s did a /announce %s", GetName(playerid), params);
		SendAMessage(COLOR_GREEN, string);

		GameTextForAll(params, 4000, 3);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:warn(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new id, reason[128], string[250];
		if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /warn [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		User[id][accountWarn] ++;

		format(string, sizeof(string), "[WARNING] "white"%s has been warned by an admin for "grey"%s "white"[%d warnings]", GetName(id), reason, User[id][accountWarn]);
		SendPlayerMessage(COLOR_RED, string);
		format(string, sizeof(string), "[WARNING] "white"%s has been warned by %s for "grey"%s "white"[%d warnings]", GetName(id), GetName(playerid), reason, User[id][accountWarn]);
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been warned by an Admin, Press a screenshot (F8) and make a complaint on the forums, if you want to.");

		format(string, sizeof(string), "%s has been warned by %s for %s (%d warnings)", GetName(id), GetName(playerid), reason, User[id][accountWarn]);
		Log("admin.txt", string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:remwarn(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
		new id, reason[128], string[250];
		if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /remwarn [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountWarn] == 0) return SendClientMessage(playerid, -1, "» "red"Player has no warnings.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		User[id][accountWarn] --;

		format(string, sizeof(string), "[WARNING] "white"%s warning has been removed by an admin for "grey"%s "white"[%d warnings left]", GetName(id), reason, User[id][accountWarn]);
		SendPlayerMessage(COLOR_ORANGE, string);
		format(string, sizeof(string), "[WARNING] "white"%s warning has been removed by %s for "grey"%s "white"[%d warnings left]", GetName(id), GetName(playerid), reason, User[id][accountWarn]);
		SendAMessage(COLOR_ORANGE, string);
		SendClientMessage(id, COLOR_ORANGE, "One of your warning has been removed by an Admin.");

		format(string, sizeof(string), "%s warning has been removed by %s for %s (%d warnings left)", GetName(id), GetName(playerid), reason, User[id][accountWarn]);
		Log("admin.txt", string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:get(playerid, params[])
{
	new string[150], id;
	SpawnCheck(playerid);
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
		if(sscanf(params, "u", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /get [playerid]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		if(Restriction(id) == 1)
		{
			SendClientMessage(playerid, -1, "» "red"You cannot use this command at that player at the moment.");
		    return 1;
		}
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerInterior(id, GetPlayerInterior(playerid));
		SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
		if(GetPlayerState(id) == 2)
		{
   			new VehicleID = GetPlayerVehicleID(id);
			SetVehiclePos(VehicleID, x+3, y, z);
			LinkVehicleToInterior(VehicleID, GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(GetPlayerVehicleID(id), GetPlayerVirtualWorld(playerid));
		}
		else SetPlayerPos(id, x+2, y, z);
		SendClientMessage(id, COLOR_LIGHTBLUE, "[GET] "white"You have been teleported to an admin's location.");
		format(string, sizeof(string), "[GET] "white"You have teleport %s to your location.", GetName(id));
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:mutecmd(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
		new id, sec, reason[128], string[250];
		if(sscanf(params, "uiS(None)[128]", id, sec, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /mutecmd [playerid] [seconds] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(sec < 30) return SendClientMessage(playerid, -1, "» "red"You cannot mute lower than 30 seconds.");
		if(User[id][accountCMuted] == 1) return SendClientMessage(playerid, -1, "» "red"Player already muted from using the commands.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been muted from using the cmds by an admin for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), sec, reason);
		SendPlayerMessage(COLOR_RED, string);
		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been muted from using the cmds by %s for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), GetName(playerid), sec, reason);
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been muted from using the cmds by an Admin, Press a screenshot (F8) and make a complaint on the forums, if you want to.");

		format(string, sizeof(string), "%s has been muted from using the commands by %s (%d seconds, reason %s)", GetName(id), GetName(playerid), sec, reason);
		Log("admin.txt", string);

		User[id][accountCMuted] = 1, User[id][accountCMuteSec] = sec;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:unmutecmd(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
		new id, reason[128], string[250];
		if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /unmutecmd [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountCMuted] == 0) return SendClientMessage(playerid, -1, "» "red"Player not muted from using the commands.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted from using the commands by an admin for "grey"%s"white".", GetName(id), reason);
		SendPlayerMessage(COLOR_ORANGE, string);
		format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted from using the commands by %s for "grey"%s"white".", GetName(id), GetName(playerid), reason);
		SendPlayerMessage(COLOR_ORANGE, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been unmuted from using the commands by an Admin.");
		format(string, sizeof(string), "%s has been unmuted from using the commands by %s", GetName(id), GetName(playerid));
		Log("admin.txt", string);

		User[id][accountCMuted] = 0, User[id][accountCMuteSec] = 0;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:mute(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new id, sec, reason[128], string[250];
		if(sscanf(params, "uiS(None)[128]", id, sec, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /mute [playerid] [seconds] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(sec < 30) return SendClientMessage(playerid, -1, "» "red"You cannot mute lower than 30 seconds.");
		if(User[id][accountMuted] == 1) return SendClientMessage(playerid, -1, "» "red"Player already muted.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been muted by an admin for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), sec, reason);
		SendPlayerMessage(COLOR_RED, string);
		format(string, sizeof(string), "[PUNISHMENT] "white"%s has been muted by %s for "grey"%d "white"seconds ["grey"%s"white"]", GetName(id), GetName(playerid), sec, reason);
		SendAMessage(COLOR_RED, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been muted by an Admin, Press a screenshot (F8) and make a complaint on the forums, if you want to.");

		format(string, sizeof(string), "%s has been muted by %s (%d seconds, reason %s)", GetName(id), GetName(playerid), sec, reason);
		Log("admin.txt", string);

		User[id][accountMuted] = 1, User[id][accountMuteSec] = sec;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:unmute(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		new id, reason[128], string[250];
		if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /unmute [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
		if(User[id][accountMuted] == 0) return SendClientMessage(playerid, -1, "» "red"Player not muted.");
		if(id == playerid) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on yourself.");

		format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted by an admin for "grey"%s"white".", GetName(id), reason);
		SendPlayerMessage(COLOR_ORANGE, string);
		format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted by %s for "grey"%s"white".", GetName(id), GetName(playerid), reason);
		SendPlayerMessage(COLOR_ORANGE, string);
		SendClientMessage(id, COLOR_ORANGE, "You have been unmuted by an Admin.");
		format(string, sizeof(string), "%s has been unmuted by %s", GetName(id), GetName(playerid));
		Log("admin.txt", string);

		User[id][accountMuted] = 0, User[id][accountMuteSec] = 0;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:colors(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_COLORS, DIALOG_STYLE_LIST, "Player Colors",\
	""red"Red\n"green"Green\n"yellow"Yellow\n"grey"Grey\n"orange"Orange\n"lightblue"Lightblue\n"lightred"Lightred\n"newb"Special Color\n"purple"Purple\n"lightgreen"Lightgreen\n"pink"Pink", "Choose", "Cancel");
	return 1;
}

CMD:credits(playerid, params[])
{
	new string[1400];

	strcat(string, ""lightred"");
	strcat(string, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Credits List\n");
	strcat(string, "Build 1 - November 22, 2014, Developers of Build 1, JaKe\n\n");
	strcat(string, ""lightblue"");
	strcat(string, "Developer: "grey"JaKe\n");
	strcat(string, ""lightblue"");
	strcat(string, "Contributions: "grey"[HiC]TheKiller, Zezombia, andrewgrob, Sneaky, Mike, Roach, Hiddos\n");
	strcat(string, ""lightblue"");
	strcat(string, "Contributions: "grey"Kwarde, LethaL, BlueRey, iMonk3y\n");
	strcat(string, ""lightblue"");
	strcat(string, "Testers: "grey"Creed, Stuun, AlexM, Jeton, Ashirwad, DarKLord\n");
	strcat(string, ""lightblue"");
	strcat(string, "Others: "grey"SA-MP Forums (Maps/Scripts)");

	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""white"Server Credits", string, "Close", "");
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, pm[128], string[250];
	if(sscanf(params, "us[128]", id, pm)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /pm [playerid] [private message]");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
	PlayerPlaySound(id, 1085, 0.0, 0.0, 0.0);
	format(string, sizeof(string), "(( PM "lightred"Sent "white"to {%06x}%s: "white"%s ))", GetPlayerColor(id) >>> 8, GetName(id), pm);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "(( PM "lightblue"Received "white"from {%06x}%s: "white"%s ))", GetPlayerColor(playerid) >>> 8, GetName(playerid), pm);
	SendClientMessage(id, -1, string);
    LastPM[playerid] = id;
    LastPM[id] = playerid;
	return 1;
}
CMD:r(playerid, params[])
{
	new string[250];
	new id = LastPM[playerid];
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"No PMs.");
	if(IsPlayerConnected(id))
	{
	    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /r [pm reply]");
		PlayerPlaySound(id, 1085, 0.0, 0.0, 0.0);

		format(string, sizeof(string), "(( PM "lightred"Sent "white"to {%06x}%s: "white"%s ))", GetPlayerColor(id) >>> 8, GetName(id), params);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "(( PM "lightblue"Received "white"from {%06x}%s: "white"%s ))", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
		SendClientMessage(id, -1, string);
	    LastPM[playerid] = id;
	    LastPM[id] = playerid;
	}
	else return SendClientMessage(playerid, -1, "» "red"Player not connected.");
	return 1;
}

CMD:serverstats(playerid, params[])
{
	new string[1400], string2[256], month_[90];
	
	strcat(string, ""red"");
	strcat(string, "Statistics of the Server\n\n");
	switch(sInfo[opening_date][1])
	{
	    case 1: month_ = "January";
	    case 2: month_ = "February";
	    case 3: month_ = "March";
	    case 4: month_ = "April";
	    case 5: month_ = "May";
	    case 6: month_ = "June";
	    case 7: month_ = "July";
	    case 8: month_ = "August";
	    case 9: month_ = "September";
	    case 10: month_ = "October";
	    case 11: month_ = "November";
	    case 12: month_ = "December";
	    default: month_ = "January";
	}

    new
        count, count2,
        DBResult: result
	;
    result = db_query(Database, "SELECT * FROM `users`");
    count = db_num_rows(result);
    result = db_query(Database, "SELECT * FROM `bans`");
    count2 = db_num_rows(result);
    db_free_result(result);
	
	format(string2, 256, ""newb"Registered Players: "white"%d\n", count);
	strcat(string, string2);
	format(string2, 256, ""newb"Banned Players: "white"%d\n", count2);
	strcat(string, string2);
	format(string2, 256, ""newb"Last Banned Player: "white"%s by %s (%s)\n", sInfo[last_bperson], sInfo[last_bwho], sInfo[last_bwhen]);
	strcat(string, string2);
	format(string2, 256, ""newb"Anticheat Bans: "white"%d\n", sInfo[bannedac]);
	strcat(string, string2);
	format(string2, 256, ""newb"First Player: "white"%s\n", sInfo[first_person]);
	strcat(string, string2);
	format(string2, 256, ""newb"New Player: "white"%s (%s)\n", sInfo[last_person], sInfo[when_person]);
	strcat(string, string2);
	format(string2, 256, ""newb"Total Maps: "white"%d\n", totalmaps);
	strcat(string, string2);
	format(string2, 256, ""newb"Server up since: "white"%02d %s %d, %02d:%02d\n", sInfo[opening_date][2], month_, sInfo[opening_date][0], sInfo[opening_date][3], sInfo[opening_date][4]);
	strcat(string, string2);
    format(string2, 256, ""newb"Most Online Players: "white"%d\n", strval(i_Number));
    strcat(string, string2);
    format(string2, 256, ""newb"Fixed by: "white"%s (%s, %s)\n", s_Name, s_Date, s_Hour);
	strcat(string, string2);
    format(string2, 256, ""newb"Server Ratings: "white"(Good: %d, Bad: %d)\n", sInfo[thumbsup], sInfo[thumbsdown]);
	strcat(string, string2);
	format(string2, 256, ""newb"Dynamic Objects: "white"%d\n", CountDynamicObjects());
	strcat(string, string2);
	format(string2, 256, ""newb"Dynamic Pickups: "white"%d\n", CountDynamicPickups());
	strcat(string, string2);
	format(string2, 256, ""newb"Dynamic 3DText Labels: "white"%d\n", CountDynamic3DTextLabels());
	strcat(string, string2);
	format(string2, 256, ""newb"Dynamic Checkpoints: "white"%d\n", CountDynamicCPs());
	strcat(string, string2);
	
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""white"Server Statistics", string, "Close", "");
	return 1;
}

CMD:random(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 3)
	{
		new id = Iter_Random(Player);
		
		new string[150];
		format(string, 150, "[RANDOM] "white"An admin has just started a random picking, PlayerID %d has been picked.", id);
		SendPlayerMessage(COLOR_RED, string);

		format(string, 150, "[RANDOM] "white"%s has just started a random picking, PlayerID %d has been picked.", GetName(playerid), id);
		SendAMessage(COLOR_RED, string);
		
		SendClientMessage(id, COLOR_RED, "[RANDOM] "white"You have been randomed picked by an admin.");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:ans(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);

	new cmdid, tmp[256], idx, string[150];
	tmp = strtok(params, idx);
	
	if(started == 0)
	{
	    SendClientMessage(playerid, COLOR_RED, "[MATH] "white"No math quiz on going at the moment.");
	    return 1;
	}
	
    if(strlen(tmp) == 0) return SendClientMessage(playerid, COLOR_RED, "USAGE: /ans [math answer]");
	cmdid = strval(tmp);

    if(cmdid != answer)
    {
        format(string, sizeof(string), "[MATH] "white"Your answer for the math quiz '"grey"%d"white"' is "red"wrong"white"!", cmdid);
        SendClientMessage(playerid, COLOR_RED, string);
        return 1;
    }

    if(cmdid == answer && answered == 0)
    {
        format(string, sizeof(string), "[MATH] "white"%s has won "green"5 score and $4000 "white"for answering the math question, The answer is "grey"'%d'", GetName(playerid), cmdid);
        SendClientMessageToAll(COLOR_RED, string);
        GivePlayerCash(playerid, 4000);
		SetPlayerScore(playerid, GetPlayerScore(playerid)+5);
		
		User[playerid][accountMath] ++;
		
        answered = 1;
        return 1;
    }
    else if(cmdid == answer && answered == 1)
    {
        format(string, sizeof(string), "[MATH] "white"Your answer'"grey"%d"white"' is "green"correct"white" but you are "red"too late", cmdid);
        SendClientMessage(playerid, COLOR_RED, string);
    }
    return 1;
}

CMD:descp(playerid, params[])
{
	new string[256], descp[101];
	
	LoginCheck(playerid);

	if(sscanf(params, "s[100]", descp))
	{
	    format(string, sizeof(string), "Your current description: "white"%s", User[playerid][accountDescp]);
	    SendClientMessage(playerid, COLOR_YELLOW, string);
	    SendClientMessage(playerid, COLOR_RED, "USAGE: /descp [description of yourself]");
	    return 1;
	}
	if(strlen(descp) < 4 || strlen(descp) > 60) return SendClientMessage(playerid, -1, "» "red"Invalid description length.");
	
	format(User[playerid][accountDescp], 100, "%s", descp);
	
	SendClientMessage(playerid, -1, "» "green"Your description has been changed.");
	return 1;
}

CMD:oban(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
	    new
			string[150],
			name[24],
			reason[128],
			Query[256],
			admin,
			ip[20],
			DBResult:Result,
			ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years
		;

		gettime(ban_hr, ban_min, ban_sec);
		getdate(ban_years, ban_month, ban_days);

	    if(sscanf(params, "s[24]s[128]", name, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /oban [name in the data] [reason]");
		foreach(new i : Player)
		{
		    if(strcmp(GetName(i), name, true) == 0)
		    {
		        SendClientMessage(playerid, -1, "Player that you are trying to banned is online, /ban instead.");
		        return 1;
		    }
		}
	    format(Query, sizeof(Query), "SELECT * FROM `users` WHERE `username` = '%s'", DB_Escape(name));
	    Result = db_query(Database, Query);
	    if(db_num_rows(Result))
	    {
	        db_get_field_assoc(Result, "admin", Query, 6);
	        admin = strval(Query);
	        db_get_field_assoc(Result, "IP", ip, 20);

			if(User[playerid][accountAdmin] < admin)
			{
				SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");

				format(string, sizeof(string), "%s has attempted to offline banned %s but failed for %s", GetName(playerid), name, reason);
				Log("admin.txt", string);
				return 1;
			}

		    format(sInfo[last_bperson], 256, "%s", name);
		    format(sInfo[last_bwho], 256, "%s", reason);
			savestatistics();

			AddBan(ip, 1);
			BanAccEx(name, ip, GetName(playerid), reason);

			format(string, sizeof(string), "[BANNED] "white"%s has been offline banned by an admin for "grey"%s"white".", name, reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[BANNED] "white"%s has been offline banned by %s for "grey"%s"white".", name, GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			format(string, sizeof(string), "[BANNED] %s has been offine banned by %s for %s.", name, GetName(playerid), reason);
			Log("ban.txt", string);
		}
		else
		{
		    SendClientMessage(playerid, -1, "There is no such thing players in the server database.");
		}
	    db_free_result(Result);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:bansearch(playerid, params[])
{
    new
        Query[256],
        name[24],
        DBResult: Result,
        string[128],
        name2[24],
        when[128],
        reason[128]
    ;

    if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /bansearch [name in the data]");
    if(strlen(name) < 3 || strlen(name) > 20) return SendClientMessage(playerid, -1, "» "red"Invalid name length.");

    SendClientMessage(playerid, -1, "Searching around the banned database, It will take seconds ... Hold on.");
    format(Query, sizeof(Query), "SELECT * FROM `bans` WHERE `username` = '%s'", DB_Escape(name));
    Result = db_query(Database, Query);
    if(db_num_rows(Result))
    {
        db_get_field_assoc(Result, "banby", Query, 24);
	    format(name2, 24, "%s", Query);
        db_get_field_assoc(Result, "banreason", Query, 128);
	    format(reason, 128, "%s", Query);
        db_get_field_assoc(Result, "banwhen", Query, 128);
	    format(when, 128, "%s", Query);
        format(string, 128, "%s (Banned by %s for %s, %s)", name, name2, reason, when);
        SendClientMessage(playerid, COLOR_RED, string);
    }
    else
    {
        SendClientMessage(playerid, COLOR_YELLOW, "No specific name on the banned database.");
    }
    db_free_result(Result);
    return 1;
}

CMD:name(playerid, params[])
{
    new
        Query[256],
        name[24],
        DBResult: Result,
        string[128],
        user
    ;
    
    if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /name [name in the data]");
    if(strlen(name) < 3 || strlen(name) > 20) return SendClientMessage(playerid, -1, "» "red"Invalid name length.");
    
    SendClientMessage(playerid, -1, "Searching around the database, It will take seconds ... Hold on.");
    format(Query, sizeof(Query), "SELECT * FROM `users` WHERE `username` = '%s'", DB_Escape(name));
    Result = db_query(Database, Query);
    if(db_num_rows(Result))
    {
        db_get_field_assoc(Result, "userid", Query, 7);
		user = strval(Query);
        format(string, 128, "(UserID: %d) %s", user, name);
        SendClientMessage(playerid, COLOR_YELLOW, string);
    }
    else
    {
        SendClientMessage(playerid, COLOR_YELLOW, "No specific name on the database.");
    }
    db_free_result(Result);
    return 1;
}

CMD:slap(playerid, params[])
{
	new string[150], id, reason[128];

    new
		Float:x,
		Float:y,
		Float:z,
		Float:health
	;

	LoginCheck(playerid);
	if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
	{
	    if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /slap [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
	    if(User[playerid][accountHelper] == 1)
	    {
	        if(User[id][accountAdmin] >= 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on the admin.");
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been slapped by a Helper. [%s]", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been slapped by %s. [%s]", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			GetPlayerPos(id, x, y, z);
		    GetPlayerHealth(id, health);
		    SetPlayerHealth(id, health-25);
			SetPlayerPos(id, x, y, z+5);
		    PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
		    PlayerPlaySound(id, 1190, 0.0, 0.0, 0.0);

			format(string, 128, "%s has been slapped by %s for %s.", GetName(id), GetName(playerid), reason);
			Log("admin.txt", string);
		}
	    else if(User[playerid][accountAdmin] >= 1)
	    {
			if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been slapped by an Admin. [%s]", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been slapped by %s. [%s]", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			GetPlayerPos(id, x, y, z);
		    GetPlayerHealth(id, health);
		    SetPlayerHealth(id, health-25);
			SetPlayerPos(id, x, y, z+5);
		    PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
		    PlayerPlaySound(id, 1190, 0.0, 0.0, 0.0);

			format(string, 128, "%s has been slapped by %s for %s.", GetName(id), GetName(playerid), reason);
			Log("admin.txt", string);
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:explode(playerid, params[])
{
	new string[150], id, Float:x, Float:y, Float:z, reason[128];
	
	LoginCheck(playerid);
	if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
	{
	    if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /explode [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");

		GetPlayerPos(id, x, y, z);

	    if(User[playerid][accountHelper] == 1)
	    {
	        if(User[id][accountAdmin] >= 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on the admin.");

			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been exploded by a Helper for "grey"%s"white".", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been exploded by %s for "grey"%s"white".", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			SendClientMessage(id, COLOR_YELLOW, "You have been slapped by a Helper.");
			CreateExplosion(x, y, z, 7, 10.0);
		}
	    else if(User[playerid][accountAdmin] >= 1)
	    {
			if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");

			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been exploded by an admin for "grey"%s"white".", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been exploded by %s for "grey"%s"white".", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			SendClientMessage(id, COLOR_YELLOW, "You have been slapped by an Admin.");
			CreateExplosion(x, y, z, 7, 10.0);
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:kick(playerid, params[])
{
	new string[150], id, reason[128];

	LoginCheck(playerid);
	if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
	{
	    if(sscanf(params, "uS(None)[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /kick [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
	    if(User[playerid][accountHelper] == 1)
	    {
	        if(User[id][accountAdmin] >= 1) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on the admin.");
			Clear_Chat(id);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been kicked from the server by a Helper. [%s]", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been kicked from the server by %s. [%s]", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			SendClientMessage(id, COLOR_YELLOW, "You have been kicked from the server by a Helper.");

			format(string, 128, "%s has been kicked by %s for %s.", GetName(id), GetName(playerid), reason);
			Log("admin.txt", string);
			KickDelay(id);
		}
	    else if(User[playerid][accountAdmin] >= 1)
	    {
			if(User[playerid][accountAdmin] < User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
			Clear_Chat(id);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been kicked from the server by an Admin. [%s]", GetName(id), reason);
			SendPlayerMessage(COLOR_RED, string);
			format(string, sizeof(string), "[PUNISHMENT] "white"%s has been kicked from the server by %s. [%s]", GetName(id), GetName(playerid), reason);
			SendAMessage(COLOR_RED, string);
			SendClientMessage(id, COLOR_YELLOW, "You have been kicked from the server by an Admin.");

			format(string, 128, "%s has been kicked by %s for %s.", GetName(id), GetName(playerid), reason);
			Log("admin.txt", string);

			KickDelay(id);
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:ban(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
	    new
			string[150],
			id,
			reason[128],
			when[128],
			ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years
		;

		gettime(ban_hr, ban_min, ban_sec);
		getdate(ban_years, ban_month, ban_days);

	    if(sscanf(params, "us[128]", id, reason)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /ban [playerid] [reason]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[playerid][accountAdmin] < User[id][accountAdmin])
		{
			SendClientMessage(playerid, -1, "» "red"You cannot use this command on high ranking admin.");
			format(string, sizeof(string), "[NOTIFY] "white"%s has attempted to banned you with the reason %s.", GetName(playerid), reason);
			SendClientMessage(id, COLOR_ORANGE, string);
			
			format(string, sizeof(string), "%s has attempted to banned %s but failed for %s", GetName(playerid), GetName(id), reason);
			Log("admin.txt", string);
			return 1;
		}

		format(when, 128, "%02d/%02d/%d %02d:%02d:%02d", ban_month, ban_days, ban_years, ban_hr, ban_min, ban_sec);

	    format(sInfo[last_bperson], 256, "%s", GetName(id));
	    format(sInfo[last_bwho], 256, "%s", reason);
		savestatistics();

		AddBan(User[id][accountIP], 1);
		BanAcc(id, GetName(playerid), reason);
		ShowBan(id, GetName(playerid), reason, when);
		
		format(string, sizeof(string), "[BANNED] "white"%s has been banned by an admin for "grey"%s"white".", GetName(id), reason);
		SendPlayerMessage(COLOR_RED, string);
		format(string, sizeof(string), "[BANNED] "white"%s has been banned by %s for "grey"%s"white".", GetName(id), GetName(playerid), reason);
		SendAMessage(COLOR_RED, string);
		format(string, sizeof(string), "[BANNED] %s has been banned by %s for %s.", GetName(id), GetName(playerid), reason);
		Log("ban.txt", string);
		
		KickDelay(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:unban(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
	    new
			string[150],
			Account[24],
			DBResult:Result,
			Query[129],
			fIP[30]
		;
		if(sscanf(params, "s[24]", Account)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /unban [account name]");
	    format(Query, 129, "SELECT  FROM `bans` WHERE `username` = '%s'", Account);
		Result = db_query(Database, Query);

		if(db_num_rows(Result))
		{
        	db_get_field_assoc(Result, "ip", fIP, 30);
			if(CheckBan(fIP))
			{
				RemoveBan(fIP);
			}
	        format(Query, 129, "DELETE FROM `bans` WHERE `username` = '%s'", Account);
		    Result = db_query(Database, Query);
	        db_free_result(Result);

			format(string, sizeof string, "[UNBANNED] "white"%s has been unbanned by an admin.", Account);
			SendPlayerMessage(COLOR_ORANGE, string);
			format(string, sizeof string, "[UNBANNED] "white"%s has been unbanned by %s.", Account, GetName(playerid));
			SendAMessage(COLOR_ORANGE, string);
			format(string, sizeof string, "[UNBANNED] %s has been unbanned by %s.", Account, GetName(playerid));
		    Log("ban.txt", string);
		}
		else
		{
		    db_free_result(Result);
		    SendClientMessage(playerid, -1, "» "red"Player is not in the banned database.");
		    return 1;
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:togglebrake(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountBrake] == 0) return SendClientMessage(playerid, -1, "» "red"You do not have the power to use this command.");

	switch(User[playerid][accountNoB])
	{
	    case 0:
	    {
	        User[playerid][accountNoB] = 1;
	        SendClientMessage(playerid, -1, "You can now use the Super Handbrake feature by pressing Y.");
	    }
	    case 1:
	    {
	        User[playerid][accountNoB] = 0;
	        SendClientMessage(playerid, -1, "You have disabled using the Super Handbrake feature.");
	    }
	}
	return 1;
}

CMD:adminduty(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    new string[150];
	    switch(AdminDuty[playerid])
	    {
	        case 0:
	        {
				AdminDuty[playerid] = 1;
				SendPlayerMessage(COLOR_GREEN, "[DUTY] "white"An administrator has just gone on duty, His/her nametag has been disabled.");
				format(string, sizeof(string), "[DUTY] "white"%s has just gone on duty.", GetName(playerid));
				SendAMessage(COLOR_GREEN, string);
				
				SetPVarInt(playerid, "color_", GetPlayerColor(playerid));
				
				foreach(new i : Player)
				{
				    ShowPlayerNameTagForPlayer(i, playerid, 0);
                    SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
				}
	        }
	        case 1:
	        {
				AdminDuty[playerid] = 0;
				SendPlayerMessage(COLOR_RED, "[DUTY] "white"An administrator has just gone off duty, His/her nametag has been enabled.");
				format(string, sizeof(string), "[DUTY] "white"%s has just gone off duty.", GetName(playerid));
				SendAMessage(COLOR_RED, string);

				foreach(new i : Player)
				{
				    ShowPlayerNameTagForPlayer(i, playerid, 1);
                    SetPlayerMarkerForPlayer(i, playerid, GetPVarInt(playerid, "color_"));
				}
	        }
	    }
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:aduty(playerid, params[]) return cmd_adminduty(playerid, "");

CMD:toggleadmin(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
	{
	    switch(ToggleAdmin[playerid])
	    {
	        case 0:
	        {
	            ToggleAdmin[playerid] = 1;
	            SendClientMessage(playerid, -1, "Admin Messages has been toggled back.");
	            SendClientMessage(playerid, COLOR_YELLOW, "You can now see the name of an admin who started something, and the admin chats as well.");
	        }
	        case 1:
	        {
	            ToggleAdmin[playerid] = 0;
	            SendClientMessage(playerid, -1, "Admin Messages has been toggled off.");
	            SendClientMessage(playerid, COLOR_YELLOW, "You cannot see the name of an admin when a notifier is sent, admin chats are disabled on your screen.");
	        }
	    }
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:stats(playerid, params[])
{
	new id;

	if(!sscanf(params, "u", id))
	{
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");
		ShowStats(playerid, id);
		
		new string[128];
		format(string, sizeof(string), ""red"[STATISTICS] "white"Now viewing '%s' stats.", GetName(id));
		SendClientMessage(playerid, -1, string);
	}
	else
	{
	    LoginCheck(playerid);
	
	    ShowStats(playerid, playerid);
	    SendClientMessage(playerid, COLOR_RED, "[NOTE] "white"You can also /stats <PlayerID>.");
	}
	return 1;
}

CMD:myvip(playerid, params[])
{
	LoginCheck(playerid);
	
	if(User[playerid][accountVIP] == 0) return SendClientMessage(playerid, -1, "» "red"Only VIPs can use this command.");

	new remaining_seconds = gettime() - User[playerid][ExpirationVIP];
	new remaining_days = remaining_seconds / 3600 / 24;
	
	new string[150];
	
	format(string, sizeof(string), "» You have "grey"%d "white"days till your "orange"VIP "white"expires.", abs(remaining_days));
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:skin(playerid, params[])
{
	SpawnCheck(playerid);

	ShowModelSelectionMenu(playerid, skinlist, "~g~Select Skin");
	return 1;
}

CMD:clearteleport(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    for(new i=0; i<4; i++)
	    {
	    	teleportmsg[i] = " ";
		}
		SendPlayerMessage(-1, "[CONTEST] "red"An admin has cleared the teleport messages.");
		new string[128];
		format(string, sizeof(string), "[CONTEST] "red"%s has cleared the teleport messages.", GetName(playerid));
		SendAMessage(-1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:clearchat(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    foreach(new i : Player)
	    {
	    	Clear_Chat(i);
		}
		SendPlayerMessage(-1, "[CONTEST] "red"An admin has cleared the chat.");
		new string[128];
		format(string, sizeof(string), "[CONTEST] "red"%s has cleared the chat.", GetName(playerid));
		SendAMessage(-1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:jetpack(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	
	if(User[playerid][accountAdmin] >= 1 || User[playerid][accountJP] == 1)
	{
	    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) return SendClientMessage(playerid, COLOR_RED, "[JETPACK] "white"You are already using a jetpack.");
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	    SendClientMessage(playerid, COLOR_RED, "[JETPACK] "white"You have spawned your premium jetpack.");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You do not have the power to use this command.");
	}
	return 1;
}

CMD:shop(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);

	ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""newb"Server Shop", "Change Name\t\t($50,000 + 100 score)\nPremium Points\t\t(10 PP)\t\t(1500 scores)", "Buy", "Cancel");
	return 1;
}

CMD:premiumshop(playerid, params[])
{
	LoginCheck(playerid);
	SpawnCheck(playerid);
	
	ShowPlayerDialog(playerid, DIALOG_PPSHOP, DIALOG_STYLE_LIST, ""newb"Premium Points Shop", "Jetpack\t\t\t(3 PP)\nVIP\t\t\t(7 days) (50 PP)\nSuper Handbrake\t(5 PP)\nChange Name\t\t(1 PP)", "Buy", "Cancel");
	return 1;
}

CMD:keys(playerid, params[])
{
	new string[1400];
	strcat(string, ""green"");
	strcat(string, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Key Informations\n\n");
	strcat(string, ""white"");
	strcat(string, "Press 2 to Repair your vehicle (The sound indicates its repaired).\n");
	strcat(string, "Press LMB for nitrous and speedboost.\n");
	strcat(string, "Press Y for super handbrake (if you had it from Premium Shop)\n");
	strcat(string, "Press N for Vehicle Jump");
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""lightblue"Key Information", string, "Close", "");
	return 1;
}

CMD:hhcmds(playerid, params[])
{
	new string[1400];
	strcat(string, ""green"");
	strcat(string, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' House System\n\n");
	strcat(string, ""white"");
	strcat(string, "/buyint - To buy interior (Works only when you choose interior on /hmenu)\n");
	strcat(string, "/cancelint - To cancel the preview interior (Same like /buyint)\n");
	strcat(string, "/buyhouse - /sellhouse (Buys/Sells house, Works only when in-range of the pickup)\n");
	strcat(string, "/hlock - To lock the house (Works only when in-range of pickup/Inside)\n");
	strcat(string, "/hmenu - Player's House Configuration Menu\n");
	strcat(string, "/henter - Enters inside the house (If not locked).\n");
	strcat(string, "/hnote - Adds a note to your house.\n");
	strcat(string, "/hcnote - Checks a note on someones house\n\n");
	strcat(string, ""lightred"");
	strcat(string, "Credits to JaKe for the house system.");
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""lightblue"House Commands", string, "Close", "");
	return 1;
}

CMD:commands(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_LIST, ""red"Commands", "Teleport Commands\nAdmin Commands\nHelper Commands\nPlayer Commands\nPremium Commands\nCredits\nHouse Commands\nKeys\n---> About the Server <---\nAnimation Commands", "Select", "Cancel");
	return 1;
}
CMD:cmds(playerid, params[]) return cmd_commands(playerid, "");

CMD:pcmds(playerid, params[])
{
	OnDialogResponse(playerid, DIALOG_CMDS, 1, 3, "");
	return 1;
}

CMD:cuff(playerid, params[])
{
	SpawnCheck(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
	return 1;
}

CMD:uncuff(playerid, params[])
{
	SpawnCheck(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	return 1;
}

CMD:handsup(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
    return 1;
}

CMD:dance(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	new id;
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /dance [1-4]");
	if(id < 1 || id > 4) return SendClientMessage(playerid, -1, "» "red"Invalid DanceID.");
	switch(id)
	{
	    case 1: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
	    case 2: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
 	    case 3: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
     	case 4: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
	}
	return 1;
}

CMD:vomit(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:eat(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:chairsit(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "BAR", "dnk_stndF_loop", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:taichi(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "PARK", "Tai_Chi_Loop", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:lay(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:gro(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:fucku(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "PED", "fucku", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:wave(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:crossarms(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1);
	return 1;
}

CMD:laugh(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:bomb(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "» "red"You cannot use this command while you are riding in a vehicle.");
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

CMD:anims(playerid, params[])
{
	new string[1400];
	strcat(string, ""green"");
	strcat(string, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Animation List\n\n");
	strcat(string, ""white"");
	strcat(string, "/dance, /handsup, /cuff, /uncuff, /vomit, /eat, /wave, /taichi, /chairsit, /fucku, /gro, /lay\n");
	strcat(string, "/crossarms, /laugh, /bomb\n\n");
	strcat(string, ""lightred"");
	strcat(string, "Credits to JaKe for the animation system.");
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""lightblue"Animation List", string, "Close", "");
	return 1;
}

CMD:help(playerid, params[])
{
	new string[1400];
	strcat(string, ""green"");
	strcat(string, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' About Info\n\n");
	strcat(string, ""white"");
	strcat(string, "We started as FunGaming back in April 2013, Now we are back, Our developers based the server to that FunGaming.\n");
	strcat(string, "The server is daily updated (Fixing bugs/Adding new stuff), The server is run 24/7 without any interruption.\n\n");
	strcat(string, ""lightred"How do i earn scores and money in the server?"white"\n");
	strcat(string, "We have plenty of minigames, races and deathmatches to join with such as Math Quiz, ReactionContest, MoneyBag, Horseshoe, Checkpoint etc.\n");
	strcat(string, "You can also join the Deathmatches (/minigun, etc.) to earn your K/D, score, cash and your own reputation.\n\n");
	strcat(string, ""lightblue"Commands of the server?"white"\n");
	strcat(string, "/commands (/cmds) - Displays organized commands of the server.\n");
	strcat(string, "/help - Displays an info regarding to the server.\n\n");
	strcat(string, ""grey"");
	strcat(string, "Credits to JaKe for the gamemode. (/credits for more info)");
	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""lightblue"Information", string, "Close", "");
	return 1;
}

CMD:hcmds(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
	{
		OnDialogResponse(playerid, DIALOG_CMDS, 1, 2, "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:giveweapon(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 2)
	{
	    new string[140], id, weapon, weaponName[40];
	    if(sscanf(params, "us[40]", id, weaponName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /giveweapon [playerid] [weapon(weapid)]");
		new WeapName[32];
		if(!isnumeric(weaponName)) weapon = GetWeaponIDFromName(weaponName); else weapon = strval(weaponName);
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(GetPlayerState(id) != 1 && GetPlayerState(id) != 2 && GetPlayerState(id) != 3) return SendClientMessage(playerid, -1, "» "red"You cannot use this command on none spawned player.");
		if(!IsValidWeapon(weapon)) return SendClientMessage(playerid, -1, "» "red" Invalid weapon ID");
		GetWeaponName(weapon, WeapName, 32);
		GivePlayerWeapon(id, weapon, 999999);
		format(string, sizeof(string), "[GIVE] "white"%s has just received a "grey"%s(%d) "white"from an admin.", GetName(id), WeapName, weapon);
		SendPlayerMessage(COLOR_YELLOW, string);
		format(string, sizeof(string), "[GIVE] "white"%s has just received a "grey"%s(%d) "white"from %s.", GetName(id), WeapName, weapon, GetName(playerid));
		SendAMessage(COLOR_YELLOW, string);
		format(string, sizeof(string), "[GIVE] "white"You received a "grey"%s(%d) "white"from an admin.", WeapName, weapon);
		SendClientMessage(id, COLOR_RED, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:acmds(playerid, params[])
{
	LoginCheck(playerid);

	if(User[playerid][accountAdmin] >= 1)
	{
		OnDialogResponse(playerid, DIALOG_CMDS, 1, 1, "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:teles(playerid, params[])
{
	OnDialogResponse(playerid, DIALOG_CMDS, 1, 0, "");
	return 1;
}

CMD:hidetd(playerid, params[])
{
	SpawnCheck(playerid);

	new id=GetPVarInt(playerid, "Textdraw4Me");
	if(id == 0)
	{
	    PlayerTextDrawShow(playerid, Textdraw0);
	    TextDrawShowForPlayer(playerid, Textdraw1);
		TextDrawShowForPlayer(playerid, Textdraw2);
		TextDrawShowForPlayer(playerid, Textdraw3);
		TextDrawShowForPlayer(playerid, Textdraw4);
		TextDrawShowForPlayer(playerid, Textdraw5);
		TextDrawShowForPlayer(playerid, Textdraw6);
		TextDrawShowForPlayer(playerid, Textdraw7);
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
	    	PlayerTextDrawShow(playerid, Textdraw8);
	    }
	    PlayerTextDrawShow(playerid, Textdraw9);
	    TextDrawShowForPlayer(playerid, Textdraw10);
	    
	    SendClientMessage(playerid, -1, "» "grey"You have enabled the visibility of the server's textdraw.");
	    
		SetPVarInt(playerid, "Textdraw4Me", 1);
	}
	else
	{
	    PlayerTextDrawHide(playerid, Textdraw0);
	    TextDrawHideForPlayer(playerid, Textdraw1);
		TextDrawHideForPlayer(playerid, Textdraw2);
		TextDrawHideForPlayer(playerid, Textdraw3);
		TextDrawHideForPlayer(playerid, Textdraw4);
		TextDrawHideForPlayer(playerid, Textdraw5);
		TextDrawHideForPlayer(playerid, Textdraw6);
		TextDrawHideForPlayer(playerid, Textdraw7);
		PlayerTextDrawHide(playerid, Textdraw8);
	    PlayerTextDrawHide(playerid, Textdraw9);
	    TextDrawHideForPlayer(playerid, Textdraw10);

	    SendClientMessage(playerid, -1, "» "grey"You have disabled the visibility of the server's textdraw.");

		SetPVarInt(playerid, "Textdraw4Me", 0);
	}
	return 1;
}

CMD:god(playerid, params[])
{
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	new id = GetPVarInt(playerid, "GodMode");
	if(id == 0)
	{
	    SendClientMessage(playerid, -1, "» "grey"You have enabled your god mode.");
		PlayerTextDrawSetString(playerid, Textdraw9, "GOD ~g~ON");
	    SetPVarInt(playerid, "GodMode", 1);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "grey"You have disabled your god mode.");
		PlayerTextDrawSetString(playerid, Textdraw9, "GOD ~r~OFF");
		SetPlayerHealth(playerid, 100.0);

	    SetPVarInt(playerid, "GodMode", 0);
	}
	return 1;
}

//debug
CMD:stuck(playerid, params[])
{
    new string[128], vID[32], vVW, vINT, vid, Float:x, Float:y, Float:z, Float:ang, veh;

	if(sscanf(params, "s[32]", vID)) return 1;
    if(isnumeric(vID)) vid = strval(vID);
    else vid = GetVehicleModelIDFromName(vID);
    if(vid < 400 || vid > 608) return 1;
    if(vid == 538 || vid == 537 || vid == 449) return 1;
	GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, ang);
	veh = CreateVehicle(vid, x, y, z, ang, 255, 255, 0);
    vVW = GetPlayerVirtualWorld(playerid);
    vINT = GetPlayerInterior(playerid);
    SetVehicleVirtualWorld(veh, vVW);
    LinkVehicleToInterior(veh, vINT);
	SetVehicleNumberPlate(veh, ""green"JaKe");
    PutPlayerInVehicle(playerid,veh, 0);
    format(string, sizeof(string), ""red"[VEHICLE] "white"You have just spawned a debug vehicle "grey"%s"white".", VehicleName[vid - 400]);
    SendClientMessage(playerid, -1, string);
	return 1;
}

//used for the vehicle pickups
CMD:car697415(playerid, params[])
{
    new string[128], vID[32], vVW, vINT, vid, Float:x, Float:y, Float:z, Float:ang;

	if(sscanf(params, "s[32]", vID)) return 1;
    if(isnumeric(vID)) vid = strval(vID);
    else vid = GetVehicleModelIDFromName(vID);
    if(vid < 400 || vid > 608) return 1;
    if(vid == 538 || vid == 537 || vid == 449) return 1;
	GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, ang);
	pVehicle[playerid] = CreateVehicle(vid, x, y, z, ang, 255, 255, 0);
    vVW = GetPlayerVirtualWorld(playerid);
    vINT = GetPlayerInterior(playerid);
    SetVehicleVirtualWorld(pVehicle[playerid], vVW);
    LinkVehicleToInterior(pVehicle[playerid], vINT);
	SetVehicleNumberPlate(pVehicle[playerid], ""green"JaKe");
    PutPlayerInVehicle(playerid, pVehicle[playerid], 0);
    format(string, sizeof(string), ""red"[VEHICLE] "white"You have just received a "grey"%s"white" from the teleport location pickup.", VehicleName[vid - 400]);
    SendClientMessage(playerid, -1, string);
	return 1;
}

//The original one
CMD:car(playerid, params[])
{
    new string[128], vID[32], vVW, vINT, vid, Float:x, Float:y, Float:z, Float:ang;

	SpawnCheck(playerid);
	PassengerCheck(playerid);

	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "» "red"You already have vehicle spawned.");

	if(sscanf(params, "s[32]", vID)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /car or /v <vehiclename or vehicleid>");

    if(isnumeric(vID)) vid = strval(vID);
    else vid = GetVehicleModelIDFromName(vID);
    
    if(vid < 400 || vid > 608) return SendClientMessage(playerid, -1, "» "red"Invalid VehicleID <400 - 611 only>.");
    if(vid == 538 || vid == 537 || vid == 449) return SendClientMessage(playerid, -1, "» "red"Cannot spawn that kind of vehicle!");

	if(vid == 425)
	{
	    if(User[playerid][accountAdmin] <= 1)
	    {
	        SendClientMessage(playerid, -1, "» "red"You cannot spawn Hunters, Only Administrators+ can spawn this.");
			return 1;
		}
	}
	if(vid == 432)
	{
	    if(User[playerid][accountAdmin] <= 3)
	    {
	        SendClientMessage(playerid, -1, "» "red"You cannot spawn Rhino, Only Managers+ can spawn this.");
			return 1;
		}
	}
	if(vid == 447)
	{
	    if(User[playerid][accountAdmin] <= 1)
	    {
	        SendClientMessage(playerid, -1, "» "red"You cannot spawn Seasparrow, Only Administrators+ can spawn this.");
			return 1;
		}
	}

	if(pVehicle[playerid] != -1)
    {
        foreach(new i : Player)
        {
        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
		}
    }
    DestroyVehicle(pVehicle[playerid]);
	GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, ang);
	pVehicle[playerid] = CreateVehicle(vid, x, y, z, ang, 255, 255, 0);
    vVW = GetPlayerVirtualWorld(playerid);
    vINT = GetPlayerInterior(playerid);
    SetVehicleVirtualWorld(pVehicle[playerid], vVW);
    LinkVehicleToInterior(pVehicle[playerid], vINT);
	SetVehicleNumberPlate(pVehicle[playerid], ""green"JaKe");
    PutPlayerInVehicle(playerid, pVehicle[playerid], 0);
    format(string, sizeof(string), ""red"[VEHICLE] "white"You have spawned "grey"%s(%i)"white".", VehicleName[vid - 400], vid);
    SendClientMessage(playerid, -1, string);
	return 1;
}
CMD:v(playerid, params[]) return cmd_car(playerid, params);

CMD:vget(playerid, params[])
{
	LoginCheck(playerid);

    new
        Float:x,
        Float:y,
        Float:z
	;

    if(pVehicle[playerid] == -1) return SendClientMessage(playerid, -1, "» "red"You haven't spawned anything, /car or /v first!");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "» "red"You cannot use this whilist inside a vehicle.");
    GetPlayerPos(playerid, x, y, z);
    new Float:a; GetPlayerFacingAngle(playerid, a);
	SetVehiclePos(pVehicle[playerid], x, y, z);
	SetVehicleZAngle(pVehicle[playerid], a);
	LinkVehicleToInterior(pVehicle[playerid], GetPlayerInterior(playerid));
    PutPlayerInVehicle(playerid, pVehicle[playerid], 0);
    SendClientMessage(playerid, COLOR_RED, "[VEHICLE] "white"You have teleported your last spawned vehicle to your location.");
	return 1;
}

CMD:skatepark(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), 1912.7152, -1400.0713, 13.1329);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 298.7019);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, 1922.0667, -1412.6779, 13.5703);
	    SetPlayerFacingAngle(playerid, 86.2690);
	}
	SendTeleportMessage(playerid, "Skate Park", "skatepark");
	return 1;
}

CMD:chilliad(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), -2251.6426, -1711.4546, 479.7952);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 73.6216);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, -2314.1245, -1693.3069, 482.5130);
	    SetPlayerFacingAngle(playerid, 355.9733);
	}
	SendTeleportMessage(playerid, "Mount Chilliad", "chilliad");
	return 1;
}

CMD:sniper(playerid, params[])
{
	SpawnCheck(playerid);

	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	ResetPlayerWeapons(playerid);
	SniperSpawn(playerid);
	sniper_ ++;
	g_DM[playerid] = 2;
	SendTeleportMessage(playerid, "Sniper Arena", "sniper");
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have spawned at Sniper Arena: "white"/leavedm to leave the arena.");
	return 1;
}
CMD:minigun(playerid, params[])
{
	SpawnCheck(playerid);

	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	ResetPlayerWeapons(playerid);
	MinigunSpawn(playerid);
	minigun_ ++;
	g_DM[playerid] = 1;
	SendTeleportMessage(playerid, "Minigun Arena", "minigun");
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have spawned at Minigun Arena: "white"/leavedm to leave the arena.");
	return 1;
}
CMD:leavedm(playerid, params[])
{
	SpawnCheck(playerid);

	if(g_DM[playerid] == 0)
	{
		SendClientMessage(playerid, -1, "» "red"You are not in any Deathmatch Arenas.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	ResetPlayerWeapons(playerid);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SpawnPlayer(playerid);
	LeaveDM(playerid, "Left");
	g_DM[playerid] = 0;
	return 1;
}

CMD:leaverp(playerid, params[])
{
	SpawnCheck(playerid);

	if(_RP[playerid] == 0)
	{
		SendClientMessage(playerid, -1, "» "red"You are not in the Roleplay World.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SpawnPlayer(playerid);
	LeaveRP(playerid, "Left");
	_RP[playerid] = 0;
	return 1;
}

CMD:rp(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);

	if(_RP[playerid] == 1) return SendClientMessage(playerid, -1, "» "red"You are already in the Roleplay Mode.");

	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	rp_ ++;
	_RP[playerid] = 1;
	SetPlayerVirtualWorld(playerid, 9876);

	SendClientMessage(playerid, -1, "You have entered the World of Roleplay.");
	SendClientMessage(playerid, COLOR_YELLOW, "You may RP in: Light, Medium, Heavy, We aren't strict on RP since we focus ourselves on having fun.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "Make sure to maintain the Roleplay though, that's why it's called /ROLEPLAY/.");

	SendTeleportMessage(playerid, "Roleplay World", "rp");
	return 1;
}

CMD:sfa(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), -1504.4640,-322.4451,6.7357);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 13.3832);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, -1514.8895,-331.4654,6.8848);
	    SetPlayerFacingAngle(playerid, 359.1662);
	}
	SendTeleportMessage(playerid, "San Fierro Airport", "sfa");
	return 1;
}

CMD:drift(playerid, params[])
{
	new string[90], string2[90], id;

	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /drift <1/1>");
	if(id < 1 || id > 1) return SendClientMessage(playerid, -1, "» "red"Invalid drift location.");

	format(string, sizeof(string), "Drift Place %d", id);
	format(string2, sizeof(string2), "drift %d", id);
	SendTeleportMessage(playerid, string, string2);
	
	switch(id)
	{
	    case 1:
	    {
			SetCameraBehindPlayer(playerid);

			if(IsPlayerInAnyVehicle(playerid))
			{
			    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
				SetVehiclePos(GetPlayerVehicleID(playerid), -278.9280,1536.9585,75.0840);
				SetVehicleZAngle(GetPlayerVehicleID(playerid), 128.8052);
			}
			else
			{
			    SetPlayerInterior(playerid, 0);
	    		SetPlayerVirtualWorld(playerid, 0);
			    SetPlayerPos(playerid, -306.6982,1533.8291,75.3594);
			    SetPlayerFacingAngle(playerid, 185.3862);
			}
		}
	}
	return 1;
}

CMD:lsa(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), 2100.5251,-2618.6121,13.2740);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 22.3881);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, 2053.7520,-2558.6763,13.5469);
	    SetPlayerFacingAngle(playerid, 257.2533);
	}
	SendTeleportMessage(playerid, "Los Santos Airport", "lsa");
	return 1;
}

CMD:sfpark(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}

	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), -2636.6350, 1394.4076, 6.6615);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 280.3826);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, -2629.9939, 1402.4919, 7.0994);
	    SetPlayerFacingAngle(playerid, 253.5358);
	}
	SendTeleportMessage(playerid, "San Fierro's Stunt Park", "sfpark");
	return 1;
}

CMD:aa(playerid, params[])
{
	SpawnCheck(playerid);
	PassengerCheck(playerid);
	if(Restriction(playerid) == 1)
	{
		SendClientMessage(playerid, -1, "» "red"You cannot use this command at the moment.");
	    return 1;
	}
	
	SetCameraBehindPlayer(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
	    SetVehiclePos(GetPlayerVehicleID(playerid), 404.0270,2447.9265,16.2271);
	    SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.4986);
	}
	else
	{
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerPos(playerid, 404.0706,2436.9111,16.5000);
	    SetPlayerFacingAngle(playerid, 359.4202);
	}
	SendTeleportMessage(playerid, "Abandoned Airport", "aa");
	return 1;
}

CMD:admins(playerid, params[])
{
	SendClientMessage(playerid, -1, "» "red"The server has renamed the command to /staffs.");
	return 1;
}
CMD:helpers(playerid, params[])
{
	SendClientMessage(playerid, -1, "» "red"The server has renamed the command to /staffs.");
	return 1;
}

CMD:vips(playerid, params[])
{
	new
	    count = 0;

	new
	    string[256],
	    string2[3000]
	;

	strcat(string2, ""grey"");
	strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Donators.\n");
	strcat(string2, ""grey"");
	strcat(string2, "You'll received the VIP once you buy it from the Premium Shop for 50 Premium Points.\n");
	strcat(string2, "You can also buy it by donating some dollars in the server, Which is more better than the Premium Shop.\n\n");

    foreach (new x : Player)
    {
	    if(User[x][accountLogged] == true && User[x][accountVIP] == 1)
	    {
	        count++;
            format(string, sizeof(string), "{%06x}VIP %s (ID:%d)\n", GetPlayerColor(x) >>> 8, GetName(x), x);
            strcat(string2, string);
        }
    }
    if(count == 0)
    {
        strcat(string2, ""grey"");
        strcat(string2, "No VIPs online at the moment.");
    }

    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""newb"Donators", string2, "Close", "");
	return 1;
}

CMD:staffs(playerid, params[])
{
	new
	    count = 0,
	    count2 = 0,
	    ranks[128]
	;

	new
	    string[256],
	    string2[3000]
	;

	strcat(string2, ""grey"");
	strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Staff Member.\n");
	strcat(string2, ""yellow"");
	strcat(string2, "Do you need help? Simply /ask and the Helper Staff will gonna help you out.\n");
	strcat(string2, ""red"");
	strcat(string2, "Saw a rule breaker or hacker? Simply /report and our friendly Admin Staff will gonna dealt with it.\n\n");

    foreach (new i : Player)
    {
	    if(User[i][accountLogged] == true && User[i][accountHelper] == 1)
	    {
	        count++;
            format(string, sizeof(string), "{%06x}Server Helper %s (ID:%d)\n", GetPlayerColor(i) >>> 8, GetName(i), i);
            strcat(string2, string);
        }
    }
    if(count == 0) 
    {
        strcat(string2, ""grey"");
        strcat(string2, "No server helper online at the moment.\n");
    }
    
    foreach (new x : Player)
    {
	    if(User[x][accountLogged] == true && User[x][accountAdmin] >= 1)
	    {
			switch(User[x][accountAdmin])
			{
			    case 1: ranks = "Moderator";
			    case 2: ranks = "Admin";
			    case 3: ranks = "Head Admin";
			    case 4: ranks = "Manager";
			    case 5: ranks = "Owner";
			}

	        if(AdminDuty[x] == 1)
	        {
	            format(string, sizeof(string), ""white"%s is hidden, Administrative Duties\n", ranks);
	            strcat(string2, string);
			}
			else
			{
	            format(string, sizeof(string), "{%06x}%s %s (ID:%d)\n", GetPlayerColor(x) >>> 8, ranks, GetName(x), x);
	            strcat(string2, string);
			}
			
			count2++;
        }
    }
    if(count2 == 0)
    {
        strcat(string2, ""grey"");
        strcat(string2, "No administrator online at the moment.\n");
    }
    
    format(string, sizeof string, ""red"\nAdministrators: "grey"%d\n", count2);
    strcat(string2, string);
    format(string, sizeof string, ""newb"Helpers: "grey"%d\n", count);
    strcat(string2, string);
    format(string, sizeof string, ""orange"Overall staffs: "grey"%d\n", count+count2);
    strcat(string2, string);
    
    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Staffs", string2, "Close", "");
	return 1;
}

CMD:jailed(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
		new
		    count = 0
		;

		new
		    string[256],
		    string2[3000]
		;

		strcat(string2, ""grey"");
		strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Jailed Players.\n\n");

	    foreach (new i : Player)
	    {
		    if(User[i][accountLogged] == true && User[i][accountJail] == 1)
		    {
		        count++;
	            format(string, sizeof(string), "{%06x}Player %s (ID:%d) -- %d seconds\n", GetPlayerColor(i) >>> 8, GetName(i), i, User[i][accountJailSec]);
	            strcat(string2, string);
	        }
	    }
	    if(count == 0)
	    {
	        strcat(string2, ""grey"");
	        strcat(string2, "No jailed players at the moment.\n");
	    }

	    format(string, sizeof string, ""orange"Overall jailed players: "grey"%d\n", count);
	    strcat(string2, string);

	    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Jailed", string2, "Close", "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:cmuted(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 2)
	{
		new
		    count = 0
		;

		new
		    string[256],
		    string2[3000]
		;

		strcat(string2, ""grey"");
		strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Command Muted Players.\n\n");

	    foreach (new i : Player)
	    {
		    if(User[i][accountLogged] == true && User[i][accountCMuted] == 1)
		    {
		        count++;
	            format(string, sizeof(string), "{%06x}Player %s (ID:%d) -- %d seconds\n", GetPlayerColor(i) >>> 8, GetName(i), i, User[i][accountCMuteSec]);
	            strcat(string2, string);
	        }
	    }
	    if(count == 0)
	    {
	        strcat(string2, ""grey"");
	        strcat(string2, "No command muted players at the moment.\n");
	    }

	    format(string, sizeof string, ""orange"Overall muted players: "grey"%d\n", count);
	    strcat(string2, string);

	    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Command Muted", string2, "Close", "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:muted(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
		new
		    count = 0
		;

		new
		    string[256],
		    string2[3000]
		;

		strcat(string2, ""grey"");
		strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Muted Players.\n\n");

	    foreach (new i : Player)
	    {
		    if(User[i][accountLogged] == true && User[i][accountMuted] == 1)
		    {
		        count++;
	            format(string, sizeof(string), "{%06x}Player %s (ID:%d) -- %d seconds\n", GetPlayerColor(i) >>> 8, GetName(i), i, User[i][accountMuteSec]);
	            strcat(string2, string);
	        }
	    }
	    if(count == 0)
	    {
	        strcat(string2, ""grey"");
	        strcat(string2, "No muted players at the moment.\n");
	    }

	    format(string, sizeof string, ""orange"Overall muted players: "grey"%d\n", count);
	    strcat(string2, string);

	    ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Muted", string2, "Close", "");
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:givepp(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
	    new string[150], id, amount;
	
		if(sscanf(params, "ui", id, amount)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /givepp [playerid] [amount]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");

		format(string, 150, "[PREMIUM POINTS] "red"%s has given %s [%d] Premium Points.", GetName(playerid), GetName(id), amount);
		SendAMessage(-1, string);
		format(string, 150, ""green"[PREMIUM POINTS] "white"You have received "grey"%d "white"premium points from an "red"admin"white".", amount, User[id][accountPP]+amount);
		SendClientMessage(id, -1, string);
		format(string, 150, "» You have given {%06x}%s "white"premium points of "grey"%d"white".", GetPlayerColor(id) >>> 8, GetName(id), amount);
		SendClientMessage(playerid, -1, string);

		format(string, 128, "%s received %d Premium Points from %s.", GetName(id), amount, GetName(playerid));
		Log("premium.txt", string);

		User[id][accountPP] += amount;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:ask(playerid, params[])
{
	new string[140];
	
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /ask [question]");
	if(strlen(params) <= 4) return SendClientMessage(playerid, -1, "» "red"Invalid /ask length.");
	
	if(User[playerid][accountAdmin] == 0 && User[playerid][accountHelper] == 0)
	{
		format(string, 140, ""newb"Ask: {%06x}%s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
		Log("ask.txt", string);
	}
	else if(User[playerid][accountAdmin] == 0 && User[playerid][accountHelper] == 1)
	{
		format(string, 140, ""newb"Ask: {%06x}Server Helper %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
		Log("ask.txt", string);
	}
	else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountHelper] == 0)
	{
	    if(User[playerid][accountAdmin] == 1)
	    {
			format(string, 140, ""newb"Ask: {%06x}Moderator %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 2)
	    {
			format(string, 140, ""newb"Ask: {%06x}Admin %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 3)
	    {
			format(string, 140, ""newb"Ask: {%06x}Head Admin %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 4)
	    {
			format(string, 140, ""newb"Ask: {%06x}Manager %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] >= 5)
	    {
			format(string, 140, ""newb"Ask: {%06x}Owner %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	}
	else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountHelper] == 1)
	{
	    if(User[playerid][accountAdmin] == 1)
	    {
			format(string, 140, ""newb"Ask: {%06x}Moderator %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 2)
	    {
			format(string, 140, ""newb"Ask: {%06x}Admin %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 3)
	    {
			format(string, 140, ""newb"Ask: {%06x}Head Admin %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] == 4)
	    {
			format(string, 140, ""newb"Ask: {%06x}Manager %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	    else if(User[playerid][accountAdmin] >= 5)
	    {
			format(string, 140, ""newb"Ask: {%06x}Owner %s "white": %s", GetPlayerColor(playerid) >>> 8, GetName(playerid), params);
			Log("ask.txt", string);
		}
	}
	SendClientMessageToAll(-1, string);
	return 1;
}

CMD:vip(playerid, params[])
{
	new string[140];

	if(User[playerid][accountAdmin] >= 5 || User[playerid][accountVIP] == 1)
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /vip [vip chat]");

		if(User[playerid][accountAdmin] == 0 && User[playerid][accountVIP] == 1)
		{
		    format(string, 140, "Premium: VIP %s: "white"%s", GetName(playerid), params);
			Log("chat.txt", string);
		}
		else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountVIP] == 0)
		{
		    if(User[playerid][accountAdmin] == 1)
		    {
				format(string, 140, "Premium: Mod %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 2)
		    {
				format(string, 140, "Premium: Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 3)
		    {
				format(string, 140, "Premium: Head Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 4)
		    {
				format(string, 140, "Premium: Manager %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] >= 5)
		    {
				format(string, 140, "Premium: Owner %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		}
		else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountVIP] == 1)
		{
		    if(User[playerid][accountAdmin] == 1)
		    {
				format(string, 140, "Premium: Mod %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 2)
		    {
				format(string, 140, "Premium: Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 3)
		    {
				format(string, 140, "Premium: Head Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 4)
		    {
				format(string, 140, "Premium: Manager %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] >= 5)
		    {
				format(string, 140, "Premium: Owner %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		}
		SendVMessage(COLOR_ORANGE, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:a(playerid, params[])
{
	new string[140];

	if(ToggleAdmin[playerid] == 0) return SendClientMessage(playerid, -1, "You have the Admin Notifier disabled.");
	if(User[playerid][accountAdmin] >= 1 || User[playerid][accountHelper] == 1)
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /a [admin chat]");

		if(User[playerid][accountAdmin] == 0 && User[playerid][accountHelper] == 1)
		{
			format(string, 140, "Chat: Helper %s: "white"%s", GetName(playerid), params);
			Log("chat.txt", string);
		}
		else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountHelper] == 0)
		{
		    if(User[playerid][accountAdmin] == 1)
		    {
				format(string, 140, "Chat: Mod %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 2)
		    {
				format(string, 140, "Chat: Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 3)
		    {
				format(string, 140, "Chat: Head Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 4)
		    {
				format(string, 140, "Chat: Manager %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] >= 5)
		    {
				format(string, 140, "Chat: Owner %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		}
		else if(User[playerid][accountAdmin] >= 1 && User[playerid][accountHelper] == 1)
		{
		    if(User[playerid][accountAdmin] == 1)
		    {
				format(string, 140, "Chat: Mod %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 2)
		    {
				format(string, 140, "Chat: Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 3)
		    {
				format(string, 140, "Chat: Head Admin %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] == 4)
		    {
				format(string, 140, "Chat: Manager %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		    else if(User[playerid][accountAdmin] >= 5)
		    {
				format(string, 140, "Chat: Owner %s: "white"%s", GetName(playerid), params);
				Log("chat.txt", string);
			}
		}
		SendAMessage(COLOR_YELLOW, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:moneybag(playerid, params[])
{
	new string[150];
    if(!MoneyBagFound) format(string, sizeof(string), "» The "green"moneybag "white"is still active and located at \""red"%s"white"\".", MoneyBagLocation);
    if(MoneyBagFound) format(string, sizeof(string), "» There's no "green"moneybag "white"at the moment.");
    return SendClientMessage(playerid, -1, string);
}
CMD:mb(playerid, params[]) return cmd_moneybag(playerid, params);

CMD:startmb(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    MoneyBag();
		new string[128];
		format(string, sizeof(string), "[MONEYBAG] "red"%s has started another moneybag contest.", GetName(playerid));
		SendAMessage(-1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:startcp(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    Checkpoint();
	    SendAMessage(-1, " ");
		new string[128];
		format(string, sizeof(string), "[CHECKPOINT] "red"%s has started another checkpoint contest.", GetName(playerid));
		SendAMessage(-1, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:startmath(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    if(started == 1) return SendClientMessage(playerid, -1, "» "red"Unable to start the math quiz, There's already an active one.");

	    SendPlayerMessage(-1, "[CONTEST] "red"An admin started the math quiz manually, It will begin in 5 seconds.");
		new string[128];
		format(string, sizeof(string), "[MATH] "red"%s has started the math quiz, It will begin in 5 seconds.", GetName(playerid));
		SendAMessage(-1, string);
		SetTimer("BeginMaths", 5000, false);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:reaction(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 1)
	{
	    if(begin_react == 1) return SendClientMessage(playerid, -1, "» "red"Unable to start the reaction contest, There's already an active one.");

	    SendPlayerMessage(-1, "[CONTEST] "red"An admin started the reaction contest manually, It will begin in 5 seconds.");
		new string[128];
		format(string, sizeof(string), "[CONTEST] "red"%s has started the reaction contest, It will begin in 5 seconds.", GetName(playerid));
		SendAMessage(-1, string);
		SetTimer("BeginReaction", 5000, false);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setmoney(playerid, params[])
{
	new
	    string[200],
	    id,
	    amount
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		if(sscanf(params, "ui", id, amount)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setmoney [playerid] [cash]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");

		format(string, 128, "[SET] "white"%s's money has been set to $%d by %s.", GetName(id), amount, GetName(playerid));
		SendAMessage(COLOR_RED, string);
        format(string, 128, "[SET] "white"An admin has set your money to $%d.", amount);
		SendClientMessage(id, COLOR_YELLOW, string);

		format(string, 128, "%s has been money set to $%d by %s.", GetName(id), amount, GetName(playerid));
		Log("admin.txt", string);

	    ResetPlayerCash(id);
	    GivePlayerCash(id, amount);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:setscore(playerid, params[])
{
	new
	    string[200],
	    id,
	    amount
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4)
	{
		if(sscanf(params, "ui", id, amount)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setscore [playerid] [score]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");

		format(string, 128, "[SET] "white"%s's score has been set to %d by %s.", GetName(id), amount, GetName(playerid));
		SendAMessage(COLOR_RED, string);
        format(string, 128, "[SET] "white"An admin has set your score to %d.", amount);
		SendClientMessage(id, COLOR_YELLOW, string);

		format(string, 128, "%s has been score set to %d by %s.", GetName(id), amount, GetName(playerid));
		Log("admin.txt", string);

	    SetPlayerScore(id, amount);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:setpremium(playerid, params[])
{
	new
	    string[200],
	    id,
	    amount
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5)
	{
		if(sscanf(params, "ui", id, amount)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setpremium [playerid] [points]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");

		format(string, 128, "[SET] "white"%s's Premium Point has been set to %d by %s.", GetName(id), amount, GetName(playerid));
		SendAMessage(COLOR_RED, string);
        format(string, 128, "[SET] "white"An admin has set your premium points to %d.", amount);
		SendClientMessage(id, COLOR_YELLOW, string);

		format(string, 128, "%s has been premium points set to %d by %s.", GetName(id), amount, GetName(playerid));
		Log("admin.txt", string);

	    User[id][accountPP] = amount;
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setvip(playerid, params[])
{
	new
	    string[200],
	    id,
	    level,
	    days
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 3)
	{
		if(sscanf(params, "uii", id, level, days)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setvip [playerid] [level(0/1)] [days]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(level < 0 || level > 1) return SendClientMessage(playerid, -1, "» "red"Levels shouldn't go below zero and shouldn't go above one.");
		if(level == User[id][accountVIP]) return SendClientMessage(playerid, -1, "» "red"Player is already in that VIP level.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");
		if(level != 0)
		{
		    if(days < 2 || days > 363) return SendClientMessage(playerid, -1, "» "red"Expiration day shouldn't go below two and shouldn't go above three hundred three.");
		}

	    if(level == 1)
	    {
	        User[id][ExpirationVIP] = gettime() + 60*60*24*days;
	    
	        format(string, 128, "» "orange"You have been invited to the VIP Team by %s for %d days.", GetName(playerid), days);
			SendClientMessage(id, -1, string);
			format(string, 128, "» "orange"You have invited %s to VIP Team rank for %d days.", GetName(id), days);
			SendClientMessage(playerid, -1, string);

			format(string, 128, "%s has been invited to the VIP Team by %s for %d days.", GetName(id), GetName(playerid), days);
			Log("premium.txt", string);
	    }
	    else if(level == 0)
	    {
	        days = 0;
	        User[id][ExpirationVIP] = 0;
	    
	        format(string, 128, "» "orange"You have been kicked out from the VIP Team by %s.", GetName(playerid));
			SendClientMessage(id, -1, string);
			format(string, 128, "» "orange"You have kicked out %s from the VIP team.", GetName(id));
			SendClientMessage(playerid, -1, string);

			format(string, 128, "%s has been kicked out from the VIP Team by %s.", GetName(id), GetName(playerid));
			Log("premium.txt", string);
	    }

	    User[id][accountVIP] = level;

		SaveData(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:sethelper(playerid, params[])
{
	new
	    string[200],
	    id,
	    level
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 4 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", id, level)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /sethelper [playerid] [level(0/1)]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(level < 0 || level > 1) return SendClientMessage(playerid, -1, "» "red"Levels shouldn't go below zero and shouldn't go above one.");
		if(level == User[id][accountHelper]) return SendClientMessage(playerid, -1, "» "red"Player is already in that helper level.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");
		if(User[id][accountAdmin] != 0) return SendClientMessage(playerid, -1, "» "red"You cannot invite an admin to the helper team.");

	    if(level == 1)
	    {
	        format(string, 128, "» "green"You have been invited to the Helper Team by %s.", GetName(playerid));
			SendClientMessage(id, -1, string);
			format(string, 128, "» "green"You have invited %s to Helper Team rank.", GetName(id));
			SendClientMessage(playerid, -1, string);

			format(string, 128, "%s has been invited to the Helper Team by %s.", GetName(id), GetName(playerid));
			Log("staff.txt", string);
	    }
	    else if(level == 0)
	    {
	        format(string, 128, "» "red"You have been kicked out from the Helper Team by %s.", GetName(playerid));
			SendClientMessage(id, -1, string);
			format(string, 128, "» "red"You have kicked out %s from the Helper team.", GetName(id));
			SendClientMessage(playerid, -1, string);
			
			format(string, 128, "%s has been kicked from the Helper Team by %s.", GetName(id), GetName(playerid));
			Log("staff.txt", string);
	    }

	    User[id][accountHelper] = level;

		SaveData(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:lockserver(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5 || IsPlayerAdmin(playerid))
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /lockserver [password]");
		if(strlen(params) >= 15 && strlen(params) <= 3) return SendClientMessage(playerid, -1, "» "red"Invalid password length <3-15>");

		new string[150];
		format(string, sizeof string, "password %s", params);
		SendRconCommand(string);
		format(string, sizeof string, "Owner %s has locked the server.", GetName(playerid));
		SendClientMessageToAll(COLOR_RED, string);
		foreach(new i : Player)
		{
		    if(User[i][accountLogged] == true)
		    {
		        if(User[i][accountAdmin] >= 3)
		        {
		            format(string, sizeof string, "The server password is "grey"%s", params);
		            SendClientMessage(i, -1, string);
		        }
		    }
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:unlockserver(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5 || IsPlayerAdmin(playerid))
	{
	    new string[128];
		SendRconCommand("password 0");
		format(string, sizeof string, "Owner %s has unlocked the server.", GetName(playerid));
		SendClientMessageToAll(COLOR_YELLOW, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:dhostname(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5 || IsPlayerAdmin(playerid))
	{
	    new string[150];
		SendRconCommand("hostname "#S_H"");
		format(string, sizeof string, "Owner %s has set the hostname back to it's default settings.", GetName(playerid));
		SendClientMessageToAll(COLOR_RED, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}
CMD:hostname(playerid, params[])
{
	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5 || IsPlayerAdmin(playerid))
	{
		if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /hostname [Name of the Host]");
		if(strlen(params) >= 100 && strlen(params) <= 3) return SendClientMessage(playerid, -1, "» "red"Invalid password length <3-15>");

		new string[150];
		format(string, sizeof string, "hostname %s", params);
		SendRconCommand(string);
		format(string, sizeof string, "Owner %s has changed the name of the server.", GetName(playerid));
		SendClientMessageToAll(COLOR_RED, string);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

CMD:setlevel(playerid, params[])
{
	new
	    string[200],
	    id,
	    level
	;

	LoginCheck(playerid);
	if(User[playerid][accountAdmin] >= 5 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", id, level)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /setlevel [playerid] [level(0/5)]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» "red"Player not connected.");
		if(level < 0 || level > 5) return SendClientMessage(playerid, -1, "» "red"Levels shouldn't go below zero and shouldn't go above five.");
		if(level == User[id][accountAdmin]) return SendClientMessage(playerid, -1, "» "red"Player is already in that level.");
		if(User[id][accountLogged] == false) return SendClientMessage(playerid, -1, "» "red"Player not logged in.");
		if(User[id][accountHelper] == 1)
		{
			User[id][accountHelper] = 0;
		}

	    if(User[id][accountAdmin] < level)
	    {
			format(string, 128, "» "green"You have been promoted to level %d administrative rank by %s.", level, GetName(playerid));
			SendClientMessage(id, -1, string);
			format(string, 128, "» "green"You have promoted %s to level %d administrative rank.", GetName(id), level);
			SendClientMessage(playerid, -1, string);

			format(string, 128, "%s has been promoted to level %d admin by %s.", GetName(id), level, GetName(playerid));
			Log("staff.txt", string);
	    }
	    else if(User[id][accountAdmin] > level)
	    {
	        format(string, 128, "» "red"You have been demoted to level %d administrative rank by %s.", level, GetName(playerid));
			SendClientMessage(id, -1, string);
			format(string, 128, "» "red"You have demoted %s to level %d administrative rank.", GetName(id), level);
			SendClientMessage(playerid, -1, string);

			format(string, 128, "%s has been demoted to level %d admin by %s.", GetName(id), level, GetName(playerid));
			Log("staff.txt", string);
	    }

	    User[id][accountAdmin] = level;

		SaveData(id);
	}
	else
	{
	    SendClientMessage(playerid, -1, "» "red"You are not authorized to use this command.");
	}
	return 1;
}

//============================================================================//

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    InCar[playerid] = 0;
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);

    if(Act[playerid] == 1)
    {
        if(oldstate == PLAYER_STATE_DRIVER)
        {
            if(newstate == PLAYER_STATE_ONFOOT)
            {
                if(InCar[playerid] == 1)
                {
                    PutPlayerInVehicle(playerid, WhatCar[playerid], 0);
                }
            }
        }
        if(oldstate == PLAYER_STATE_PASSENGER)
        {
            if(newstate == PLAYER_STATE_ONFOOT)
            {
                if(InCar[playerid] == 1)
                {
                    PutPlayerInVehicle(playerid, WhatCar[playerid], 1);
                }
            }
        }
        if(oldstate == PLAYER_STATE_ONFOOT)
        {
            if(newstate == PLAYER_STATE_DRIVER || PLAYER_STATE_PASSENGER)
            {
                InCar[playerid] = 1;
                WhatCar[playerid] = GetPlayerVehicleID(playerid);
            }
        }
    }

	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
	    if(newstate == PLAYER_STATE_ONFOOT)
	    {
	    	InCar[playerid] = 0;
	    }
	
		for(new x=0; x<MAX_PLAYERS; x++) {
	    	if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid && User[x][SpecType] == ADMIN_SPEC_TYPE_VEHICLE) {
	        	TogglePlayerSpectating(x, 1);
		        PlayerSpectatePlayer(x, playerid);
	    	    User[x][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
			}
		}
	}
	if(newstate == PLAYER_STATE_PASSENGER)
	{
		for(new x=0; x<MAX_PLAYERS; x++) {
		    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid) {
		        TogglePlayerSpectating(x, 1);
		        PlayerSpectateVehicle(x, vehicleid);
		        User[x][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
			}
		}
	}

	if(newstate == PLAYER_STATE_DRIVER)
	{
		for(new x=0; x<MAX_PLAYERS; x++) {
		    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid) {
		        TogglePlayerSpectating(x, 1);
		        PlayerSpectateVehicle(x, vehicleid);
		        User[x][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
			}
		}
		PlayerTextDrawShow(playerid, Textdraw8);
	}
	else
	{
		PlayerTextDrawHide(playerid, Textdraw8);
	}
	return 1;
}

stock Float:GetPlayerSpeed(playerid, bool:az = true)
{
    new Float:SpeedX, Float:SpeedY, Float:SpeedZ;
    new Float:Speed;
    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), SpeedX, SpeedY, SpeedZ);
    else GetPlayerVelocity(playerid, SpeedX, SpeedY, SpeedZ);
    if(az) Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatadd(floatpower(SpeedY, 2.0), floatpower(SpeedZ, 2.0))));
    else Speed = floatsqroot(floatadd(floatpower(SpeedX, 2.0), floatpower(SpeedY, 2.0)));
    Speed = floatround(Speed * 100 * 1.61);
    return Speed;
}

public UpdatePlayer()
{
	new string[256];

	foreach(new i : Player)
	{
		if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
		{
			new Float:speed = GetPlayerSpeed(i);
		    new ss = floatround(speed);
		    format(string, sizeof(string), "KM/H: %d", ss);
		    PlayerTextDrawSetString(i, Textdraw8, string);
		}

		if(GetPVarInt(i, "GodMode") == 1)
		{
		    if(g_DM[i] == 0)
		    {
		        if(g_IsPlayerDueling[i] == 0)
		        {
				    SetPlayerHealth(i, 100000);
				}
			}
		}
		if(g_AFK[i] == 1)
		{
		    SetPlayerHealth(i, 100000);
		}

		if(IsPlayerInAnyVehicle(i))
		{
			new Float:hp;
			GetVehicleHealth(GetPlayerVehicleID(i), hp);
			if(hp <= 307.0)
			{
			    RepairVehicle(GetPlayerVehicleID(i));
			    SetVehicleHealth(GetPlayerVehicleID(i), 10000.0);
			}
		}

		format(string, 128, "Premium Points: %d", User[i][accountPP]);
		PlayerTextDrawSetString(i, Textdraw0, string);

	    new g_h, g_m, g_s;
	    gettime(g_h, g_m, g_s);
	    new g_m2, g_d, g_y;
	    getdate(g_y, g_m2, g_d);

	    format(string, 128, "%02d/%02d/%d", g_m2, g_d, g_y);
	    TextDrawSetString(Textdraw2, string);
	    format(string, 128, "%02d:%02d:%02d", g_h, g_m, g_s);
	    TextDrawSetString(Textdraw3, string);

	    TextDrawSetString(Textdraw4, teleportmsg[0]);
	    TextDrawSetString(Textdraw5, teleportmsg[1]);
	    TextDrawSetString(Textdraw6, teleportmsg[2]);
	    TextDrawSetString(Textdraw7, teleportmsg[3]);
	    
	    format(string, 128, "/minigun: %d~n~/sniper: %d~n~/rp: %d", minigun_, sniper_, rp_);
	    TextDrawSetString(Textdraw10, string);
	}
	return 1;
}

public Heartbeat()
{
	new string[256];

	foreach(new i : Player)
	{
		if(User[i][accountJail] == 1)
		{
		    if(User[i][accountJailSec] >= 1)
		    {
		        User[i][accountJailSec] --;
		    }
	        else if(User[i][accountJailSec] == 0)
	        {
	            User[i][accountJail] = 0;
	            format(string, sizeof(string), "[RELEASE] "white"%s has been unjailed from Admin's Jail by Finn.", GetName(i));
				SendClientMessageToAll(COLOR_GREEN, string);
				SpawnPlayer(i);
	        }
		}
		if(User[i][accountMuted] == 1)
		{
		    if(User[i][accountMuteSec] >= 1)
		    {
		        User[i][accountMuteSec] --;
		    }
	        else if(User[i][accountMuteSec] == 0)
	        {
	            User[i][accountMuted] = 0;
	            format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted from Admin's Mute by Finn.", GetName(i));
				SendClientMessageToAll(COLOR_ORANGE, string);
	        }
		}
		if(User[i][accountCMuted] == 1)
		{
		    if(User[i][accountCMuteSec] >= 1)
		    {
		        User[i][accountCMuteSec] --;
		    }
	        else if(User[i][accountCMuteSec] == 0)
	        {
	            User[i][accountCMuted] = 0;
	            format(string, sizeof(string), "[UNMUTE] "white"%s has been unmuted from Admin's Command Mute by Finn.", GetName(i));
				SendClientMessageToAll(COLOR_ORANGE, string);
	        }
		}
		
		if(User[i][accountVIP] == 1)
		{
			if(gettime() > User[i][ExpirationVIP])
			{
				SendClientMessage(i, COLOR_ORANGE, "[VIP] "white"Today is the expiration day of your VIP, You are no longer a VIP Player.");
				SendClientMessage(i, COLOR_YELLOW, "You can donate a dollar again to the server to get the VIP back or buy it from Premium Shop.");
				format(string, 200, "» "red"%s lost his/her VIP - Expired.", GetName(i));
				SendClientMessageToAll(-1, string);

				User[i][ExpirationVIP] = 0;
				User[i][accountVIP] = 0;
			}
		}
	}
	return 1;
}

forward PlayerRecord(playerid);
public PlayerRecord(playerid)
{
	new string[250];
	
    format(string, 250, "» Record for Online Players: {97FA17}%d{FFFFFF}, fixed by {97FA17}%s{FFFFFF}, on {97FA17}%s{FFFFFF}, at {97FA17}%s{FFFFFF}.", strval(i_Number), s_Name, s_Date, s_Hour);
	SendClientMessage(playerid, -1, string);

    if(strval(i_Number) < Iter_Count(ON_Player))
    {
        format(s_Name, sizeof s_Name, "%s", GetName(playerid));
        format(i_Number, sizeof i_Number, "%d", Iter_Count(ON_Player));

        SaveRec(); LoadRec();

        format(string, 250, "» New record for Online Players: {97FA17}%d{FFFFFF}, fixed by {97FA17}%s{FFFFFF}, on {97FA17}%s{FFFFFF}, at {97FA17}%s{FFFFFF}.", Iter_Count(ON_Player), GetName(playerid), g_date( #. ), g_hour( #: ));
        SendClientMessageToAll(-1, string);
    }
    return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	new string[140];

	if(checkpointid == cp_reward)
	{
	    new i = current_cp;
	
     	format(string, sizeof(string), "[CHECKPOINT] {%06x}%s(%d) "white"has collected the "red"hidden checkpoint "white"and earned "green"15 score + $15000", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid);
        SendClientMessageToAll(-1, string);
        SendClientMessageToAll(-1, "[CHECKPOINT] A new "red"hidden checkpoint "white"will be set in a few minutes, Stand by.");
		SetPlayerScore(playerid, GetPlayerScore(playerid) + 15);
		GivePlayerCash(playerid, 15000);
		
		User[playerid][accountCP] ++;

		format(CPSPAWN[i][Previous_Winner], 24, "%s", GetName(playerid));
		
		CPSPAWN[i][CP_Found] = 1;  //Yes.
		cppos[0] = 0.0, cppos[1] = 0.0, cppos[2] = 0.0;

        DestroyDynamicCP(cp_reward);
	}
	for(new x=0; x<MAX_HOUSES; x++)
	{
		if(checkpointid == hInfo[x][hCP])
		{
		    #if FREEZE_LOAD == true
		        House_Load(playerid);

		        SetPlayerPos(playerid, hInfo[x][hPickupP][0], hInfo[x][hPickupP][1], hInfo[x][hPickupP][2]);
		        SetPlayerInterior(playerid, 0);
		        SetPlayerVirtualWorld(playerid, 0);

		    #else
		        SetPlayerPos(playerid, hInfo[x][hPickupP][0], hInfo[x][hPickupP][1], hInfo[x][hPickupP][2]);
		        SetPlayerInterior(playerid, 0);
		        SetPlayerVirtualWorld(playerid, 0);

		    #endif

	        h_Inside[playerid] = -1;
		}
	}
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(User[playerid][accountLogged] == false)
	{
	    SendClientMessage(playerid, -1, "» "red"You cannot spawn unless you are logged in.");
	    return 0;
	}

	#if CHRISTMAS_SPIRIT == true
		if(GetPVarInt(playerid, "_christmas_") == 1)
		{
			SetPVarInt(playerid, "_christmas_", 0);
		}
	#endif
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	new string[280];

    if(pickupid == MoneyBagPickup)
    {
        new money = MoneyBagCash;
        format(string, sizeof(string), "[MONEYBAG] {%06x}%s "white"found the moneybag at "red"%s "white"and received "green"$%d/20 score", GetPlayerColor(playerid) >>> 8, GetName(playerid), MoneyBagLocation, money);
        MoneyBagFound = 1;
        SendClientMessageToAll(-1, string);
        DestroyDynamicPickup(MoneyBagPickup);
        SetPlayerScore(playerid, GetPlayerScore(playerid) + 20);
        GivePlayerCash(playerid, money);
        MoneyBagPos[0] = 0, MoneyBagPos[1] = 0, MoneyBagPos[2] = 0;
        GameTextForPlayer(playerid, "~g~Found the moneybag!", 4000, 3);
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
        
        User[playerid][accountMB] ++;
    }
	else if(pickupid == pickup[0])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "nrg");
	}
	else if(pickupid == pickup[1])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "bullet");
	}
	else if(pickupid == pickup[2])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "infernus");
	}
	else if(pickupid == pickup[3])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "nrg");
	}
	else if(pickupid == pickup[4])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "sultan");
	}
	else if(pickupid == pickup[5])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;
	
	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "elegy");
	}
	else if(pickupid == pickup[6])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 1;

	    if(pVehicle[playerid] != -1)
	    {
	        foreach(new i : Player)
	        {
	        	if(IsPlayerInVehicle(i,  pVehicle[playerid])) DestroyVehicle(pVehicle[playerid]);
			}
	    }
	    DestroyVehicle(pVehicle[playerid]);
	    cmd_car697415(playerid, "fcr");
	}

	if(pickupid == horse[0])
	{
		if(User[playerid][accountHS] == 1) return SendClientMessage(playerid, -1, "» "red"You have already collected this horseshoe!");
		GameTextForPlayer(playerid, "~w~Horseshoe 1 ~r~out ~w~of 30", 2500, 3);
		SendClientMessage(playerid, COLOR_GREEN, "[HORSESHOE] "white"Horseshoe collected, 1/30.");
		User[playerid][accountHS] = 1;
		format(string, sizeof(string), "[HORSESHOE] {%06x}%s "white"has collected the "grey"1st horseshoe "white"and received $1000 + 2 scores", GetPlayerColor(playerid) >>> 8, GetName(playerid));
		SendClientMessageToAll(COLOR_RED, string);
		GivePlayerMoney(playerid, 1000);
		SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
	}
	else if(pickupid == horse[29])
	{
	    if(User[playerid][accountHS] < 29) return SendClientMessage(playerid, -1, "» "red"Collect the horseshoe in order! This horseshoe is the final horseshoe.");
		if(User[playerid][accountHS] == 30) return SendClientMessage(playerid, -1, "» "red"You have already collected all the horseshoes.");
		GameTextForPlayer(playerid, "~w~Horseshoe 30 ~r~out ~w~of 30", 2500, 3);
		SendClientMessage(playerid, COLOR_GREEN, "[HORSESHOE] "white"All horseshoes has been collected, 30/30.");
		User[playerid][accountHS] = 30;
		format(string, sizeof(string), "[HORSESHOE] {%06x}%s "white"has collected the "grey"30th horseshoe "white"and received $50000 + 100 scores", GetPlayerColor(playerid) >>> 8, GetName(playerid));
		SendClientMessageToAll(COLOR_RED, string);
		GivePlayerMoney(playerid, 50000);
		SetPlayerScore(playerid, GetPlayerScore(playerid) + 100);
		new rand = random(3);
		switch(rand)
		{
		    case 0:
		    {
		        format(string, sizeof(string), "[ADDITIONAL] "white"%s receives another "grey"100 score and $50000 "white"as a reward of collecting the horseshoe "red"(Random REWARD)", GetName(playerid));
				SendClientMessageToAll(COLOR_GREEN, string);
				GivePlayerMoney(playerid, 50000);
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 100);
		    }
		    case 1:
		    {
		        format(string, sizeof(string), "[ADDITIONAL] "white"%s receives a "grey"7 "white"day VIP as a reward of collecting the horseshoe "red"(Random REWARD)", GetName(playerid));
				SendClientMessageToAll(COLOR_GREEN, string);
			    User[playerid][accountVIP] = 1;
				User[playerid][ExpirationVIP] = gettime() + 60*60*24*7;
				
				format(string, sizeof(string), "%s won 7 days VIP from the horseshoe minigame.", GetName(playerid));
				Log("premium.txt", string);
		    }
		    case 2:
		    {
		        format(string, sizeof(string), "[ADDITIONAL] "white"%s didn't received any random reward from the horseshoe.", GetName(playerid));
				SendClientMessageToAll(COLOR_GREEN, string);
				SendClientMessage(playerid, COLOR_RED, "Aw, No random rewards given to you by the Horseshoe, You missed the 2 other cool rewards.");
		    }
		}
	}
	for(new i = 0; i < sizeof(hcord); i++)
	{
		if(pickupid == horse[hcord[i][hpickup]])
		{
		    if(User[playerid][accountHS] < hcord[i][order]-1)
		    {
			    format(string, sizeof(string), "» "red"Collect the horseshoe in order! This is %d/30 horseshoe.", hcord[i][order]);
				SendClientMessage(playerid, -1, string);
				return 1;
			}
			if(User[playerid][accountHS] >= hcord[i][order]) return SendClientMessage(playerid, -1, "» "red"You have already collected this horseshoe.");
			format(string, sizeof(string), "~w~Horseshoe %i ~r~out ~w~of 30", hcord[i][order]);
			GameTextForPlayer(playerid, string, 2500, 3);
			format(string, sizeof(string), "[HORSESHOE] "white"Horseshoe collected, %d/30.", hcord[i][order]);
			SendClientMessage(playerid, COLOR_GREEN, string);
			User[playerid][accountHS] = hcord[i][order];
			format(string, sizeof(string), "[HORSESHOE] {%06x}%s "white"has collected the "grey"%d out of 30 horseshoe "white"and received $1000 + 2 scores", GetPlayerColor(playerid) >>> 8, GetName(playerid), hcord[i][order]);
			SendClientMessageToAll(COLOR_RED, string);
			GivePlayerMoney(playerid, 1000);
			SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
		}
	}

	for(new x=0; x<MAX_HOUSES; x++)
	{
	    if(pickupid == hInfo[x][hPickup])
	    {
	        h_ID[playerid] = x;
     	}
	}
    return 1;
}

forward JakSpawnHome(playerid);
public JakSpawnHome(playerid)
{
    SetPlayerInterior(playerid, jpInfo[playerid][p_Interior]);
    SetPlayerPos(playerid, jpInfo[playerid][p_SpawnPoint][0], jpInfo[playerid][p_SpawnPoint][1], jpInfo[playerid][p_SpawnPoint][2]);
    SetPlayerFacingAngle(playerid, jpInfo[playerid][p_SpawnPoint][3]);
    return SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] "white"Finally spawned at your house.");
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	new x = 0;
	while(x!=MAX_PLAYERS) {
	    if( IsPlayerConnected(x) &&	GetPlayerState(x) == PLAYER_STATE_SPECTATING &&
			User[x][SpecID] == playerid && User[x][SpecType] == ADMIN_SPEC_TYPE_PLAYER )
   		{
   		    SetPlayerInterior(x,newinteriorid);
		}
		x++;
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vid = GetPlayerVehicleID(playerid);
	new Float:xx, Float:xy, Float:xz, Float:Ang;
	new Float:x, Float:y, Float:z;

    if(newkeys & 16)
    {
	    if(IsPlayerInAnyVehicle(playerid) && IsVehicleRCVehicle(GetPlayerVehicleID(playerid)))
	    {
	        InCar[playerid] = 0;
	        WhatCar[playerid] = 0;
			GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
			SetPlayerPos(playerid, x, y, z+1.2);
			return 1; 
	    }
	    for(new v; v < MAX_VEHICLES; v++)
	    {
			GetVehiclePos(v,x,y,z);
			if(IsPlayerInRangeOfPoint(playerid, 8, x, y, z) && IsVehicleRCVehicle(v)) 
			{
                InCar[playerid] = 1;
                WhatCar[playerid] = GetPlayerVehicleID(playerid);

				PutPlayerInVehicle(playerid, v, 0);
				return 1;
			}
	    }
    }

	if(HOLDING(KEY_FIRE))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid), xx, xy, xz);
		SetVehicleVelocity(GetPlayerVehicleID(playerid), xx+(xx / 4), xy+(xy / 4), xz+(xz / 4));

		if(CheckVehicle(GetPlayerVehicleID(playerid))) AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	}
	else if(RELEASED(KEY_FIRE))
	{
		if(CheckVehicle(GetPlayerVehicleID(playerid))) RemoveVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	}

	if(newkeys & KEY_SUBMISSION && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		GetVehicleZAngle(vid, Ang);
		SetVehicleZAngle(vid, Ang);
		RepairVehicle(GetPlayerVehicleID(playerid));
		SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	}
	
	if(newkeys & KEY_YES)
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
	        if(User[playerid][accountNoB] == 1)
		    {
				if(User[playerid][accountBrake] == 1)
				{
		        	SetVehicleVelocity(vid, 0.0, 0.0, 0.0);
				}
			}
	    }
	}
	if(newkeys & KEY_NO)
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
			GetVehicleVelocity(GetPlayerVehicleID(playerid), xx, xy, xz);
	        SetVehicleVelocity(GetPlayerVehicleID(playerid), xx, xy, xz + 0.25);
		}
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && User[playerid][SpecID] != INVALID_PLAYER_ID)
	{
		if(newkeys == KEY_JUMP) AdvanceSpectate(playerid);
		else if(newkeys == KEY_SPRINT) ReverseSpectate(playerid);
	}
	
	if(newkeys & KEY_CROUCH)
	{
	    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);

    if((GetPlayerWeapon(playerid) == 44 || GetPlayerWeapon(playerid) == 45) && keys & KEY_FIRE && !IsPlayerInAnyVehicle(playerid))
    {
        return 0;
    }
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	if(AdminDuty[playerid] == 1)
	{
	    ShowPlayerNameTagForPlayer(forplayerid, playerid, 0);
		SetPlayerMarkerForPlayer(forplayerid, playerid, 0xFFFFFF00);
	}
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	new string[150];

    if(listid == skinlist)
    {
        if(response)
        {
			format(string, sizeof string, ""red"» "white"You have changed your skin from "grey"%d "white"to "grey"%d"white".", GetPlayerSkin(playerid), modelid);
			SendClientMessage(playerid, -1, string);
            SetPlayerSkin(playerid, modelid);
        }
        return 1;
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string2[1000];
	new string3[250];
	new pp = User[playerid][accountPP];
	new hid = h_ID[playerid];

	if(dialogid == DIALOG_HMENU)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                ShowPlayerDialog(playerid, DIALOG_HNAME, DIALOG_STYLE_INPUT, ""green"House Name",\
	                ""white"You are now editing the name of your house.\nPut the name of your house below (E.G. Jake's House)\n\nMaximum Length for the house name: 100", "Configure", "Back");
	            }
	            case 1:
	            {
	                ShowPlayerDialog(playerid, DIALOG_HPRICE, DIALOG_STYLE_INPUT, ""green"House Price ($)",\
	                ""white"You are now editing the price of your house.\nPut the price of your house below (E.G. 500)", "Configure", "Back");
	            }
	            case 2:
	            {
	                ShowPlayerDialog(playerid, DIALOG_HSTOREC, DIALOG_STYLE_INPUT, ""green"Store Cash ($)",\
	                ""white"You are now storing your money into your house safe.\nPut the amount of cash you want to store into your house. (E.G. 500)", "Configure", "Back");
				}
				case 3:
				{
	                ShowPlayerDialog(playerid, DIALOG_WCASH, DIALOG_STYLE_INPUT, ""green"Withdraw Cash ($)",\
	                ""white"You are now withdrawing a money from your house safe.\nPut the amount of cash you want to withdraw from your house safe. (E.G. 500)", "Configure", "Back");
				}
				case 4:
				{
				    new string[1000];
				    format(string, sizeof(string), ""white"Your house safe status:\n\nCash Stored: "green"$%d\n"white"Notes:\n"red"%s", hInfo[hid][MoneyStore], hInfo[hid][hNotes]);
				    ShowPlayerDialog(playerid, DIALOG_HSTORE, DIALOG_STYLE_MSGBOX, ""green"Storage Info",\
				    string, "Back", "");
				}
				case 5:
				{
	                ShowPlayerDialog(playerid, DIALOG_HWORLD, DIALOG_STYLE_INPUT, ""green"Virtual World",\
	                ""white"You are now editing the virtual world of your house (inside).\nPut the virtual world you want to set to your house. (E.G. 1)", "Configure", "Back");
				}
				case 6:
				{
				    new string[1200];

				    for(new a=0; a<sizeof(intInfo); a++)
				    {
				        format(string, sizeof(string), "%s%s - $%d\n", string, intInfo[a][Name], intInfo[a][i_Price]);
				    }
					ShowPlayerDialog(playerid, DIALOG_HINTERIOR, DIALOG_STYLE_LIST, ""green"Interior", string, "Preview", "Back");
				}
				case 7:
				{
				    if(jpInfo[playerid][p_Spawn] == 0)
				    {
				        ShowPlayerDialog(playerid, DIALOG_HSPAWN, DIALOG_STYLE_MSGBOX, ""yellow"Spawn at Home, Are you sure?",\
				        ""white"Are you sure you want to spawn at your house everytime you die?", "Yes", "No");
				    }
				    else
				    {
				        ShowPlayerDialog(playerid, DIALOG_HSPAWN, DIALOG_STYLE_MSGBOX, ""yellow"Are you sure?",\
				        ""white"Are you sure you will no longer spawn at your house everytime you die?", "Yes", "No");
				    }
				}
	        }
	    }
	}
	if(dialogid == DIALOG_HSPAWN)
	{
	    if(response)
	    {
	        if(jpInfo[playerid][p_Spawn] == 0)
	        {
				jpInfo[playerid][p_Spawn] = 1;
				SendClientMessage(playerid, -1, "[SPAWN] You will now spawn at your house, everytime you die.");
	        }
	        else if(jpInfo[playerid][p_Spawn] == 1)
	        {
				jpInfo[playerid][p_Spawn] = 0;
				SendClientMessage(playerid, -1, "[SPAWN] You will no longer spawn at your house, everytime you die.");
	        }
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HINTERIOR)
	{
	    if(response)
	    {
	        new hi = listitem;
	        h_Selected[playerid] = hi;

			TogglePlayerControllable(playerid, 0);
			SetCameraBehindPlayer(playerid);

			h_Selection[playerid] = 1;

			new Float:x_Pos[3];
			GetPlayerPos(playerid, x_Pos[0], x_Pos[1], x_Pos[2]);
			SetPVarInt(playerid, "h_Interior", GetPlayerInterior(playerid));
			SetPVarInt(playerid, "h_World", GetPlayerVirtualWorld(playerid));
			SetPVarFloat(playerid, "h_X", x_Pos[0]);
			SetPVarFloat(playerid, "h_Y", x_Pos[1]);
			SetPVarFloat(playerid, "h_Z", x_Pos[2]);

	        SetPlayerPos(playerid, intInfo[hi][SpawnPointX], intInfo[hi][SpawnPointY], intInfo[hi][SpawnPointZ]);
			SetPlayerInterior(playerid, intInfo[hi][i_Int]);
			SetPlayerFacingAngle(playerid, intInfo[hi][SpawnPointA]);
			SetPlayerVirtualWorld(playerid, 271569); //So in that way, no one can see you during the preview.

			new string[250];
			format(string, sizeof(string), "~w~You are now viewing: ~g~%s~n~/buyint to buy the interior~n~~r~/cancelint to cancel buying it.", intInfo[hi][Name]);
			GameTextForPlayer(playerid, string, 15000, 3);

			format(string, sizeof(string), "You are now viewing the house '%s' - /buyint to buy the interior, /cancelint to cancel buying it.", intInfo[hi][Name]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			format(string, sizeof(string), "The house interior costs "green"$%d, "white"Notes left in the interior: "red"'%s'", intInfo[hi][i_Price], intInfo[hi][Notes]);
			SendClientMessage(playerid, -1, string);
		}
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HSTORE)
	{
	    if(response || !response)
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HNAME)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_HNAME, DIALOG_STYLE_INPUT, ""green"House Name",\
                ""white"You are now editing the name of your house.\nPut the name of your house below (E.G. Jake's House)\n\nMaximum Length for the house name: 100\n"red"Invalid House Name Length.", "Configure", "Back");
	            return 1;
	        }

			new string[128];
			format(string, 128, "You have changed the name of your house to '%s'", inputtext);
			SendClientMessage(playerid, -1, string);

			format(hInfo[hid][hName], 256, "%s", inputtext);

			SaveHouse(hid);

		    DestroyDynamicCP(hInfo[hid][hCP]);
		    DestroyDynamicPickup(hInfo[hid][hPickup]);
		    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

		    LoadHouse(hid);

			cmd_hmenu(playerid, "");
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HPRICE)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_HPRICE, DIALOG_STYLE_INPUT, ""green"House Price ($)",\
                ""white"You are now editing the price of your house.\nPut the price of your house below (E.G. 500)", "Configure", "Back");
	            return 1;
	        }
	        if(!isnumeric(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_HPRICE, DIALOG_STYLE_INPUT, ""green"House Price ($)",\
                ""white"You are now editing the price of your house.\nPut the price of your house below (E.G. 500)\n\n"red"Invalid Integer.", "Configure", "Back");
	            return 1;
	        }

			new string[128];
			format(string, 128, "You have changed the price of your house to $%d.", strval(inputtext));
			SendClientMessage(playerid, -1, string);

			hInfo[hid][hPrice] = strval(inputtext);

			SaveHouse(hid);

		    DestroyDynamicCP(hInfo[hid][hCP]);
		    DestroyDynamicPickup(hInfo[hid][hPickup]);
		    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

		    LoadHouse(hid);

			cmd_hmenu(playerid, "");
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HSTOREC)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_HSTOREC, DIALOG_STYLE_INPUT, ""green"Store Cash ($)",\
                ""white"You are now storing your money into your house safe.\nPut the amount of cash you want to store into your house. (E.G. 500)", "Configure", "Back");
	            return 1;
	        }
	        if(!isnumeric(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_HSTOREC, DIALOG_STYLE_INPUT, ""green"Store Cash ($)",\
                ""white"You are now storing your money into your house safe.\nPut the amount of cash you want to store into your house. (E.G. 500)\n\n"red"Invalid Integer", "Configure", "Back");
	            return 1;
	        }

			GivePlayerCash(playerid, -strval(inputtext));
			hInfo[hid][MoneyStore] = hInfo[hid][MoneyStore] + strval(inputtext);

			new string[128];
			format(string, 128, "You have store your $%d into your house safe. ($%d over all in your safe)", strval(inputtext), hInfo[hid][MoneyStore]);
			SendClientMessage(playerid, -1, string);

			SaveHouse(hid);

		    DestroyDynamicCP(hInfo[hid][hCP]);
		    DestroyDynamicPickup(hInfo[hid][hPickup]);
		    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

		    LoadHouse(hid);

			cmd_hmenu(playerid, "");
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_HWORLD)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
	            ShowPlayerDialog(playerid, DIALOG_HWORLD, DIALOG_STYLE_INPUT, ""green"Virtual World",\
	            ""white"You are now editing the virtual world of your house (inside).\nPut the virtual world you want to set to your house. (E.G. 1)", "Configure", "Back");
	            return 1;
	        }
	        if(!isnumeric(inputtext))
	        {
	            ShowPlayerDialog(playerid, DIALOG_HWORLD, DIALOG_STYLE_INPUT, ""green"Virtual World",\
	            ""white"You are now editing the virtual world of your house (inside).\nPut the virtual world you want to set to your house. (E.G. 1)\n\n"red"Invalid Integer.", "Configure", "Back");
	            return 1;
	        }

			hInfo[hid][hWorld] = strval(inputtext);

			new string[128];
			format(string, 128, "You have change your inside house virtual world to %d.", strval(inputtext));
			SendClientMessage(playerid, -1, string);

			SaveHouse(hid);

		    DestroyDynamicCP(hInfo[hid][hCP]);
		    DestroyDynamicPickup(hInfo[hid][hPickup]);
		    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

		    LoadHouse(hid);

			cmd_hmenu(playerid, "");
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}
	if(dialogid == DIALOG_WCASH)
	{
	    if(response)
	    {
	        if(!strlen(inputtext))
	        {
                ShowPlayerDialog(playerid, DIALOG_WCASH, DIALOG_STYLE_INPUT, ""green"Withdraw Cash ($)",\
                ""white"You are now withdrawing a money from your house safe.\nPut the amount of cash you want to withdraw from your house safe. (E.G. 500)", "Configure", "Back");
	            return 1;
	        }
	        if(!isnumeric(inputtext))
	        {
	            ShowPlayerDialog(playerid, DIALOG_WCASH, DIALOG_STYLE_INPUT, ""green"Withdraw Cash ($)",\
	            ""white"You are now withdrawing a money from your house safe.\nPut the amount of cash you want to withdraw from your house safe. (E.G. 500)\n\n"red"Invalid Integer.", "Configure", "Back");
	            return 1;
	        }
            if(strval(inputtext) > hInfo[hid][MoneyStore])
            {
	            ShowPlayerDialog(playerid, DIALOG_WCASH, DIALOG_STYLE_INPUT, ""green"Withdraw Cash ($)",\
	            ""white"You are now withdrawing a money from your house safe.\nPut the amount of cash you want to withdraw from your house safe. (E.G. 500)\n\n"red"You do not have that amount of cash on your safe.", "Configure", "Back");
                return 1;
            }

			GivePlayerCash(playerid, strval(inputtext));
			hInfo[hid][MoneyStore] = hInfo[hid][MoneyStore] - strval(inputtext);

			new string[128];
			format(string, 128, "You have withdrawn a $%d from your house safe. ($%d over all in your safe)", strval(inputtext), hInfo[hid][MoneyStore]);
			SendClientMessage(playerid, -1, string);

			SaveHouse(hid);

		    DestroyDynamicCP(hInfo[hid][hCP]);
		    DestroyDynamicPickup(hInfo[hid][hPickup]);
		    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
		    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);

		    LoadHouse(hid);

			cmd_hmenu(playerid, "");
	    }
	    else
	    {
	        cmd_hmenu(playerid, "");
	    }
	}


	switch(dialogid)
	{
	    case DIALOG_MUSICS:
	    {
	        if(response)
	        {
				switch(listitem)
				{
				    case 0:
				    {
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"You're my number one by S Club 7");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/9qehawrhjw/S_Club_7_-_You_re_my_number_one.mp3");
					}
					case 1:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"Christmas Song");
						PlayAudioStreamForPlayer(playerid, "http://tms-server.comyr.com/creed/christmas.mp3");
					}
					case 2:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"The Fox by Ylvis");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/jdnww26bm4/What_does_the_Fox_Say_by_Ylvis.mp3");
					}
					case 3:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"Rude by MAGIC!");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/al7q5x4pjq/Magic_-_Rude.mp3");
					}
					case 4:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"Trumpets by Jason DeRulo.");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/g7rod80qsl/Jason_DeRulo_-_Trumpets.mp3");
					}
					case 5:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"Problem by Ariana Grande ft. Iggy Azalea.");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/qhqt9j1sun/Ariana_Grande_Ft._Iggy_Azalea_-_Problem.mp3");
					}
					case 6:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"Boombastic by Shaggy.");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/jy2dnldms6/11_boombastic_1.mp3");
					}
					case 7:
					{
					    StopAudioStreamForPlayer(playerid);
					    SendClientMessage(playerid, -1, "Now playing: "lightblue"A Thounsand Years by Christina Perri.");
						PlayAudioStreamForPlayer(playerid, "http://k003.kiwi6.com/hotlink/hdc9l1tp52/-_a_thousand_years_-.mp3");
					}
				    case 8: // Dead last, nothing
				    {
				        SendClientMessage(playerid, -1, "There is no music in here, You have been placed out of the /musics dialog.");
				    }
				}
	        }
	    }
	    case DIALOG_RADIOS:
	    {
			if(response)
			{
            	if(listitem == sizeof(radiolist)) return cmd_radios(playerid, "");
                StopAudioStreamForPlayer(playerid);
                PlayAudioStreamForPlayer(playerid, radiolist[listitem][0]);
                new string[128];
				format(string, 128, "Now playing: "lightblue"%s", radiolist[listitem][1]);
                SendClientMessage(playerid, -1, string);
			}
	    }
	    case DIALOG_COLORS:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    SetPlayerColor(playerid, COLOR_RED);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 1:
	                {
	                    SetPlayerColor(playerid, COLOR_GREEN);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 2:
	                {
	                    SetPlayerColor(playerid, COLOR_YELLOW);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 3:
	                {
	                    SetPlayerColor(playerid, COLOR_GREY);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 4:
	                {
	                    SetPlayerColor(playerid, COLOR_ORANGE);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 5:
	                {
	                    SetPlayerColor(playerid, COLOR_LIGHTBLUE);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 6:
	                {
	                    SetPlayerColor(playerid, COLOR_LIGHTRED);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 7:
	                {
	                    SetPlayerColor(playerid, COLOR_NEWB);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 8:
	                {
	                    SetPlayerColor(playerid, COLOR_PURPLE);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 9:
	                {
	                    SetPlayerColor(playerid, COLOR_LIGHTGREEN);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	                case 10:
	                {
	                    SetPlayerColor(playerid, COLOR_PINK);
	                    SendClientMessage(playerid, COLOR_ORANGE, "[COLOR] "white"Your player color has been changed (Please check tab or Press T to check it out)");
	                }
	            }
	        }
	    }
	    case DIALOG_NAME:
	    {
			if(response)
			{
			    new Query[500], DBResult:Result;
			
			    if(strlen(inputtext) < 4 || strlen(inputtext) > 20)
			    {
			        ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"Invalid name length! <4-20>", "Change", "");
			        return 1;
				}
				if(strcmp(inputtext, GetName(playerid), true) == 0)
				{
			        ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"You already have this name.", "Change", "");
			        return 1;
				}
			    format(Query, sizeof(Query), "SELECT `userid` FROM `users` WHERE `username` = '%s'", inputtext);
			    Result = db_query(Database, Query);
			    if(db_num_rows(Result))
			    {
			        ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"Name is taken, Find another one.", "Change", "");
			        return 1;
			    }
			    db_free_result(Result);

				format(string3, 128, "[NAME] "white"%s has successfully changed his/her name to %s using the Premium Shop Points!", GetName(playerid), inputtext);
				SendClientMessageToAll(COLOR_RED, string3);
				
				SendClientMessage(playerid, COLOR_YELLOW, "You have changed your name, Your statistics has been saved.");

			    format(Query, sizeof(Query), "UPDATE `users` SET `username` = '%s' WHERE `username` = '%s'", inputtext, DB_Escape(User[playerid][accountName]));
			    db_query(Database, Query);
				db_free_result(db_query(Database, Query));
			    
				format(User[playerid][accountName], 24, "%s", inputtext);
				
				SetPlayerName(playerid, inputtext);
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.", "Change", "");
			}
	    }
	    case DIALOG_NAME2:
	    {
			if(response)
			{
			    new Query[500], DBResult:Result;

			    if(strlen(inputtext) < 4 || strlen(inputtext) > 20)
			    {
					ShowPlayerDialog(playerid, DIALOG_NAME2, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for $50K + 100 score, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"Invalid name length! <4-20>", "Change", "");
			        return 1;
				}
				if(strcmp(inputtext, GetName(playerid), true) == 0)
				{
					ShowPlayerDialog(playerid, DIALOG_NAME2, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for $50K + 100 score, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"You already have this name.", "Change", "");
			        return 1;
				}
			    format(Query, sizeof(Query), "SELECT `userid` FROM `users` WHERE `username` = '%s'", inputtext);
			    Result = db_query(Database, Query);
			    if(db_num_rows(Result))
			    {
					ShowPlayerDialog(playerid, DIALOG_NAME2, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for $50K + 100 score, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.\n"red"Name is taken, Find another one.", "Change", "");
			        return 1;
			    }
			    db_free_result(Result);

				format(string3, 128, "[NAME] "white"%s has successfully changed his/her name to %s using the Server Shop!", GetName(playerid), inputtext);
				SendClientMessageToAll(COLOR_RED, string3);

				SendClientMessage(playerid, COLOR_YELLOW, "You have changed your name, Your statistics has been saved.");

			    format(Query, sizeof(Query), "UPDATE `users` SET `username` = '%s' WHERE `username` = '%s'", inputtext, DB_Escape(User[playerid][accountName]));
			    db_query(Database, Query);
				db_free_result(db_query(Database, Query));

				format(User[playerid][accountName], 24, "%s", inputtext);

				SetPlayerName(playerid, inputtext);
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.", "Change", "");
			}
	    }
	    case DIALOG_SHOP:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0: //Change Name for $50,000 and 100 scores.
	                {
						if(GetPlayerCash(playerid) >= 50000)
						{
						    if(GetPlayerScore(playerid) >= 100)
						    {
							    if(User[playerid][accountCWait] >= 1) return SendClientMessage(playerid, -1, ""red"[SHOP] "white"You are still in waiting time period!");
								GivePlayerCash(playerid, -50000);
								SetPlayerScore(playerid, GetPlayerScore(playerid) - 100);
							    User[playerid][accountCName] += 1;
							    User[playerid][accountCWait] = 336; //Waiting hours (14 days)

							    SendClientMessage(playerid, -1, ""red"[SHOP] "white"You have bought the Change Name, You have a new name!.");
								SendClientMessage(playerid, -1, ""red"[SHOP] "white"You have spent "grey"$50,000 + 100 score "white"for this item.");

								format(string3, 128, "%s has bought the Change Name from the Server Shop", GetName(playerid));
								Log("shop.txt", string3);

								ShowPlayerDialog(playerid, DIALOG_NAME2, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for $50K + 100 score, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.", "Change", "");
							}
							else
							{
							    cmd_shop(playerid, "");
							    SendClientMessage(playerid, -1, ""red"[SHOP] "white"You do not have 100 score to buy this item.");
							}
						}
						else
						{
						    cmd_shop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[SHOP] "white"You do not have $50,000 to buy this item.");
						}
	                }
	                case 1: //10 PP for 1500 score
	                {
						if(GetPlayerScore(playerid) >= 1500)
						{
						    User[playerid][accountPP] += 10;

							SetPlayerScore(playerid, GetPlayerScore(playerid) - 1500);

						    SendClientMessage(playerid, -1, ""red"[SHOP] "white"You have bought the 10 PP, You can use them on /premiumshop.");
							format(string3, sizeof(string3), ""red"[SHOP] "white"You have spent "grey"1500 score "white"for this item, You have "grey"%d "white"remaining score.", GetPlayerScore(playerid));
							SendClientMessage(playerid, -1, string3);

							format(string3, 128, "%s has bought the 10 PP from the Server Shop.", GetName(playerid));
							Log("shop.txt", string3);
						}
						else
						{
						    cmd_shop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[SHOP] "white"You do not have 1500 score to buy this item.");
						}
	                }
	            }
	        }
	    }
	    case DIALOG_PPSHOP:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0: //Jetpack for 3 PP
	                {
						if(pp >= 3)
						{
						    User[playerid][accountPP] -= 3;
						    User[playerid][accountJP] = 1;
						
						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You have bought the Jetpack, Now you have permission to use /jetpack!");
							format(string3, sizeof(string3), ""red"[PREMIUM] "white"You have spent "grey"3 PP "white"for this item, You have "grey"%d "white"remaining PP.", User[playerid][accountPP]);
							SendClientMessage(playerid, -1, string3);

							format(string3, 128, "%s has bought the Jetpack Item from the Premium Shop.", GetName(playerid));
							Log("premium.txt", string3);
						}
						else
						{
						    cmd_premiumshop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You do not have 3 PP to buy this item.");
						}
	                }
	                case 1: //VIP for 50PP for 7 Days.
	                {
						if(pp >= 50)
						{
						    if(User[playerid][accountVIP] == 1) return SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You already have VIP.");
						    User[playerid][accountPP] -= 50;
						    User[playerid][accountVIP] = 1;
							User[playerid][ExpirationVIP] = gettime() + 60*60*24*7;

						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You have bought the VIP, Now you have access to VIP stuffs, It will expire in the 7th day.");
							format(string3, sizeof(string3), ""red"[PREMIUM] "white"You have spent "grey"50 PP "white"for this item, You have "grey"%d "white"remaining PP.", User[playerid][accountPP]);
							SendClientMessage(playerid, -1, string3);
							
							format(string3, 128, "%s has bought the Very Important Person Item from the Premium Shop, Expiration date is 7 days.", GetName(playerid));
							Log("premium.txt", string3);
						}
						else
						{
						    cmd_premiumshop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You do not have 50 PP to buy this item.");
						}
	                }
	                case 2: //Superhandbrake for 5 PP.
	                {
						if(pp >= 5)
						{
						    if(User[playerid][accountBrake] == 1) return SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You already have the Super Handbrake feature.");
						    User[playerid][accountPP] -= 5;
						    User[playerid][accountBrake] = 1;

						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You have bought the Super Handbrake, Press Y to have a super handbrake, You also have now access to /togglebrake.");
							format(string3, sizeof(string3), ""red"[PREMIUM] "white"You have spent "grey"5 PP "white"for this item, You have "grey"%d "white"remaining PP.", User[playerid][accountPP]);
							SendClientMessage(playerid, -1, string3);

							format(string3, 128, "%s has bought the Super Handbrake from the Premium Shop", GetName(playerid));
							Log("premium.txt", string3);
						}
						else
						{
						    cmd_premiumshop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You do not have 5 PP to buy this item.");
						}
	                }
	                case 3: //Changename for 1 PP
	                {
						if(pp >= 1)
						{
						    if(User[playerid][accountCWait] >= 1) return SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You are still in waiting time period!");
						    User[playerid][accountPP] -= 1;
						    User[playerid][accountCName] += 1;
						    User[playerid][accountCWait] = 336; //Waiting hours (14 days)

						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You have bought the Change Name, You have a new name!.");
							format(string3, sizeof(string3), ""red"[PREMIUM] "white"You have spent "grey"1 PP "white"for this item, You have "grey"%d "white"remaining PP.", User[playerid][accountPP]);
							SendClientMessage(playerid, -1, string3);

							format(string3, 128, "%s has bought the Change Name from the Premium Shop", GetName(playerid));
							Log("premium.txt", string3);
							
							ShowPlayerDialog(playerid, DIALOG_NAME, DIALOG_STYLE_INPUT, ""newb"Choose your new name.", ""grey"You have just bought a change name for 1 PP, Please type your new name.\n\nYou cannot decline this box until you are done setting your new name.", "Change", "");
						}
						else
						{
						    cmd_premiumshop(playerid, "");
						    SendClientMessage(playerid, -1, ""red"[PREMIUM] "white"You do not have 1 PP to buy this item.");
						}
	                }
	            }
	        }
	    }
	    case DIALOG_CMDS:
	    {
	        if(response)
	        {
		        switch(listitem)
		        {
		            case 0:
		            {
		                strcat(string2, ""red"");
		                strcat(string2, "STUNTS: "grey"/lsa, /sfa, /skatepark, /sfpark, /aa, /chilliad\n");
		                strcat(string2, ""lightblue"");
		                strcat(string2, "ARENAS: "grey"/minigun, /sniper\n");
		                strcat(string2, ""lightred"");
		                strcat(string2, "ROLEPLAY: "grey"/rp\n");
		                strcat(string2, ""orange"");
		                strcat(string2, "DRIFTINGS: "grey"/drift[parameter]\n");
		                ShowPlayerDialog(playerid, DIALOG_TELE, DIALOG_STYLE_MSGBOX, ""newb"Teleports", string2, "Back", "");
		            }
		            case 1:
		            {
		                LoginCheck(playerid);
		            
		                if(User[playerid][accountAdmin] == 0)
		                {
		                    SendClientMessage(playerid, -1, "» "red"You do not have permission to access this listitem.");
		                    cmd_commands(playerid, "");
		                    return 1;
		                }

						strcat(string2, ""green"");
						strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Administrative Commands.\n\n");
						if(User[playerid][accountAdmin] >= 1)
						{
							strcat(string2, ""grey"Moderator (Level 1)\n");
							strcat(string2, ""white"");
							strcat(string2, "/a, /ask, /adminduty, /toggleadmin, /clearchat, /jetpack, /startmb, /startcp, /reaction, /kick, /slap\n");
							strcat(string2, "/startmath, /explode, /clearteleport, /(un)mute, /warn, /announce(ann), /jail, /reports, /goto\n");
							strcat(string2, "/spec, /specoff, /muted\n\n");
						}
						if(User[playerid][accountAdmin] >= 2)
						{
						    strcat(string2, ""grey"Admin (Level 2)\n");
						    strcat(string2, ""white"");
						    strcat(string2, "/giveweapon, /ban, /unban, /(un)mutecmd, /get, /remwarn, /disarm, /unjail, /ip, /spawn, /gotohouse\n");
						    strcat(string2, "/jailed, /cmuted, /heal, /akill\n\n");
						}
						if(User[playerid][accountAdmin] >= 3)
						{
							strcat(string2, ""grey"Head Admin (Level 3)\n");
							strcat(string2, ""white"");
							strcat(string2, "/givepp, /setvip, /random, /setinterior, /setworld, /oban, /respawnveh, /gotoco, /setname, /setskin\n");
							strcat(string2, "/armour\n\n");
						}
						if(User[playerid][accountAdmin] >= 4)
						{
							strcat(string2, ""grey"Manager (Level 4)\n");
							strcat(string2, ""white"");
							strcat(string2, "/sethelper, /setscore, /setmoney, /fakechat, /addhouse, /hmove, /asellhouse, /hnear, /healall, /armourall\n");
							strcat(string2, "/kickall, /gotohs\n\n");
						}
						if(User[playerid][accountAdmin] >= 5)
						{
							strcat(string2, ""grey"Owner (Level 5)\n");
							strcat(string2, ""white"");
							strcat(string2, "/vip, /setlevel, /setpremium, /removehouse, /fakecmd, /lockserver, /unlockserver, /hostname, /dhostname\n");
							strcat(string2, "/seths");
						}
						ShowPlayerDialog(playerid, DIALOG_ACMDS, DIALOG_STYLE_MSGBOX, ""orange"Administrator Commands", string2, "Close", "");
		            }
		            case 2:
		            {
		                LoginCheck(playerid);

		                if(User[playerid][accountHelper] == 1 || User[playerid][accountAdmin] >= 1)
		                {
							strcat(string2, ""green"");
							strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Helper Commands.\n\n");
							strcat(string2, ""grey"Server Helper\n");
							strcat(string2, ""white"");
							strcat(string2, "/a, /ask, /kick, /slap, /explode\n\n");
							ShowPlayerDialog(playerid, DIALOG_HCMDS, DIALOG_STYLE_MSGBOX, ""newb"Helper Commands", string2, "Close", "");
						}
						else
						{
		                    SendClientMessage(playerid, -1, "» "red"You do not have permission to access this listitem.");
		                    cmd_commands(playerid, "");
		                    return 1;
		                }
		            }
		            case 3:
		            {
						strcat(string2, ""newb"");
						strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Player Commands.\n\n");
						strcat(string2, ""white"");
						strcat(string2, "/ask, /teles, /commands, /premiumshop, /god, /stats, /skin, /hidetd, /car(/v), /staffs, /vips, /name\n");
						strcat(string2, "/descp, /vget, /serverstats, /pm, /credits, /pcmds, /colors, /report, /mb, /hinteriors, /givemoney\n");
						strcat(string2, "/cduel, /duel, /duelaccept, /rate, /keys, /help, /afk, /afks, /shop, /me, /af, (/myt)ime, (/myw)eather\n");
						strcat(string2, "/spos, /lpos, /saveskin, /useskin, /dontuseskin, /kill, /radios, /moff, /musics, /getwet, /startwet\n");
						strcat(string2, "/rules");
						#if CHRISTMAS_SPIRIT == true
						strcat(string2, "\n"lightred"Christmas Edition: "white"/snow");
						#endif
						strcat(string2, "\n"lightblue"Roleplay: "white"/b, /me, /do, /o, (/l)ow, (/s)hout");
						ShowPlayerDialog(playerid, DIALOG_HCMDS, DIALOG_STYLE_MSGBOX, ""newb"Helper Commands", string2, "Close", "");
		            }
		            case 4:
		            {
						strcat(string2, ""newb"");
						strcat(string2, "JaKe's Stunt/DM/Freeroam/Minigames/Roleplay' Premium Commands.\n\n");
						strcat(string2, ""white"");
						strcat(string2, "JETPACK: /jetpack\n");
						strcat(string2, "SUPER HANDBRAKE: /togglebrake - Press Y to activate the handbrake (Unless the /togglebrake is off)\n");
						strcat(string2, "VIP: Visit the VIP item on /commands for the commands of it.\n");
						strcat(string2, "NAMECHANGE: N/A - The changename dialog automatically appears.\n");
						ShowPlayerDialog(playerid, DIALOG_HCMDS, DIALOG_STYLE_MSGBOX, ""newb"Helper Commands", string2, "Close", "");
		            }
		            case 5:
		            {
		                cmd_credits(playerid, "");
		            }
		            case 6:
		            {
		                cmd_hhcmds(playerid, "");
		            }
		            case 7:
		            {
		                cmd_keys(playerid, "");
		            }
		            case 8:
		            {
		                cmd_help(playerid, "");
		            }
		            case 9:
		            {
		                cmd_anims(playerid, "");
		            }
		        }
			}
	    }
	    case DIALOG_REGISTER:
	    {
	        new
	            string[200],
	            hashpass[129]
			;
			if(response)
			{
		        if(!IsValidPassword(inputtext))
		        {
        			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", ""grey"Welcome to the JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.\nYour account doesn't exist on our database, Please insert your password below.\n\nTIPS: Make the password long so no one can hack it.\nERROR: Invalid password symbol.", "Register", "Quit");
		            return 1;
		        }
		        if (strlen(inputtext) < 4 || strlen(inputtext) > 20)
		        {
        			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", ""grey"Welcome to the JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.\nYour account doesn't exist on our database, Please insert your password below.\n\nTIPS: Make the password long so no one can hack it.\nERROR: Password length shouldn't go below 4 and shouldn't go higher 20.", "Register", "Quit");
		            return 1;
		        }

		        WP_Hash(hashpass, 129, inputtext);

		        SetPlayerScore(playerid, 0);
		        GivePlayerCash(playerid, 50000);
		        User[playerid][accountScore] = 0;
		        User[playerid][accountCash] = 50000;

		        //Time = Hours, Time2 = Minutes, Time3 = Seconds
		        new time, time2, time3;
		        gettime(time, time2, time3);
		        new date, date2, date3;
		        //Date = Month, Date2 = Day, Date3 = Year
		        getdate(date3, date, date2);

		        format(User[playerid][accountDate], 150, "%02d/%02d/%d %02d:%02d:%02d", date, date2, date3, time, time2, time3);

				new
					query[1400]
				;
			    format(query, sizeof(query),
				"INSERT INTO `users` (`username`, `IP`, `joindate`, `password`, `description`, `admin`, `helper`, `vip`, `expirevip`, `kills`, `deaths`, `math`, `mb`, `cp`, `react`, `score`, `money`, `hours`, `minutes`, `seconds`, `premiumpoints`, `muted`, `mutesec`, `cmuted`, `cmutesec`, `warnings`, `jail`, `jailsec`, `rated`, `hs`, `sskin`, `uskin`, `wet`) VALUES ('%s','%s','%s','%s','Server Player',0,0,0,0,0,0,0,0,0,0,%d,%d,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)",\
					GetName(playerid),
					User[playerid][accountIP],
					User[playerid][accountDate],
					hashpass,
					User[playerid][accountScore],
					User[playerid][accountCash]
			 	);
			 	
			 	format(User[playerid][accountDescp], 100, "Server Player");

			 	User[playerid][accountNoB] = 1;
			 	
				db_query(Database, query);
			    format(query, sizeof(query),
				"INSERT INTO `premium` (`username`, `jetpack`, `brake`, `brakeset`, `namechange`, `changewait`) VALUES ('%s',0,0,1,0,0)",\
					GetName(playerid),
					User[playerid][accountJP]
			 	);
				db_query(Database, query);

				User[playerid][accountLogged] = true;

				PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

			    new
			        count,
			        DBResult: result
				;
			    result = db_query(Database, "SELECT * FROM `users`");
			    count = db_num_rows(result);
			    
			    if(count == 1)
			    {
			        format(sInfo[first_person], 256, "%s", GetName(playerid));
			    }
			    
			    format(sInfo[last_person], 256, "%s", GetName(playerid));
		        format(sInfo[when_person], 256, "%02d/%02d/%d %02d:%02d:%02d", date, date2, date3, time, time2, time3);

				savestatistics();
    			format(query, sizeof(query), "SELECT * FROM `users` WHERE `username` = '%s'", DB_Escape(GetName(playerid)));
			    result = db_query(Database, query);
				if(db_num_rows(result))
				{
	    			db_get_field_assoc(result, "userid", query, 7);
	    			User[playerid][accountID] = strval(query);
			    }
				SendClientMessage(playerid, -1, "» "green"You have successfully registered from the database.");
				format(string, sizeof(string), "» {%06x}%s(%d) "white"has just registered "white"in the server, Overall we got "grey"%d "white"players registered.", GetPlayerColor(playerid) >>> 8, GetName(playerid), playerid, count);
				SendClientMessageToAll(-1, string);
			    db_free_result(result);
			}
			else
			{
			    KickDelay(playerid);
			}
	    }
	    case DIALOG_LOGIN:
	    {
	        new
	            hashp[129],
	            string[256+256]
			;
			if(response)
			{
			    WP_Hash(hashp, 129, inputtext);
			    if(!strcmp(hashp, User[playerid][accountPassword], false))
			    {
			        LoginPlayer(playerid);
			        LoginPremium(playerid);
			    }
			    else
			    {
			        User[playerid][WarnLog]++;

			        if(User[playerid][WarnLog] == 3)
			        {
						ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""red"Kicked", ""grey"You have been kicked from the server having too much wrong passwords!\nTry again, Reconnect (/q then join to the server again.)", "Close", "");
						KickDelay(playerid);
						return 1;
			        }

			        format(string, sizeof(string), "Invalid password! "white"- "grey"%d out of 3 Warning Log Tires.", User[playerid][WarnLog]);
			        SendClientMessage(playerid, COLOR_RED, string);

			        format(string, sizeof(string), ""grey"Welcome back to JaKe's Stunt/DM/Freeroam/Minigames/Roleplay.\nYour account exists on our database, Please insert your account's password below.\n\nTIPS: If you do not own the account, Please /q and use another username.\nERROR: Wrong password (%d/3 Warnings Log)", User[playerid][WarnLog]);
        			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Quit");
			    }
			}
			else
			{
			    KickDelay(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

//============================================================================//
//  Stock Functions     //
//============================================================================//

stock IsValidWeapon(weaponid)
{
    if (weaponid > 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
    return 0;
}

stock GetName(playerid)
{
	new pName[24];
	GetPlayerName(playerid, pName, 24);
	return pName;
}

stock Clear_CP()
{
	current_cp = -1;

	cppos[0] = 0.0, cppos[1] = 0.0, cppos[2] = 0.0;
	for(new i=0; i<sizeof(CPSPAWN); i++)
	{
		format(CPSPAWN[i][Previous_Winner], 24, "None");
		CPSPAWN[i][CP_Found] = 0;
	}
	return 1;
}
stock Clear_Chat(playerid)
{
	for(new i=0; i<100; i++)
	{
	    SendClientMessage(playerid, -1, " ");
	}
	return 1;
}

stock IsValidPassword( const password[ ] )
{
    for( new i = 0; password[ i ] != EOS; ++i )
    {
        switch( password[ i ] )
        {
            case '0'..'9', 'A'..'Z', 'a'..'z': continue;
            default: return 0;
        }
    }
    return 1;
}

stock DB_Escape(text[])
{
    new
        ret[80* 2],
        ch,
        i,
        j;
    while ((ch = text[i++]) && j < sizeof (ret))
    {
        if (ch == '\'')
        {
            if (j < sizeof (ret) - 2)
            {
                ret[j++] = '\'';
                ret[j++] = '\'';
            }
        }
        else if (j < sizeof (ret))
        {
            ret[j++] = ch;
        }
        else
        {
            j++;
        }
    }
    ret[sizeof (ret) - 1] = '\0';
    return ret;
}

stock savestatistics()
{
	dini_Set("server/data/configurations/statistics.ini", "firstregister", sInfo[first_person]);
	dini_Set("server/data/configurations/statistics.ini", "lastregister", sInfo[last_person]);
	dini_Set("server/data/configurations/statistics.ini", "whenregister", sInfo[when_person]);
	dini_Set("server/data/configurations/statistics.ini", "lastban", sInfo[last_bperson]);
	dini_Set("server/data/configurations/statistics.ini", "lastbanwho", sInfo[last_bwho]);
	dini_IntSet("server/data/configurations/statistics.ini", "acbans", sInfo[bannedac]);
	dini_Set("server/data/configurations/statistics.ini", "lastbanwhen", sInfo[last_bwhen]);
	dini_Set("server/data/configurations/statistics.ini", "good", sInfo[thumbsup]);
	dini_Set("server/data/configurations/statistics.ini", "bad", sInfo[thumbsdown]);
	return 1;
}

stock loaddb()
{
	new string[1500];

    Database = db_open(_DB_);
    
    strcat(string, "CREATE TABLE IF NOT EXISTS `users`");
    strcat(string, "(`userid` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT, `IP` TEXT, `joindate` TEXT, `password` TEXT, `description` TEXT, `admin` NUMERIC, `helper` NUMERIC, `vip` NUMERIC, `expirevip` NUMERIC, `kills` NUMERIC, `deaths` NUMERIC, `math` NUMERIC, `mb` NUMERIC, `cp` NUMERIC, `react` NUMERIC, `score` NUMERIC, `money` NUMERIC, `hours` NUMERIC, `minutes` NUMERIC, `seconds` NUMERIC, `premiumpoints` NUMERIC, ");
	strcat(string, "`muted` NUMERIC, `mutesec` NUMERIC, `cmuted` NUMERIC, `cmutesec` NUMERIC, `warnings` NUMERIC, `jail` NUMERIC, `jailsec` NUMERIC, `rated` NUMERIC, `hs` NUMERIC, `sskin` NUMERIC, `uskin` NUMERIC, `wet` NUMERIC)");
	db_query(Database, string);
    
    db_query(Database,
	"CREATE TABLE IF NOT EXISTS `premium`\
	(`username` TEXT, `jetpack` NUMERIC, `brake` NUMERIC, `brakeset` NUMERIC, `namechange` NUMERIC, `changewait` NUMERIC)");

    db_query(Database,
	"CREATE TABLE IF NOT EXISTS `bans`\
	(`username` TEXT,  TEXT, `banby` TEXT, `banreason` TEXT, `banwhen` TEXT)");

    db_query(Database,
	"CREATE TABLE IF NOT EXISTS `records`\
	(`Name` TEXT, `Number` INTEGRER, `Date` TEXT, `Hour` TEXT)");

	if(fexist("server/data/configurations/statistics.ini"))
	{
		format(sInfo[first_person], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "firstregister"));
		format(sInfo[last_person], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "lastregister"));
		format(sInfo[when_person], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "whenregister"));
		format(sInfo[last_bperson], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "lastban"));
		format(sInfo[last_bwho], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "lastbanwho"));
		sInfo[bannedac] = dini_Int("server/data/configurations/statistics.ini", "acbans");
		format(sInfo[last_bwhen], 256, "%s", dini_Get("server/data/configurations/statistics.ini", "lastbanwhen"));
		sInfo[thumbsup] = dini_Int("server/data/configurations/statistics.ini", "good");
		sInfo[thumbsdown] = dini_Int("server/data/configurations/statistics.ini", "good");
	}
	else
	{
		format(sInfo[first_person], 256, "N/A");
		format(sInfo[last_person], 256, "N/A");
		format(sInfo[when_person], 256, "N/A");
		format(sInfo[last_bperson], 256, "N/A");
		format(sInfo[last_bwho], 256, "N/A");
		format(sInfo[last_bwhen], 256, "N/A");

		dini_Create("server/data/configurations/statistics.ini");
		dini_Set("server/data/configurations/statistics.ini", "firstregister", "N/A");
		dini_Set("server/data/configurations/statistics.ini", "lastregister", "N/A");
		dini_Set("server/data/configurations/statistics.ini", "whenregister", "N/A");
		dini_Set("server/data/configurations/statistics.ini", "lastban", "N/A");
		dini_Set("server/data/configurations/statistics.ini", "lastbanwho", "N/A");
		dini_IntSet("server/data/configurations/statistics.ini", "acbans", 0);
		dini_Set("server/data/configurations/statistics.ini", "lastbanwhen", "N/A");
		dini_IntSet("server/data/configurations/statistics.ini", "good", 0);
		dini_IntSet("server/data/configurations/statistics.ini", "bad", 0);
	}
	if(!fexist("server/data/configurations/ban.cfg"))
	{
	    dini_Create("server/data/configurations/ban.cfg");
	}
	return 1;
}

stock closedb()
{
	db_close(Database);
	return 1;
}

forward KickMe(playerid);
public KickMe(playerid)
{
	Kick(playerid);
}
forward ObjectDone(playerid);
public ObjectDone(playerid)
{
	GameTextForPlayer(playerid, "~g~Loaded!", 2300, 3);
	SendClientMessage(playerid, -1, "Done loading the objects, Ready to move.");
	KillTimer(freezeme[playerid]);
	return TogglePlayerControllable(playerid, 1);
}

stock LoadPlayer(playerid)
{
	SendClientMessage(playerid, -1, "Loading the objects, Preventing you from falling, We freezed you.");
	GameTextForPlayer(playerid, "~w~Loading....", 3300, 3);
	KillTimer(freezeme[playerid]);
	freezeme[playerid] = SetTimerEx("ObjectDone", 3500, false, "d", playerid);
	return TogglePlayerControllable(playerid, 0);
}

stock KickDelay(playerid)
{
	SetTimerEx("KickMe", 1000, false, "d", playerid);
	return 1;
}

stock SavePremium(playerid)
{
    new
        Query[256]
    ;

    format(Query, sizeof(Query), "UPDATE `premium` SET `jetpack` = %d, `brake` = %d, `brakeset` = %d, `namechange` = %d, `changewait` = %d WHERE `username` = '%s'", User[playerid][accountJP], User[playerid][accountBrake], User[playerid][accountNoB], User[playerid][accountCName], User[playerid][accountCWait], DB_Escape(User[playerid][accountName]));
    db_query(Database, Query);
	db_free_result(db_query(Database, Query));
	return 1;
}

stock SaveData(playerid)
{
    new
        Query[1400]
    ;

    format(Query, sizeof(Query), "UPDATE `users` SET `description` = '%s', `admin` = %d, `helper` = %d, `vip` = %d, `expirevip` = %d, `kills` = %d, `deaths` = %d, `math` = %d, `mb` = %d, `cp` = %d, `react` = %d, `score` = %d, `money` = %d, `hours` = %d, `minutes` = %d, `seconds` = %d, `premiumpoints` = %d, `muted` = %d, `mutesec` = %d, `cmuted` = %d, `cmutesec` = %d, `warnings` = %d,\
	`jail` = %d, `jailsec` = %d, `rated` = %d, `hs` = %d, `sskin` = %d, `uskin` = %d, `wet`= %d WHERE `username` = '%s'",
			User[playerid][accountDescp],
			User[playerid][accountAdmin],
			User[playerid][accountHelper],
			User[playerid][accountVIP],
			User[playerid][ExpirationVIP],
			User[playerid][accountKills],
			User[playerid][accountDeaths],
			User[playerid][accountMath],
			User[playerid][accountMB],
			User[playerid][accountCP],
			User[playerid][accountReact],
			GetPlayerScore(playerid),
			GetPlayerCash(playerid),
			User[playerid][accountGame][2],
			User[playerid][accountGame][1],
			User[playerid][accountGame][0],
			User[playerid][accountPP],
			User[playerid][accountMuted],
			User[playerid][accountMuteSec],
			User[playerid][accountCMuted],
			User[playerid][accountCMuteSec],
			User[playerid][accountWarn],
			User[playerid][accountJail],
			User[playerid][accountJailSec],
			User[playerid][Rated],
			User[playerid][accountHS],
			User[playerid][accountSkin],
			User[playerid][accountUse],
			User[playerid][accountWet],
			DB_Escape(User[playerid][accountName])
	);
    db_query(Database, Query);
	db_free_result(db_query(Database, Query));
	return 1;
}

stock LoginPlayer(playerid)
{
    new
        Query[900],
        DBResult:Result,
        string[200]
    ;

    format(Query, sizeof(Query), "UPDATE `users` SET `IP` = '%s' WHERE `username` = '%s'",
			User[playerid][accountIP],
			DB_Escape(User[playerid][accountName])
	);
    db_query(Database, Query);
	db_free_result(db_query(Database, Query));
    format(Query, sizeof(Query), "SELECT * FROM `users` WHERE `username` = '%s'", DB_Escape(GetName(playerid)));
    Result = db_query(Database, Query);
    if(db_num_rows(Result))
    {
        db_get_field_assoc(Result, "userid", Query, 7);
        User[playerid][accountID] = strval(Query);

		db_get_field_assoc(Result, "description", Query, 100);
		format(User[playerid][accountDescp], 100, "%s", Query);

        db_get_field_assoc(Result, "score", Query, 7);
        User[playerid][accountScore] = strval(Query);
        SetPlayerScore(playerid, User[playerid][accountScore]);

        db_get_field_assoc(Result, "money", Query, 7);
        User[playerid][accountCash] = strval(Query);
        GivePlayerCash(playerid, User[playerid][accountCash]);

        db_get_field_assoc(Result, "hours", Query, 6);
        User[playerid][accountGame][2] = strval(Query);

        db_get_field_assoc(Result, "minutes", Query, 8);
        User[playerid][accountGame][1] = strval(Query);

        db_get_field_assoc(Result, "seconds", Query, 8);
        User[playerid][accountGame][0] = strval(Query);

        db_get_field_assoc(Result, "kills", Query, 7);
        User[playerid][accountKills] = strval(Query);

        db_get_field_assoc(Result, "deaths", Query, 7);
        User[playerid][accountDeaths] = strval(Query);

        db_get_field_assoc(Result, "math", Query, 5);
        User[playerid][accountMath] = strval(Query);

        db_get_field_assoc(Result, "mb", Query, 3);
        User[playerid][accountMB] = strval(Query);

        db_get_field_assoc(Result, "cp", Query, 3);
        User[playerid][accountCP] = strval(Query);

        db_get_field_assoc(Result, "react", Query, 6);
        User[playerid][accountReact] = strval(Query);

        db_get_field_assoc(Result, "admin", Query, 7);
        User[playerid][accountAdmin] = strval(Query);

        db_get_field_assoc(Result, "helper", Query, 7);
        User[playerid][accountHelper] = strval(Query);

        db_get_field_assoc(Result, "vip", Query, 4);
        User[playerid][accountVIP] = strval(Query);

        db_get_field_assoc(Result, "expirevip", Query, 10);
        User[playerid][ExpirationVIP] = strval(Query);

		db_get_field_assoc(Result, "joindate", Query, 150);
		format(User[playerid][accountDate], 150, "%s", Query);

        db_get_field_assoc(Result, "premiumpoints", Query, 14);
        User[playerid][accountPP] = strval(Query);

        db_get_field_assoc(Result, "muted", Query, 6);
        User[playerid][accountMuted] = strval(Query);

        db_get_field_assoc(Result, "mutesec", Query, 7);
        User[playerid][accountMuteSec] = strval(Query);

        db_get_field_assoc(Result, "cmuted", Query, 7);
        User[playerid][accountCMuted] = strval(Query);

        db_get_field_assoc(Result, "cmutesec", Query, 8);
        User[playerid][accountCMuteSec] = strval(Query);

        db_get_field_assoc(Result, "warnings", Query, 8);
        User[playerid][accountWarn] = strval(Query);

        db_get_field_assoc(Result, "jail", Query, 5);
        User[playerid][accountJail] = strval(Query);

        db_get_field_assoc(Result, "jailsec", Query, 8);
        User[playerid][accountJailSec] = strval(Query);

        db_get_field_assoc(Result, "rated", Query, 6);
        User[playerid][Rated] = strval(Query);

        db_get_field_assoc(Result, "hs", Query, 3);
        User[playerid][accountHS] = strval(Query);

        db_get_field_assoc(Result, "sskin", Query, 6);
        User[playerid][accountSkin] = strval(Query);

        db_get_field_assoc(Result, "uskin", Query, 6);
        User[playerid][accountUse] = strval(Query);

        db_get_field_assoc(Result, "wet", Query, 4);
        User[playerid][accountWet] = strval(Query);

		User[playerid][accountLogged] = true;

		SendClientMessage(playerid, -1, "» "green"You have successfully logged in from the server.");

		if(User[playerid][accountVIP] == 1)
		{
			if(gettime() > User[playerid][ExpirationVIP])
			{
				SendClientMessage(playerid, COLOR_ORANGE, "[VIP] "white"Today is the expiration day of your VIP, You are no longer a VIP Player.");
				SendClientMessage(playerid, COLOR_YELLOW, "You can donate a dollar again to the server to get the VIP back or buy it from Premium Shop.");
				format(string, 200, "» "red"%s lost his/her VIP - Expired.", GetName(playerid));
				SendClientMessageToAll(-1, string);
				
				User[playerid][ExpirationVIP] = 0;
				User[playerid][accountVIP] = 0;
			}
			else
			{
				format(string, 200, "[CONNECT] "newb"VIP %s "white"has logged in to his/her account.", GetName(playerid));
				SendClientMessageToAll(COLOR_RED, string);

				new remaining_seconds = gettime() - User[playerid][ExpirationVIP];
				new remaining_days = remaining_seconds / 3600 / 24;

				format(string, sizeof(string), "[NOTE] "white"You have "grey"%d "white"days till your "orange"VIP "white"expires.", abs(remaining_days));
				SendClientMessage(playerid, COLOR_RED, string);
			}
		}

		new ranks[90];
		switch(User[playerid][accountAdmin])
		{
		    case 1: ranks = "Moderator";
		    case 2: ranks = "Admin";
		    case 3: ranks = "Head Admin";
		    case 4: ranks = "Manager";
		    case 5: ranks = "Owner";
		}

		if(User[playerid][accountAdmin] >= 1)
		{
			format(string, 200, "[CONNECT] "green"%s %s "white"has logged in to his/her account.", ranks, GetName(playerid));
			SendClientMessageToAll(COLOR_RED, string);
		}
		if(User[playerid][accountMuted] == 1)
		{
		    format(string, 200, "[PUNISHMENT] "white"You have been muted from using the chat for "grey"%d "white"seconds, You are muted the last time you logged out.", User[playerid][accountMuteSec]);
		    SendClientMessage(playerid, COLOR_RED, string);
		}
		if(User[playerid][accountCMuted] == 1)
		{
		    format(string, 200, "[PUNISHMENT] "white"You have been muted from using the commands for "grey"%d "white"seconds, You are muted the last time you logged out.", User[playerid][accountCMuteSec]);
		    SendClientMessage(playerid, COLOR_RED, string);
		}

		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    }
	db_free_result(Result);
    return 1;
}

stock LoginPremium(playerid)
{
    new
        Query[900],
        DBResult:Result
    ;
    format(Query, sizeof(Query), "SELECT * FROM `premium` WHERE `username` = '%s'", DB_Escape(GetName(playerid)));
    Result = db_query(Database, Query);
    if(db_num_rows(Result))
    {
        db_get_field_assoc(Result, "jetpack", Query, 8);
        User[playerid][accountJP] = strval(Query);

        db_get_field_assoc(Result, "brake", Query, 6);
        User[playerid][accountBrake] = strval(Query);

        db_get_field_assoc(Result, "brakeset", Query, 10);
        User[playerid][accountNoB] = strval(Query);

        db_get_field_assoc(Result, "namechange", Query, 11);
        User[playerid][accountCName] = strval(Query);
        
        db_get_field_assoc(Result, "changewait", Query, 11);
        User[playerid][accountCWait] = strval(Query);
    }
	db_free_result(Result);
    return 1;
}

stock SendVMessage(color, string[])
{
	foreach(new i : Player)
	{
	    if(User[i][accountLogged] == true)
	    {
	        if(User[i][accountVIP] == 1 || User[i][accountAdmin] == 5)
	        {
	            SendClientMessage(i, color, string);
	        }
	    }
	}
}

stock SendAMessage(color, string[])
{
	foreach(new i : Player)
	{
	    if(User[i][accountLogged] == true)
	    {
	        if(ToggleAdmin[i] == 1)
	        {
		        if(User[i][accountHelper] == 1 || User[i][accountAdmin] >= 1)
		        {
		            SendClientMessage(i, color, string);
		        }
			}
	    }
	}
}

stock SendPlayerMessage(color, string[])
{
	foreach(new i : Player)
	{
	    if(User[i][accountLogged] == true)
	    {
	        if(User[i][accountHelper] == 0 && User[i][accountAdmin] == 0)
	        {
	            SendClientMessage(i, color, string);
	        }
	        else if(User[i][accountHelper] == 1 || User[i][accountAdmin] >= 1)
	        {
	            if(ToggleAdmin[i] == 0)
	            {
	                SendClientMessage(i, color, string);
	            }
	        }
	    }
	}
}

stock PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid, animlib, "null", 0.0, 0, 0, 0, 0, 0);
	return 1;
}

stock getIP(playerid)
{
	new twerp[20];
	GetPlayerIp(playerid, twerp, 20);
	return twerp;
}

stock loadtd()
{
	Textdraw1 = TextDrawCreate(4.000000, 433.000000, "~y~JaKe's ~w~Stunt/~r~DM~w~/~g~Race~w~/~p~Freeroam~w~/~b~Minigames");
	TextDrawBackgroundColor(Textdraw1, 255);
	TextDrawFont(Textdraw1, 0);
	TextDrawLetterSize(Textdraw1, 0.490000, 1.100000);
	TextDrawColor(Textdraw1, -1);
	TextDrawSetOutline(Textdraw1, 1);
	TextDrawSetProportional(Textdraw1, 1);
	TextDrawSetSelectable(Textdraw1, 0);

	Textdraw2 = TextDrawCreate(532.000000, 4.000000, "11/22/2014");
	TextDrawBackgroundColor(Textdraw2, 255);
	TextDrawFont(Textdraw2, 1);
	TextDrawLetterSize(Textdraw2, 0.410000, 1.000000);
	TextDrawColor(Textdraw2, -1);
	TextDrawSetOutline(Textdraw2, 0);
	TextDrawSetProportional(Textdraw2, 1);
	TextDrawSetShadow(Textdraw2, 1);
	TextDrawSetSelectable(Textdraw2, 0);

	Textdraw3 = TextDrawCreate(540.000000, 17.000000, "00:00:00");
	TextDrawBackgroundColor(Textdraw3, 255);
	TextDrawFont(Textdraw3, 1);
	TextDrawLetterSize(Textdraw3, 0.410000, 1.000000);
	TextDrawColor(Textdraw3, -1);
	TextDrawSetOutline(Textdraw3, 0);
	TextDrawSetProportional(Textdraw3, 1);
	TextDrawSetShadow(Textdraw3, 1);
	TextDrawSetSelectable(Textdraw3, 0);

	Textdraw4 = TextDrawCreate(145.000000, 407.000000, " ");
	TextDrawBackgroundColor(Textdraw4, 255);
	TextDrawFont(Textdraw4, 1);
	TextDrawLetterSize(Textdraw4, 0.220000, 1.000000);
	TextDrawColor(Textdraw4, -1);
	TextDrawSetOutline(Textdraw4, 0);
	TextDrawSetProportional(Textdraw4, 1);
	TextDrawSetShadow(Textdraw4, 1);
	TextDrawSetSelectable(Textdraw4, 0);

	Textdraw5 = TextDrawCreate(145.000000, 393.000000, " ");
	TextDrawBackgroundColor(Textdraw5, 255);
	TextDrawFont(Textdraw5, 1);
	TextDrawLetterSize(Textdraw5, 0.220000, 1.000000);
	TextDrawColor(Textdraw5, -1);
	TextDrawSetOutline(Textdraw5, 0);
	TextDrawSetProportional(Textdraw5, 1);
	TextDrawSetShadow(Textdraw5, 1);
	TextDrawSetSelectable(Textdraw5, 0);

	Textdraw6 = TextDrawCreate(145.000000, 379.000000, " ");
	TextDrawBackgroundColor(Textdraw6, 255);
	TextDrawFont(Textdraw6, 1);
	TextDrawLetterSize(Textdraw6, 0.220000, 1.000000);
	TextDrawColor(Textdraw6, -1);
	TextDrawSetOutline(Textdraw6, 0);
	TextDrawSetProportional(Textdraw6, 1);
	TextDrawSetShadow(Textdraw6, 1);
	TextDrawSetSelectable(Textdraw6, 0);

	Textdraw7 = TextDrawCreate(145.000000, 365.000000, " ");
	TextDrawBackgroundColor(Textdraw7, 255);
	TextDrawFont(Textdraw7, 1);
	TextDrawLetterSize(Textdraw7, 0.220000, 1.000000);
	TextDrawColor(Textdraw7, -1);
	TextDrawSetOutline(Textdraw7, 0);
	TextDrawSetProportional(Textdraw7, 1);
	TextDrawSetShadow(Textdraw7, 1);
	TextDrawSetSelectable(Textdraw7, 0);

	Textdraw10 = TextDrawCreate(524.000000, 236.000000, "/minigun: 0~n~/sniper: 0~n~/rp: 0");
	TextDrawBackgroundColor(Textdraw10, 255);
	TextDrawFont(Textdraw10, 1);
	TextDrawLetterSize(Textdraw10, 0.430000, 1.000000);
	TextDrawColor(Textdraw10, -1);
	TextDrawSetOutline(Textdraw10, 0);
	TextDrawSetProportional(Textdraw10, 1);
	TextDrawSetShadow(Textdraw10, 1);
	TextDrawUseBox(Textdraw10, 1);
	TextDrawBoxColor(Textdraw10, 0x00000044);
	TextDrawTextSize(Textdraw10, 630.000000, 0.000000);
	TextDrawSetSelectable(Textdraw10, 0);
	return 1;
}

stock load_pp(playerid)
{
	Textdraw0 = CreatePlayerTextDraw(playerid,501.000000, 100.000000, "Premium Points: 69");
	PlayerTextDrawBackgroundColor(playerid,Textdraw0, -1);
	PlayerTextDrawFont(playerid,Textdraw0, 1);
	PlayerTextDrawLetterSize(playerid,Textdraw0, 0.320000, 0.799999);
	PlayerTextDrawColor(playerid,Textdraw0, 65535);
	PlayerTextDrawSetOutline(playerid,Textdraw0, 1);
	PlayerTextDrawSetProportional(playerid,Textdraw0, 1);
	PlayerTextDrawUseBox(playerid,Textdraw0, 1);
	PlayerTextDrawBoxColor(playerid,Textdraw0, 0x00000044);
	PlayerTextDrawTextSize(playerid,Textdraw0, 606.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid,Textdraw0, 0);

	Textdraw8 = CreatePlayerTextDraw(playerid,526.000000, 428.000000, "KM/H: 69");
	PlayerTextDrawBackgroundColor(playerid,Textdraw8, 255);
	PlayerTextDrawFont(playerid,Textdraw8, 1);
	PlayerTextDrawLetterSize(playerid,Textdraw8, 0.470000, 1.100000);
	PlayerTextDrawColor(playerid,Textdraw8, -1);
	PlayerTextDrawSetOutline(playerid,Textdraw8, 0);
	PlayerTextDrawSetProportional(playerid,Textdraw8, 1);
	PlayerTextDrawSetShadow(playerid,Textdraw8, 1);
	PlayerTextDrawUseBox(playerid,Textdraw8, 1);
	PlayerTextDrawBoxColor(playerid,Textdraw8, 0x00000044);
	PlayerTextDrawTextSize(playerid,Textdraw8, 630.000000, 3.000000);
	PlayerTextDrawSetSelectable(playerid,Textdraw8, 0);

	Textdraw9 = CreatePlayerTextDraw(playerid,526.000000, 408.000000, "GOD ~r~OFF");
	PlayerTextDrawBackgroundColor(playerid,Textdraw9, 255);
	PlayerTextDrawFont(playerid,Textdraw9, 1);
	PlayerTextDrawLetterSize(playerid,Textdraw9, 0.420000, 1.100000);
	PlayerTextDrawColor(playerid,Textdraw9, -1);
	PlayerTextDrawSetOutline(playerid,Textdraw9, 0);
	PlayerTextDrawSetProportional(playerid,Textdraw9, 1);
	PlayerTextDrawSetShadow(playerid,Textdraw9, 1);
	PlayerTextDrawUseBox(playerid,Textdraw9, 1);
	PlayerTextDrawBoxColor(playerid,Textdraw9, 0x00000044);
	PlayerTextDrawTextSize(playerid,Textdraw9, 629.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid,Textdraw9, 0);
	return 1;
}
stock unloadpp(playerid)
{
	PlayerTextDrawDestroy(playerid, Textdraw0);
	PlayerTextDrawDestroy(playerid, Textdraw8);
	PlayerTextDrawDestroy(playerid, Textdraw9);
	return 1;
}

stock SendTeleportMessage(playerid, teleport[], teleportcmd[])
{
	new string[150];
	format(string, sizeof(string), "~r~[TELEPORT] ~w~%s(%d) has teleported to %s (/%s).", GetName(playerid), playerid, teleport, teleportcmd);
	teleportmsg[3] = teleportmsg[2];
	teleportmsg[2] = teleportmsg[1];
	teleportmsg[1] = teleportmsg[0];
	teleportmsg[0] = string;
	return 1;
}

stock GetVehicleModelIDFromName(const vname[])
{
    for(new i=0; i < sizeof(VehicleName); i++)
    {
        if (strfind(VehicleName[i], vname, true) != -1) return i + 400;
    }
    return -1;
}

stock loadobjects()
{
	//Jail-Duel Map
	totalmaps++;
	CreateDynamicObject(969,251.6000061,2107.5000000,22.0000000,0.0000000,0.0000000,90.0000000); //object(electricgate)(1)
	CreateDynamicObject(969,251.6000061,2095.1999512,22.0000000,0.0000000,0.0000000,90.0000000); //object(electricgate)(2)
	CreateDynamicObject(969,251.6000061,2101.3000488,22.0000000,0.0000000,0.0000000,90.0000000); //object(electricgate)(3)
	CreateDynamicObject(969,251.5000000,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(4)
	CreateDynamicObject(969,251.5000000,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(5)
	CreateDynamicObject(969,254.6000061,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(6)
	CreateDynamicObject(969,257.7000122,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(7)
	CreateDynamicObject(969,260.7999878,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(8)
	CreateDynamicObject(969,263.8999939,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(9)
	CreateDynamicObject(969,267.0000000,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(10)
	CreateDynamicObject(969,270.1000061,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(11)
	CreateDynamicObject(969,273.2000122,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(12)
	CreateDynamicObject(969,276.2999878,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(13)
	CreateDynamicObject(969,279.3999939,2107.5000000,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(14)
	CreateDynamicObject(969,254.6000061,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(15)
	CreateDynamicObject(969,257.7000122,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(16)
	CreateDynamicObject(969,260.7999878,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(17)
	CreateDynamicObject(969,263.8999939,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(18)
	CreateDynamicObject(969,267.0000000,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(19)
	CreateDynamicObject(969,270.0996094,2095.1992188,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(20)
	CreateDynamicObject(969,273.2000122,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(21)
	CreateDynamicObject(969,276.2999878,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(22)
	CreateDynamicObject(969,279.3999939,2095.1999512,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(23)
	CreateDynamicObject(969,251.5000000,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(24)
	CreateDynamicObject(969,254.5996094,2101.2998047,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(25)
	CreateDynamicObject(969,257.6992188,2101.2998047,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(26)
	CreateDynamicObject(969,260.7999878,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(27)
	CreateDynamicObject(969,263.8999939,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(28)
	CreateDynamicObject(969,267.0000000,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(29)
	CreateDynamicObject(969,270.1000061,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(30)
	CreateDynamicObject(969,273.2000122,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(31)
	CreateDynamicObject(969,276.2999878,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(32)
	CreateDynamicObject(969,279.3999939,2101.3000488,22.0000000,90.0000000,0.0000000,90.0000000); //object(electricgate)(33)
	CreateDynamicObject(969,260.2999878,2095.1000977,22.0000000,0.0000000,0.0000000,180.0000000); //object(electricgate)(34)
	CreateDynamicObject(969,269.0996094,2095.1000977,22.0000000,0.0000000,0.0000000,179.9945068); //object(electricgate)(35)
	CreateDynamicObject(969,277.8999939,2095.1000977,22.0000000,0.0000000,0.0000000,180.0000000); //object(electricgate)(36)
	CreateDynamicObject(969,282.5000000,2095.1000977,22.0000000,0.0000000,0.0000000,180.0000000); //object(electricgate)(37)
	CreateDynamicObject(969,251.6999970,2116.1999512,22.0000000,0.0000000,0.0000000,0.0000000); //object(electricgate)(38)
	CreateDynamicObject(969,260.5000000,2116.1999512,22.0000000,0.0000000,0.0000000,0.0000000); //object(electricgate)(39)
	CreateDynamicObject(969,269.2998047,2116.1999512,22.0000000,0.0000000,0.0000000,0.0000000); //object(electricgate)(40)
	CreateDynamicObject(969,273.7999878,2116.1999512,22.0000000,0.0000000,0.0000000,0.0000000); //object(electricgate)(41)
	CreateDynamicObject(969,282.6000061,2116.1000977,22.0000000,0.0000000,0.0000000,270.0000000); //object(electricgate)(42)
	CreateDynamicObject(969,282.6000061,2103.8000488,22.0000000,0.0000000,0.0000000,270.0000000); //object(electricgate)(43)
	CreateDynamicObject(969,282.6000061,2110.0000000,22.0000000,0.0000000,0.0000000,270.0000000); //object(electricgate)(44)
	CreateDynamicObject(969,282.6000061,2116.1000977,25.1000004,0.0000000,0.0000000,270.0000000); //object(electricgate)(45)
	CreateDynamicObject(969,282.6000061,2103.8000488,25.1000004,0.0000000,0.0000000,270.0000000); //object(electricgate)(46)
	CreateDynamicObject(969,282.6000061,2110.0000000,25.1000004,0.0000000,0.0000000,270.0000000); //object(electricgate)(47)
	CreateDynamicObject(13649,255.0000000,2105.5000000,22.5000000,0.0000000,0.0000000,0.0000000); //object(ramplandpad01)(1)
	CreateDynamicObject(13649,279.0000000,2105.5000000,22.5000000,0.0000000,0.0000000,0.0000000); //object(ramplandpad01)(2)
	CreateDynamicObject(3524,253.8000030,2106.3999023,21.2999992,0.0000000,0.0000000,52.0000000); //object(skullpillar01_lvs)(1)
	CreateDynamicObject(3524,253.8994141,2104.5000000,21.2999992,0.0000000,0.0000000,121.9976807); //object(skullpillar01_lvs)(2)
	CreateDynamicObject(3524,280.1000061,2106.6999512,21.2999992,0.0000000,0.0000000,296.0000000); //object(skullpillar01_lvs)(3)
	CreateDynamicObject(3524,280.2000122,2104.5000000,21.2999992,0.0000000,0.0000000,238.0000000); //object(skullpillar01_lvs)(4)
	CreateDynamicObject(2057,280.6000061,2105.8000488,23.2999992,0.0000000,0.0000000,298.0000000); //object(flame_tins)(1)
	CreateDynamicObject(2057,253.3999939,2105.1000977,23.2999992,0.0000000,0.0000000,310.0000000); //object(flame_tins)(2)
	CreateDynamicObject(2057,253.3999939,2105.8000488,23.2999992,0.0000000,0.0000000,252.0000000); //object(flame_tins)(3)
	CreateDynamicObject(2057,280.7000122,2105.1000977,23.2999992,0.0000000,0.0000000,0.0000000); //object(flame_tins)(4)
	CreateDynamicObject(2045,278.0000000,2105.5000000,23.2000008,0.0000000,0.0000000,0.0000000); //object(cj_bbat_nails)(1)
	CreateDynamicObject(2045,256.0000000,2105.3994141,23.2000008,0.0000000,0.0000000,0.0000000); //object(cj_bbat_nails)(2)
	CreateDynamicObject(3461,253.6999970,2105.5000000,24.7000008,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(1)
	CreateDynamicObject(3461,280.3999939,2105.5000000,24.7000008,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(2)
	CreateDynamicObject(3461,280.7999878,2110.3999023,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(3)
	CreateDynamicObject(3258,281.7999878,2112.8999023,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(1)
	CreateDynamicObject(3258,273.3999939,2109.1000977,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(2)
	CreateDynamicObject(3258,282.3999939,2103.6000977,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(3)
	CreateDynamicObject(3258,273.1000061,2100.6999512,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(4)
	CreateDynamicObject(3258,255.6999970,2109.8999023,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(5)
	CreateDynamicObject(3258,263.2999878,2105.8000488,-15.0000000,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(6)
	CreateDynamicObject(3259,262.6000061,2104.1999512,-6.0000000,0.0000000,0.0000000,0.0000000); //object(refcondens1)(1)
	CreateDynamicObject(3259,274.5000000,2105.3000488,-6.0000000,0.0000000,0.0000000,88.0000000); //object(refcondens1)(2)
	CreateDynamicObject(3461,271.5000000,2115.3000488,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(4)
	CreateDynamicObject(3461,270.8999939,2109.8999023,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(5)
	CreateDynamicObject(3461,263.5000000,2114.8999023,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(6)
	CreateDynamicObject(3461,260.8999939,2111.1000977,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(7)
	CreateDynamicObject(3461,256.1000061,2097.6999512,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(8)
	CreateDynamicObject(3461,262.5000000,2099.6999512,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(9)
	CreateDynamicObject(3461,269.6000061,2098.6000977,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(10)
	CreateDynamicObject(3461,277.8999939,2101.1999512,20.0000000,0.0000000,0.0000000,0.0000000); //object(tikitorch01_lvs)(11)
	CreateDynamicObject(10841,271.5000000,2117.0000000,20.0000000,0.0000000,0.0000000,180.0000000); //object(drydock1_sfse01)(1)
	CreateDynamicObject(10841,261.3999939,2117.0000000,20.0000000,0.0000000,0.0000000,180.0000000); //object(drydock1_sfse01)(2)
	CreateDynamicObject(10841,250.5996094,2105.5000000,20.0000000,0.0000000,0.0000000,270.0000000); //object(drydock1_sfse01)(3)
	CreateDynamicObject(10841,261.0996094,2094.0996094,20.0000000,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(4)
	CreateDynamicObject(10841,272.0996094,2094.0996094,20.0000000,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(5)
	CreateDynamicObject(10841,283.5000000,2105.0000000,20.0000000,0.0000000,0.0000000,90.0000000); //object(drydock1_sfse01)(6)
	CreateDynamicObject(2985,278.8999939,2103.6999512,23.1000004,0.0000000,0.0000000,208.0000000); //object(minigun_base)(1)
	CreateDynamicObject(2985,278.8994141,2107.1992188,23.1000004,0.0000000,0.0000000,141.9982910); //object(minigun_base)(2)
	CreateDynamicObject(2985,254.8999939,2107.1999512,23.1000004,0.0000000,0.0000000,30.0000000); //object(minigun_base)(3)
	CreateDynamicObject(2985,254.8999939,2103.8000488,23.1000004,0.0000000,0.0000000,320.0000000); //object(minigun_base)(4)
	CreateDynamicObject(2977,261.7000122,2099.8000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(kmilitary_crate)(1)
	CreateDynamicObject(2976,276.7000122,2105.5000000,23.1000004,0.0000000,0.0000000,0.0000000); //object(green_gloop)(1)
	CreateDynamicObject(2976,257.2999878,2105.5000000,23.1000004,0.0000000,0.0000000,0.0000000); //object(green_gloop)(2)
	CreateDynamicObject(16641,273.8994141,2100.5000000,18.3999996,0.0000000,0.0000000,0.0000000); //object(des_a51warheads)(1)
	CreateDynamicObject(1481,261.8999939,2097.0000000,23.0000000,0.0000000,0.0000000,142.0000000); //object(dyn_bar_b_q)(1)
	CreateDynamicObject(2806,261.7999878,2099.8000488,23.2999992,0.0000000,0.0000000,0.0000000); //object(cj_meat_2)(1)
	CreateDynamicObject(2805,261.7999878,2095.0000000,24.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(1)
	CreateDynamicObject(2804,258.8999939,2096.8000488,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(1)
	CreateDynamicObject(2804,267.5000000,2102.6999512,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(2)
	CreateDynamicObject(2804,270.6000061,2106.6000977,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(3)
	CreateDynamicObject(2804,276.7999878,2103.1000977,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(4)
	CreateDynamicObject(2804,279.1000061,2097.8000488,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(5)
	CreateDynamicObject(2804,270.7000122,2097.3999023,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(6)
	CreateDynamicObject(2804,255.5000000,2112.8999023,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(7)
	CreateDynamicObject(2804,262.6000061,2110.6000977,22.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_1)(8)
	CreateDynamicObject(2803,259.8999939,2113.6999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_1)(1)
	CreateDynamicObject(2805,251.5000000,2116.1000977,22.8999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(2)
	CreateDynamicObject(2805,269.3999939,2116.1999512,22.8999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(3)
	CreateDynamicObject(2805,262.7999878,2116.1999512,22.8999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(4)
	CreateDynamicObject(2805,255.8999939,2116.1999512,22.8999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(5)
	CreateDynamicObject(2805,251.5000000,2112.1000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(6)
	CreateDynamicObject(2805,251.5000000,2105.1999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(7)
	CreateDynamicObject(2805,251.5000000,2097.1999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(8)
	CreateDynamicObject(2805,256.6000061,2095.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(9)
	CreateDynamicObject(2805,270.2000122,2095.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(10)
	CreateDynamicObject(2805,275.3999939,2095.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(11)
	CreateDynamicObject(2805,282.6000061,2099.1999512,22.7000008,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(12)
	CreateDynamicObject(2805,282.7000122,2104.6000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(13)
	CreateDynamicObject(2805,282.6000061,2111.6999512,22.5000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(14)
	CreateDynamicObject(2905,268.2999878,2107.8999023,22.2999992,0.0000000,0.0000000,0.0000000); //object(kmb_deadleg)(1)
	CreateDynamicObject(969,260.5000000,2116.1999512,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(48)
	CreateDynamicObject(969,251.6992188,2116.1992188,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(49)
	CreateDynamicObject(969,269.2999878,2116.1999512,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(50)
	CreateDynamicObject(969,273.8999939,2116.1999512,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(51)
	CreateDynamicObject(969,251.6000061,2107.5000000,25.1000004,0.0000000,0.0000000,90.0000000); //object(electricgate)(52)
	CreateDynamicObject(969,251.6000061,2095.3000488,25.1000004,0.0000000,0.0000000,90.0000000); //object(electricgate)(53)
	CreateDynamicObject(969,251.6000061,2101.3000488,25.1000004,0.0000000,0.0000000,90.0000000); //object(electricgate)(54)
	CreateDynamicObject(969,260.2999878,2095.1000977,25.1000004,0.0000000,0.0000000,180.0000000); //object(electricgate)(55)
	CreateDynamicObject(969,269.1000061,2095.1000977,25.1000004,0.0000000,0.0000000,180.0000000); //object(electricgate)(56)
	CreateDynamicObject(969,277.8999939,2095.1000977,25.1000004,0.0000000,0.0000000,180.0000000); //object(electricgate)(57)
	CreateDynamicObject(969,282.5000000,2095.1000977,25.1000004,0.0000000,0.0000000,180.0000000); //object(electricgate)(58)
	CreateDynamicObject(969,273.8999939,2095.1000977,25.1000004,90.0000000,0.0000000,0.0000000); //object(electricgate)(59)
	CreateDynamicObject(969,260.3999939,2095.1000977,25.1000004,90.0000000,0.0000000,0.0000000); //object(electricgate)(60)
	CreateDynamicObject(969,251.6999970,2095.1000977,25.1000004,90.0000000,0.0000000,0.0000000); //object(electricgate)(61)
	CreateDynamicObject(969,267.5000000,2095.1000977,25.1000004,90.0000000,0.0000000,0.0000000); //object(electricgate)(62)
	CreateDynamicObject(969,251.6999970,2095.1000977,28.2000008,90.0000000,0.0000000,0.0000000); //object(electricgate)(63)
	CreateDynamicObject(969,260.5000000,2095.1000977,28.2000008,90.0000000,0.0000000,0.0000000); //object(electricgate)(64)
	CreateDynamicObject(969,273.8999939,2095.1000977,28.2000008,90.0000000,0.0000000,0.0000000); //object(electricgate)(65)
	CreateDynamicObject(969,267.2999878,2095.1000977,28.2000008,90.0000000,0.0000000,0.0000000); //object(electricgate)(66)
	CreateDynamicObject(969,273.8999939,2092.0000000,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(68)
	CreateDynamicObject(969,251.8000030,2092.0000000,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(69)
	CreateDynamicObject(969,260.6000061,2092.0000000,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(70)
	CreateDynamicObject(969,266.5000000,2092.0000000,25.1000004,0.0000000,0.0000000,0.0000000); //object(electricgate)(71)
	CreateDynamicObject(2603,281.0000000,2092.6999512,25.5000000,0.0000000,0.0000000,90.0000000); //object(police_cell_bed)(1)
	CreateDynamicObject(2718,281.0000000,2092.1999512,27.0000000,0.0000000,0.0000000,180.0000000); //object(cj_fly_killer)(1)
	CreateDynamicObject(2738,279.0000000,2092.5000000,25.7000008,0.0000000,0.0000000,178.0000000); //object(cj_toilet_bs)(1)
	CreateDynamicObject(2739,277.0000000,2092.0000000,25.2999992,0.0000000,0.0000000,0.0000000); //object(cj_b_sink1)(1)
	CreateDynamicObject(2603,270.0000000,2092.6992188,25.5000000,0.0000000,0.0000000,90.0000000); //object(police_cell_bed)(2)
	CreateDynamicObject(2603,260.0000000,2092.6999512,25.5000000,0.0000000,0.0000000,90.0000000); //object(police_cell_bed)(3)
	CreateDynamicObject(2718,269.7999878,2092.1999512,27.0000000,0.0000000,0.0000000,180.0000000); //object(cj_fly_killer)(2)
	CreateDynamicObject(2718,259.8999939,2092.1999512,27.0000000,0.0000000,0.0000000,180.0000000); //object(cj_fly_killer)(3)
	CreateDynamicObject(2738,258.0000000,2092.5000000,25.7000008,0.0000000,0.0000000,180.0000000); //object(cj_toilet_bs)(2)
	CreateDynamicObject(2033,280.5000000,2094.0000000,29.0000000,0.0000000,0.0000000,0.0000000); //object(cj_sawnoff2)(1)
	CreateDynamicObject(2945,282.6000061,2093.8000488,26.3999996,0.0000000,0.0000000,90.0000000); //object(kmb_netting)(1)
	CreateDynamicObject(2945,251.6000061,2093.8000488,26.3999996,0.0000000,0.0000000,90.0000000); //object(kmb_netting)(2)
	CreateDynamicObject(2805,282.3999939,2094.3000488,26.5000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(15)
	CreateDynamicObject(2805,282.3999939,2093.1000977,26.1000004,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(16)
	CreateDynamicObject(2805,251.8000030,2092.8000488,26.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(17)
	CreateDynamicObject(2805,251.8000030,2094.1999512,27.3999996,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(18)
	CreateDynamicObject(2805,282.6000061,2112.8999023,26.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(19)
	CreateDynamicObject(2805,282.6000061,2107.3999023,27.0000000,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(20)
	CreateDynamicObject(2805,282.6000061,2097.3000488,26.2000008,0.0000000,0.0000000,0.0000000); //object(cj_meat_bag_2)(21)
	CreateDynamicObject(3524,274.5000000,2095.0000000,24.7000008,0.0000000,0.0000000,185.9985352); //object(skullpillar01_lvs)(5)
	CreateDynamicObject(3524,271.3999939,2095.0000000,24.6000004,0.0000000,0.0000000,185.9985352); //object(skullpillar01_lvs)(6)
	CreateDynamicObject(3524,268.2000122,2095.0000000,24.6000004,0.0000000,0.0000000,186.9982910); //object(skullpillar01_lvs)(7)
	CreateDynamicObject(3524,265.1000061,2095.0000000,24.6000004,0.0000000,0.0000000,177.9949951); //object(skullpillar01_lvs)(8)
	CreateDynamicObject(3524,261.8999939,2095.0000000,24.6000004,0.0000000,0.0000000,177.9949951); //object(skullpillar01_lvs)(9)
	CreateDynamicObject(3524,259.0000000,2095.0000000,24.6000004,0.0000000,0.0000000,177.9949951); //object(skullpillar01_lvs)(10)
	CreateDynamicObject(3524,255.8000030,2095.0000000,24.6000004,0.0000000,0.0000000,177.9949951); //object(skullpillar01_lvs)(11)
	CreateDynamicObject(3524,252.6000061,2095.0000000,24.6000004,0.0000000,0.0000000,177.9949951); //object(skullpillar01_lvs)(12)
	CreateDynamicObject(3525,261.0000000,2116.6999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(1)
	CreateDynamicObject(3525,256.2000122,2116.8999023,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(2)
	CreateDynamicObject(3525,251.8999939,2116.8999023,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(3)
	CreateDynamicObject(3525,250.6999970,2114.1999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(4)
	CreateDynamicObject(3525,250.6000061,2110.6000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(5)
	CreateDynamicObject(3525,250.8000030,2106.3000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(6)
	CreateDynamicObject(3525,250.8000030,2101.8000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(7)
	CreateDynamicObject(3525,250.6999970,2097.5000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(8)
	CreateDynamicObject(1225,259.1000061,2116.6999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(1)
	CreateDynamicObject(1225,254.8999939,2116.8000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(2)
	CreateDynamicObject(1225,250.6000061,2116.8000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(3)
	CreateDynamicObject(1225,250.6000061,2113.3000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(4)
	CreateDynamicObject(1225,250.6000061,2109.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(5)
	CreateDynamicObject(1225,250.8999939,2105.1000977,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(6)
	CreateDynamicObject(1225,250.8000030,2100.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(7)
	CreateDynamicObject(1225,250.6999970,2096.1000977,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(8)
	CreateDynamicObject(2985,257.6000061,2116.8000488,21.7000008,0.0000000,0.0000000,85.9954834); //object(minigun_base)(5)
	CreateDynamicObject(2985,253.3999939,2116.8000488,21.7000008,0.0000000,0.0000000,90.0000000); //object(minigun_base)(6)
	CreateDynamicObject(2985,250.6999970,2115.0000000,21.7000008,0.0000000,0.0000000,177.9995117); //object(minigun_base)(7)
	CreateDynamicObject(2985,250.6000061,2112.0000000,21.7000008,0.0000000,0.0000000,184.0000000); //object(minigun_base)(8)
	CreateDynamicObject(2985,250.6000061,2107.6000977,21.7000008,0.0000000,0.0000000,177.9959717); //object(minigun_base)(9)
	CreateDynamicObject(2985,250.8999939,2103.1999512,21.7000008,0.0000000,0.0000000,177.9949951); //object(minigun_base)(10)
	CreateDynamicObject(2985,250.8000030,2098.8000488,21.7000008,0.0000000,0.0000000,177.9949951); //object(minigun_base)(11)
	CreateDynamicObject(6865,282.6000061,2112.8000488,27.0000000,0.0000000,0.0000000,311.9947510); //object(steerskull)(1)
	CreateDynamicObject(2985,262.5000000,2116.8000488,21.7000008,0.0000000,0.0000000,90.0000000); //object(minigun_base)(12)
	CreateDynamicObject(2985,271.2999878,2094.1000977,21.7000008,0.0000000,0.0000000,266.0000000); //object(minigun_base)(13)
	CreateDynamicObject(2985,283.7000122,2112.6999512,21.7000008,0.0000000,0.0000000,356.0000000); //object(minigun_base)(14)
	CreateDynamicObject(2985,273.2000122,2117.0000000,21.7000008,0.0000000,0.0000000,92.0000000); //object(minigun_base)(15)
	CreateDynamicObject(2985,278.3999939,2116.8999023,21.7000008,0.0000000,0.0000000,92.0000000); //object(minigun_base)(16)
	CreateDynamicObject(2985,267.8999939,2116.8999023,21.7000008,0.0000000,0.0000000,88.0000000); //object(minigun_base)(17)
	CreateDynamicObject(2985,283.5000000,2107.8000488,21.7000008,0.0000000,0.0000000,0.0000000); //object(minigun_base)(18)
	CreateDynamicObject(2985,280.5000000,2094.1000977,21.7000008,0.0000000,0.0000000,274.0000000); //object(minigun_base)(19)
	CreateDynamicObject(2985,283.6000061,2099.6999512,21.7000008,0.0000000,0.0000000,0.0000000); //object(minigun_base)(20)
	CreateDynamicObject(2985,275.7999878,2094.1000977,21.7000008,0.0000000,0.0000000,274.0000000); //object(minigun_base)(21)
	CreateDynamicObject(2985,283.5000000,2103.0000000,21.7000008,0.0000000,0.0000000,0.0000000); //object(minigun_base)(22)
	CreateDynamicObject(1225,264.2000122,2116.8000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(9)
	CreateDynamicObject(1225,270.1000061,2116.8000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(10)
	CreateDynamicObject(1225,275.0000000,2116.8999023,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(11)
	CreateDynamicObject(1225,280.6000061,2116.8999023,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(12)
	CreateDynamicObject(1225,283.5000000,2101.3000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(13)
	CreateDynamicObject(1225,283.6000061,2096.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(14)
	CreateDynamicObject(1225,283.6000061,2111.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(15)
	CreateDynamicObject(1225,283.3999939,2115.6000977,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(16)
	CreateDynamicObject(1225,283.3999939,2106.0000000,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(17)
	CreateDynamicObject(1225,282.2999878,2094.0000000,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(18)
	CreateDynamicObject(3525,266.2000122,2116.8000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(9)
	CreateDynamicObject(3525,271.8999939,2116.8999023,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(10)
	CreateDynamicObject(3525,276.8999939,2117.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(11)
	CreateDynamicObject(3525,282.2000122,2117.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(12)
	CreateDynamicObject(3525,283.6000061,2104.5000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(13)
	CreateDynamicObject(3525,283.2999878,2094.3000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(14)
	CreateDynamicObject(3525,283.6000061,2109.3999023,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(15)
	CreateDynamicObject(3525,283.6000061,2098.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(16)
	CreateDynamicObject(3525,279.1000061,2094.1000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(17)
	CreateDynamicObject(3525,283.6000061,2114.0000000,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(18)
	CreateDynamicObject(3525,269.8999939,2094.1000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(19)
	CreateDynamicObject(3525,274.5000000,2094.1000977,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(20)
	CreateDynamicObject(3525,261.2000122,2094.3000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(21)
	CreateDynamicObject(3525,265.6000061,2094.1999512,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(22)
	CreateDynamicObject(1225,272.7999878,2094.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(19)
	CreateDynamicObject(1225,264.2000122,2094.3000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(20)
	CreateDynamicObject(1225,268.2999878,2094.3999023,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(21)
	CreateDynamicObject(1225,277.6000061,2094.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(22)
	CreateDynamicObject(2985,266.7999878,2094.1000977,21.7000008,0.0000000,0.0000000,272.0000000); //object(minigun_base)(23)
	CreateDynamicObject(2985,253.1000061,2094.1999512,21.7000008,0.0000000,0.0000000,274.0000000); //object(minigun_base)(24)
	CreateDynamicObject(2985,257.8999939,2094.1999512,21.7000008,0.0000000,0.0000000,270.0000000); //object(minigun_base)(25)
	CreateDynamicObject(2985,262.7000122,2094.1000977,21.7000008,0.0000000,0.0000000,272.0000000); //object(minigun_base)(26)
	CreateDynamicObject(1225,259.7000122,2094.1999512,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(23)
	CreateDynamicObject(1225,255.0000000,2094.3000488,22.1000004,0.0000000,0.0000000,0.0000000); //object(barrel4)(24)
	CreateDynamicObject(3525,256.6000061,2093.3999023,22.8999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(23)
	CreateDynamicObject(3525,250.8999939,2094.3000488,22.3999996,0.0000000,0.0000000,0.0000000); //object(exbrtorch01)(24)
	CreateDynamicObject(3524,277.6000061,2095.0000000,24.6000004,0.0000000,0.0000000,178.0000000); //object(skullpillar01_lvs)(13)
	CreateDynamicObject(3524,280.6000061,2095.0000000,24.7000008,0.0000000,0.0000000,178.0000000); //object(skullpillar01_lvs)(14)
	CreateDynamicObject(3524,252.6999970,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(15)
	CreateDynamicObject(3524,255.8000030,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(16)
	CreateDynamicObject(3524,258.8999939,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(17)
	CreateDynamicObject(3524,262.0000000,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(18)
	CreateDynamicObject(3524,265.1000061,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(19)
	CreateDynamicObject(3524,268.2000122,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(20)
	CreateDynamicObject(3524,271.2999878,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(21)
	CreateDynamicObject(3524,274.3999939,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(22)
	CreateDynamicObject(3524,277.5000000,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(23)
	CreateDynamicObject(3524,280.6000061,2116.1000977,24.6000004,0.0000000,0.0000000,0.0000000); //object(skullpillar01_lvs)(24)
	CreateDynamicObject(3524,251.5000000,2102.6000977,23.3999996,0.0000000,0.0000000,86.0000000); //object(skullpillar01_lvs)(25)
	CreateDynamicObject(3524,251.6999970,2105.6999512,23.3999996,0.0000000,0.0000000,88.0000000); //object(skullpillar01_lvs)(26)
	CreateDynamicObject(3524,251.5000000,2108.8999023,23.3999996,0.0000000,0.0000000,90.0000000); //object(skullpillar01_lvs)(27)
	CreateDynamicObject(3524,282.6000061,2108.8000488,23.3999996,0.0000000,0.0000000,272.0000000); //object(skullpillar01_lvs)(28)
	CreateDynamicObject(3524,282.6000061,2105.6000977,23.3999996,0.0000000,0.0000000,270.0000000); //object(skullpillar01_lvs)(29)
	CreateDynamicObject(3524,282.6000061,2102.6000977,23.3999996,0.0000000,0.0000000,276.0000000); //object(skullpillar01_lvs)(30)
	CreateDynamicObject(6865,282.6000061,2098.3999023,27.0000000,0.0000000,0.0000000,322.0000000); //object(steerskull)(2)
	CreateDynamicObject(6865,251.5000000,2098.6999512,27.0000000,0.0000000,0.0000000,134.0000000); //object(steerskull)(3)
	CreateDynamicObject(6865,251.5000000,2112.8999023,27.0000000,0.0000000,0.0000000,130.0000000); //object(steerskull)(4)

	//Loop
	totalmaps++;
	CreateDynamicObject(17310,1463.3770000,1851.6550000,13.2340000,0.0000000,150.4020000,90.0000000); //
	CreateDynamicObject(17310,1475.2350000,1851.7520000,13.2920000,0.0000000,150.4020000,90.0000000); //
	CreateDynamicObject(17310,1463.3990000,1865.7390000,37.3860000,0.0000000,89.3810000,90.0000000); //
	CreateDynamicObject(17310,1475.1900000,1865.7730000,37.4680000,0.0000000,89.3810000,90.0000000); //
	CreateDynamicObject(16358,1295.2080000,1493.8980000,5472.2190000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(16358,1295.2150000,1326.4480000,5301.4690000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(16358,1295.2210000,1161.0670000,5132.7810000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(16358,1295.2270000,993.9220000,4962.3950000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(17310,1294.8840000,925.6430000,4898.6850000,0.0000000,195.0930000,-90.0000000); //
	CreateDynamicObject(17310,1294.9650000,900.0420000,4903.6080000,0.0000000,143.5260000,-90.0000000); //
	CreateDynamicObject(16358,1294.6780000,886.6690000,4922.9900000,0.0000000,61.8790000,-270.0000000); //
	CreateDynamicObject(17310,1294.8270000,823.1440000,5043.5480000,0.0000000,-28.3610000,-90.0000000); //
	CreateDynamicObject(17310,1295.0700000,796.8920000,5044.6980000,0.0000000,23.2050000,-90.0000000); //
	CreateDynamicObject(16358,1295.1730000,705.7310000,4945.0590000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(16358,1295.1450000,539.3690000,4775.4500000,0.0000000,45.5500000,-90.0000000); //
	CreateDynamicObject(16358,1295.1230000,457.1310000,4694.7090000,0.0000000,42.1120000,-90.0000000); //
	CreateDynamicObject(16358,1295.1180000,447.8040000,4688.4380000,0.0000000,39.5340000,-90.0000000); //
	CreateDynamicObject(16358,1295.0810000,388.8680000,4645.5820000,0.0000000,36.9560000,-90.0000000); //
	CreateDynamicObject(16358,1295.1410000,442.5720000,4689.1270000,0.0000000,34.3770000,-90.0000000); //
	CreateDynamicObject(16358,1295.1580000,407.5040000,4670.4400000,0.0000000,30.9400000,-90.0000000); //
	CreateDynamicObject(16358,1295.1560000,421.8230000,4682.7820000,0.0000000,26.6430000,-90.0000000); //
	CreateDynamicObject(16358,1295.1390000,442.3640000,4694.2850000,0.0000000,20.6260000,-90.0000000); //
	CreateDynamicObject(16358,1295.6230000,428.1590000,4689.9680000,0.0000000,17.1890000,-90.0000000); //
	CreateDynamicObject(16358,1296.1070000,395.6060000,4681.8530000,0.0000000,14.6100000,-90.0000000); //
	CreateDynamicObject(16358,1296.6620000,411.2990000,4687.7700000,0.0000000,8.5940000,-90.0000000); //
	CreateDynamicObject(16358,1297.3100000,401.6280000,4686.9720000,0.0000000,6.0160000,-90.0000000); //
	CreateDynamicObject(16358,1297.9100000,401.4290000,4687.2960000,0.0000000,0.8590000,-90.0000000); //
	CreateDynamicObject(16358,1298.4860000,371.9100000,4688.9910000,0.0000000,-4.2970000,-90.0000000); //
	CreateDynamicObject(16358,1299.1590000,373.7490000,4690.4660000,0.0000000,-12.0320000,-90.0000000); //
	CreateDynamicObject(16358,1299.7290000,343.4930000,4700.5630000,0.0000000,-18.0480000,-90.0000000); //
	CreateDynamicObject(16358,1300.1960000,352.8610000,4699.4060000,0.0000000,-24.9240000,-90.0000000); //
	CreateDynamicObject(16358,1300.5780000,344.6020000,4705.5380000,0.0000000,-31.7990000,-90.0000000); //
	CreateDynamicObject(16358,1301.3010000,334.9270000,4713.6700000,0.0000000,-36.9560000,-90.0000000); //
	CreateDynamicObject(16358,1301.9040000,337.8220000,4712.8360000,0.0000000,-44.6910000,-90.0000000); //
	CreateDynamicObject(16358,1302.4540000,318.8520000,4735.4250000,0.0000000,-49.8470000,-90.0000000); //
	CreateDynamicObject(16358,1303.0010000,321.3330000,4738.1730000,0.0000000,-59.3010000,-90.0000000); //
	CreateDynamicObject(16358,1303.5210000,326.1570000,4731.2530000,0.0000000,-67.8950000,-90.0000000); //
	CreateDynamicObject(16358,1304.0570000,323.0210000,4741.6510000,0.0000000,-76.4900000,-90.0000000); //
	CreateDynamicObject(16358,1304.5960000,320.9750000,4755.7070000,0.0000000,-82.5060000,-90.0000000); //
	CreateDynamicObject(16358,1305.1290000,321.2230000,4759.4890000,0.0000000,-89.3810000,-90.0000000); //
	CreateDynamicObject(16358,1305.7000000,321.0390000,4759.5960000,0.0000000,-96.2570000,-90.0000000); //
	CreateDynamicObject(16358,1306.2500000,325.6210000,4782.7640000,0.0000000,-104.8510000,-90.0000000); //
	CreateDynamicObject(16358,1306.8440000,325.7610000,4781.5390000,0.0000000,-111.7270000,-90.0000000); //
	CreateDynamicObject(16358,1307.4130000,328.8620000,4788.5680000,0.0000000,-117.7430000,-90.0000000); //
	CreateDynamicObject(16358,1307.9290000,331.3640000,4793.2710000,0.0000000,-124.6180000,-90.0000000); //
	CreateDynamicObject(16358,1308.5710000,333.1440000,4796.8960000,0.0000000,-135.7910000,-90.0000000); //
	CreateDynamicObject(16358,1309.2510000,344.5980000,4807.0660000,0.0000000,-146.1040000,-90.0000000); //
	CreateDynamicObject(16358,1309.7800000,349.4160000,4810.2370000,0.0000000,-152.9800000,-90.0000000); //
	CreateDynamicObject(16358,1310.3170000,346.7750000,4810.4440000,0.0000000,-161.5740000,-90.0000000); //
	CreateDynamicObject(16358,1310.8610000,352.2750000,4813.4490000,0.0000000,-167.5900000,-90.0000000); //
	CreateDynamicObject(16358,1311.3740000,355.9560000,4815.7230000,0.0000000,-173.6060000,-90.0000000); //
	CreateDynamicObject(16358,1311.8970000,363.3410000,4817.8710000,0.0000000,-179.6230000,-90.0000000); //
	CreateDynamicObject(16358,1312.3690000,371.0310000,4819.3540000,0.0000000,-187.3580000,-90.0000000); //
	CreateDynamicObject(16358,1312.8400000,377.1650000,4820.0400000,0.0000000,-194.2330000,-90.0000000); //
	CreateDynamicObject(16358,1313.3740000,382.1570000,4820.0000000,0.0000000,-199.3900000,-90.0000000); //
	CreateDynamicObject(16358,1313.8620000,389.2700000,4819.1290000,0.0000000,-206.2650000,-90.0000000); //
	CreateDynamicObject(16358,1314.4200000,394.6920000,4817.6480000,0.0000000,-210.5630000,-90.0000000); //
	CreateDynamicObject(16358,1314.9500000,401.2050000,4815.3630000,0.0000000,-216.5790000,-90.0000000); //
	CreateDynamicObject(16358,1315.4540000,407.5820000,4812.4530000,0.0000000,-222.5950000,-90.0000000); //
	CreateDynamicObject(16358,1315.9740000,412.7090000,4809.5330000,0.0000000,-227.7510000,-90.0000000); //
	CreateDynamicObject(16358,1316.4860000,418.0940000,4804.8400000,0.0000000,-231.1890000,-90.0000000); //
	CreateDynamicObject(16358,1316.9250000,422.6520000,4800.4700000,0.0000000,-234.6270000,-90.0000000); //
	CreateDynamicObject(16358,1317.3710000,427.0810000,4796.0330000,0.0000000,-238.9240000,-90.0000000); //
	CreateDynamicObject(16358,1318.0130000,431.2190000,4791.7280000,0.0000000,-244.0810000,-90.0000000); //
	CreateDynamicObject(16358,1318.5180000,435.3500000,4786.0830000,0.0000000,-248.3780000,-90.0000000); //
	CreateDynamicObject(16358,1319.0380000,438.6450000,4780.4170000,0.0000000,-251.8150000,-90.0000000); //
	CreateDynamicObject(16358,1319.0340000,442.6600000,4772.1010000,0.0000000,-256.9720000,-90.0000000); //
	CreateDynamicObject(16358,1319.4080000,445.2630000,4766.2240000,0.0000000,-263.8470000,-90.0000000); //
	CreateDynamicObject(16358,1319.2310000,447.2300000,4746.6110000,0.0000000,-269.8630000,-90.0000000); //
	CreateDynamicObject(16358,1319.1650000,449.4030000,4752.6660000,0.0000000,-279.3170000,-90.0000000); //
	CreateDynamicObject(16358,1319.2910000,448.4500000,4739.7270000,0.0000000,-285.3330000,-90.0000000); //
	CreateDynamicObject(16358,1319.1010000,446.2600000,4728.7850000,0.0000000,-293.0680000,-90.0000000); //
	CreateDynamicObject(16358,1319.3330000,443.8610000,4720.9550000,0.0000000,-300.8030000,-90.0000000); //
	CreateDynamicObject(16358,1319.1670000,439.4830000,4712.4340000,0.0000000,-309.3970000,-90.0000000); //
	CreateDynamicObject(16358,1319.0570000,436.6570000,4708.0960000,0.0000000,-315.4130000,-90.0000000); //
	CreateDynamicObject(16358,1319.1380000,266.9280000,4540.7480000,0.0000000,-315.4130000,-90.0000000); //
	CreateDynamicObject(16358,1319.1610000,96.5150000,4372.7890000,0.0000000,-315.4130000,-90.0000000); //
	CreateDynamicObject(16358,1313.8370000,383.6650000,4819.6090000,0.0000000,-201.1090000,-90.0000000); //
	CreateDynamicObject(17310,1318.8880000,16.4600000,4298.8200000,0.0000000,195.9520000,-90.0000000); //
	CreateDynamicObject(16358,1319.2260000,-249.0180000,4290.5900000,0.0000000,0.0000000,-90.0000000); //
	CreateDynamicObject(8040,1295.3090000,1618.8660000,5560.2170000,0.0000000,0.0000000,-90.0000000); //

	//Big Ear
	totalmaps++;
	CreateDynamicObject(18450,-279.67993164,1449.39685059,76.38051605,0.00000000,328.00000000,8.00000000); //
	CreateDynamicObject(1655,-287.15252686,1448.39611816,72.55813599,350.02465820,4.06149292,272.70458984); //
	CreateDynamicObject(8040,-206.72924805,1459.19946289,98.61604309,0.00000000,0.00000000,188.00000000); //
	CreateDynamicObject(978,-201.09939575,1461.03210449,98.69063568,0.00000000,0.00000000,8.00000000); //
	CreateDynamicObject(978,-192.01562500,1462.31738281,98.69063568,0.00000000,0.00000000,7.99804688); //
	CreateDynamicObject(978,-210.03038025,1459.77685547,98.69063568,0.00000000,0.00000000,7.99804688); //
	CreateDynamicObject(978,-218.89834595,1458.53063965,98.69063568,0.00000000,0.00000000,7.99804688); //
	CreateDynamicObject(979,-191.36978149,1459.95971680,98.69063568,0.00000000,0.00000000,188.00000000); //
	CreateDynamicObject(979,-200.65394592,1458.67639160,98.69063568,0.00000000,0.00000000,187.99804688); //
	CreateDynamicObject(979,-209.67922974,1457.40075684,98.69063568,0.00000000,0.00000000,187.99804688); //
	CreateDynamicObject(979,-218.38818359,1456.19653320,98.69063568,0.00000000,0.00000000,187.99804688); //
	CreateDynamicObject(3379,-286.53018188,1456.17736816,74.08238220,0.00000000,0.00000000,280.00000000); //
	CreateDynamicObject(3379,-283.41275024,1441.04357910,74.69529724,0.00000000,0.00000000,279.99755859); //
	CreateDynamicObject(9833,-225.45979309,1456.21435547,94.72483826,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(9833,-209.03132629,1458.55651855,94.47483826,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(9833,-186.68188477,1462.00170898,94.47483826,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(700,-187.26884460,1461.73413086,98.02229309,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(700,-209.75274658,1458.70275879,98.02229309,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(700,-226.50186157,1456.45190430,98.02229309,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(7392,-243.95146179,1441.08544922,111.13691711,0.00000000,0.00000000,6.00000000); //
	CreateDynamicObject(16776,-237.83993530,1455.49487305,97.60041809,0.00000000,0.00000000,276.00000000); //
	CreateDynamicObject(7073,-172.57540894,1479.70068359,116.12480164,0.00000000,0.00000000,232.00000000); //
	CreateDynamicObject(7073,-169.51464844,1450.29296875,116.11717224,0.00000000,0.00000000,139.99877930); //
	CreateDynamicObject(709,-313.00265503,1452.96997070,67.98974609,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-306.82003784,1464.48901367,79.60317993,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-304.42584229,1443.16748047,78.45117188,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-302.50454712,1412.92346191,77.34817505,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-320.44390869,1419.70739746,74.75354004,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-331.54754639,1441.91503906,72.13352966,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-350.68554688,1469.34606934,69.24256897,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-375.34140015,1468.85412598,67.45297241,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-386.12554932,1439.71752930,66.24720764,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-373.42480469,1416.87280273,64.72256470,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-363.12622070,1397.81030273,63.44344711,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-349.29428101,1373.62231445,61.66342545,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-332.19384766,1343.62646484,59.54368591,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-330.04037476,1324.35070801,57.84596634,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-346.42724609,1338.88745117,55.68307877,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-362.68649292,1367.57922363,51.59106445,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-378.93652344,1397.75817871,47.22568130,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-389.15753174,1418.37133789,44.51769257,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-400.65228271,1442.53039551,41.79159927,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-424.99804688,1454.69921875,39.49274063,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-435.05776978,1452.01574707,38.96519852,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-429.40689087,1430.06665039,39.06636429,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-419.26983643,1439.06604004,40.47578812,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-407.29101562,1421.81066895,43.54029465,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-396.86383057,1401.74523926,46.08290482,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-382.79656982,1374.08886719,49.71704102,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-367.53549194,1346.19738770,53.28285217,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-350.19088745,1317.06994629,56.40634537,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-317.97018433,1313.82446289,58.25236511,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-314.58087158,1340.42138672,59.58316422,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-330.47341919,1368.14025879,61.08909225,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-343.30975342,1390.82336426,62.65583801,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-357.59359741,1416.11059570,64.38761139,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-366.12368774,1434.18505859,65.63647461,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-371.07980347,1452.49584961,66.85322571,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-359.61941528,1453.72631836,69.78364563,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-338.09774780,1420.25122070,74.08729553,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-348.05282593,1439.04504395,71.91230774,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-325.33111572,1398.54882812,76.45893860,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-306.20071411,1387.66101074,77.46928406,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-286.64208984,1413.34179688,77.56785583,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-310.16577148,1402.71972656,77.06687927,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-287.17868042,1438.73547363,78.49105835,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-288.53744507,1458.63525391,79.50282288,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-284.67553711,1474.64099121,80.63168335,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-286.34017944,1484.21630859,81.04196167,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1259,-294.08746338,1432.96569824,77.51805878,0.00000000,0.00000000,274.00000000); //
	CreateDynamicObject(10838,-428.54031372,1444.63745117,48.27235413,0.00000000,0.00000000,194.00000000); //
	CreateDynamicObject(1634,-406.24975586,1449.33752441,36.45693207,359.86047363,271.99511719,24.00238037); //
	CreateDynamicObject(1634,-413.04269409,1453.21936035,35.83359909,359.85717773,271.99401855,45.99963379); //
	CreateDynamicObject(1634,-420.55929565,1453.99804688,35.48525238,359.85168457,271.98840332,69.99420166); //
	CreateDynamicObject(1634,-428.91659546,1452.14648438,35.23525238,359.85168457,271.98306274,83.99389648); //
	CreateDynamicObject(1634,-312.89242554,1325.66442871,53.22887039,359.79101562,84.00360107,199.98907471); //
	CreateDynamicObject(1634,-315.60833740,1317.87133789,53.47887039,359.78576660,84.00146484,173.98413086); //
	CreateDynamicObject(1634,-321.41247559,1311.72998047,53.47887039,359.78027344,83.99600220,151.97949219); //
	CreateDynamicObject(1634,-328.66754150,1308.68212891,53.28945541,0.00000000,271.99993896,252.00000000); //
	CreateDynamicObject(1634,-319.60311890,1392.60632324,72.32783508,0.00000000,271.99945068,207.99938965); //
	CreateDynamicObject(1634,-342.76193237,1313.05554199,52.03945541,0.00000000,271.99401855,207.99475098); //
	CreateDynamicObject(1634,-386.34335327,1453.40747070,62.49601364,0.00000000,90.00000000,18.00000000); //
	CreateDynamicObject(1634,-383.07211304,1461.52844238,62.49601364,0.00000000,90.00000000,349.99536133); //
	CreateDynamicObject(1634,-377.12570190,1467.17858887,62.49601364,0.00000000,90.00000000,327.99121094); //
	CreateDynamicObject(1634,-369.63485718,1470.37878418,62.74601364,0.00000000,270.00000000,77.98529053); //
	CreateDynamicObject(1634,-362.12341309,1471.37023926,62.74601364,0.00000000,270.00000000,65.98043823); //
	CreateDynamicObject(1634,-354.47628784,1470.18554688,62.74601364,0.00000000,270.00000000,43.97796631); //
	CreateDynamicObject(1634,-336.38476562,1309.58496094,52.78945541,0.00000000,271.99401855,223.99475098); //
	CreateDynamicObject(1634,-312.93713379,1389.38049316,72.58810425,0.00000000,271.99401855,227.99865723); //
	CreateDynamicObject(1634,-305.22616577,1388.95092773,72.46266937,0.88412476,84.06524658,125.06198120); //
	CreateDynamicObject(1634,-297.33731079,1392.04138184,72.21266937,0.97888184,82.05975342,149.07995605); //
	CreateDynamicObject(1634,-291.48693848,1398.42163086,71.46266937,1.02810669,80.05249023,179.10070801); //
	CreateDynamicObject(7301,-295.92120361,1432.07531738,82.59123993,0.00000000,0.00000000,320.00000000); //
	CreateDynamicObject(3336,-336.97473145,1454.92370605,64.82476807,0.00000000,0.00000000,296.00000000); //
	CreateDynamicObject(736,-350.79425049,1427.77478027,75.57531738,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-316.09667969,1431.45800781,80.69522095,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-332.63671875,1398.40649414,80.30352783,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-363.03939819,1386.56311035,67.77736664,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-420.49243164,1403.67675781,42.22832870,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-424.07775879,1433.87939453,44.77791595,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-387.14196777,1368.77172852,55.32614899,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-342.94192505,1352.80810547,62.99997711,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-346.51409912,1408.12219238,72.22316742,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-364.80017090,1444.28820801,72.30462646,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-332.06527710,1462.27893066,79.50465393,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-316.00448608,1488.54614258,86.17981720,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-274.04757690,1493.81762695,85.76258850,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-260.29934692,1472.25817871,85.77803040,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-288.97552490,1401.33972168,82.71812439,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-282.46295166,1401.92248535,82.83477783,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-282.14385986,1423.23352051,83.45706177,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-307.96627808,1418.46044922,82.40341949,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-300.55755615,1384.33972168,82.84944916,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-317.23193359,1386.29931641,82.78201294,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-339.08898926,1414.89648438,79.51436615,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-342.81756592,1430.48425293,78.12042236,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-341.37530518,1463.18188477,75.22412109,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-383.08639526,1431.76049805,71.07225800,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-405.53607178,1394.74658203,49.88657379,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-363.63101196,1328.38183594,60.11727905,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-374.28149414,1350.96325684,57.99860382,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-407.55087280,1381.62597656,42.96275330,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-417.55377197,1415.10046387,44.72354126,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-391.63018799,1464.60522461,71.58386230,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-398.16741943,1453.65344238,69.72828674,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-350.69836426,1479.28283691,77.78495789,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-334.50744629,1479.38610840,84.23415375,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-318.47744751,1438.94506836,80.36264038,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-349.21725464,1420.25000000,74.42421722,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-335.99502563,1390.57019043,74.49814606,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-314.86685181,1345.54870605,65.18968201,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-331.02426147,1333.67907715,64.22896576,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(9833,-357.21527100,1446.41308594,65.91195679,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(6965,-303.40817261,1521.97229004,77.16189575,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(7073,-328.25119019,1494.98364258,86.63296509,0.00000000,0.00000000,40.00000000); //
	CreateDynamicObject(7073,-340.85519409,1531.30883789,88.07925415,0.00000000,0.00000000,329.99572754); //
	CreateDynamicObject(7073,-301.89398193,1578.35656738,89.12612915,0.00000000,0.00000000,257.99084473); //
	CreateDynamicObject(7916,-373.90322876,1486.70556641,69.47004700,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(8483,-379.74191284,1490.20727539,72.40189362,0.00000000,0.00000000,284.00000000); //
	CreateDynamicObject(13562,-347.13467407,1467.67333984,64.50485992,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(16776,-335.74304199,1487.11169434,72.73579407,0.00000000,0.00000000,332.00000000); //
	CreateDynamicObject(7392,-364.12786865,1452.22827148,66.12641907,0.00000000,0.00000000,12.00000000); //
	CreateDynamicObject(7388,-367.43661499,1473.20373535,59.62631226,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-352.82614136,1451.59216309,65.96758270,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-357.11047363,1457.34509277,64.95125580,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-365.22534180,1457.97119141,64.00271606,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-372.67114258,1452.38012695,62.32486725,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-371.28637695,1443.51733398,61.82688904,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-329.81378174,1338.79089355,54.94683075,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-348.60498047,1444.47790527,66.88285828,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-367.73828125,1435.76367188,61.44948959,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-327.12295532,1331.75146484,54.75506592,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-327.73373413,1323.76538086,53.82077789,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-336.87014771,1324.97888184,52.16129303,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-341.77987671,1330.57873535,51.65567780,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-345.46215820,1335.76757812,51.04059601,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-332.75869751,1344.66784668,55.27644730,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-409.36145020,1429.16320801,38.43736267,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-412.93270874,1436.11645508,37.58217621,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-419.30130005,1440.75805664,35.88808441,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-425.77584839,1438.33947754,35.26288605,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-429.17794800,1431.98803711,34.81613922,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-443.18209839,1424.84497070,33.72187042,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-443.89868164,1427.47534180,33.79379272,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-444.73608398,1430.48840332,33.88179779,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-445.39208984,1433.18334961,33.95861816,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-445.98910522,1435.96228027,34.04214859,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-446.71234131,1438.81933594,34.14346313,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-447.38668823,1441.86413574,34.24002075,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-448.08419800,1444.74755859,34.33735657,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-448.74908447,1447.03991699,34.43861389,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-449.33630371,1449.46923828,34.55200958,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-449.64495850,1452.32006836,34.63072205,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-435.01409912,1450.60510254,34.63016129,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-436.16522217,1455.15917969,34.68710709,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-437.26348877,1459.76098633,34.76969910,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-428.54983521,1424.28295898,33.95121002,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-426.45117188,1416.61108398,33.30744171,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-438.78494263,1468.00183105,34.75755310,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-317.06353760,1411.88867188,71.30569458,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-313.68621826,1406.38000488,71.99789429,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-309.29965210,1401.62841797,72.82662964,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-303.21936035,1404.23937988,72.98079681,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-301.76971436,1410.95300293,72.96369934,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-302.39630127,1420.61596680,73.15848541,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-320.37091064,1418.40954590,70.52608490,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-308.26806641,1497.11486816,76.33709717,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-295.13977051,1497.09704590,76.43931580,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(6865,-309.94613647,1453.37634277,79.82287598,0.00000000,0.00000000,178.00000000); //
	CreateDynamicObject(16120,-333.25714111,1500.38500977,64.47074890,0.00000000,0.00000000,244.00000000); //
	CreateDynamicObject(16120,-361.61920166,1527.61230469,70.81250000,0.00000000,0.00000000,331.99536133); //
	CreateDynamicObject(16120,-388.93887329,1472.10595703,45.90357208,0.00000000,0.00000000,131.99435425); //
	CreateDynamicObject(16120,-315.91473389,1438.47888184,56.60243225,0.00000000,0.00000000,157.99536133); //
	CreateDynamicObject(16120,-376.59909058,1429.75964355,29.90357208,0.00000000,358.00000000,319.98974609); //
	CreateDynamicObject(16120,-383.99484253,1450.13061523,29.90357208,0.00000000,357.99499512,319.98779297); //
	CreateDynamicObject(16120,-390.74368286,1467.54382324,29.90357208,0.00000000,357.99499512,319.98779297); //
	CreateDynamicObject(16120,-403.05914307,1395.95336914,24.15357208,0.00000000,357.99499512,163.98779297); //
	CreateDynamicObject(7392,-371.99990845,1411.11791992,61.49316406,0.00000000,0.00000000,26.00000000); //
	CreateDynamicObject(7073,-339.89242554,1407.95385742,77.10331726,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(7073,-356.47283936,1436.41613770,77.10331726,0.00000000,0.00000000,252.00000000); //
	CreateDynamicObject(3528,-367.23825073,1472.56555176,69.66184235,0.00000000,0.00000000,304.00000000); //
	CreateDynamicObject(3524,-343.17559814,1462.01147461,66.73471069,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3524,-350.09011841,1447.49072266,67.72615814,0.00000000,0.00000000,64.00000000); //
	CreateDynamicObject(3524,-372.04962158,1447.16845703,63.30328369,0.00000000,0.00000000,247.99536133); //
	CreateDynamicObject(3524,-385.72918701,1443.19641113,63.13811493,0.00000000,0.00000000,159.99438477); //
	CreateDynamicObject(13594,-391.91650391,1484.54223633,79.75473785,0.00000000,0.00000000,30.00000000); //
	CreateDynamicObject(7392,-293.44299316,1392.02832031,76.12037659,0.00000000,0.00000000,314.00000000); //
	CreateDynamicObject(16776,-330.59375000,1449.87695312,64.46105957,0.00000000,0.00000000,293.99963379); //
	CreateDynamicObject(5189,-297.88067627,1314.86242676,58.49811172,0.00000000,0.00000000,354.00000000); //
	CreateDynamicObject(6283,-262.98464966,1454.71325684,77.85772705,0.00000000,0.00000000,280.00000000); //
	CreateDynamicObject(736,-268.03906250,1421.99804688,83.67868042,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-310.53845215,1411.92785645,81.80300140,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-306.53878784,1403.64074707,82.63397980,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-327.52819824,1434.95751953,78.23164368,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-357.90643311,1379.44799805,67.11534119,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-322.70254517,1359.34375000,65.90903473,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-336.55834961,1338.80493164,63.56771851,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-356.00479126,1324.99487305,60.94873810,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-355.47531128,1357.46203613,58.73043060,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-372.57608032,1385.80505371,54.43654633,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-379.37933350,1361.96850586,56.60404205,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-401.55722046,1407.95007324,50.54984283,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-395.87466431,1432.49987793,47.98330688,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-413.15298462,1427.49072266,48.08071136,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-440.07318115,1410.63916016,42.77078629,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(736,-453.53787231,1462.28491211,44.70081329,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(5715,-220.28451538,2620.57934570,71.09972382,0.00000000,0.00000000,180.00000000); //
	CreateDynamicObject(16120,-317.34863281,1475.40625000,64.35243225,0.00000000,0.00000000,157.99438477); //
	CreateDynamicObject(16120,-265.54589844,1507.72753906,70.31250000,0.00000000,0.00000000,105.99063110); //
	CreateDynamicObject(16120,-243.31152344,1554.44531250,70.62556458,0.00000000,0.00000000,181.99401855); //
	CreateDynamicObject(16120,-283.61523438,1594.91210938,70.53166199,0.00000000,0.00000000,201.99462891); //
	CreateDynamicObject(16120,-319.37597656,1598.16503906,72.26064301,0.00000000,0.00000000,281.99157715); //
	CreateDynamicObject(16120,-344.35711670,1563.18835449,67.31250000,0.00000000,0.00000000,297.99035645); //
	CreateDynamicObject(7392,-320.90753174,1352.92089844,57.17362595,0.00000000,0.00000000,25.99914551); //
	CreateDynamicObject(3877,-290.10739136,1536.65747070,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-293.48892212,1540.50952148,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-296.82922363,1543.94091797,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-297.01644897,1535.41650391,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-303.26626587,1535.40270996,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-310.31652832,1535.10388184,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-317.77609253,1535.11181641,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-325.59921265,1535.10156250,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3877,-333.86242676,1535.01989746,76.22824097,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-304.19363403,1453.78503418,72.92326355,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-304.08474731,1452.02490234,72.83580017,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-303.96743774,1449.98754883,72.73526001,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-303.82324219,1447.88842773,72.62356567,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-303.59045410,1445.91809082,72.52377319,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-303.46807861,1443.46325684,72.40987396,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-303.13186646,1441.22106934,72.28790283,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(1237,-302.94012451,1438.71557617,72.16631317,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(5627,-300.33554077,1478.10620117,79.18874359,0.00000000,0.00000000,2.00000000); //
	CreateDynamicObject(711,-305.47976685,1451.46154785,78.89624023,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-260.29217529,1422.53137207,78.37202454,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-271.47369385,1398.18237305,76.76205444,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-280.35577393,1378.36840820,75.74871826,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-298.33016968,1369.86682129,74.86123657,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-281.81884766,1392.42480469,76.92471313,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-247.20336914,1470.91992188,103.82771301,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(711,-242.22439575,1436.27636719,103.82771301,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(9132,-285.17886353,1496.45361328,92.86878204,0.00000000,0.00000000,30.00000000); //
	CreateDynamicObject(8406,-290.06396484,1450.97888184,77.46452332,0.00000000,0.00000000,280.00000000); //
	CreateDynamicObject(7415,-278.69067383,1520.47387695,83.40556335,0.00000000,0.00000000,358.00000000); //
	CreateDynamicObject(6986,-311.96636963,1507.25561523,87.35386658,0.00000000,0.00000000,268.00000000); //
	CreateDynamicObject(6986,-292.24038696,1507.17919922,87.35417938,0.00000000,0.00000000,87.99499512); //
	CreateDynamicObject(3110,-449.74002075,1438.99218750,31.32524109,0.00000000,358.00000000,123.99996948); //
	CreateDynamicObject(7391,-338.65203857,1511.15893555,78.43009949,0.00000000,0.00000000,58.00000000); //
	CreateDynamicObject(2775,-294.15747070,1506.45141602,87.10185242,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(2775,-310.61779785,1506.72351074,86.95968628,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(17000,-256.31723022,1535.53210449,73.56250000,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3092,-449.06875610,1435.03662109,40.39289093,0.00000000,0.00000000,290.00000000); //
	CreateDynamicObject(3864,-360.76174927,1426.63525391,65.35967255,0.00000000,0.00000000,20.00000000); //
	CreateDynamicObject(3528,-308.34219360,1506.98925781,87.00646973,0.00000000,0.00000000,352.00000000); //
	CreateDynamicObject(3528,-295.89068604,1507.28344727,86.68654633,0.00000000,0.00000000,179.99645996); //
	CreateDynamicObject(3534,-305.41488647,1468.23352051,74.99527740,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-306.49853516,1479.00219727,75.59673309,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-307.20034790,1490.26525879,75.93588257,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-307.99542236,1499.09741211,75.91706085,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-308.82867432,1506.16796875,75.86991119,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-295.52630615,1505.86840820,75.90226746,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-295.32247925,1498.17858887,76.06632996,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-294.33358765,1488.15625000,76.07662201,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-293.52719116,1478.56542969,75.62879181,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-292.62033081,1466.27453613,74.93034363,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-290.69177246,1455.79956055,74.46883392,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-289.23489380,1440.27038574,73.71357727,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-304.30828857,1454.95788574,74.28607941,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3534,-302.75360107,1437.51416016,73.40152740,0.00000000,0.00000000,0.00000000); //
	CreateDynamicObject(3524,-310.36755371,1486.67993164,82.62876892,0.00000000,0.00000000,186.00000000); //
	CreateDynamicObject(3524,-290.57974243,1487.67541504,82.62876892,0.00000000,0.00000000,185.99853516); //
	CreateDynamicObject(3524,-246.90956116,1461.98498535,100.73575592,0.00000000,0.00000000,281.99853516); //
	CreateDynamicObject(3524,-244.57417297,1446.43908691,100.74338531,0.00000000,0.00000000,281.99707031); //

	//Skate Park
	totalmaps++;
	CreateDynamicObject(12943,1916.7000000,-1412.8100000,12.5700000,0.0000000,0.0000000,0.0000000); // skatehouse
	CreateDynamicObject(13648,1865.4900000,-1417.0200000,12.5700000,0.0000000,0.0000000,0.0000000); // jump
	CreateDynamicObject(13637,1884.1000000,-1382.0700000,13.5700000,0.0000000,0.0000000,0.0000000); // jump
	CreateDynamicObject(13640,1903.9300000,-1368.9800000,13.5600000,0.0000000,0.0000000,0.0000000); // jump
	CreateDynamicObject(13641,1932.4300000,-1401.5600000,13.5700000,0.0000000,0.0000000,0.0000000); // jump
	CreateDynamicObject(13592,1904.0600000,-1442.2000000,21.5600000,0.0000000,0.0000000,0.0000000); // loop
	CreateDynamicObject(7073,1862.5000000,-1375.5300000,13.5600000,0.0000000,0.0000000,0.0000000); // cowboy
	CreateDynamicObject(7073,1862.7400000,-1389.8000000,13.3900000,0.0000000,0.0000000,0.0000000); // cowboy
	CreateDynamicObject(2780,1861.8200000,-1378.4400000,12.3900000,0.0000000,0.0000000,0.0000000); // smoke
	CreateDynamicObject(2780,1862.1900000,-1385.0400000,12.3900000,0.0000000,0.0000000,0.0000000); // smoke
	CreateDynamicObject(3249,1899.4800000,-1362.9400000,12.5400000,0.0000000,0.0000000,0.0000000); // saloon
	CreateDynamicObject(3279,1917.5300000,-1404.1600000,12.5700000,0.0000000,0.0000000,0.0000000); // tower
	CreateDynamicObject(3749,1886.3900000,-1351.4300000,17.5000000,0.0000000,0.0000000,0.0000000); // entrance

	//Abandoned Airport
	totalmaps++;
	CreateDynamicObject(2918, 395.420929, 2534.436035, 18.184071, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 399.352875, 2529.460693, 17.950439, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 299.444397, 2477.942383, 17.223509, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 353.471436, 2458.421631, 23.042997, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 356.446350, 2477.676514, 17.928112, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 155.572891, 2479.328613, 17.005680, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 146.209167, 2474.382080, 17.368963, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 221.446960, 2438.474854, 29.549589, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 91.334366, 2530.683105, 18.434420, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, -69.997406, 2486.468506, 17.490721, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, -64.139214, 2477.631592, 17.475082, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 47.421055, 2530.761719, 17.713833, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 63.485096, 2382.500977, 29.420967, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 63.588371, 2429.571533, 29.231689, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2918, 314.065582, 2533.108887, 17.122639, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 252.297150, 2516.068848, 16.718069, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 252.305786, 2524.790771, 16.714315, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 245.271759, 2516.064941, 20.911545, 16.3292971612, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 245.265945, 2524.763428, 20.919661, 16.3292971612, 0.000000, 89.999981276); //
	CreateDynamicObject(16776, 233.801392, 2520.297852, 17.438437, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 213.609528, 2515.536377, 16.713894, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 213.608383, 2524.205566, 16.705725, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 220.631836, 2515.541748, 20.944448, 16.3292971612, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 220.629761, 2524.106201, 20.925800, 16.3292971612, 0.000000, -89.999981276); //
	CreateDynamicObject(16304, 233.560394, 2519.714111, 19.620682, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13641, 276.035156, 2490.251709, 17.128620, 0.000000, 0.000000, -181.718835937); //
	CreateDynamicObject(13641, 250.776550, 2489.732910, 17.103621, 0.000000, 0.000000, -361.718855785); //
	CreateDynamicObject(10379, 240.067627, 2545.864258, 24.161379, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8881, 365.604218, 2595.554199, 49.741150, 0.000000, 0.000000, -63.2028024935); //
	CreateDynamicObject(978, 340.558197, 2555.080322, 16.514040, 0.000000, 0.000000, -157.499967233); //
	CreateDynamicObject(979, 389.710236, 2557.764404, 16.379049, 0.000000, 0.000000, -168.749936245); //
	CreateDynamicObject(979, 396.990173, 2559.229980, 16.361370, 0.000000, 0.000000, -168.749936245); //
	CreateDynamicObject(13592, 364.659271, 2477.992676, 26.730013, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 363.935791, 2473.088623, 31.543264, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 363.127625, 2468.101807, 36.397675, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 362.326660, 2463.409912, 41.043243, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 361.555786, 2458.464111, 45.876598, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 360.802917, 2453.505615, 50.733963, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 360.037354, 2448.496094, 55.651833, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(7092, 380.483795, 2558.194580, 31.183489, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(7092, 387.865173, 2475.728516, 24.812595, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(8423, 364.375732, 2557.884033, 30.459934, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8357, 252.250305, 2457.779541, 20.695913, 0.000000, -20.6264806247, -89.999981276); //
	CreateDynamicObject(8357, 51.616653, 2457.751465, 20.703758, 0.000000, -20.6264806247, -89.999981276); //
	CreateDynamicObject(8357, -87.889977, 2457.802490, 20.677460, 0.000000, -20.6264806247, -89.999981276); //
	CreateDynamicObject(4867, 252.674744, 2347.506348, 27.660458, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(4867, 40.234085, 2347.494873, 27.685362, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(4867, -86.358719, 2347.491943, 27.707317, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13592, 359.220673, 2443.457764, 60.564713, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(13592, 358.474091, 2438.610107, 65.336288, -48.9878341879, -32.6588235056, 0.936785995039); //
	CreateDynamicObject(4867, 358.204803, 2347.584229, -79.118690, 0.000000, 90.2408527331, 0.000000); //
	CreateDynamicObject(9907, 338.566864, 2406.491943, 8.609175, 0.000000, 18.0481705466, 0.000000); //
	CreateDynamicObject(8171, 491.591705, 2502.527100, 43.372314, 24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(8171, 365.991302, 2502.540039, -8.220849, 20.6264806247, 0.000000, -89.999981276); //
	CreateDynamicObject(8171, 615.938904, 2502.571289, 98.884193, 24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(8171, 739.984192, 2502.597656, 154.269653, 24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(8171, 863.318237, 2502.608398, 209.346893, 24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(8171, 988.684814, 2502.619873, 265.307159, 24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 783.550110, 2502.489746, 173.800278, -35.2369044005, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 775.831177, 2502.494629, 173.557190, -15.4698604685, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 767.982300, 2502.498291, 175.718811, 0.859436692696, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 761.044983, 2502.505859, 180.285812, 19.767043932, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 755.848083, 2502.513428, 186.783203, 36.9557204902, 0.000000, 89.999981276); //
	CreateDynamicObject(6189, 641.856323, 2501.861328, 178.691101, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 600.289856, 2487.906250, 91.995796, -35.2369044005, 0.000000, 89.999981276); //
	CreateDynamicObject(5005, 500.559692, 2521.891113, 50.471756, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 649.194458, 2521.834229, 116.850983, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 797.777954, 2521.790283, 183.200272, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 946.382141, 2521.743896, 249.570404, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 974.602661, 2521.762695, 262.193512, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 500.552856, 2483.060547, 50.506020, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 649.124512, 2483.005859, 116.837624, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 797.673828, 2482.956055, 183.172150, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 946.333435, 2482.894775, 249.560608, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(5005, 974.572998, 2482.923096, 262.198639, 0.000000, -24.0642273955, 0.000000); //
	CreateDynamicObject(8040, 1091.790161, 2502.908203, 300.200928, 0.000000, -179.622440661, -360.000039696); //
	CreateDynamicObject(1655, 592.026489, 2487.902832, 91.445801, -18.0481705466, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 583.942993, 2487.895996, 93.231705, -2.57831007809, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 576.573792, 2487.900391, 97.120354, 12.8915503904, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 487.310669, 2516.934570, 41.585567, -35.2369044005, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 478.761597, 2516.944092, 41.405392, -13.7509870831, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 470.910889, 2516.952881, 43.854111, 2.57831007809, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 416.129120, 2502.525146, 16.559490, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 423.024750, 2502.520264, 20.463875, 13.7509870831, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 438.330139, 2502.443115, 20.377710, -21.4859173174, 0.000000, -269.999943828); //
	CreateDynamicObject(1655, 429.978424, 2502.448975, 21.684492, -6.01605684887, 0.000000, -269.999943828); //
	CreateDynamicObject(6189, 512.057373, 2501.876953, 178.693161, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 451.463379, 2502.145996, 194.226151, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, 445.544861, 2502.160889, 197.756729, 15.4698604685, 0.000000, 89.999981276); //
	CreateDynamicObject(3434, 450.603027, 2490.954834, 200.746063, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(3434, 450.501831, 2513.634033, 200.746002, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(3434, 307.767975, 2531.681885, 29.585302, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 318.753143, 2406.415283, 28.738522, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 325.879211, 2406.417480, 32.685978, 12.8915503904, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 331.855927, 2406.419189, 38.322845, 28.361410859, 0.000000, -89.999981276); //
	CreateDynamicObject(16395, 247.872498, 2446.895752, 43.966644, 0.000000, -12.8915503904, -9.60844492856); //
	CreateDynamicObject(1634, 136.142212, 2467.288330, 44.400928, 0.000000, 0.000000, 78.7500122644); //
	CreateDynamicObject(8391, 317.392334, 2308.241699, 49.243767, 0.000000, 0.000000, 101.250007583); //
	CreateDynamicObject(17310, 329.981293, 2307.716309, 36.459980, 0.000000, -229.469711541, -24.9236640882); //
	CreateDynamicObject(13666, 294.171722, 2475.985840, 20.282415, -0.859436692696, 0.000000, -44.999990638); //
	CreateDynamicObject(1655, 102.606964, 2496.409424, 16.534491, 0.000000, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 96.028305, 2495.967041, 20.477163, 16.3292971612, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 90.652542, 2495.490234, 25.973856, 30.0802842444, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 87.047699, 2494.983154, 32.411362, 46.4095241098, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 85.591621, 2494.598145, 39.318123, 64.4576946564, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 86.452942, 2494.105469, 45.996349, 82.5058652031, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 89.302986, 2493.724365, 52.561386, 98.8351623643, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 94.315887, 2493.273926, 58.384888, 117.742769604, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 100.725784, 2492.846680, 61.933228, 138.36936482, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 108.019943, 2492.411133, 63.395702, 153.83933988, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 115.645882, 2491.917969, 62.531982, 173.606498404, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 122.435905, 2491.394775, 59.655426, 187.357600078, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 128.158234, 2490.961670, 55.317806, 201.968138446, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 132.363098, 2490.531250, 49.645676, 220.016423584, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 134.575211, 2489.990234, 43.381557, 236.345720745, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 134.857452, 2489.402100, 36.221203, 254.393719404, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 132.894623, 2488.929932, 29.448776, 273.301154756, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 129.354446, 2488.522217, 23.765760, 285.333153862, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 124.929146, 2488.153076, 19.298872, 299.084026354, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 119.262093, 2487.492676, 15.721376, 311.975462153, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 118.908478, 2487.501465, 16.003393, 319.710335091, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 172.677383, 2531.098633, 16.739592, 0.000000, 0.000000, -67.499985957); //
	CreateDynamicObject(9907, 39.219246, 2405.912842, 26.656128, 0.000000, 53.2850176514, -180.000019848); //
	CreateDynamicObject(1655, 13.652691, 2405.895996, 64.107246, 22.3453540101, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 8.961398, 2405.899658, 70.483391, 39.534087864, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 6.423105, 2405.921143, 78.041031, 57.5822011149, 0.000000, -270.000001124); //
	CreateDynamicObject(1655, 6.362353, 2405.935791, 86.462212, 75.6303716615, 0.000000, -270.000001124); //
	CreateDynamicObject(17310, 39.109673, 2424.496094, 48.792786, 0.000000, -246.658273508, -179.845321243); //
	CreateDynamicObject(17310, 38.942867, 2387.379150, 48.945061, 0.000000, -246.658273508, -179.845321243); //
	CreateDynamicObject(621, 61.965660, 2381.758057, 27.035330, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(621, 62.038681, 2429.280762, 27.338781, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16133, 226.615204, 2283.891602, 25.765226, 0.000000, 0.000000, -85.6254485102); //
	CreateDynamicObject(16133, 178.856094, 2297.037842, 27.265219, 0.000000, 0.000000, -130.625439148); //
	CreateDynamicObject(16120, 161.945099, 2566.632568, 13.418808, 0.000000, 0.000000, -123.749945607); //
	CreateDynamicObject(16120, 366.315918, 2436.949951, 8.581348, 0.000000, 0.000000, -208.516072016); //
	CreateDynamicObject(8493, 225.113129, 2284.814941, 59.999393, 0.000000, 1.71887338539, -89.999981276); //
	CreateDynamicObject(8397, 185.145035, 2431.513428, 38.166786, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1632, 185.276215, 2443.856445, 28.792276, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8881, 88.544022, 2289.555420, 56.161587, 0.000000, 0.000000, 88.358457193); //
	CreateDynamicObject(13641, 160.268402, 2365.360352, 29.382650, 0.000000, 0.000000, -179.999962552); //
	CreateDynamicObject(13641, 160.282440, 2351.175293, 29.432650, 0.000000, 0.000000, -179.999962552); //
	CreateDynamicObject(13641, 135.053741, 2349.777100, 29.379604, 0.000000, 0.000000, -359.9999824); //
	CreateDynamicObject(13641, 135.033340, 2363.994385, 29.357651, 0.000000, 0.000000, -359.9999824); //
	CreateDynamicObject(16430, -61.464195, 2358.310791, 45.778111, 0.000000, 16.3292971612, 0.000000); //
	CreateDynamicObject(18450, -160.007935, 2358.320313, 80.013733, 0.000000, 29.2208475517, 0.000000); //
	CreateDynamicObject(1655, 177.956238, 2533.277588, 20.367996, 18.9076072393, 0.000000, -67.499985957); //
	CreateDynamicObject(1655, 137.197906, 2531.677979, 16.845842, 0.000000, 0.000000, 56.2500169454); //
	CreateDynamicObject(1655, 131.223373, 2535.678467, 21.239092, 17.1887338539, 0.000000, 56.2500169454); //
	CreateDynamicObject(1655, 126.531464, 2538.816650, 27.411875, 32.6585943225, 0.000000, 56.2500169454); //
	CreateDynamicObject(1655, 123.482719, 2540.854248, 34.943169, 49.8472708806, 0.000000, 56.2500169454); //
	CreateDynamicObject(1655, 122.338661, 2541.617432, 42.940266, 65.3171313491, 0.000000, 56.2500169454); //
	CreateDynamicObject(4023, 69.144424, 2551.126953, 23.449482, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16120, 116.164482, 2567.610596, 10.193699, 0.000000, 0.000000, -123.749945607); //
	CreateDynamicObject(13666, 263.366089, 2434.567383, 32.543705, 0.000000, 0.000000, 134.999971914); //
	CreateDynamicObject(17310, 139.208679, 2319.817383, 32.706966, 0.000000, -215.718609867, -148.673609695); //
	CreateDynamicObject(17310, 41.503025, 2327.443604, 32.306957, 0.000000, -215.718609867, -33.5953230217); //
	CreateDynamicObject(8040, -592.128540, 2503.749023, 228.555176, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -380.767059, 2503.460205, 150.952118, -37.8152144786, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -372.414612, 2503.445313, 150.221359, -18.0481705466, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -364.367584, 2503.462158, 152.189499, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -357.300812, 2503.468506, 156.244568, 14.6104237758, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -351.626770, 2503.472412, 162.298660, 33.5180310152, 0.000000, -89.999981276); //
	CreateDynamicObject(16430, -229.249146, 2503.492920, 190.125214, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16430, -69.791641, 2503.510254, 190.111694, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 9.899498, 2503.594727, 191.505615, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(17310, -175.722427, 2492.983398, 61.782578, 0.000000, -180.481705466, -359.845341091); //
	CreateDynamicObject(17310, -154.147995, 2493.108643, 70.618462, 0.000000, -224.313263273, -359.845341091); //
	CreateDynamicObject(1655, -80.641251, 2515.705078, 16.947474, -37.8152144786, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -72.409569, 2515.717285, 16.144878, -18.9076072393, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -64.352837, 2515.735840, 18.097433, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -57.325333, 2515.741455, 22.466793, 18.0481705466, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -51.773609, 2515.738037, 28.860535, 34.3774104121, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -281.725220, 2515.690186, 106.734222, -37.8152144786, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -274.636444, 2515.693115, 105.945763, -20.6264806247, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -266.990814, 2515.695801, 107.504387, -2.57831007809, 0.000000, -89.999981276); //
	CreateDynamicObject(16430, -26.345257, 2471.176758, 19.252113, 0.000000, 14.6104237758, 27.6566154752); //
	CreateDynamicObject(16430, -136.061600, 2413.644287, 67.504768, 0.000000, 25.7831007809, 27.6566154752); //
	CreateDynamicObject(1655, 213.155396, 2474.849121, 16.534491, 0.000000, 0.000000, -236.249979497); //
	CreateDynamicObject(1655, 207.500229, 2471.072998, 20.796253, 18.0481705466, 0.000000, -236.249979497); //
	CreateDynamicObject(1655, 202.890121, 2467.996094, 27.148033, 34.3774677078, 0.000000, -236.249979497); //
	CreateDynamicObject(1655, 200.201828, 2466.193604, 34.518074, 52.4255809587, 0.000000, -236.249979497); //
	CreateDynamicObject(1655, 199.442429, 2465.693359, 42.718662, 69.6143148126, 0.000000, -236.249979497); //
	CreateDynamicObject(1655, 174.315613, 2476.000244, 16.534491, 0.000000, 0.000000, -134.999971914); //
	CreateDynamicObject(1655, 179.274033, 2471.030273, 20.895906, 18.0481705466, 0.000000, -134.999971914); //
	CreateDynamicObject(1655, 183.096222, 2467.218262, 27.090145, 34.3774677078, 0.000000, -134.999971914); //
	CreateDynamicObject(1655, 185.505753, 2464.812500, 34.779682, 52.4255809587, 0.000000, -134.999971914); //
	CreateDynamicObject(1655, 186.111618, 2464.192139, 42.938950, 69.6143148126, 0.000000, -134.999971914); //
	CreateDynamicObject(17310, 106.426147, 2538.415527, 19.973236, 0.000000, -213.140299789, 53.8263481762); //
	CreateDynamicObject(8171, -71.086823, 2580.417236, 43.365273, 24.0642273955, 0.000000, -326.250018069); //
	CreateDynamicObject(8171, -140.821228, 2684.758301, 99.411217, 24.0642273955, 0.000000, -326.250018069); //
	CreateDynamicObject(8040, -197.807861, 2770.615723, 128.368927, 0.000000, 0.000000, -56.2500169454); //
	CreateDynamicObject(1655, -127.172318, 2636.298584, 77.913124, -37.8152144786, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -122.561378, 2629.423584, 77.051880, -19.767043932, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -117.854103, 2622.361816, 78.951180, -0.859436692696, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -27.185881, 2543.034912, 18.446745, -37.8152144786, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -22.448675, 2535.962158, 17.784184, -17.1887338539, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -17.831882, 2529.052490, 19.886885, 0.000000, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -13.705973, 2522.864014, 24.333284, 16.3292971612, 0.000000, -146.249998221); //
	CreateDynamicObject(1655, -10.585569, 2518.181152, 30.762461, 35.2368471048, 0.000000, -146.249998221); //
	CreateDynamicObject(17310, 32.849556, 2465.538330, 19.867287, 0.000000, -213.140299789, -58.6736284188); //
	CreateDynamicObject(17310, 55.185730, 2465.320313, 19.880987, 0.000000, -213.140299789, -125.314177683); //
	CreateDynamicObject(5767, -110.448608, 2393.749023, 64.504974, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(18450, -144.752319, 2286.444824, 109.892700, 0.000000, 12.0321136977, -191.249988859); //
	CreateDynamicObject(18450, -206.677063, 2298.757568, 98.735779, 0.000000, 6.87549354157, -191.249988859); //
	CreateDynamicObject(18450, -23.769341, 2252.572021, 120.018074, 0.000000, 2.57831007809, -191.249988859); //
	CreateDynamicObject(16430, 117.415192, 2312.612305, 98.584213, 0.000000, 16.3292971612, 44.999990638); //
	CreateDynamicObject(1655, 172.250107, 2367.721680, 77.335846, -15.4698604685, 0.000000, -44.999990638); //
	CreateDynamicObject(1655, 177.502533, 2372.980957, 79.414680, 0.859436692696, 0.000000, -44.999990638); //
	CreateDynamicObject(1655, 23.991402, 2529.675781, 16.534491, 0.000000, 0.000000, -56.2499596496); //
	CreateDynamicObject(1655, 29.219753, 2533.165039, 20.438824, 17.1887338539, 0.000000, -56.2499596496); //
	CreateDynamicObject(1655, 33.252209, 2535.858154, 25.952049, 34.3774677078, 0.000000, -56.2499596496); //
	CreateDynamicObject(13666, 216.376892, 2436.238525, 32.543690, 0.000000, 0.000000, 134.999971914); //
	CreateDynamicObject(1655, -100.300392, 2503.463867, 25.700300, -37.8152144786, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -56.126793, 2503.072021, 16.534491, 0.000000, 0.000000, -269.999943828); //
	CreateDynamicObject(1655, -75.399765, 2477.011230, 16.484491, 0.000000, 0.000000, -239.765075571); //
	CreateDynamicObject(1655, -81.484428, 2473.469482, 20.628275, 15.4698604685, 0.000000, -239.765075571); //
	CreateDynamicObject(1655, -86.556442, 2470.522705, 26.597548, 30.0802842444, 0.000000, -239.765075571); //
	CreateDynamicObject(1655, -90.095612, 2468.469971, 33.895966, 45.5500874171, 0.000000, -239.765075571); //
	CreateDynamicObject(1655, -91.785545, 2467.486328, 41.991039, 61.8793845783, 0.000000, -239.765075571); //
	CreateDynamicObject(1655, -91.374535, 2467.726318, 50.383427, 79.0681184323, 0.000000, -239.765075571); //
	CreateDynamicObject(8620, -70.004608, 2480.321045, 38.550095, 0.000000, 0.000000, -56.2500169454); //
	CreateDynamicObject(16120, 5.993061, 2556.333984, 12.639149, 0.000000, 0.000000, -123.749945607); //
	CreateDynamicObject(13641, 12.775715, 2499.387695, 17.078613, 0.000000, 0.000000, -539.999944952); //
	CreateDynamicObject(13641, -12.460205, 2497.988770, 17.180674, 0.000000, 0.000000, -719.999792912); //
	CreateDynamicObject(1655, -63.423794, 2503.072266, 20.825264, 15.4698604685, 0.000000, -269.999943828); //
	CreateDynamicObject(1655, -69.048645, 2503.066406, 27.127958, 35.2369044005, 0.000000, -269.999943828); //
	CreateDynamicObject(1655, -92.102577, 2503.443115, 25.081173, -17.1887338539, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -84.056366, 2503.446045, 27.301250, 2.57831007809, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, -79.722610, 2503.437988, 29.861786, 14.6104237758, 0.000000, -89.999981276); //
	CreateDynamicObject(726, 336.134918, 2558.789795, 15.064713, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(726, 391.168976, 2562.580811, 14.764709, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 113.913872, 2517.356445, 17.640133, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 86.551926, 2516.960205, 17.501911, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 64.960381, 2516.351318, 17.484375, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 29.624765, 2516.413086, 17.484375, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 45.719616, 2516.546875, 17.492180, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 138.280197, 2517.255615, 17.609325, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 221.447571, 2393.695068, 29.713406, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 181.895355, 2394.303223, 29.713406, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 199.730515, 2394.027588, 29.713406, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 165.069519, 2394.383789, 29.660458, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 146.486618, 2394.385254, 29.660458, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3851, 125.173340, 2394.260254, 29.685362, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 233.808365, 2519.563721, 27.659225, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 233.860992, 2516.884277, 27.966047, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 233.775024, 2523.903809, 27.959703, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 233.779694, 2521.752930, 27.796730, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 263.528351, 2489.941406, 21.271383, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1225, 263.291046, 2484.739258, 26.925911, 0.000000, 90.2409100289, -85.6254485102); //
	CreateDynamicObject(1225, 263.723297, 2495.606201, 26.698874, 0.000000, 90.2409100289, -85.6254485102); //
	CreateDynamicObject(2918, 378.398315, 2479.776123, 17.751963, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16133, 347.898743, 2348.703369, 9.637272, 0.000000, 0.000000, -14.5330744735); //
	CreateDynamicObject(1655, 376.751190, 2358.735596, 25.114605, 0.000000, 0.000000, -271.718874509); //
	CreateDynamicObject(13831, 362.618347, 2558.737549, 41.176796, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2714, 404.820984, 2476.810059, 23.698668, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(10281, 404.518799, 2476.923096, 26.151306, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(1828, 400.443634, 2551.207031, 19.509233, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1383, 191.556290, 2550.691406, 47.985878, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1384, 191.414154, 2550.765381, 80.113403, 0.000000, 0.000000, -213.749984178); //
	CreateDynamicObject(1383, 128.913879, 2433.537842, 56.115662, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1384, 128.905045, 2433.507813, 88.641975, 0.000000, 0.000000, -326.250018069); //
	CreateDynamicObject(3361, 385.707336, 2551.231934, 17.788399, 0.000000, 4.29718346348, -180.000019848); //
	CreateDynamicObject(17310, 216.996292, 2307.603760, 32.807072, 0.000000, -215.718609867, -92.4236500452); //
	CreateDynamicObject(2918, 268.496246, 2436.745117, 29.404886, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3528, 404.180328, 2473.939941, 25.780321, 0.000000, 0.000000, -94.5379789008); //
	CreateDynamicObject(978, 375.056488, 2476.511963, 16.324594, 0.000000, 0.000000, -6.01605684887); //
	CreateDynamicObject(13593, 403.190735, 2531.447754, 19.904379, 0.000000, 0.000000, -182.200521556); //
	CreateDynamicObject(2745, 404.757507, 2536.920166, 20.745132, 0.000000, 0.000000, -92.896397522); //
	CreateDynamicObject(8644, 404.103119, 2433.804443, 23.274242, 0.000000, 0.000000, -63.5982579637); //
	CreateDynamicObject(3505, 378.100342, 2478.872559, 15.253851, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(2404, 399.453064, 2553.924316, 20.983397, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(6869, 230.725174, 2590.835205, 14.328714, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1238, 405.343079, 2536.888184, 20.936123, 0.000000, -54.1444543441, 0.859436692696); //
	CreateDynamicObject(2738, 394.139923, 2551.145264, 31.857790, 0.000000, 0.000000, -91.9596688227); //
	CreateDynamicObject(10757, 403.818939, 2472.606934, 31.067047, 0.000000, 0.000000, -179.622497957); //
	CreateDynamicObject(3528, 390.766998, 2551.596680, 28.391508, 0.000000, 0.000000, -185.638783989); //
	CreateDynamicObject(3505, 261.381958, 2472.288086, 15.011968, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 239.047272, 2434.887207, 28.710573, 0.000000, 0.000000, -44.999990638); //
	CreateDynamicObject(1383, 268.200928, 2305.238525, 60.140713, 0.000000, 0.000000, 33.7500216264); //
	CreateDynamicObject(1384, 268.182343, 2305.265869, 92.166634, 0.000000, 0.000000, -303.75002275); //
	CreateDynamicObject(17310, -55.587029, 2421.036865, 32.753880, 0.000000, -215.718609867, -146.095299617); //
	CreateDynamicObject(1655, 334.668976, 2483.113525, 16.484491, 0.000000, 0.000000, 236.249979497); //
	CreateDynamicObject(1655, 340.656586, 2479.118408, 20.932135, 18.0481705466, 0.000000, 236.249979497); //
	CreateDynamicObject(1655, 345.420624, 2475.941162, 27.185024, 31.7991576298, 0.000000, 236.249979497); //
	CreateDynamicObject(1655, 348.569977, 2473.841309, 34.952057, 50.7067075733, 0.000000, 236.249979497); //
	CreateDynamicObject(13641, 348.908447, 2473.675293, 43.183792, 0.000000, -67.8954414272, -394.609440719); //
	CreateDynamicObject(2918, 277.404968, 2532.081787, 17.033674, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3505, 324.996918, 2472.012939, 15.203854, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, 412.389587, 2520.553711, 17.674803, 2.57831007809, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 419.534271, 2520.562500, 22.315729, 18.0481705466, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 425.163635, 2520.573730, 28.886278, 35.2369044005, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 428.555115, 2520.568359, 36.772083, 52.4255809587, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 429.588989, 2520.578857, 44.977222, 67.8954414272, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 428.170441, 2520.573242, 53.644573, 85.0841752811, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 404.580994, 2520.538086, 15.225786, -12.8915503904, 0.000000, -89.999981276); //
	CreateDynamicObject(1655, 365.220551, 2476.301758, 16.084494, -3.43774677078, 0.859436692696, 179.999962552); //
	CreateDynamicObject(17310, 141.926880, 2426.557129, 32.881962, 0.000000, -215.718609867, -238.673705562); //
	CreateDynamicObject(17310, 116.492432, 2425.356445, 32.881947, 0.000000, -215.718609867, -295.783159201); //
	CreateDynamicObject(13666, 151.327148, 2476.874268, 20.260025, -1.71887338539, 0.859436692696, -38.9065844868); //
	CreateDynamicObject(2918, 269.970703, 2311.118652, 29.549593, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(978, 240.197266, 2532.330322, 16.550888, 0.000000, 0.000000, -179.999962552); //
	CreateDynamicObject(14780, 380.495453, 2472.522461, 25.006374, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16708, -93.403717, 2549.329346, 16.393381, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(14416, 392.911804, 2551.179443, 18.206860, -20.6264806247, 0.000000, 89.3813587446); //
	CreateDynamicObject(6189, -141.739731, 2503.528320, 28.488857, -24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(6189, -260.762146, 2503.530518, 81.635635, -24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(6189, -380.000488, 2503.531982, 134.888870, -24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(6189, -499.337677, 2503.534668, 188.172043, -24.0642273955, 0.000000, -89.999981276); //
	CreateDynamicObject(8881, 457.810333, 2443.730469, 48.405624, 0.000000, 0.000000, 120.157614823); //
	CreateDynamicObject(656, 391.833679, 2529.792969, 15.593643, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3472, 392.071930, 2529.455811, 18.229008, 0.000000, 0.000000, 22.499995319); //
	CreateDynamicObject(3472, 392.028229, 2529.515625, 15.792650, 0.000000, 0.000000, -44.999990638); //
	CreateDynamicObject(3472, 392.054474, 2529.476074, 20.170212, 0.000000, 0.000000, -168.74999354); //
	CreateDynamicObject(3472, 392.078003, 2529.600586, 22.932238, 0.000000, 0.000000, -292.500053739); //
	CreateDynamicObject(3472, 392.097229, 2529.430176, 26.010450, 0.000000, 0.000000, -360.000039696); //
	CreateDynamicObject(7666, 392.121918, 2529.279053, 41.499920, 0.000000, 0.000000, 33.7500216264); //
	CreateDynamicObject(2479, 392.191925, 2530.878662, 15.670429, 0.000000, 0.000000, -146.249998221); //
	CreateDynamicObject(2478, 390.371033, 2530.089111, 15.794766, 0.000000, 0.000000, -67.499985957); //
	CreateDynamicObject(2480, 391.216248, 2531.658203, 15.658852, -91.9596688227, 0.859436692696, -157.499967233); //
	CreateDynamicObject(3525, 389.958588, 2528.964111, 15.026812, 0.000000, 0.000000, -134.999971914); //
	CreateDynamicObject(3525, 394.249329, 2529.087402, 15.021349, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3525, 392.135406, 2527.211182, 15.005840, 0.000000, 0.000000, 0.000000); //

	//Los Santos Airport
	totalmaps++;
	CreateDynamicObject(1634, 1985.181152, -2565.469971, 13.594204, 0.0000, 0.0000, 89.9994);
	CreateDynamicObject(1634, 1979.997192, -2565.510254, 18.335501, 32.6578, 357.4217, 89.9994);
	CreateDynamicObject(18450, 2019.655151, -2544.967773, 45.298801, 2.5775, 0.0000, 334.9216);
	CreateDynamicObject(18450, 2024.071655, -2535.942871, 48.062000, 28.3606, 0.0000, 334.9216);
	CreateDynamicObject(18450, 2015.068848, -2554.523438, 48.030399, 30.9389, 0.0000, 154.9212);
	CreateDynamicObject(1632, 2054.332764, -2558.129639, 46.693100, 0.0000, 0.0000, 247.4997);
	CreateDynamicObject(1632, 2052.791016, -2561.995117, 46.730999, 0.0000, 0.0000, 247.4997);
	CreateDynamicObject(1632, 2051.226563, -2565.831055, 46.736900, 0.0000, 0.0000, 247.4997);
	CreateDynamicObject(1632, 2056.697998, -2563.589844, 50.685699, 29.2200, 0.0000, 247.4997);
	CreateDynamicObject(1632, 2055.112061, -2567.411133, 50.694096, 29.2200, 0.0000, 247.4997);
	CreateDynamicObject(1632, 2058.266357, -2559.758789, 50.685097, 29.2200, 0.0000, 247.4997);
	CreateDynamicObject(1634, 1937.532715, -2507.657227, 13.836400, 0.0000, 0.0000, 348.7528);
	CreateDynamicObject(1634, 1937.665771, -2507.008789, 15.536400, 22.3445, 0.0000, 348.7528);
	CreateDynamicObject(1634, 1938.043213, -2505.145752, 18.099501, 35.2361, 0.0000, 348.7528);
	CreateDynamicObject(13641, 1861.506714, -2616.030029, 14.266100, 0.0000, 0.0000, 213.7525);
	CreateDynamicObject(3851, 1853.236084, -2622.294678, 21.780704, 0.8586, 359.1406, 216.3308);
	CreateDynamicObject(3851, 1853.255249, -2622.231689, 25.631001, 0.8586, 359.1406, 216.3308);
	CreateDynamicObject(13604, 1789.565796, -2539.483154, 14.004896, 0.0000, 0.0000, 355.7028);
	CreateDynamicObject(16139, 1768.489380, -2617.451172, 10.680120, 0.0000, 7.7341, 343.5962);
	CreateDynamicObject(16139, 1755.865845, -2592.684082, 11.079945, 0.0000, 9.4530, 165.3892);
	CreateDynamicObject(18450, 1756.761841, -2604.406250, 18.608500, 0.0000, 9.4530, 0.0000);
	CreateDynamicObject(619, 1795.444824, -2611.426758, 12.869900, 0.0000, 0.0000, 292.4998);
	CreateDynamicObject(619, 1796.346313, -2596.553955, 12.928700, 0.0000, 0.0000, 11.2520);
	CreateDynamicObject(3461, 1794.448120, -2597.888428, 14.461500, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3461, 1794.402588, -2610.568115, 14.469100, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16776, 1707.590210, -2526.634277, 12.297730, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1633, 1692.697510, -2529.126953, 13.847200, 0.0000, 0.0000, 269.9998);
	CreateDynamicObject(1633, 1695.325684, -2529.138916, 16.120501, 24.0634, 0.0000, 269.9998);
	CreateDynamicObject(7392, 1739.348633, -2523.823975, 20.716999, 0.0000, 0.0000, 169.9954);
	CreateDynamicObject(7392, 1740.048096, -2561.431396, 20.992001, 0.0000, 0.0000, 1.9532);
	CreateDynamicObject(1211, 1749.195801, -2556.460449, 13.157700, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18450, 1743.969482, -2604.410645, 26.183918, 0.0000, 17.1878, 0.0000);
	CreateDynamicObject(1634, 1979.594971, -2565.591553, 25.208046, 81.6455, 0.0000, 89.9994);
	CreateDynamicObject(17310, 1409.150757, -2457.283203, 17.626297, 0.0000, 220.7711, 339.3736);
	CreateDynamicObject(1655, 1551.912720, -2604.473877, 13.521992, 0.0000, 0.0000, 90.0000);
	CreateDynamicObject(1655, 1545.503296, -2604.463623, 17.555511, 18.9076, 0.0000, 90.0000);
	CreateDynamicObject(1655, 1540.553345, -2604.487549, 23.280512, 34.3775, 0.0000, 90.0000);
	CreateDynamicObject(1655, 1537.658691, -2604.484131, 30.752773, 57.5822, 0.0000, 90.0000);
	CreateDynamicObject(1655, 1764.567017, -2458.463379, 13.554804, 0.0000, 0.0000, 45.0000);
	CreateDynamicObject(1655, 1760.144409, -2454.052979, 17.142418, 14.6104, 0.0000, 45.0000);
	CreateDynamicObject(13590, 2029.526855, -2617.995850, 13.597723, 0.0000, 0.0000, 90.0000);
	CreateDynamicObject(3374, 2037.121948, -2571.347900, 14.040852, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2037.107910, -2571.356201, 16.904274, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2037.098267, -2571.371582, 19.796303, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2037.059937, -2571.353271, 22.721304, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2039.160645, -2568.163086, 14.002875, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2047.721191, -2557.629150, 13.940853, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2045.596191, -2560.745850, 13.960550, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2047.789429, -2557.678711, 16.885536, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2045.791504, -2560.585205, 19.830780, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2047.724609, -2557.669922, 19.817831, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2045.767822, -2560.575195, 22.555784, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2045.678101, -2560.510742, 25.399334, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2047.469727, -2557.428223, 25.390675, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2036.936890, -2571.275391, 25.481167, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(3374, 2061.021240, -2552.388916, 14.040852, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2061.996582, -2551.498291, 16.715834, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2062.743652, -2550.771973, 19.040852, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2063.507324, -2550.114014, 21.423914, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2064.166260, -2549.542236, 24.122515, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2067.224365, -2547.060791, 24.136555, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2068.016846, -2546.370850, 21.430183, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2068.750977, -2545.778809, 18.962706, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2069.418457, -2545.215576, 15.993019, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2070.388672, -2544.448730, 13.540859, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2065.678223, -2548.276367, 19.022655, 0.0000, 0.0000, 309.0613);
	CreateDynamicObject(3374, 2081.022217, -2541.935303, 13.915854, 0.0000, 0.0000, 299.6075);
	CreateDynamicObject(3374, 2080.996582, -2541.903320, 16.615858, 0.0000, 0.0000, 299.6075);
	CreateDynamicObject(3374, 2081.023193, -2541.879150, 19.269239, 0.0000, 0.0000, 299.6075);
	CreateDynamicObject(3374, 2081.024414, -2541.802734, 22.243423, 0.0000, 0.0000, 299.6075);
	CreateDynamicObject(3374, 2080.976563, -2541.741455, 24.272045, 0.0000, 0.0000, 299.6075);
	CreateDynamicObject(3374, 2092.416016, -2540.966309, 14.040852, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2092.373779, -2540.810303, 16.815855, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2092.376221, -2540.789795, 19.656393, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2092.373779, -2540.767822, 22.190948, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2092.345947, -2540.792725, 24.265888, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2095.485596, -2539.797119, 24.242163, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2097.965576, -2539.100586, 24.244492, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2097.947510, -2539.029541, 21.752884, 0.0000, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2095.641846, -2539.822754, 18.373066, 39.5341, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2097.458008, -2539.148926, 20.123484, 39.5341, 0.0000, 285.8565);
	CreateDynamicObject(3374, 2095.643311, -2539.884521, 15.390850, 153.8392, 0.8594, 285.8565);
	CreateDynamicObject(3374, 2098.665283, -2538.853027, 13.845953, 153.8392, 0.8594, 285.8565);
	CreateDynamicObject(7980, 1922.064575, -2616.420410, 14.533843, 0.0000, 0.0000, 359.1406);
	CreateDynamicObject(1378, 2132.228516, -2538.562500, 34.559380, 0.0000, 0.0000, 91.9597);
	CreateDynamicObject(1632, 1522.161377, -2622.247559, 14.471995, 10.3125, 0.0000, 179.5183);
	CreateDynamicObject(3287, 2044.691406, -2596.241943, 17.235901, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3287, 2053.240723, -2596.297119, 17.091101, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(6928, 1976.277466, -2644.833740, 14.413200, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(13593, 2061.339844, -2597.901611, 13.408100, 10.3124, 0.0000, 89.2774);
	CreateDynamicObject(13592, 1409.492188, -2593.011719, 21.642500, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(13592, 1408.378052, -2593.435791, 28.767500, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(13592, 1407.353760, -2593.805908, 35.342499, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(13592, 1406.208740, -2594.205566, 42.596401, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(13592, 1405.101196, -2594.613525, 49.859001, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(13592, 1403.980103, -2595.031250, 57.111500, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(1655, 1394.803345, -2603.250000, 66.831802, 358.2811, 85.9428, 84.2240);
	CreateDynamicObject(1632, 1415.949341, -2601.727783, 14.197000, 10.3124, 29.2200, 127.1958);
	CreateDynamicObject(18450, 1827.548218, -2381.769775, 24.222799, 0.8586, 18.0473, 290.3856);
	CreateDynamicObject(18450, 1801.248779, -2312.205078, 48.444302, 0.8586, 18.0473, 290.3856);
	CreateDynamicObject(8420, 1754.596436, -2267.727295, 61.259399, 0.0000, 0.0000, 110.0071);
	CreateDynamicObject(1655, 1752.635742, -2308.737061, 63.115398, 11.1718, 0.0000, 171.7834);
	CreateDynamicObject(3749, 1786.846924, -2274.841309, 66.719398, 0.0000, 0.0000, 19.7662);
	CreateDynamicObject(17565, 1653.458008, -2595.797852, 14.655606, 0.0000, 0.0000, 269.7591);
	CreateDynamicObject(13640, 1765.062012, -2235.102783, 61.931198, 0.0000, 0.0000, 21.4851);
	CreateDynamicObject(13640, 1744.021851, -2243.576904, 62.231201, 0.0000, 0.0000, 21.4851);
	CreateDynamicObject(8420, 1698.682617, -2288.073486, 61.065201, 0.0000, 0.0000, 289.5262);
	CreateDynamicObject(13647, 1698.970215, -2285.436279, 61.037800, 0.0000, 0.0000, 20.6256);
	CreateDynamicObject(13648, 1735.095215, -2272.055176, 61.031898, 0.0000, 0.0000, 110.0071);
	CreateDynamicObject(16304, 1661.489258, -2274.046387, 66.080200, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(13638, 1711.534180, -2316.452393, 63.564201, 0.0000, 0.0000, 109.1476);
	CreateDynamicObject(13636, 1706.535767, -2254.115967, 63.322201, 0.0000, 0.0000, 19.0099);
	CreateDynamicObject(11395, 1379.274292, -2561.021484, 69.816498, 0.0000, 0.0000, 356.5623);
	CreateDynamicObject(13592, 1819.901489, -2568.908691, 22.092501, 359.9992, 1.7180, 99.6938);
	CreateDynamicObject(13592, 1813.126465, -2569.135010, 22.067499, 359.9992, 1.7180, 99.6938);
	CreateDynamicObject(13592, 1806.329834, -2569.268311, 22.017500, 359.9992, 1.7180, 99.6938);
	CreateDynamicObject(13592, 1799.560303, -2569.428711, 22.017500, 359.9992, 1.7180, 99.6938);
	CreateDynamicObject(1655, 1795.904297, -2565.658691, 14.372000, 10.3124, 0.0000, 3.4369);
	CreateDynamicObject(1634, 1402.684692, -2660.955322, 13.525000, 0.0000, 0.0000, 340.2330);
	CreateDynamicObject(1634, 1347.787964, -2551.638428, 13.422300, 0.0000, 0.0000, 271.4780);
	CreateDynamicObject(8391, 1395.774780, -2431.324951, 28.960100, 0.0000, 0.0000, 270.6186);
	CreateDynamicObject(1655, 1385.604248, -2422.687500, 14.254801, 8.5935, 0.0000, 86.8023);
	CreateDynamicObject(1655, 1365.349487, -2453.858398, 48.652100, 13.7501, 0.0000, 184.7780);
	CreateDynamicObject(1655, 1427.353271, -2408.754883, 48.602093, 13.7501, 0.8594, 272.4406);
	CreateDynamicObject(10948, 1905.370728, -2250.657959, 62.393398, 0.0000, 0.0000, 89.2774);
	CreateDynamicObject(5001, 1947.194702, -2290.480957, 32.918701, 80.7862, 312.7310, 133.2118);
	CreateDynamicObject(1633, 1951.494751, -2272.379639, 13.058600, 354.8434, 358.2811, 357.4217);
	CreateDynamicObject(1632, 1890.504761, -2273.584473, 59.199799, 16.3285, 0.0000, 87.6617);
	CreateDynamicObject(1632, 1886.002808, -2273.401855, 65.116798, 42.1116, 0.0000, 87.6617);
	CreateDynamicObject(1632, 1884.591309, -2273.360352, 71.989304, 67.8947, 0.0000, 87.6617);
	CreateDynamicObject(1632, 1885.802490, -2273.252441, 79.782898, 85.9428, 0.0000, 94.5372);
	CreateDynamicObject(1632, 1911.164917, -2211.925537, 83.174797, 16.3285, 0.0000, 1.7180);
	CreateDynamicObject(1632, 1911.111450, -2207.342529, 89.172302, 42.1116, 0.0000, 1.7180);
	CreateDynamicObject(1632, 1911.143066, -2205.306152, 96.662498, 61.8786, 0.0000, 358.2811);
	CreateDynamicObject(1655, 1847.484131, -2245.543701, 105.724800, 0.0000, 0.0000, 104.7473);
	CreateDynamicObject(13638, 1704.099854, -2331.697266, 71.681999, 0.0000, 0.0000, 109.1476);
	CreateDynamicObject(13592, 1402.820923, -2595.449707, 64.366898, 274.0563, 0.0000, 354.8434);
	CreateDynamicObject(4113, 1378.957764, -2579.281250, 26.275478, 0.0000, 0.0000, 278.3535);
	CreateDynamicObject(1684, 1886.183350, -2195.461182, 103.239502, 0.0000, 0.0000, 269.7591);
	CreateDynamicObject(1684, 1886.146973, -2205.505859, 103.239502, 0.0000, 0.0000, 269.7591);
	CreateDynamicObject(1684, 1886.100830, -2215.551270, 103.245300, 0.0000, 0.0000, 269.7591);
	CreateDynamicObject(13638, 1688.669312, -2333.504883, 79.768501, 0.0000, 0.0000, 18.9068);
	CreateDynamicObject(7073, 1977.467407, -2628.285889, 49.440125, 0.0000, 6.0161, 88.5211);
	CreateDynamicObject(13722, 2045.721436, -2638.500488, 21.983400, 0.0000, 0.0000, 180.3777);
	CreateDynamicObject(13831, 2045.705200, -2638.513428, 21.963200, 0.0000, 0.0000, 180.3777);
	CreateDynamicObject(1267, 2139.728271, -2489.103516, 28.611601, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(6066, 2111.718994, -2493.414307, 14.497309, 0.0000, 0.0000, 184.7780);
	CreateDynamicObject(1655, 2105.789795, -2493.889404, 13.689200, 2.5775, 0.0000, 274.9158);
	CreateDynamicObject(9237, 2095.310059, -2638.382568, 20.532301, 0.0000, 0.0000, 282.6507);
	CreateDynamicObject(1632, 1392.424683, -2560.342041, 63.170895, 4.2963, 0.0000, 325.6225);
	CreateDynamicObject(11111, 1439.064697, -2496.987061, 2.429701, 329.0603, 0.0000, 269.7591);
	CreateDynamicObject(1378, 2036.934326, -2373.857666, 36.613098, 0.0000, 0.0000, 312.7310);
	CreateDynamicObject(1632, 1983.898193, -2421.146729, 13.847000, 4.2963, 0.0000, 310.9090);
	CreateDynamicObject(1632, 1981.232300, -2418.039795, 13.847000, 4.2963, 0.0000, 310.9090);
	CreateDynamicObject(1655, 1985.701904, -2416.703369, 17.115000, 30.0794, 0.0000, 311.0121);
	CreateDynamicObject(1632, 2020.638306, -2389.098145, 44.242699, 23.2039, 0.0000, 310.9090);
	CreateDynamicObject(13592, 1508.350586, -2495.192871, 21.775330, 359.9992, 1.7180, 7.3565);
	CreateDynamicObject(1655, 1798.069092, -2434.893066, 13.504797, 0.0000, 0.0000, 66.7201);
	CreateDynamicObject(1632, 2062.030273, -2622.842041, 13.471992, 0.0000, 359.1406, 112.5674);
	CreateDynamicObject(1632, 2059.226074, -2624.040283, 16.196993, 24.9229, 359.1406, 112.5675);
	CreateDynamicObject(1655, 1894.168457, -2547.338867, 13.546991, 0.0000, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1894.168457, -2538.588867, 13.546991, 0.0000, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1874.907959, -2538.650879, 13.646990, 0.0000, 0.0000, 269.9998);
	CreateDynamicObject(1655, 1874.907959, -2547.900879, 13.646990, 0.0000, 0.0000, 269.9998);
	CreateDynamicObject(1225, 1887.571167, -2539.274170, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1887.189209, -2536.926025, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1881.664795, -2536.705322, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1881.636963, -2539.611328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1886.636963, -2546.861328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1886.636963, -2549.361328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1880.636963, -2548.361328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1882.386963, -2546.111328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1882.386963, -2549.861328, 12.952630, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1655, 1834.822754, -2543.000732, 13.846987, 0.0000, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1831.847290, -2543.000732, 15.446981, 7.7341, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1827.347290, -2543.000732, 18.721954, 18.9068, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1825.397095, -2543.000732, 20.696951, 25.7823, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1822.021729, -2543.000732, 25.146936, 35.2361, 0.0000, 89.9994);
	CreateDynamicObject(1655, 1662.840210, -2547.387207, 13.471992, 0.8586, 0.0000, 90.0796);
	CreateDynamicObject(1655, 1662.756958, -2538.522217, 13.471992, 0.8586, 0.0000, 90.0796);
	CreateDynamicObject(18450, 1765.612671, -2543.646484, 38.633293, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18450, 1708.590576, -2543.608154, 38.690025, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18450, 1615.420776, -2544.013428, 51.936661, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18449, 1542.543091, -2544.023438, 51.933403, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(13666, 1575.171387, -2544.156738, 54.557465, 0.0000, 0.0000, 12.8907);
	CreateDynamicObject(13666, 1562.421387, -2544.156738, 54.557465, 0.0000, 0.0000, 12.8907);
	CreateDynamicObject(13666, 1550.171387, -2544.156738, 54.557465, 0.0000, 0.0000, 12.8907);
	CreateDynamicObject(13666, 1538.421387, -2544.156738, 54.557465, 0.0000, 0.0000, 12.8907);
	CreateDynamicObject(1632, 1501.518799, -2546.135986, 52.665535, 0.0000, 0.0000, 89.0653);
	CreateDynamicObject(1632, 1501.569580, -2542.065186, 52.665535, 0.0000, 0.0000, 89.9248);
	CreateDynamicObject(1655, 1688.343140, -2544.022705, 40.008869, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(1655, 1683.093140, -2544.022705, 43.258869, 17.1879, 0.0000, 90.2400);
	CreateDynamicObject(17565, 1776.008667, -2491.739746, 14.563401, 0.0000, 0.0000, 90.2400);
	CreateDynamicObject(5126, 1953.082642, -2657.010010, 26.496246, 0.0000, 0.0000, 89.3806);
	CreateDynamicObject(1632, 1953.600464, -2612.573486, 13.346987, 0.0000, 0.0000, 178.4354);
	CreateDynamicObject(1632, 1953.475342, -2616.899170, 15.846987, 13.7501, 0.0000, 178.4354);
	CreateDynamicObject(619, 1576.564697, -2536.968750, 52.056770, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(619, 1555.989624, -2536.819336, 52.056770, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(619, 1539.490112, -2536.968750, 52.056770, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1632, 1492.271851, -2426.578613, 13.854799, 7.7341, 0.0000, 290.7065);
	CreateDynamicObject(1655, 1794.369141, -2433.293457, 15.754797, 13.7501, 0.0000, 66.7201);
	CreateDynamicObject(3110, 1392.590088, -2545.967041, 9.791678, 0.0000, 0.0000, 110.0071);
	CreateDynamicObject(7388, 2095.244873, -2637.474121, 14.153080, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1655, 1379.447632, -2422.558350, 19.575186, 25.7821, 0.0000, 86.8023);
	CreateDynamicObject(1655, 1374.930664, -2422.481201, 26.484589, 42.1113, 0.0000, 88.5211);
	CreateDynamicObject(1655, 1372.765381, -2422.544189, 34.767113, 63.5970, 0.0000, 88.5211);
	CreateDynamicObject(1655, 1373.813599, -2422.537354, 43.054920, 83.3638, 0.0000, 89.3806);
	CreateDynamicObject(11111, 1389.273682, -2496.774902, 32.758064, 328.2008, 0.0000, 269.7591);
	CreateDynamicObject(11111, 1340.121338, -2496.681152, 62.821762, 329.0603, 0.0000, 269.7591);
	CreateDynamicObject(11111, 1289.727295, -2496.479492, 93.145531, 329.0603, 0.0000, 269.7591);
	CreateDynamicObject(11111, 1234.095703, -2496.261963, 110.268219, 356.5623, 0.0000, 269.7591);
	CreateDynamicObject(11111, 1446.980225, -2497.020752, 5.165510, 341.9518, 0.0000, 269.7591);
	CreateDynamicObject(1632, 1406.056396, -2497.214111, 20.773096, 320.4659, 0.0000, 270.0000);
	CreateDynamicObject(1632, 1414.655884, -2497.229736, 19.542337, 336.7952, 0.0000, 270.0000);
	CreateDynamicObject(1632, 1422.737915, -2497.247070, 20.700184, 353.9839, 0.0000, 270.0000);
	CreateDynamicObject(1632, 1430.378906, -2497.256104, 24.182434, 11.1727, 0.0000, 270.0000);
	CreateDynamicObject(1632, 1436.718384, -2497.261475, 29.718729, 25.7831, 0.0000, 270.0000);
	CreateDynamicObject(13593, 2035.861206, -2597.869873, 13.289734, 10.3124, 0.0000, 269.2774);
	CreateDynamicObject(1655, 2021.954224, -2493.836182, 13.614233, 0.0000, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2029.256348, -2493.833008, 17.899996, 15.4699, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2035.230469, -2493.845947, 23.848019, 29.2208, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2039.502197, -2493.850342, 31.013893, 43.8313, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2041.885376, -2493.854004, 39.182938, 58.4416, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2041.915161, -2493.836914, 47.739292, 75.6304, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2039.614014, -2493.843262, 55.991428, 90.2408, 0.0000, 269.9998);
	CreateDynamicObject(1655, 2035.338745, -2493.848877, 63.221203, 105.7106, 0.0000, 269.9998);
	CreateDynamicObject(1632, 1977.046875, -2614.947266, 13.471994, 0.0000, 0.0000, 178.4354);
	CreateDynamicObject(1632, 1976.876831, -2621.244873, 17.272957, 17.1887, 0.0000, 178.4354);
	CreateDynamicObject(1632, 1976.746704, -2626.148926, 22.887352, 35.2369, 0.0000, 178.4354);
	CreateDynamicObject(1632, 1976.671143, -2629.200439, 30.078264, 53.2850, 0.0000, 178.4354);
	CreateDynamicObject(1632, 1976.646729, -2629.963623, 37.470280, 69.6143, 0.0000, 178.4354);
	CreateDynamicObject(13641, 1858.234741, -2618.424316, 16.110140, 0.0000, 343.6707, 213.7525);
	CreateDynamicObject(13638, 1702.427368, -2317.529541, 63.564178, 0.0000, 0.0000, 199.3885);
	CreateDynamicObject(3374, 2037.066528, -2571.338135, 13.986930, 0.0000, 0.0000, 326.2500);
	CreateDynamicObject(17310, 1980.099487, -2526.428467, 13.946930, 0.0000, 202.7229, 335.0763);
	CreateDynamicObject(17310, 1966.822266, -2520.647461, 31.366039, 358.2811, 96.1525, 158.1366);
	CreateDynamicObject(8620, 2015.691772, -2493.938477, 35.535446, 0.0000, 0.0000, 271.4781);
	CreateDynamicObject(8493, 1791.527222, -2569.648438, 51.754890, 0.0000, 0.0000, 91.9597);
	CreateDynamicObject(3851, 1547.767090, -2544.937256, 14.546875, 0.8586, 358.2811, 180.2343);
	CreateDynamicObject(3851, 1528.716431, -2545.708252, 14.460798, 0.8586, 359.1406, 181.6441);
	CreateDynamicObject(3851, 1507.486938, -2546.060547, 14.546875, 0.8586, 359.1406, 180.7847);
	CreateDynamicObject(3851, 1480.463013, -2546.864258, 14.546875, 0.8586, 359.1406, 181.6441);
	CreateDynamicObject(3851, 1994.783203, -2595.231689, 14.796875, 0.8586, 1.7189, 182.5036);
	CreateDynamicObject(3851, 1929.030518, -2594.497559, 14.546875, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1961.152344, -2594.352783, 14.546874, 0.8586, 359.1406, 180.7847);
	CreateDynamicObject(3851, 2014.654785, -2595.318115, 14.546875, 0.8586, 359.1406, 179.9253);
	CreateDynamicObject(676, 2063.561523, -2564.686035, 12.545872, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(676, 2077.379639, -2549.751709, 12.545872, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16061, 1746.534668, -2596.528320, 25.987368, 16.3293, 0.0000, 90.2408);
	CreateDynamicObject(16061, 1747.775513, -2612.602051, 25.500410, 16.3293, 0.0000, 90.2408);
	CreateDynamicObject(1655, 1642.793579, -2538.817871, 14.046984, 5.1557, 0.0000, 270.5611);
	CreateDynamicObject(1655, 1706.671509, -2608.704834, 37.556595, 359.1398, 0.0000, 90.2393);
	CreateDynamicObject(1655, 1706.628540, -2600.241943, 37.564457, 359.1398, 0.0000, 90.2393);
	CreateDynamicObject(16776, 1610.417969, -2493.228760, 10.155575, 0.0000, 0.0000, 1.7187);
	CreateDynamicObject(16776, 1628.831665, -2494.308594, 10.655537, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16061, 2023.832153, -2472.422852, 12.234304, 0.0000, 0.0000, 90.2408);
	CreateDynamicObject(16061, 1388.683472, -2497.827148, 12.546875, 0.0000, 0.0000, 173.6062);
	CreateDynamicObject(16061, 1593.863037, -2627.960449, 12.546875, 0.0000, 3.4377, 85.9436);
	CreateDynamicObject(16061, 1661.192505, -2627.212646, 11.384298, 0.0000, 0.0000, 91.1002);
	CreateDynamicObject(16061, 1892.286011, -2515.380615, 12.134298, 0.0000, 0.0000, 90.2407);
	CreateDynamicObject(16061, 1425.060913, -2633.519775, 12.134298, 0.0000, 3.4377, 85.9436);
	CreateDynamicObject(16061, 1471.259521, -2410.683838, 12.317120, 0.8594, 0.0000, 268.8997);
	CreateDynamicObject(16061, 1568.072998, -2395.581787, 11.892111, 0.0000, 3.4377, 85.9436);
	CreateDynamicObject(16061, 1642.782715, -2395.143311, 11.592115, 0.0000, 3.4377, 88.5219);
	CreateDynamicObject(16061, 1723.977783, -2396.484863, 12.642113, 0.0000, 3.4377, 96.2569);
	CreateDynamicObject(16061, 1997.792969, -2315.867188, 12.459309, 0.0000, 0.0000, 2.5783);
	CreateDynamicObject(1632, 1647.350830, -2507.430908, 13.504799, 6.0161, 0.0000, 90.2409);
	CreateDynamicObject(1632, 1647.322754, -2503.301270, 13.510681, 6.0161, 0.0000, 90.2409);
	CreateDynamicObject(1632, 1647.356079, -2499.275635, 13.504801, 6.0161, 0.0000, 88.5220);
	CreateDynamicObject(1632, 1647.510498, -2495.151611, 13.507164, 6.0161, 0.0000, 88.5220);
	CreateDynamicObject(1632, 1647.609619, -2490.996826, 13.518862, 6.0161, 0.0000, 88.5220);
	CreateDynamicObject(1632, 1647.692017, -2486.996582, 13.529804, 6.0161, 0.0000, 88.5220);
	CreateDynamicObject(1632, 1647.785889, -2482.885498, 13.554804, 6.0161, 0.0000, 88.5220);
	CreateDynamicObject(16776, 1620.035034, -2493.245850, 10.055531, 0.0000, 0.0000, 1.7187);
	CreateDynamicObject(1632, 1592.629028, -2483.149658, 13.579777, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(1632, 1592.543579, -2487.289063, 13.579803, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(1632, 1592.465576, -2495.495850, 13.579803, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(1632, 1592.498657, -2491.359375, 13.579803, 4.2972, 0.0000, 269.7591);
	CreateDynamicObject(1632, 1592.305298, -2503.658447, 13.579803, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(1632, 1592.373779, -2499.643066, 13.580938, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(1632, 1592.221802, -2507.758057, 13.579803, 4.2972, 0.0000, 268.8997);
	CreateDynamicObject(3851, 1965.642212, -2490.898926, 15.039080, 138.3674, 359.1406, 182.8126);
	CreateDynamicObject(3851, 1957.104492, -2491.669434, 15.545273, 46.4083, 359.1406, 182.8126);
	CreateDynamicObject(3851, 1986.605225, -2491.320068, 14.539118, 46.4083, 359.1406, 182.8126);
	CreateDynamicObject(3851, 1978.776611, -2490.049561, 14.639120, 140.9457, 359.1406, 182.8126);
	CreateDynamicObject(3851, 1972.969727, -2491.344482, 14.539118, 46.4083, 359.1406, 182.8126);
	CreateDynamicObject(3851, 1951.302246, -2490.500000, 15.939119, 46.4083, 359.1406, 5.8728);
	CreateDynamicObject(3851, 1945.339478, -2491.143311, 14.539118, 121.1786, 359.1406, 5.8728);
	CreateDynamicObject(3851, 1938.462769, -2491.116699, 14.539118, 46.4083, 359.1406, 5.8728);
	CreateDynamicObject(3851, 1931.069580, -2490.837646, 14.539118, 127.1950, 359.1406, 5.8728);
	CreateDynamicObject(3851, 1922.615723, -2489.458984, 15.439104, 46.4083, 359.1406, 5.8728);
	CreateDynamicObject(3851, 1762.401001, -2604.422119, 22.842506, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1729.223999, -2604.717285, 33.878078, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1771.175171, -2604.290283, 20.128492, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1749.641479, -2604.833740, 26.789265, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(1225, 1669.739746, -2543.412354, 39.439529, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1669.777100, -2537.580322, 39.439529, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1669.749756, -2540.307373, 39.439529, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1669.734741, -2546.771729, 39.439529, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1225, 1669.785400, -2549.819580, 39.439529, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3505, 2056.283447, -2555.017334, 12.541348, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3505, 2035.832397, -2576.201660, 12.541348, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3505, 2073.594238, -2537.811035, 12.541348, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(3505, 2102.440918, -2535.424805, 12.541348, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1655, 1642.836060, -2547.337402, 14.022999, 5.1557, 0.0000, 270.5611);
	CreateDynamicObject(1655, 1658.779419, -2547.288574, 16.029963, 18.0472, 0.0000, 90.0796);
	CreateDynamicObject(1655, 1658.762451, -2538.598145, 16.041815, 18.0472, 0.0000, 90.0796);
	CreateDynamicObject(1655, 1646.229004, -2547.298096, 16.547010, 18.0472, 0.0000, 270.0796);
	CreateDynamicObject(1655, 1646.252441, -2538.802734, 16.565464, 18.0472, 0.0000, 270.0796);
	CreateDynamicObject(1655, 1839.405518, -2414.158203, 12.759804, 350.5462, 0.0000, 20.6265);
	CreateDynamicObject(16304, 1706.937866, -2542.070801, 15.182156, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16061, 1495.852905, -2640.930176, 12.134298, 0.0000, 3.4377, 92.8191);
	CreateDynamicObject(8357, 1451.650635, -2629.008789, 38.291237, 327.3414, 0.0000, 315.0000);
	CreateDynamicObject(8357, 1326.957397, -2753.744385, 151.344360, 327.3414, 0.0000, 315.0000);
	CreateDynamicObject(8357, 1207.157837, -2873.545654, 259.920288, 327.3414, 0.0000, 315.0000);
	CreateDynamicObject(8040, 1115.313843, -2964.850342, 318.075775, 0.0000, 0.0000, 45.0000);
	CreateDynamicObject(1655, 1146.640991, -2933.511963, 314.798004, 317.8876, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1150.768311, -2929.564209, 310.884705, 26.6425, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1213.177612, -2884.415527, 261.759338, 311.8715, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1218.762573, -2878.846680, 259.794189, 334.2169, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1224.333130, -2873.276611, 260.998108, 357.4217, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1273.772827, -2806.707275, 200.536285, 329.9197, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1279.217407, -2801.282959, 200.809509, 348.8273, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1284.477783, -2796.029053, 203.770874, 8.5943, 0.0000, 315.0000);
	CreateDynamicObject(1655, 1288.708252, -2791.817383, 209.117050, 28.3614, 0.0000, 315.0000);
	CreateDynamicObject(17310, 1400.166260, -2700.262939, 97.343025, 359.1406, 177.7992, 226.0141);
	CreateDynamicObject(17310, 1425.470581, -2635.080322, 56.561249, 359.1406, 177.7992, 226.0141);
	CreateDynamicObject(18450, 1351.614868, -2729.225098, 199.858780, 0.0000, 0.0000, 45.0000);
	CreateDynamicObject(18450, 1407.157593, -2673.685303, 199.845581, 0.0000, 0.0000, 45.0000);
	CreateDynamicObject(1655, 1434.583740, -2646.212646, 200.689453, 356.5623, 0.0000, 315.0000);
	CreateDynamicObject(1632, 1522.119751, -2628.015625, 19.464361, 25.7822, 0.0000, 179.5183);
	CreateDynamicObject(1632, 1522.079224, -2632.179932, 26.059635, 43.8302, 0.0000, 179.5183);
	CreateDynamicObject(1632, 1522.073242, -2634.026855, 33.603714, 62.7376, 0.0000, 179.5183);
	CreateDynamicObject(1632, 1522.105103, -2633.397217, 41.566936, 80.7857, 0.0000, 179.5183);
	CreateDynamicObject(3851, 1622.536377, -2587.384277, 14.546875, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1596.057129, -2587.556641, 14.546875, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1595.693970, -2598.740723, 14.696873, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1570.041870, -2587.722656, 14.546875, 0.8586, 359.1406, 179.9253);
	CreateDynamicObject(3851, 1622.183838, -2598.584229, 14.696873, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(3851, 1546.552734, -2586.216797, 14.546875, 0.8586, 359.1406, 178.2064);
	CreateDynamicObject(1655, 1492.464966, -2610.385498, 12.271996, 347.1084, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1486.314087, -2604.242676, 12.277994, 347.1084, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1480.180908, -2598.105225, 12.274298, 347.1084, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1474.242798, -2592.025879, 12.271980, 347.1084, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1489.022827, -2613.836182, 13.977276, 5.1566, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1482.873291, -2607.687744, 13.973618, 5.1566, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1476.793945, -2601.611572, 13.971985, 5.1566, 0.0000, 135.0000);
	CreateDynamicObject(1655, 1470.756592, -2595.568359, 13.971985, 5.1566, 0.0000, 135.0000);
	CreateDynamicObject(8618, 2147.217773, -2587.222656, 25.552778, 0.0000, 0.0000, 87.6625);
	CreateDynamicObject(2898, 2094.278564, -2633.392334, 12.600760, 0.0000, 0.0000, 11.1727);
	CreateDynamicObject(2985, 2092.407959, -2631.352295, 12.578382, 0.0000, 0.0000, 197.6705);
	CreateDynamicObject(3092, 2094.833496, -2635.185547, 13.906953, 0.0000, 0.0000, 0.0000);
	
	//Mount Chilliad
	totalmaps++;
	CreateDynamicObject(16133, -2367.733398, -1603.614380, 475.600555, 0.0000, 335.0763, 160.0784);
	CreateDynamicObject(16133, -2372.995117, -1609.019775, 478.692902, 0.0000, 352.2651, 172.9698);
	CreateDynamicObject(4867, -2401.987793, -1539.044189, 477.351074, 0.0000, 0.0000, 276.1708);
	CreateDynamicObject(16141, -2445.336914, -1581.441528, 467.570038, 0.0000, 0.0000, 292.5000);
	CreateDynamicObject(5005, -2318.819092, -1456.996460, 480.552673, 0.0000, 0.0000, 276.0934);
	CreateDynamicObject(4867, -2406.934570, -1493.294800, 477.348022, 0.0000, 0.0000, 276.1708);
	CreateDynamicObject(5005, -2405.908203, -1386.418701, 480.574615, 0.0000, 0.0000, 186.0934);
	CreateDynamicObject(5005, -2426.622070, -1388.611206, 480.578979, 0.0000, 0.0000, 186.0934);
	CreateDynamicObject(5005, -2500.007324, -1479.637817, 480.602661, 0.0000, 0.0000, 96.0933);
	CreateDynamicObject(5005, -2489.837402, -1575.889648, 480.602661, 0.0000, 0.0000, 96.0933);
	CreateDynamicObject(1655, -2359.707764, -1412.587891, 478.398193, 0.0000, 0.0000, 5.1566);
	CreateDynamicObject(1655, -2360.356201, -1405.525513, 482.634033, 16.3293, 0.0000, 5.1566);
	CreateDynamicObject(1655, -2360.836914, -1400.028320, 488.724640, 33.5180, 0.0000, 5.1566);
	CreateDynamicObject(1655, -2361.086426, -1396.881226, 496.230530, 54.1445, 0.0000, 5.1566);
	CreateDynamicObject(1655, -2361.127930, -1396.476929, 504.540863, 73.9115, 0.0000, 5.1566);
	CreateDynamicObject(13592, -2402.928955, -1408.991089, 487.743561, 0.0000, 345.3896, 101.2500);
	CreateDynamicObject(13592, -2411.467041, -1405.442139, 488.451111, 0.0000, 345.3896, 101.2500);
	CreateDynamicObject(13592, -2420.024902, -1401.762207, 489.422729, 0.0000, 345.3896, 101.2500);
	CreateDynamicObject(1632, -2424.100098, -1402.571289, 480.352631, 339.3735, 0.0000, 6.0161);
	CreateDynamicObject(1632, -2424.633545, -1397.527954, 481.543060, 358.2811, 0.0000, 6.0161);
	CreateDynamicObject(1632, -2425.099854, -1393.022217, 484.447296, 18.9076, 0.0000, 6.0161);
	CreateDynamicObject(13831, -2433.231934, -1586.090942, 499.387695, 0.0000, 0.0000, 211.1717);
	CreateDynamicObject(13722, -2433.109131, -1585.542358, 499.367462, 0.0000, 0.0000, 211.1717);
	CreateDynamicObject(1655, -2459.956543, -1442.699219, 478.376251, 0.0000, 0.0000, 65.3172);
	CreateDynamicObject(1655, -2464.282471, -1440.722168, 481.332001, 19.7670, 0.0000, 65.3172);
	CreateDynamicObject(1655, -2468.946777, -1531.217896, 478.376251, 0.0000, 0.0000, 144.0671);
	CreateDynamicObject(1655, -2472.125488, -1535.630249, 481.632294, 17.1887, 0.0000, 144.0671);
	CreateDynamicObject(16133, -2482.744873, -1487.614624, 477.352905, 0.0000, 347.1084, 160.0784);
	CreateDynamicObject(16133, -2324.287109, -1489.340820, 475.902893, 0.0000, 347.1084, 12.2556);
	CreateDynamicObject(16133, -2386.093750, -1573.152954, 482.045532, 0.0000, 327.3414, 268.2640);
	CreateDynamicObject(16133, -2452.604004, -1400.911011, 477.399841, 0.0000, 335.0763, 112.7063);
	CreateDynamicObject(16037, -2233.225830, -1588.548096, 482.915497, 0.0000, 5.1566, 21.6406);
	CreateDynamicObject(16037, -2123.113281, -1544.881958, 461.069702, 0.0000, 15.4699, 21.6406);
	CreateDynamicObject(16037, -2016.906738, -1502.714722, 429.396118, 0.0000, 15.4699, 21.6406);
	CreateDynamicObject(3502, -2282.901123, -1660.623413, 483.176605, 0.0000, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2273.989990, -1661.890869, 483.215973, 0.0000, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2265.248535, -1663.133545, 482.867645, 354.8434, 341.9518, 260.5462);
	CreateDynamicObject(3502, -2259.701172, -1664.185181, 481.814606, 346.2490, 357.4217, 259.6868);
	CreateDynamicObject(3502, -2251.645996, -1665.360352, 479.925659, 348.8273, 0.0000, 262.2651);
	CreateDynamicObject(3502, -2244.312256, -1666.311523, 480.139709, 12.0321, 357.4217, 263.9840);
	CreateDynamicObject(3502, -2225.496338, -1668.427979, 484.032623, 6.8755, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2217.831787, -1669.223389, 484.966522, 6.8755, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2210.459961, -1670.093628, 485.823212, 6.8755, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2203.328125, -1671.063599, 486.722290, 6.8755, 0.0000, 263.1245);
	CreateDynamicObject(3502, -2197.360596, -1671.774414, 487.543762, 6.8755, 0.0000, 263.1245);
	CreateDynamicObject(3554, -2283.532959, -1660.568726, 491.427063, 0.0000, 0.0000, 82.7466);
	CreateDynamicObject(726, -2317.475586, -1523.263550, 476.748627, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2262.246338, -1687.043335, 478.717285, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(13831, -2371.499512, -1609.126221, 510.351898, 0.0000, 0.8594, 78.8274);
	CreateDynamicObject(16133, -2271.329102, -1725.697510, 467.926666, 0.0000, 347.1084, 205.0009);
	CreateDynamicObject(726, -2244.677734, -1751.020386, 479.253052, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2332.699951, -1395.800049, 476.595551, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2456.037598, -1415.987793, 478.839233, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2475.019287, -1500.015381, 483.235046, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2401.300537, -1556.422485, 476.978363, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(726, -2474.946045, -1602.279785, 476.548798, 0.0000, 0.0000, 348.8273);
	CreateDynamicObject(13641, -2296.286133, -1598.397949, 481.657684, 359.1406, 17.1887, 29.5301);
	CreateDynamicObject(1655, -2237.607178, -1732.991211, 480.597504, 1.7189, 0.8594, 210.2350);
	CreateDynamicObject(4853, -2273.502686, -1563.095215, 479.013184, 0.0000, 358.2811, 45.0000);
	CreateDynamicObject(733, -2328.628906, -1685.137939, 481.263336, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(735, -2359.962158, -1646.896484, 480.823181, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16127, -2346.484375, -1683.917969, 486.535278, 346.2490, 0.8594, 292.5000);
	CreateDynamicObject(16127, -2316.885254, -1707.428955, 485.294098, 349.6868, 0.0000, 321.7209);
	CreateDynamicObject(1655, -2287.536865, -1640.013428, 483.290405, 359.1406, 0.8594, 271.8735);
	CreateDynamicObject(1655, -2287.704346, -1631.852661, 483.343323, 359.1406, 0.0000, 270.1547);
	CreateDynamicObject(9685, -2282.945068, -1531.112549, 536.956421, 0.0000, 0.0000, 320.2340);
	CreateDynamicObject(9685, -2196.876221, -1427.748413, 545.709290, 0.0000, 0.0000, 320.2341);
	CreateDynamicObject(9685, -2110.682129, -1324.258545, 554.474060, 0.0000, 0.0000, 320.2341);
	CreateDynamicObject(1655, -1897.739380, -1056.234497, 523.446411, 0.0000, 0.0000, 321.0934);
	CreateDynamicObject(7916, -2362.495605, -1613.521729, 497.175476, 28.3614, 0.0000, 77.0311);
	CreateDynamicObject(7916, -2355.780273, -1657.320801, 495.550903, 29.2208, 359.1406, 109.0622);
	CreateDynamicObject(16127, -2363.804199, -1645.952271, 482.383606, 346.2490, 0.8594, 292.5000);
	CreateDynamicObject(16133, -2384.800537, -1575.735107, 485.205292, 350.5462, 332.4980, 254.5129);
	CreateDynamicObject(11435, -2310.024414, -1584.276733, 485.406494, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(7392, -2287.596436, -1672.066162, 491.210052, 0.0000, 0.0000, 353.1245);
	CreateDynamicObject(8483, -2354.760010, -1579.378906, 490.026672, 358.2811, 357.4217, 331.6386);
	CreateDynamicObject(13562, -2288.042236, -1654.219604, 483.428680, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16776, -2309.831787, -1695.022583, 481.263855, 0.0000, 0.0000, 135.7911);
	CreateDynamicObject(1655, -2293.263916, -1607.783081, 483.331848, 358.2811, 359.1406, 290.7811);
	CreateDynamicObject(1655, -2290.208740, -1615.830811, 483.378387, 358.2811, 0.0000, 290.7811);
	CreateDynamicObject(1655, -1746.057617, -1395.105103, 356.689148, 344.5301, 0.0000, 292.5000);
	CreateDynamicObject(1655, -1738.833496, -1392.102417, 358.864594, 0.8594, 0.0000, 292.5000);
	CreateDynamicObject(1655, -1732.128052, -1389.344116, 363.115265, 14.6104, 0.0000, 292.5000);
	CreateDynamicObject(1655, -2344.177734, -1555.536255, 479.025848, 8.5944, 0.0000, 189.4538);
	CreateDynamicObject(1655, -2340.236328, -1571.689819, 483.501282, 12.8916, 0.0000, 12.8916);
	CreateDynamicObject(10838, -2321.319336, -1576.838623, 497.207764, 359.1406, 358.2811, 48.1285);
	CreateDynamicObject(3502, -2236.016602, -1667.085815, 481.978516, 12.0321, 357.4217, 263.9840);
	CreateDynamicObject(3502, -2231.742920, -1667.539307, 483.079529, 12.0321, 357.4217, 263.9840);
	CreateDynamicObject(3502, -2189.548096, -1672.909180, 488.475128, 6.8755, 0.0000, 259.6868);
	CreateDynamicObject(3502, -2182.247803, -1674.791748, 489.424927, 6.8755, 0.0000, 249.3735);
	CreateDynamicObject(3502, -2175.396973, -1678.202148, 490.330475, 6.8755, 0.0000, 235.6225);
	CreateDynamicObject(3502, -2169.115479, -1682.439209, 490.702087, 359.1406, 1.7189, 235.6225);
	CreateDynamicObject(3502, -2162.809570, -1687.261353, 490.582703, 359.1406, 1.7189, 227.0281);
	CreateDynamicObject(3502, -2157.657715, -1693.175049, 490.435760, 359.1406, 1.7189, 212.4175);
	CreateDynamicObject(3502, -2153.705078, -1699.343628, 490.112579, 354.8434, 0.0000, 212.4175);
	CreateDynamicObject(3502, -2150.361816, -1705.594360, 489.456421, 354.8434, 0.0000, 200.3854);
	CreateDynamicObject(3502, -2148.392334, -1712.520264, 488.786682, 354.8434, 0.0000, 188.3531);
	CreateDynamicObject(3502, -2147.960449, -1719.520508, 488.138397, 354.8434, 0.0000, 176.3210);
	CreateDynamicObject(3502, -2148.934814, -1726.642578, 487.486542, 354.8434, 0.0000, 165.1482);
	CreateDynamicObject(3502, -2150.717041, -1733.483643, 486.590454, 349.6868, 0.0000, 165.1482);
	CreateDynamicObject(3502, -2153.015869, -1739.367188, 485.401703, 349.6868, 0.0000, 153.9754);
	CreateDynamicObject(3502, -2156.837158, -1745.682251, 484.070984, 349.6868, 0.0000, 141.9433);
	CreateDynamicObject(3502, -2161.273926, -1750.572876, 482.887634, 349.6868, 0.0000, 129.9110);
	CreateDynamicObject(3502, -2167.023926, -1754.297974, 481.637604, 349.6868, 0.0000, 115.3008);
	CreateDynamicObject(3502, -2173.998291, -1756.777100, 480.306000, 349.6868, 0.0000, 102.4093);
	CreateDynamicObject(3502, -2181.328125, -1757.569458, 478.920044, 349.6868, 0.0000, 87.7990);
	CreateDynamicObject(3502, -2188.537109, -1756.432861, 477.593719, 349.6868, 0.0000, 74.0482);
	CreateDynamicObject(3502, -2195.460693, -1753.232056, 476.218719, 349.6868, 0.0000, 56.0002);
	CreateDynamicObject(3502, -2201.581543, -1748.011963, 474.669128, 349.6868, 0.0000, 42.2493);
	CreateDynamicObject(3502, -2205.860840, -1742.106567, 473.359680, 349.6868, 0.0000, 27.6390);
	CreateDynamicObject(3502, -2208.186523, -1735.107544, 471.998138, 349.6868, 0.0000, 8.7316);
	CreateDynamicObject(3502, -2208.333008, -1727.435181, 470.608276, 349.6868, 0.0000, 352.4024);
	CreateDynamicObject(3502, -2206.184326, -1719.654297, 469.124237, 349.6868, 0.0000, 337.7921);
	CreateDynamicObject(3502, -2202.089355, -1713.131836, 467.796204, 349.6868, 0.0000, 318.0252);
	CreateDynamicObject(3502, -2196.138184, -1708.348267, 466.406311, 349.6868, 0.0000, 299.9772);
	CreateDynamicObject(3502, -2189.043701, -1705.487061, 465.060394, 349.6868, 0.0000, 283.6481);
	CreateDynamicObject(3502, -2181.029053, -1704.219482, 463.627960, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(3502, -2173.138916, -1703.716919, 462.158630, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(3502, -2166.241699, -1703.246948, 460.851471, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(3502, -2158.819336, -1702.773804, 459.460571, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(3502, -2151.518066, -1702.335083, 458.113007, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(3502, -2144.233887, -1701.886230, 456.762085, 349.6868, 0.0000, 273.3349);
	CreateDynamicObject(13641, -2148.504150, -1700.999390, 446.601807, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(13641, -2142.585938, -1700.974854, 446.369110, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(1655, -1810.578247, -1636.152344, 443.571930, 351.4056, 0.0000, 270.0000);
	CreateDynamicObject(1655, -1802.608643, -1636.158203, 446.361755, 2.5783, 0.0000, 270.0000);
	CreateDynamicObject(1655, -1796.575195, -1636.114624, 450.264862, 17.1887, 0.0000, 270.0000);
	CreateDynamicObject(1655, -1790.488525, -1636.095337, 456.110718, 25.7831, 0.0000, 270.0000);
	CreateDynamicObject(6986, -2349.082275, -1572.664551, 499.172119, 0.0000, 0.0000, 303.2772);
	CreateDynamicObject(2918, -1893.173462, -1063.102661, 524.188721, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -2403.692627, -1416.831543, 481.090088, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -2402.507813, -1416.592651, 481.020844, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -2404.888428, -1416.949707, 481.043274, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(16133, -2382.161377, -1605.630005, 488.946136, 0.0000, 334.2169, 136.8732);
	CreateDynamicObject(16127, -2363.821289, -1674.433594, 499.316986, 346.2490, 0.8594, 292.5000);
	CreateDynamicObject(8618, -2355.659668, -1591.174438, 499.221191, 0.0000, 0.0000, 24.9237);
	CreateDynamicObject(3715, -2287.515625, -1636.579956, 491.155884, 0.0000, 0.0000, 270.6186);
	CreateDynamicObject(1655, -2245.182129, -1737.325684, 480.616455, 1.7189, 359.1406, 209.3755);
	CreateDynamicObject(13641, -2235.341309, -1746.547974, 489.821381, 0.8594, 341.9518, 299.8395);
	CreateDynamicObject(13722, -2371.522705, -1609.125732, 510.788025, 0.0000, 0.0000, 78.8183);
	CreateDynamicObject(16133, -2391.179932, -1617.601563, 504.422729, 0.0000, 352.2651, 172.1104);
	CreateDynamicObject(10281, -2360.666748, -1667.896606, 507.080811, 0.0000, 358.2811, 116.0238);
	CreateDynamicObject(16480, -2272.725586, -1686.892090, 482.329712, 0.0000, 0.0000, 262.8837);
	CreateDynamicObject(3528, -2287.642090, -1635.914673, 496.569214, 1.7189, 0.0000, 180.3774);
	CreateDynamicObject(13667, -2224.704102, -1497.719360, 503.366241, 0.8594, 0.0000, 243.9762);
	CreateDynamicObject(9685, -2024.513794, -1220.604126, 563.332825, 0.0000, 0.0000, 320.2341);
	CreateDynamicObject(9685, -1937.978027, -1116.640747, 572.140137, 0.0000, 0.0000, 320.2341);
	CreateDynamicObject(1655, -1885.763428, -1065.629395, 523.496094, 0.0000, 0.0000, 320.2340);
	CreateDynamicObject(1655, -1893.638672, -1051.214111, 527.073120, 12.0321, 0.0000, 321.0934);
	CreateDynamicObject(1655, -1891.218994, -1048.136597, 530.248108, 21.4859, 0.0000, 321.0934);
	CreateDynamicObject(1655, -1882.046997, -1061.124023, 526.657410, 12.0321, 0.0000, 320.2340);
	CreateDynamicObject(1655, -1878.976318, -1057.240112, 530.952026, 23.2048, 0.0000, 320.2340);
	CreateDynamicObject(2918, -1814.756104, -1630.923584, 444.398956, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1814.233032, -1642.566650, 444.214264, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1814.360107, -1641.334717, 444.011475, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1814.285522, -1629.354004, 444.276611, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1751.891113, -1390.118530, 357.958679, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1751.580688, -1391.690796, 357.638977, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1748.322266, -1401.555786, 358.254395, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -1746.572998, -1402.643311, 358.207123, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(2918, -2307.165527, -1589.942871, 485.268677, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(4853, -2210.492432, -1500.054443, 481.670502, 0.0000, 358.2811, 45.0000);
	CreateDynamicObject(4853, -2150.038330, -1439.543701, 483.539093, 0.0000, 359.1406, 45.0000);
	CreateDynamicObject(4853, -2087.690430, -1377.160889, 484.828461, 0.0000, 359.1406, 45.0000);
	CreateDynamicObject(4853, -2025.604614, -1315.127563, 484.129333, 0.0000, 1.7189, 45.0000);
	CreateDynamicObject(4853, -1962.248535, -1251.777466, 481.448669, 0.0000, 1.7189, 45.0000);
	CreateDynamicObject(4853, -1904.201538, -1193.699585, 479.618042, 0.8594, 0.8594, 45.0000);
	CreateDynamicObject(1655, -1871.277100, -1160.854126, 483.567352, 4.2972, 0.0000, 313.9859);
	CreateDynamicObject(2918, -2285.191406, -1664.533203, 483.925903, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18449, -2245.029541, -1636.056641, 484.846588, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18449, -2165.407227, -1636.061401, 484.833618, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18449, -2086.046143, -1636.096313, 484.845520, 0.0000, 0.0000, 0.0000);
	CreateDynamicObject(18449, -2007.129395, -1636.095337, 477.757751, 0.0000, 10.3132, 0.0000);
	CreateDynamicObject(18449, -1929.063110, -1636.092651, 463.594421, 0.0000, 10.3132, 0.0000);
	CreateDynamicObject(18449, -1852.876831, -1636.080688, 449.734955, 0.0000, 10.3132, 0.0000);
	CreateDynamicObject(18449, -1928.735352, -1467.160767, 400.454315, 0.0000, 12.8916, 21.4859);
	CreateDynamicObject(18449, -1856.401978, -1438.663330, 382.688263, 0.0000, 12.8916, 21.4859);
	CreateDynamicObject(18449, -1784.238525, -1410.250366, 364.949280, 0.0000, 12.8916, 21.4859);
	CreateDynamicObject(1655, -2234.173096, -1738.968384, 484.516846, 11.1727, 1.7189, 210.2349);
	CreateDynamicObject(1655, -2241.746826, -1743.292236, 484.245148, 11.1727, 1.7189, 210.2349);

	//San Fierro Airport
	totalmaps++;
	CreateDynamicObject(18882,2694.92529297,-2055.54980469,498.18206787,0.00000000,0.00000000,0.00000000); //object(og_door)(5)
	CreateDynamicObject(18882,2695.39208984,-2056.81298828,498.18139648,0.00000000,0.00000000,44.25000000); //object(og_door)(6)
	CreateDynamicObject(18854,-1157.69726562,304.41015625,85.27660370,49.41650391,137.63122559,214.87609863); //object(a_vgsgymboxa)(2)
	CreateDynamicObject(18847,-1112.97656250,122.17578125,31.41416168,0.00000000,0.00000000,43.99475098); //object(genint_warehs)(1)
	CreateDynamicObject(18846,-1522.69824219,-300.96679688,9.92865181,0.00000000,0.00000000,343.99291992); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1522.69824219,-300.96679688,9.92865181,0.00000000,0.00000000,343.99291992); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18836,-1519.75585938,-245.70794678,12.41532707,348.18493652,349.78125000,191.88616943); //object(int3int_brothel03)
	CreateDynamicObject(18836,-1519.75585938,-245.70794678,12.41532707,348.18493652,349.78125000,191.88616943); //object(int3int_brothel03
	CreateDynamicObject(18786,-1157.93359375,-392.73925781,99.00852966,0.00000000,1.99951172,9.99755859); //object(steps)(1)
	CreateDynamicObject(18786,-1295.81311035,-562.36334229,15.64843750,0.00000000,3.98803711,23.98413086); //object(steps)(2)
	CreateDynamicObject(18750,-1210.14843750,-99.39062500,47.78957367,90.00000000,179.99450684,133.99475098); //object(sumoring)(1)
	CreateDynamicObject(18860,-1374.68945312,-306.86035156,75.58260345,0.00000000,0.00000000,305.99121094); //object(int_kbsgarage3b)(1)
	CreateDynamicObject(18860,-1374.68945312,-306.86035156,75.58260345,0.00000000,0.00000000,305.99121094); //object(int_kbsgarage3b)(1)
	CreateDynamicObject(18859,-1467.40136719,65.52734375,22.79420471,0.00000000,0.00000000,45.99975586); //object(int_kbsgarage05b)(1)
	CreateDynamicObject(18859,-1498.22460938,33.80371094,23.10605621,0.00000000,0.00000000,45.99975586); //object(int_kbsgarage05b)(2)
	CreateDynamicObject(18859,-1530.59545898,0.57065344,23.25201416,0.00000000,0.00000000,45.99975586); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18752,-1598.03247070,-234.45643616,-10.97603607,0.00000000,0.00000000,131.99401855); //object(genint3_smashtv)(1)
	CreateDynamicObject(18752,-1598.03247070,-234.45643616,-10.97603607,0.00000000,0.00000000,131.99401855); //object(genint3_smashtv)(1)
	CreateDynamicObject(18852,-1094.68457031,-275.37207031,32.57359314,0.00000000,67.99987793,11.98059082); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18851,-1366.33068848,-403.62994385,10.62823486,0.00000000,0.00000000,345.99792480); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18851,-1366.33068848,-403.62994385,10.62823486,0.00000000,0.00000000,345.99792480); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18835,-1338.08105469,-204.48632812,45.61994171,0.00000000,0.00000000,0.00000000); //object(int3int_low_tv)(2)
	CreateDynamicObject(18830,-1370.29882812,-243.60644531,15.72062302,0.00000000,137.99377441,205.99365234); //object(immy_clothes)(2)
	CreateDynamicObject(18825,-1321.82617188,-476.90722656,31.97656250,0.00000000,351.99096680,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18750,-1629.55859375,-80.17150116,30.51136589,90.00000000,179.99450684,225.99475098); //object(sumoring)(1)
	CreateDynamicObject(18790,-1171.48144531,-151.45703125,13.14843750,3.94958496,327.91442871,45.81298828); //object(wall2)(2)
	CreateDynamicObject(18789,-1213.50292969,-194.43652344,47.66661835,0.00000000,0.00000000,43.98925781); //object(wall1)(1)
	CreateDynamicObject(18784,-1411.46093750,-103.99511719,15.64396572,0.00000000,353.99597168,249.99389648); //object(rings)(1)
	CreateDynamicObject(18781,-1390.75109863,-111.94002533,21.70432472,0.00000000,0.00000000,153.99487305); //object(ramparse)(2)
	CreateDynamicObject(18858,-1397.28808594,-127.92500305,36.15469742,0.00000000,0.00000000,333.99975586); //object(stunt1)(1)
	CreateDynamicObject(18780,-1247.38635254,-183.47413635,24.14843750,0.00000000,0.00000000,137.99377441); //object(stunt1)(2)
	CreateDynamicObject(18779,-1225.06774902,-31.51200104,22.84501266,0.00000000,0.00000000,133.98925781); //object(tuberamp)(1)
	CreateDynamicObject(18779,-1290.89062500,-249.86425781,17.11386108,0.00000000,0.00000000,109.98416138); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1355.82519531,-242.24316406,23.14062500,0.00000000,0.00000000,45.98327637); //object(tuberamp)(3)
	CreateDynamicObject(18779,-1222.12597656,-310.88183594,17.59983444,0.00000000,0.00000000,19.98413086); //object(tuberamp)(4)
	CreateDynamicObject(18777,-1362.69653320,-495.25265503,39.04573822,0.00000000,0.00000000,117.99169922); //object(therocks10)(1)
	CreateDynamicObject(18846,-1506.11108398,-297.81857300,9.80125999,0.00000000,0.00000000,327.99291992); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1506.11108398,-297.81857300,9.80125999,0.00000000,0.00000000,327.99291992); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1413.95642090,-389.58523560,9.86258125,0.00000000,0.00000000,285.99060059); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1413.95642090,-389.58523560,9.86258125,0.00000000,0.00000000,285.99060059); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1415.43603516,-409.26766968,9.92187500,0.00000000,0.00000000,291.99060059); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1415.43603516,-409.26766968,9.92187500,0.00000000,0.00000000,291.99060059); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1301.89428711,-283.79577637,29.35937500,0.00000000,0.00000000,219.98913574); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1301.89428711,-283.79577637,29.35937500,0.00000000,0.00000000,219.98913574); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18846,-1370.17968750,-228.46548462,18.06584167,0.00000000,0.00000000,135.97924805); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1370.17968750,-228.46548462,18.06584167,0.00000000,0.00000000,135.97924805); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18779,-1281.50769043,-186.51466370,23.14062500,0.00000000,0.00000000,133.98962402); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1214.33715820,-115.90894318,23.13615417,0.00000000,0.00000000,133.98925781); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1454.43457031,-189.17382812,23.14062500,0.00000000,0.00000000,73.98925781); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1587.68652344,-51.00488281,22.94360352,0.00000000,0.00000000,287.97912598); //object(tuberamp)(2)
	CreateDynamicObject(18883,-944.31542969,281.38574219,59.75061798,0.00000000,0.00000000,45.99426270); //object(dj_stuff)(1)
	CreateDynamicObject(19001,-1269.69104004,-111.97781372,22.73705864,0.00000000,0.00000000,314.00000000); //object(clothes-spot)(1)
	CreateDynamicObject(19005,-1360.36889648,146.83792114,15.63509560,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18854,-1157.69726562,304.41015625,85.27660370,49.41650391,137.63122559,214.87609863); //object(a_vgsgymboxa)(2)
	CreateDynamicObject(19280,-1318.12500000,178.71875000,13.14843750,0.00000000,0.00000000,0.00000000); //object(des_rockgp2_04)(1)
	CreateDynamicObject(19280,-1377.88671875,-253.80468750,13.14843750,0.00000000,0.00000000,7.99804688); //object(des_rockgp2_04)(2)
	CreateDynamicObject(19005,-1268.34375000,206.91809082,16.12090302,0.00000000,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(18851,-1043.94335938,377.42773438,19.51086807,0.00000000,0.00000000,135.99426270); //object(ab_sfgymbits01a)(3)
	CreateDynamicObject(18985,-830.52539062,169.08789062,18.56834030,359.00024414,3.99902344,44.05517578); //object(munation_xtras03)(1)
	CreateDynamicObject(18985,-830.52539062,169.08789062,18.56834030,359.00024414,3.99902344,44.05517578); //object(munation_xtras03)(1)
	CreateDynamicObject(18984,-843.75415039,382.91717529,17.81826973,0.00000000,0.00000000,314.00000000); //object(range_xtras03)(1)
	CreateDynamicObject(18982,-780.07257080,444.44674683,17.63769150,0.00000000,0.00000000,313.98925781); //object(ammu_twofloor)(1)
	CreateDynamicObject(18982,-732.25494385,490.58273315,17.52691269,0.00000000,0.00000000,313.98925781); //object(ammu_twofloor)(2)
	CreateDynamicObject(18982,-682.52142334,538.54705811,17.44925880,0.00000000,0.00000000,313.98925781); //object(ammu_twofloor)(3)
	CreateDynamicObject(18982,-633.81738281,585.42089844,17.28548813,0.00000000,0.00000000,313.98925781); //object(ammu_twofloor)(4)
	CreateDynamicObject(18772,-1153.20898438,-438.09375000,93.89518738,0.00000000,0.00000000,285.99609375); //object(8screen)(1)
	CreateDynamicObject(1634,-1030.47680664,-400.20639038,93.14501953,11.00000000,0.00000000,286.00000000); //object(landjump2)(2)
	CreateDynamicObject(1634,-1029.45642090,-404.16390991,93.14501953,10.99731445,0.00000000,285.99609375); //object(landjump2)(3)
	CreateDynamicObject(1634,-1027.29248047,-399.17706299,97.18093872,30.99987793,0.00000000,285.99609375); //object(landjump2)(4)
	CreateDynamicObject(1634,-1025.06530762,-402.53826904,103.12242126,69.99938965,0.00000000,285.99609375); //object(landjump2)(5)
	CreateDynamicObject(1634,-1026.23754883,-402.86450195,97.15281677,30.99792480,0.00000000,285.99609375); //object(landjump2)(6)
	CreateDynamicObject(1634,-1025.98132324,-398.82861328,103.16699982,69.99938965,0.00000000,285.99609375); //object(landjump2)(7)
	CreateDynamicObject(18449,-1069.08203125,-372.80664062,58.26478577,0.00000000,0.00000000,11.99157715); //object(cs_roadbridge01)(1)
	CreateDynamicObject(5152,-1116.05761719,-318.62597656,12.07802391,0.00000000,0.00000000,187.99804688); //object(stuntramp1_las2)(1)
	CreateDynamicObject(5152,-1115.77148438,-320.38476562,12.07802773,0.00000000,0.00000000,187.99255371); //object(stuntramp1_las2)(2)
	CreateDynamicObject(5152,-1115.41552734,-322.34240723,12.07802582,0.00000000,0.00000000,187.99255371); //object(stuntramp1_las2)(3)
	CreateDynamicObject(5152,-1111.79199219,-321.95312500,10.44444752,0.00000000,0.00000000,187.99255371); //object(stuntramp1_las2)(4)
	CreateDynamicObject(5152,-1112.40136719,-319.86718750,10.62080956,0.00000000,0.00000000,187.99255371); //object(stuntramp1_las2)(5)
	CreateDynamicObject(5152,-1112.59082031,-317.98632812,10.59474659,0.00000000,0.00000000,187.99255371); //object(stuntramp1_las2)(6)
	CreateDynamicObject(18779,-1366.36767578,-253.39495850,44.06782532,0.00000000,43.99475098,45.97778320); //object(tuberamp)(3)
	CreateDynamicObject(18779,-1358.93249512,-245.43994141,77.08634186,0.00000000,105.99853516,45.97778320); //object(tuberamp)(2)
	CreateDynamicObject(18846,-1343.76245117,-248.08828735,18.07031250,0.00000000,0.00000000,135.97778320); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1343.76245117,-248.08828735,18.07031250,0.00000000,0.00000000,135.97778320); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18808,-1029.19531250,-262.91015625,60.26262665,0.00000000,245.99487305,7.99804688); //object(loopwee)(1)
	CreateDynamicObject(18811,-1527.92480469,-397.81445312,59.45127869,0.00000000,115.99914551,71.99890137); //object(motel_grill)(1)
	CreateDynamicObject(18778,-1256.57128906,33.63378906,14.86718750,13.99108887,0.00000000,313.98376465); //object(logramps)(3)
	CreateDynamicObject(18778,-1255.12426758,35.55209351,18.65319061,49.94952393,356.89086914,316.36462402); //object(logramps)(3)
	CreateDynamicObject(18779,-1465.15307617,-186.12583923,23.14062500,0.00000000,0.00000000,73.98742676); //object(tuberamp)(2)
	CreateDynamicObject(18449,-1483.72351074,-274.41534424,45.84572601,0.00000000,0.00000000,73.99707031); //object(cs_roadbridge01)(2)
	CreateDynamicObject(18449,-1497.91540527,-269.55847168,45.84572601,0.00000000,0.00000000,73.99291992); //object(cs_roadbridge01)(3)
	CreateDynamicObject(18449,-1511.74511719,-345.28613281,45.75353622,0.00000000,0.00000000,73.98742676); //object(cs_roadbridge01)(4)
	CreateDynamicObject(18822,-1535.86425781,-435.58593750,84.53608704,317.62023926,199.11071777,209.14672852); //object(immy_rooms2)(1)
	CreateDynamicObject(18822,-1535.86425781,-435.58593750,84.53608704,317.62023926,199.11071777,209.14672852); //object(immy_rooms2)(1)
	CreateDynamicObject(18824,-1525.07519531,-471.20410156,111.32769775,0.00000000,77.99743652,291.99462891); //object(hexi_lite)(1)
	CreateDynamicObject(1634,-1514.41406250,-492.97656250,107.67788696,0.00000000,0.00000000,201.99462891); //object(landjump2)(8)
	CreateDynamicObject(1634,-1518.09277344,-494.49121094,107.67788696,0.00000000,0.00000000,201.98913574); //object(landjump2)(9)
	CreateDynamicObject(18858,-1238.27404785,-311.10147095,30.05397797,0.00000000,0.00000000,295.99975586); //object(stunt1)(1)
	CreateDynamicObject(18800,-1090.66503906,-404.32812500,22.78746796,0.00000000,1.99707031,357.98950195); //object(stunt1)(1)
	CreateDynamicObject(18800,-1132.52502441,-403.08569336,51.53746796,0.00000000,347.99597168,177.99353027); //object(stunt1)(1)
	CreateDynamicObject(18853,-1429.69860840,144.19978333,32.22656631,0.00000000,297.99993896,289.99453735); //object(stunt1)(1)
	CreateDynamicObject(18779,-1019.04687500,-355.87695312,67.80233765,0.00000000,0.00000000,191.98059082); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1004.59490967,-352.83352661,87.30233765,0.00000000,42.00000000,191.98059082); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1004.59472656,-352.83300781,105.80233765,0.00000000,77.99526978,191.97509766); //object(tuberamp)(2)
	CreateDynamicObject(18779,-1233.10351562,-488.84277344,58.03685760,0.00000000,353.99047852,107.97363281); //object(tuberamp)(2)
	CreateDynamicObject(18449,-1051.66796875,-369.92459106,96.16477966,0.00000000,0.00000000,191.99707031); //object(cs_roadbridge01)(1)
	CreateDynamicObject(18449,-1051.66796875,-369.92459106,96.16477966,0.00000000,0.00000000,191.99707031); //object(cs_roadbridge01)(1)
	CreateDynamicObject(18449,-1126.26892090,-385.81326294,96.16477966,0.00000000,0.00000000,191.99707031); //object(cs_roadbridge01)(1)
	CreateDynamicObject(18449,-1126.26892090,-385.81326294,96.16477966,0.00000000,0.00000000,191.99707031); //object(cs_roadbridge01)(1)
	CreateDynamicObject(18786,-1167.29638672,-394.43090820,104.00852966,0.00000000,21.99951172,9.99755859); //object(steps)(1)
	CreateDynamicObject(18801,-1615.03906250,-122.44921875,35.50605774,2.03796387,0.00000000,238.03527832); //object(8bar5)(1)
	CreateDynamicObject(18772,-910.60302734,-257.91079712,139.67608643,323.79248047,347.57214355,91.43652344); //object(8screen)(1)
	CreateDynamicObject(18779,-1226.53222656,-300.64550781,17.59983635,0.00000000,0.00000000,19.97314453); //object(tuberamp)(4)
	CreateDynamicObject(18858,-1242.80273438,-300.33593750,30.48917580,0.00000000,0.00000000,293.99414062); //object(stunt1)(1)
	CreateDynamicObject(18843,-1472.63671875,256.49902344,110.57738495,0.00000000,283.99658203,293.99414062); //object(stunt1)(1)
	CreateDynamicObject(18836,-1447.05139160,194.23545837,79.20486450,47.12796021,5.88479614,16.95925903); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18822,-1164.55664062,-669.02343750,79.31476593,77.21740723,38.97949219,7.71240234); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18779,-1297.21777344,-351.67749023,17.59983444,0.00000000,0.00000000,283.98413086); //object(tuberamp)(4)
	CreateDynamicObject(18779,-1286.59765625,-348.87158203,17.59983444,0.00000000,4.00000000,283.97460938); //object(tuberamp)(4)
	CreateDynamicObject(18779,-1289.35192871,-337.32739258,34.84983444,0.00000000,45.99478149,283.97460938); //object(tuberamp)(4)
	CreateDynamicObject(18779,-1300.42712402,-338.86871338,34.84983444,0.00000000,45.98925781,283.96911621); //object(tuberamp)(4)
	CreateDynamicObject(18779,-1289.84814453,-337.76397705,51.84983444,0.00000000,90.00000000,283.96899414); //object(tuberamp)(4)
	CreateDynamicObject(18779,-1300.20581055,-339.33111572,51.84983444,0.00000000,88.00000000,283.97463989); //object(tuberamp)(4)
	CreateDynamicObject(18789,-1262.93103027,-420.16659546,50.44444656,0.00000000,0.00000000,107.99011230); //object(wall1)(1)
	CreateDynamicObject(18789,-1204.34655762,-585.76275635,69.64444733,0.00000000,0.00000000,109.99011230); //object(wall1)(1)
	CreateDynamicObject(18822,-1122.89843750,-680.49224854,84.81476593,81.06036377,63.59106445,36.67962646); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18822,-1122.89843750,-680.49224854,84.81476593,81.06036377,63.59106445,36.67962646); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18825,-1101.46704102,-656.30145264,88.20033264,81.05712891,63.58886719,150.67785645); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18825,-1101.46704102,-656.30145264,88.20033264,81.05712891,63.58886719,150.67785645); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18832,-1119.94238281,-614.31701660,86.29750824,79.23855591,291.60943604,94.02673340); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18832,-1119.94238281,-614.31701660,86.29750824,79.23855591,291.60943604,94.02673340); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18786,-1185.95678711,-494.89572144,15.81397629,0.00000000,1.99951172,137.97094727); //object(tuberamp)(4)
	CreateDynamicObject(18786,-1176.46948242,-503.22460938,22.81397629,0.00000000,25.99951172,137.96630859); //object(tuberamp)(4)
	CreateDynamicObject(18786,-1169.80920410,-509.03866577,32.81397629,0.00000000,43.99914551,137.96081543); //object(tuberamp)(4)
	CreateDynamicObject(18786,-1167.35205078,-510.83215332,42.31397629,0.00000000,69.99475098,137.96081543); //object(tuberamp)(4)
	CreateDynamicObject(18786,-1168.19140625,-509.90597534,56.56397629,0.00000000,91.99996948,137.96081543); //object(tuberamp)(4)
	CreateDynamicObject(18786,-1171.25659180,-507.74554443,62.56397629,0.00000000,111.99951172,137.96084595); //object(tuberamp)(4)
	CreateDynamicObject(18750,-1638.22912598,-773.21728516,89.88240814,87.17102051,314.97253418,206.98059082); //object(steps)(2)
	CreateDynamicObject(18786,-1305.83544922,-566.89178467,21.79863167,0.00000000,27.99462891,23.98413086); //object(steps)(2)
	CreateDynamicObject(18784,-1415.17675781,-114.08300781,21.64396667,1.69189453,327.97485352,251.05957031); //object(rings)(1)
	CreateDynamicObject(18842,-1446.81860352,-558.51989746,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18825,-1308.58190918,-469.58474731,66.70321655,1.96957397,169.99414062,30.33419800); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18786,-1380.25573730,-598.71276855,15.64843750,0.00000000,3.98803711,201.98913574); //object(steps)(2)
	CreateDynamicObject(18851,-1339.99731445,-488.55654907,82.29850006,0.00000000,0.00000000,209.99792480); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18851,-1339.99731445,-488.55654907,82.29850006,0.00000000,0.00000000,209.99792480); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18851,-1415.09863281,-537.97729492,88.47952271,0.00000000,0.00000000,213.99267578); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18851,-1415.09863281,-537.97729492,88.47952271,0.00000000,0.00000000,213.99267578); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18819,-1374.90100098,-510.83203125,83.54574585,278.24584961,165.88018799,110.00704956); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18819,-1374.90100098,-510.83203125,83.54574585,278.24584961,165.88018799,110.00704956); //object(im_mtel_sckts)(1
	CreateDynamicObject(18829,-1401.49218750,-469.97177124,85.23211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1401.49218750,-469.97177124,85.23211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1427.46679688,-428.44177246,86.98211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1427.46679688,-428.44177246,86.98211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1453.38134766,-386.83666992,88.73211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1453.38134766,-386.83666992,88.73211670,0.00000000,267.99499512,121.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1476.60681152,-349.78652954,90.23211670,0.00000000,267.99499512,121.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18829,-1476.60681152,-349.78652954,90.23211670,0.00000000,267.99499512,121.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1483.29394531,-581.02832031,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1522.52905273,-605.65319824,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1547.34765625,-621.15142822,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1588.43432617,-646.90954590,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1630.01721191,-672.67889404,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1670.83642578,-698.36029053,86.44288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18841,-1700.77221680,-717.30474854,100.77101135,0.00241089,351.99993896,31.98455811); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18841,-1700.77221680,-717.30474854,100.77101135,0.00241089,351.99993896,31.98455811); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1672.80200195,-700.24896240,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1672.80200195,-700.24896240,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1631.56701660,-674.38684082,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1631.56701660,-674.38684082,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1590.42553711,-648.77368164,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1590.42553711,-648.77368164,117.94288635,0.00000000,270.00000000,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18855,-1272.13085938,-620.49121094,79.45681000,87.17102051,314.97253418,166.97021484); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18855,-1272.13085938,-620.49121094,79.45681000,87.17102051,314.97253418,166.97021484); //object(ab_sfgymbits01a)(
	CreateDynamicObject(18841,-1280.25524902,-576.65106201,81.83418274,87.17102051,314.97802734,344.97070312); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18841,-1280.25524902,-576.65106201,81.83418274,87.17102051,314.97802734,344.97070312); //object(ab_sfgymbits01a)(
	CreateDynamicObject(18846,-1300.49011230,-350.10644531,18.07031250,0.00000000,0.00000000,27.98547363); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1300.49011230,-350.10644531,18.07031250,0.00000000,0.00000000,27.98547363); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1272.20910645,-345.16412354,18.07031250,0.00000000,0.00000000,5.98217773); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1272.20910645,-345.16412354,18.07031250,0.00000000,0.00000000,5.98217773); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1194.76721191,-122.97599792,30.69172287,0.00000000,0.00000000,309.98120117); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1194.76721191,-122.97599792,30.69172287,0.00000000,0.00000000,309.98120117); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18846,-1339.94824219,-428.24954224,17.90200615,0.00000000,0.00000000,95.97570801); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1339.94824219,-428.24954224,17.90200615,0.00000000,0.00000000,95.97570801); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18780,-1343.17871094,-99.57812500,24.89843750,0.00000000,0.00000000,315.98876953); //object(stunt1)(2)
	CreateDynamicObject(18780,-1336.24658203,-92.85594177,24.89843750,0.00000000,0.00000000,315.98876953); //object(stunt1)(2)
	CreateDynamicObject(18780,-1241.25866699,-175.89036560,24.14843750,0.00000000,0.00000000,137.99377441); //object(stunt1)(2)
	CreateDynamicObject(19005,-1351.63732910,138.43815613,15.63509560,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1343.16333008,130.27175903,15.63509560,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1351.18884277,156.26707458,24.63509560,18.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1342.28515625,147.68041992,24.63509560,17.99560547,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1333.90710449,139.68431091,24.63509560,17.99560547,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1328.33825684,144.84477234,33.13509369,31.99560547,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1336.80786133,153.18148804,33.13509369,31.99218750,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1345.71093750,161.76684570,33.13509369,31.99218750,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18985,-1530.53027344,-611.21105957,118.37825775,359.00024414,3.99902344,122.05517578); //object(munation_xtras03)
	CreateDynamicObject(18985,-1530.53027344,-611.21105957,118.37825775,359.00024414,3.99902344,122.05517578); //object(munation_xtras03)
	CreateDynamicObject(18985,-1480.70837402,-580.09210205,119.37825775,358.99475098,3.99353027,122.05261230); //object(munation_xtras03)
	CreateDynamicObject(18985,-1480.70837402,-580.09210205,119.37825775,358.99475098,3.99353027,122.05261230); //object(munation_xtras03)
	CreateDynamicObject(18781,-1378.14160156,-170.60839844,23.67826843,0.00000000,0.00000000,65.98937988); //object(ramparse)(2)
	CreateDynamicObject(18789,-1491.00000000,-123.41601562,40.19444656,0.00000000,0.00000000,157.98889160); //object(wall1)(1)
	CreateDynamicObject(18772,-1589.23852539,-82.49005127,51.50519562,356.00000000,0.00000000,247.99609375); //object(8screen)(1)
	CreateDynamicObject(18772,-1024.28161621,-144.27127075,58.13439941,339.99047852,0.00000000,115.99438477); //object(8screen)(1)
	CreateDynamicObject(18772,-1795.53247070,0.96421748,66.81519318,355.99548340,0.00000000,247.99438477); //object(8screen)(1)
	CreateDynamicObject(19005,-1921.55541992,51.83615112,75.68353271,0.00000000,0.00000000,67.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1935.24230957,57.47824860,84.18353271,14.00000000,0.00000000,67.98889160); //object(gap_window)(1)
	CreateDynamicObject(19005,-1945.58874512,61.96181488,96.43353271,33.99658203,0.00000000,67.98889160); //object(gap_window)(1)
	CreateDynamicObject(19005,-1952.49829102,64.87590027,115.18353271,53.99169922,0.00000000,67.98889160); //object(gap_window)(1)
	CreateDynamicObject(19005,-1953.47656250,65.19904327,134.43353271,71.98681641,0.00000000,67.98889160); //object(gap_window)(1)
	CreateDynamicObject(19005,-1950.11865234,63.95849228,147.18353271,84.01980591,180.00000000,247.98889160); //object(gap_window)(1)
	CreateDynamicObject(18649,-1397.60974121,72.79566193,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(19005,-1276.85437012,215.08377075,16.12090302,0.00000000,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1285.75305176,223.56320190,16.12090302,0.00000000,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1298.46850586,210.42852783,27.50148392,15.99609375,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1289.86791992,202.10229492,27.50148392,15.99060059,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1281.23803711,193.72827148,27.50148392,15.99060059,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1288.78112793,186.05474854,38.50148392,27.99316406,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1297.44226074,194.46286011,38.50148392,27.99316406,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(19005,-1306.07775879,202.84268188,38.50148392,27.99316406,0.00000000,135.99426270); //object(gap_window)(1)
	CreateDynamicObject(18649,-1383.35656738,87.08313751,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1400.26452637,93.05411530,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1422.89685059,70.36574554,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1445.47204590,47.70878983,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1455.85949707,15.12551117,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1496.89599609,-4.16026306,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18649,-1384.63391113,130.23144531,13.17187500,0.00000000,0.00000000,315.98876953); //object(gap_window)(1)
	CreateDynamicObject(18780,-1550.24462891,-176.05238342,24.89396667,0.00000000,0.00000000,223.98876953); //object(stunt1)(2)
	CreateDynamicObject(18780,-1543.95898438,-182.51074219,24.89396667,0.00000000,0.00000000,223.98376465); //object(stunt1)(2)
	CreateDynamicObject(18780,-1651.81396484,-287.57513428,24.89396667,0.00000000,0.00000000,41.98376465); //object(stunt1)(2)
	CreateDynamicObject(18780,-1657.77282715,-280.78961182,24.89396667,0.00000000,0.00000000,41.97875977); //object(stunt1)(2)
	CreateDynamicObject(10819,-1825.01062012,-461.34741211,-0.75000000,0.00000000,0.00000000,147.98645020); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1825.01062012,-461.34741211,-0.75000000,0.00000000,0.00000000,147.98645020); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1795.19042969,-385.69628906,-0.75000000,0.00000000,0.00000000,117.97875977); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1795.19042969,-385.69628906,-0.75000000,0.00000000,0.00000000,117.97875977); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1737.76318359,-299.12298584,-0.75000000,0.00000000,0.00000000,137.98278809); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1737.76318359,-299.12298584,-0.75000000,0.00000000,0.00000000,137.98278809); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1731.00390625,-820.77734375,-0.50000000,0.00000000,0.00000000,147.98583984); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1731.00390625,-820.77734375,-0.50000000,0.00000000,0.00000000,147.98583984); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1477.54785156,-870.65527344,-0.50000000,0.00000000,0.00000000,183.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1477.54785156,-870.65527344,-0.50000000,0.00000000,0.00000000,183.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1271.33496094,-861.85058594,-0.50000000,0.00000000,0.00000000,183.97705078); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1271.33496094,-861.85058594,-0.50000000,0.00000000,0.00000000,183.97705078); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1114.67077637,-617.48431396,-0.50000000,0.00000000,0.00000000,299.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(10819,-1114.67077637,-617.48431396,-0.50000000,0.00000000,0.00000000,299.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18833,-1096.68457031,-324.02441406,23.68115044,316.83471680,99.51416016,191.74987793); //object(int3int_kbsgarage)
	CreateDynamicObject(18833,-1096.68457031,-324.02441406,23.68115044,316.83471680,99.51416016,191.74987793); //object(int3int_kbsgarage)
	CreateDynamicObject(18833,-1053.15393066,-311.07583618,22.18115044,318.10864258,75.09042358,198.24420166); //object(int3int_kbsgarage)
	CreateDynamicObject(18833,-1053.15393066,-311.07583618,22.18115044,318.10864258,75.09042358,198.24420166); //object(int3int_kbsgarage)
	CreateDynamicObject(18834,-1033.18847656,-276.01556396,10.44923401,312.34802246,240.77001953,96.85659790); //object(int3int_kbsgarage)
	CreateDynamicObject(18834,-1033.18847656,-276.01556396,10.44923401,312.34802246,240.77001953,96.85659790); //object(int3int_kbsgarage)
	CreateDynamicObject(18842,-1069.36145020,-283.80133057,35.25551605,0.00000000,293.99996948,31.98672485); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1108.90380859,-308.37710571,51.32551575,0.00000000,283.99963379,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1146.31616211,-331.83184814,62.32551575,0.00000000,283.99658203,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1184.73828125,-355.91796875,73.57551575,0.00000000,283.99658203,31.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18772,-1013.45477295,-172.69305420,57.97374725,339.98840332,0.00000000,109.99359131); //object(8screen)(1)
	CreateDynamicObject(18772,-819.14300537,-44.36500931,141.17623901,339.98840332,0.00000000,115.99362183); //object(8screen)(1)
	CreateDynamicObject(18772,-652.22839355,36.91828537,208.76651001,339.98840332,0.00000000,115.99365234); //object(8screen)(1)
	CreateDynamicObject(18772,-444.29830933,138.37698364,292.97689819,339.98840332,0.00000000,115.99362183); //object(8screen)(1)
	CreateDynamicObject(974,-341.08435059,190.51252747,335.20364380,339.98840332,0.00000000,115.99362183); //object(8screen)(1)
	CreateDynamicObject(974,-339.45190430,187.56842041,335.26809692,339.98840332,0.00000000,115.99365234); //object(8screen)(1)
	CreateDynamicObject(18779,-1139.87695312,-206.35345459,17.59983635,0.00000000,0.00000000,23.97766113); //object(tuberamp)(4)
	CreateDynamicObject(18772,-800.46478271,-95.22404480,140.51374817,339.98840332,0.00000000,109.98962402); //object(8screen)(1)
	CreateDynamicObject(18772,-582.73370361,-15.78168106,224.89418030,339.98840332,0.00000000,109.98962402); //object(8screen)(1)
	CreateDynamicObject(18772,-372.85842896,60.88378143,306.24456787,339.98840332,0.00000000,109.98962402); //object(8screen)(1)
	CreateDynamicObject(974,-266.19131470,101.50260925,347.92642212,339.98840332,0.00000000,109.98962402); //object(8screen)(1)
	CreateDynamicObject(974,-265.24771118,97.95956421,347.80825806,339.98840332,0.00000000,109.98962402); //object(8screen)(1)
	CreateDynamicObject(18784,-1142.91357422,-220.49822998,15.64396572,0.00000000,353.99597168,205.99389648); //object(rings)(1)
	CreateDynamicObject(18784,-1148.55151367,-222.96446228,18.22396851,0.00000000,325.99597168,205.99362183); //object(rings)(1)
	CreateDynamicObject(18844,-1127.42480469,366.75878906,90.20124817,1.99401855,183.99353027,63.83056641); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18844,-1127.42480469,366.75878906,90.20124817,1.99401855,183.99353027,63.83056641); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18780,-1151.19213867,343.05984497,13.14583969,0.00000000,0.00000000,45.98364258); //object(stunt1)(2)
	CreateDynamicObject(18845,-1593.63012695,-507.10739136,60.39492035,0.00000000,0.00000000,312.00000000); //object(des_rockgp2_04)(1)
	CreateDynamicObject(1660,-1586.80395508,-514.14923096,18.09375000,0.00000000,0.00000000,43.99523926); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1589.92773438,-517.26147461,21.11718750,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1583.81127930,-514.52996826,21.11718750,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1577.23559570,-521.11621094,21.10763550,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1582.73132324,-526.07257080,21.11718750,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1572.78186035,-536.15960693,20.69807053,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1567.95654297,-530.53466797,20.71486855,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1521.04235840,-577.18383789,13.17187500,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1526.19616699,-582.45953369,13.17187500,0.00000000,0.00000000,43.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1309.23791504,-567.35937500,13.17187500,0.00000000,0.00000000,109.99475098); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1315.63891602,-549.05316162,13.17187500,0.00000000,0.00000000,109.98962402); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1310.38500977,-472.01141357,13.18894196,0.00000000,0.00000000,127.98962402); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1312.71789551,-468.95962524,13.18024826,0.00000000,0.00000000,117.98522949); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1338.73254395,-414.04565430,13.17187500,0.00000000,0.00000000,79.98217773); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1336.99865723,-404.24786377,13.07051468,0.00000000,0.00000000,79.98046875); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1122.06494141,-217.59446716,13.17187500,0.00000000,0.00000000,109.98046875); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1131.98681641,-191.05862427,13.16740322,0.00000000,0.00000000,115.97863770); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1150.85156250,350.43557739,13.27343750,0.00000000,0.00000000,137.97717285); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1158.46594238,341.83850098,13.27343750,0.00000000,0.00000000,137.97180176); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1143.64025879,343.97479248,13.27343750,0.00000000,0.00000000,133.97180176); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1151.36450195,336.27676392,13.27343750,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1165.43298340,334.59274292,13.27343750,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1159.07910156,326.89202881,13.27343750,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1192.09814453,300.94406128,13.17187500,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1234.00354004,258.51928711,13.17187500,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1363.91906738,128.37840271,13.16432571,0.00000000,0.00000000,133.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1358.63952637,-64.37520599,13.16963005,0.00000000,0.00000000,225.96728516); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1372.27514648,-78.28967285,13.17187500,0.00000000,0.00000000,225.96679688); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1228.15380859,-207.22709656,13.16740322,0.00000000,0.00000000,225.96679688); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18647,-1215.59204102,-192.78872681,13.17187500,0.00000000,0.00000000,225.96679688); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18809,-1199.08544922,-65.59642029,40.52127457,316.83471680,99.51419067,143.74987793); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1199.08544922,-65.59642029,40.52127457,316.83471680,99.51419067,143.74987793); //object(int3int_kbsgarage)
	CreateDynamicObject(18779,-1215.74841309,-382.95443726,86.13982391,358.01095581,6.00363159,34.18225098); //object(tuberamp)(4)
	CreateDynamicObject(18818,-1168.87792969,-93.37617493,44.78562164,274.00524902,0.01174927,227.99121094); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18818,-1168.87792969,-93.37617493,44.78562164,274.00524902,0.01174927,227.99121094); //object(int3int_kbsgarage)(
	CreateDynamicObject(18809,-1128.95874023,-64.75939941,47.57688141,316.83471680,99.51419067,227.74511719); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1128.95874023,-64.75939941,47.57688141,316.83471680,99.51419067,227.74511719); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1088.39208984,-43.37009048,49.41281891,283.39514160,116.16491699,26.77099609); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1088.39208984,-43.37009048,49.41281891,283.39514160,116.16491699,26.77099609); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1057.16027832,-68.11392975,44.91281891,283.39233398,116.16394043,306.76818848); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1057.16027832,-68.11392975,44.91281891,283.39233398,116.16394043,306.76818848); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1020.34790039,-145.13264465,34.67282104,283.38684082,116.16394043,256.76574707); //object(int3int_kbsgarage)
	CreateDynamicObject(18824,-1020.34790039,-145.13264465,34.67282104,283.38684082,116.16394043,256.76574707); //object(int3int_kbsgarage
	CreateDynamicObject(18809,-1075.89855957,-105.94364929,40.57014084,61.94729614,273.36614990,217.95996094); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1075.89855957,-105.94364929,40.57014084,61.94729614,273.36614990,217.95996094); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1113.84948730,-138.79463196,39.07014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1113.84948730,-138.79463196,39.07014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1151.57043457,-171.63104248,37.57014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1151.57043457,-171.63104248,37.57014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1189.51782227,-203.92825317,36.07014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1189.51782227,-203.92825317,36.07014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1226.82287598,-236.48599243,34.82014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1226.82287598,-236.48599243,34.82014084,61.94641113,273.36181641,217.95776367); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1265.99877930,-268.68286133,30.89014053,61.02023315,284.30047607,205.52038574); //object(int3int_kbsgarage)
	CreateDynamicObject(18809,-1265.99877930,-268.68286133,30.89014053,61.02023315,284.30047607,205.52038574); //object(int3int_kbsgarage)
	CreateDynamicObject(18842,-1267.30187988,-209.78088379,56.44854736,356.29705811,208.06378174,309.74511719); //object(int3int_kbsgarage)
	CreateDynamicObject(18842,-1267.30187988,-209.78088379,56.44854736,356.29705811,208.06378174,309.74511719); //object(int3int_kbsgarage
	CreateDynamicObject(18842,-1239.79516602,-239.74876404,81.95854187,359.85321045,268.00061035,311.96624756); //object(int3int_kbsgarage)
	CreateDynamicObject(18842,-1239.79516602,-239.74876404,81.95854187,359.85321045,268.00061035,311.96624756); //object(int3int_kbsgarage
	CreateDynamicObject(18842,-1211.31811523,-271.58743286,83.45854187,359.85168457,268.00048828,311.96228027); //object(int3int_kbsgarage)
	CreateDynamicObject(18842,-1211.31811523,-271.58743286,83.45854187,359.85168457,268.00048828,311.96228027); //object(int3int_kbsgarage
	CreateDynamicObject(18789,-1351.03479004,-18.31754684,50.46585464,0.00000000,0.00000000,223.98889160); //object(wall1)(1)
	CreateDynamicObject(18784,-1295.82373047,37.44159698,15.64843750,0.00000000,0.00000000,44.00000000); //object(rings)(1)
	CreateDynamicObject(18784,-1289.41967773,43.44236755,22.38843536,0.00000000,326.00000000,43.99475098); //object(rings)(1)
	CreateDynamicObject(18784,-1284.54223633,48.21295929,36.63843536,0.00000000,295.99996948,43.98922729); //object(rings)(1)
	CreateDynamicObject(18784,-1283.72534180,48.79548645,47.88843536,0.00000000,281.99996948,43.98370361); //object(rings)(1)
	CreateDynamicObject(18784,-1285.63500977,47.18260193,59.63843536,0.00000000,264.00000000,43.97827148); //object(rings)(1)
	CreateDynamicObject(18852,-1429.97265625,-95.02275085,55.64669800,0.00000000,270.00000000,44.00000000); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18852,-1493.09741211,-155.97154236,55.64669800,0.00000000,270.00000000,43.99475098); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18852,-1518.07409668,-180.25057983,55.64669800,0.00000000,270.00000000,43.99475098); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(1634,-1554.88757324,-215.96212769,52.02216339,3.99755859,357.99511719,132.12353516); //object(stunt1)(2)
	CreateDynamicObject(1634,-1558.93115234,-219.69012451,56.27216339,19.98327637,357.87167358,132.70953369); //object(stunt1)(2)
	CreateDynamicObject(18852,-1158.43395996,-675.70800781,96.59208679,0.00000000,100.00000000,34.00000000); //object(ab_sfgymmain1)(2)
	CreateDynamicObject(18785,-1321.81665039,-451.87707520,15.64843750,0.00000000,0.00000000,302.00000000); //object(logramps02)(1)
	CreateDynamicObject(18785,-1331.77856445,-457.63775635,20.14843750,342.00000000,0.00000000,298.00000000); //object(logramps02)(2)
	CreateDynamicObject(18785,-1346.52355957,-465.48086548,30.52843475,341.99890137,0.00000000,297.99865723); //object(logramps02)(3)
	CreateDynamicObject(18785,-1363.54260254,-474.52667236,36.27843475,11.99890137,0.00000000,297.99871826); //object(logramps02)(4)
	CreateDynamicObject(18805,-1137.04089355,-457.73672485,17.46572876,0.00000000,335.99993896,348.00000000); //object(dirtfences)(1)
	CreateDynamicObject(18805,-1014.08422852,-486.42324829,58.05572510,0.00000000,349.99493408,345.99743652); //object(dirtfences)(4)
	CreateDynamicObject(18855,-909.97943115,-474.99789429,73.46741486,85.86038208,255.08843994,279.88183594); //object(ab_vgsgymbits01a)(1)
	CreateDynamicObject(18855,-909.97943115,-474.99789429,73.46741486,85.86038208,255.08843994,279.88183594); //object(ab_vgsgymbits01a)(
	CreateDynamicObject(18852,-963.79907227,-306.02691650,72.82263947,0.00000000,268.00000000,348.00000000); //object(ab_sfgymmain1)(3)
	CreateDynamicObject(18841,-945.11798096,-424.50366211,76.49057007,81.90936279,98.55737305,258.14624023); //object(int_boxing02)(1)
	CreateDynamicObject(18841,-922.13537598,-395.07843018,76.49057007,81.90856934,98.55288696,72.14575195); //object(int_boxing02)(2)
	CreateDynamicObject(18841,-935.78363037,-360.92211914,76.49057007,81.90856934,98.55288696,252.14172363); //object(int_boxing02)(3)
	CreateDynamicObject(18841,-911.13763428,-334.05377197,76.49057007,81.90856934,98.55285645,66.13623047); //object(int_boxing02)(4)
	CreateDynamicObject(18852,-1058.73242188,-285.84478760,69.32263947,0.00000000,267.99499512,347.99743652); //object(ab_sfgymmain1)(4)
	CreateDynamicObject(18852,-1058.73242188,-285.84478760,69.32263947,0.00000000,267.99499512,347.99743652); //object(ab_sfgymmain1)(4)
	CreateDynamicObject(16401,-1104.54394531,-275.78808594,62.75580978,0.00000000,0.00000000,165.99792480); //object(desn2_peckjump)(1)
	CreateDynamicObject(18822,-1222.82934570,-709.99713135,104.56476593,85.52740479,63.45394897,36.60681152); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18822,-1222.82934570,-709.99713135,104.56476593,85.52740479,63.45394897,36.60681152); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18853,-1295.70397949,-699.14788818,102.34586334,85.52307129,63.45153809,0.60644531); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18853,-1295.70397949,-699.14788818,102.34586334,85.52307129,63.45153809,0.60644531); //object(des_rockgp2_04)(1)
	CreateDynamicObject(18852,-1340.59082031,-567.92089844,81.16615295,87.17102051,314.97253418,254.97070312); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18852,-1340.59082031,-567.92089844,81.16615295,87.17102051,314.97253418,254.97070312); //object(ab_sfgymbits01a)(
	CreateDynamicObject(18841,-1246.13183594,-536.42297363,63.54665375,87.17102051,314.97253418,308.97021484); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18841,-1246.13183594,-536.42297363,63.54665375,87.17102051,314.97253418,308.97021484); //object(ab_sfgymbits01a)(
	CreateDynamicObject(18841,-1284.69470215,-602.29400635,97.83418274,3.98999023,355.98950195,110.26330566); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18841,-1284.69470215,-602.29400635,97.83418274,3.98999023,355.98950195,110.26330566); //object(ab_sfgymbits01a)(1
	CreateDynamicObject(18852,-1305.30664062,-547.30480957,116.03614807,87.17102051,314.97253418,246.97070312); //object(ab_sfgymbits01a)
	CreateDynamicObject(18852,-1305.30664062,-547.30480957,116.03614807,87.17102051,314.97253418,246.97070312); //object(ab_sfgymbits01a)
	CreateDynamicObject(18852,-1328.26611328,-490.49081421,118.28614807,87.17102051,314.97253418,246.96716309); //object(ab_sfgymbits01a)
	CreateDynamicObject(18852,-1328.26611328,-490.49081421,118.28614807,87.17102051,314.97253418,246.96716309); //object(ab_sfgymbits01a)
	CreateDynamicObject(18844,-1361.78259277,-397.88842773,124.97569275,0.20867920,264.00360107,107.98181152); //object(int3int_kbsgarage)
	CreateDynamicObject(18844,-1361.78259277,-397.88842773,124.97569275,0.20867920,264.00360107,107.98181152); //object(int3int_kbsgarage)
	CreateDynamicObject(18843,-1510.61816406,-287.17300415,103.89883423,0.00000000,285.99658203,297.99414062); //object(stunt1)(1)
	CreateDynamicObject(18821,-1283.03918457,-290.99884033,46.81027603,0.00000000,301.99572754,107.99710083); //object(immy_curtains02)(1)
	CreateDynamicObject(18821,-1283.03918457,-290.99884033,46.81027603,0.00000000,301.99572754,107.99710083); //object(immy_curtains02)(1
	CreateDynamicObject(18994,-794.53326416,130.96403503,14.00226212,358.99777222,359.99844360,125.98513794); //object(munation_xtras03)(1)
	CreateDynamicObject(18994,-794.53326416,130.96403503,14.00226212,358.99777222,359.99844360,125.98513794); //object(munation_xtras03)(
	CreateDynamicObject(19005,-602.03417969,615.08789062,9.35534286,0.00000000,0.00000000,335.99487305); //object(munation_xtras03)(1)
	CreateDynamicObject(19005,-594.32324219,632.75439453,9.35534286,0.00000000,0.00000000,155.99487305); //object(munation_xtras03)(1)
	CreateDynamicObject(18789,-1280.70239258,-258.19812012,47.66661835,0.00000000,0.00000000,43.98925781); //object(wall1)(1)
	CreateDynamicObject(18825,-1331.89929199,-307.18368530,68.74201202,0.00000000,0.00000000,44.00000000); //object(im_mtel_sckts)(2)
	CreateDynamicObject(18852,-1290.26770020,-264.34921265,88.08591461,0.00000000,85.99993896,45.98059082); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18824,-1249.63220215,-206.39904785,93.89344788,276.30261230,180.00012207,358.30261230); //object(hexi_lite)(2)
	CreateDynamicObject(18825,-1261.70275879,-176.14985657,112.25396729,0.00000000,0.00000000,313.99475098); //object(im_mtel_sckts)(3)
	CreateDynamicObject(18852,-1223.15490723,-220.96829224,131.41590881,0.00000000,85.99548340,309.97778320); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18852,-1223.15490723,-220.96829224,131.41590881,0.00000000,85.99548340,309.97778320); //object(ab_sfgymmain1)(1)
	CreateDynamicObject(18824,-1186.07360840,-281.91903687,132.43344116,276.30065918,180.00000000,358.29711914); //object(hexi_lite)(3)
	CreateDynamicObject(18842,-1210.03674316,-321.59832764,126.68518066,0.00000000,262.00000000,43.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(18842,-1210.03674316,-321.59832764,126.68518066,0.00000000,262.00000000,43.98669434); //object(im_mtel_sckts)(1)
	CreateDynamicObject(16401,-1226.88415527,-337.59442139,119.01322174,0.00000000,0.00000000,223.99792480); //object(desn2_peckjump)(1)
	CreateDynamicObject(16401,-1226.88415527,-337.59442139,119.01322174,0.00000000,0.00000000,223.99792480); //object(desn2_peckjump)(1)
	CreateDynamicObject(18772,-1485.16357422,-527.94976807,65.16519165,0.00000000,0.00000000,293.99609375); //object(8screen)(1)
	CreateDynamicObject(18785,-1720.40954590,-686.72241211,16.68750000,0.00000000,0.00000000,330.00000000); //object(logramps02)(5)
	CreateDynamicObject(3080,-1598.65686035,-580.54870605,63.96530533,4.00000000,0.00000000,113.99996948); //object(ad_jump)(1)
	CreateDynamicObject(3080,-1600.22912598,-577.14392090,63.96530533,3.99902344,0.00000000,113.99963379); //object(ad_jump)(4)
	CreateDynamicObject(18778,-1722.22399902,-660.73986816,14.40625000,6.00000000,0.00000000,100.00000000); //object(logramps)(2)
	CreateDynamicObject(18778,-1458.25708008,-622.43408203,14.86718750,5.99853516,0.00000000,175.99548340); //object(logramps)(4)
	CreateDynamicObject(18783,-1736.28869629,-660.98944092,14.05413628,0.00000000,0.00000000,9.99755859); //object(kickramp04)(2)
	CreateDynamicObject(18783,-1739.71789551,-642.85943604,14.05413628,0.00000000,0.00000000,9.99755859); //object(kickramp04)(4)
	CreateDynamicObject(18825,-1748.39099121,-737.05889893,40.03654480,0.00000000,0.00000000,60.00000000); //object(im_mtel_sckts)(4)
	CreateDynamicObject(18783,-1740.64904785,-719.32409668,16.70863152,0.00000000,0.00000000,329.99755859); //object(kickramp04)(6)
	CreateDynamicObject(18785,-1717.29736328,-681.25402832,15.18302727,0.00000000,0.00000000,329.99633789); //object(logramps02)(6)
	CreateDynamicObject(18783,-1730.41442871,-703.92700195,16.70863152,0.00000000,0.00000000,329.99633789); //object(kickramp04)(7)
	CreateDynamicObject(18836,-1728.69067383,-707.84649658,55.76342010,0.00000000,0.00000000,143.99996948); //object(int3int_brothel03)(2)
	CreateDynamicObject(18836,-1728.69067383,-707.84649658,55.76342010,0.00000000,0.00000000,143.99996948); //object(int3int_brothel03)(2
	CreateDynamicObject(18836,-1700.14453125,-668.46759033,55.76342010,0.00000000,0.00000000,143.99780273); //object(int3int_brothel03)(3)
	CreateDynamicObject(18836,-1700.14453125,-668.46759033,55.76342010,0.00000000,0.00000000,143.99780273); //object(int3int_brothel03)(3
	CreateDynamicObject(18852,-1659.07714844,-609.09027100,55.62300873,0.00000000,270.00000000,55.99926758); //object(ab_sfgymmain1)(8)
	CreateDynamicObject(18838,-1627.56188965,-561.17926025,63.42290115,0.00000000,0.00000000,240.00000000); //object(int3int_brothel04)(1)
	CreateDynamicObject(18838,-1627.56188965,-561.17926025,63.42290115,0.00000000,0.00000000,240.00000000); //object(int3int_brothel04)(1
	CreateDynamicObject(18852,-1659.28173828,-608.94616699,71.37300873,0.00000000,270.00000000,55.99731445); //object(ab_sfgymmain1)(9)
	CreateDynamicObject(18855,-1684.86462402,-693.30328369,71.51496887,87.17102051,314.97253418,90.97021484); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18855,-1684.86462402,-693.30328369,71.51496887,87.17102051,314.97253418,90.97021484); //object(ab_sfgymbits01a)(1
	CreateDynamicObject(1634,-1638.10400391,-691.37829590,69.73274231,4.00000000,0.00000000,306.00000000); //object(landjump2)(10)
	CreateDynamicObject(18778,-1724.83105469,-645.75756836,14.40625000,5.99853516,0.00000000,99.99755859); //object(logramps)(6)
	CreateDynamicObject(18778,-1726.14880371,-638.20214844,14.40625000,5.99853516,0.00000000,99.99755859); //object(logramps)(7)
	CreateDynamicObject(18780,-1600.44555664,-746.97558594,25.23524094,0.00000000,0.00000000,250.00000000); //object(stunt1)(3)
	CreateDynamicObject(18778,-1458.56152344,-626.46099854,18.36718750,35.99853516,0.00000000,175.98999023); //object(logramps)(8)
	CreateDynamicObject(18778,-1458.65881348,-628.36242676,22.61718750,53.99670410,0.00000000,175.98999023); //object(logramps)(9)
	CreateDynamicObject(18855,-1566.67773438,-475.01229858,32.52497864,79.80477905,78.80187988,145.34735107); //object(ab_sfgymbits01a)(1)
	CreateDynamicObject(18855,-1566.67773438,-475.01229858,32.52497864,79.80477905,78.80187988,145.34735107); //object(ab_sfgymbits01a)(1
	CreateDynamicObject(3080,-1613.20568848,-475.51800537,21.17234421,0.00000000,0.00000000,310.00000000); //object(ad_jump)(5)
	CreateDynamicObject(3080,-1584.49182129,-537.57037354,21.13273621,0.00000000,0.00000000,140.00000000); //object(ad_jump)(6)
	CreateDynamicObject(3080,-1581.66076660,-540.04339600,21.13273621,0.00000000,0.00000000,139.99877930); //object(ad_jump)(7)
	CreateDynamicObject(3080,-1584.12145996,-543.03942871,23.38273621,16.00000000,0.00000000,139.99877930); //object(ad_jump)(8)
	CreateDynamicObject(3080,-1586.95410156,-540.51953125,23.38273621,15.99609375,0.00000000,139.99877930); //object(ad_jump)(9)
	CreateDynamicObject(18781,-1637.75891113,-747.06982422,23.91406250,0.00000000,0.00000000,153.98937988); //object(ramparse)(2)
	CreateDynamicObject(18783,-1644.54162598,-761.15466309,39.76772690,270.00000000,180.00000000,153.99755859); //object(kickramp04)(8)
	CreateDynamicObject(18783,-1613.28100586,-779.87060547,60.67772293,270.00000000,179.99450684,159.99487305); //object(kickramp04)(9)
	CreateDynamicObject(18859,-1314.47375488,-685.37481689,24.56250000,0.00000000,0.00000000,1.99755859); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1361.62133789,-687.01470947,24.56250000,0.00000000,0.00000000,1.99755859); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.72387695,-688.67010498,24.56250000,0.00000000,0.00000000,1.99755859); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1458.24755859,-691.41979980,24.56250000,0.00000000,0.00000000,3.99755859); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1361.53430176,-696.24884033,59.43155670,85.99597168,0.00000000,1.98852539); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1361.53430176,-696.24884033,59.43155670,85.99597168,0.00000000,1.98852539); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.84436035,-694.56414795,59.43155670,85.99548340,0.00000000,1.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.84436035,-694.56414795,59.43155670,85.99548340,0.00000000,1.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.63928223,-698.02398682,59.43155670,85.99548340,0.00000000,1.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.63928223,-698.02398682,59.43155670,85.99548340,0.00000000,1.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1457.54345703,-700.67437744,59.43155670,85.99548340,0.00000000,3.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1457.54345703,-700.67437744,59.43155670,85.99548340,0.00000000,3.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1505.54870605,-694.78778076,24.56250000,0.00000000,0.00000000,3.99353027); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1505.09509277,-704.15570068,59.43155670,85.99548340,0.00000000,3.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1505.09509277,-704.15570068,59.43155670,85.99548340,0.00000000,3.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.06250000,-726.45837402,24.56250000,0.00000000,0.00000000,181.99401855); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.06250000,-726.45837402,24.56250000,0.00000000,0.00000000,181.99401855); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.23791504,-717.08325195,59.43155670,85.99548340,0.00000000,181.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1313.23791504,-717.08325195,59.43155670,85.99548340,0.00000000,181.98303223); //object(int_kbsgarage05b)(3
	CreateDynamicObject(18859,-1360.82006836,-728.44250488,24.56250000,0.00000000,0.00000000,181.99401855); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1360.82006836,-728.44250488,24.56250000,0.00000000,0.00000000,181.99401855); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1360.64465332,-719.06518555,59.43155670,85.99548340,0.00000000,181.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1360.64465332,-719.06518555,59.43155670,85.99548340,0.00000000,181.98303223); //object(int_kbsgarage05b)(3
	CreateDynamicObject(18859,-1409.13049316,-731.02178955,24.56250000,0.00000000,0.00000000,183.98852539); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.13049316,-731.02178955,24.56250000,0.00000000,0.00000000,183.98852539); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.03662109,-721.61401367,59.43155670,85.99548340,0.00000000,183.98303223); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1409.03662109,-721.61401367,59.43155670,85.99548340,0.00000000,183.98303223); //object(int_kbsgarage05b)(3
	CreateDynamicObject(18859,-1457.43774414,-734.58441162,24.56250000,0.00000000,0.00000000,183.98803711); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1457.43774414,-734.58441162,24.56250000,0.00000000,0.00000000,183.98803711); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1457.52746582,-725.23370361,59.43155670,85.99548340,0.00000000,183.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1457.52746582,-725.23370361,59.43155670,85.99548340,0.00000000,183.98254395); //object(int_kbsgarage05b)(3
	CreateDynamicObject(18859,-1502.20996094,-737.82501221,24.56250000,0.00000000,0.00000000,183.98803711); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1502.20996094,-737.82501221,24.56250000,0.00000000,0.00000000,183.98803711); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1503.39477539,-728.57641602,59.43155670,85.99548340,0.00000000,183.98254395); //object(int_kbsgarage05b)(3)
	CreateDynamicObject(18859,-1503.39477539,-728.57641602,59.43155670,85.99548340,0.00000000,183.98254395); //object(int_kbsgarage05b)(3
	CreateDynamicObject(18783,-1282.67004395,-704.45275879,11.42968750,0.00000000,0.00000000,7.99755859); //object(kickramp04)(10)
	CreateDynamicObject(18783,-1534.80212402,-718.30297852,11.42968750,0.00000000,0.00000000,7.99255371); //object(kickramp04)(11)
	CreateDynamicObject(18785,-1554.62109375,-720.99816895,11.43750000,0.00000000,0.00000000,97.99633789); //object(logramps02)(7)
	CreateDynamicObject(18785,-1262.90466309,-701.75305176,11.43750000,0.00000000,0.00000000,277.99255371); //object(logramps02)(8)
	CreateDynamicObject(18850,-1334.64135742,-578.99945068,24.99453163,0.00000000,0.00000000,22.00000000); //object(ab_sfgymbits02a)(1)
	CreateDynamicObject(18786,-1310.54101562,-568.85229492,27.54863167,0.00000000,43.99316406,23.98315430); //object(steps)(2)
	CreateDynamicObject(18786,-1370.23449707,-594.42419434,21.79863167,0.00000000,27.99316406,203.98315430); //object(steps)(2)
	CreateDynamicObject(18786,-1364.92480469,-592.16705322,27.54863167,0.00000000,43.98925781,203.97766113); //object(steps)(2)
	CreateDynamicObject(18857,-1340.40820312,-427.76443481,23.44759750,0.00000000,270.00000000,190.00000000); //object(ab_vegasgymmain2)(1)
	CreateDynamicObject(18857,-1340.40820312,-427.76443481,23.44759750,0.00000000,270.00000000,190.00000000); //object(ab_vegasgymmain2)(
	CreateDynamicObject(18857,-1339.98925781,-387.85064697,23.44759750,0.00000000,270.00000000,171.99755859); //object(ab_vegasgymmain2)(2)
	CreateDynamicObject(18857,-1339.98925781,-387.85064697,23.44759750,0.00000000,270.00000000,171.99755859); //object(ab_vegasgymmain2)(
	CreateDynamicObject(18846,-1339.48352051,-387.36431885,17.94213104,0.00000000,0.00000000,77.97106934); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1339.48352051,-387.36431885,17.94213104,0.00000000,0.00000000,77.97106934); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1641.03112793,-771.19702148,66.66762543,0.00000000,0.00000000,157.97924805); //object(int3int_kbsgarage)(5)
	CreateDynamicObject(18846,-1641.03112793,-771.19702148,66.66762543,0.00000000,0.00000000,157.97924805); //object(int3int_kbsgarage)(5
	CreateDynamicObject(18862,-1262.77136230,-502.86059570,18.19984436,0.00000000,0.00000000,0.00000000); //object(otb_glass)(1)
	CreateDynamicObject(18778,-1643.17041016,-593.14074707,14.86718750,5.99853516,0.00000000,19.98999023); //object(logramps)(11)
	CreateDynamicObject(18778,-1644.33630371,-589.57647705,17.86718750,29.99853516,0.00000000,19.98962402); //object(logramps)(12)
	CreateDynamicObject(18778,-1629.10009766,-587.93310547,14.86718750,5.99853516,0.00000000,19.98962402); //object(logramps)(15)
	CreateDynamicObject(18778,-1629.94494629,-584.31127930,17.86718750,29.99816895,0.00000000,19.98413086); //object(logramps)(17)
	CreateDynamicObject(10828,-1667.07958984,-118.39147186,10.27123451,0.00000000,0.00000000,314.00000000); //object(drydock1_sfse)(1)
	CreateDynamicObject(6959,-1752.85815430,-554.02703857,12.76294899,0.00000000,0.00000000,0.00000000); //object(vegasnbball1)(1)
	CreateDynamicObject(18801,-1754.78137207,-308.64135742,35.50605774,2.03796387,0.00000000,278.03527832); //object(8bar5)(1)
	CreateDynamicObject(18778,-1767.91748047,-546.60125732,13.45044899,3.99902344,0.00000000,179.99951172); //object(logramps)(19)
	CreateDynamicObject(18783,-1765.76306152,-560.63092041,12.97388649,0.00000000,0.00000000,359.99755859); //object(kickramp04)(12)
	CreateDynamicObject(18778,-1752.36621094,-546.64147949,13.45044899,3.99353027,0.00000000,179.99450684); //object(logramps)(20)
	CreateDynamicObject(18783,-1754.38098145,-560.50103760,12.97388649,0.00000000,0.00000000,359.99450684); //object(kickramp04)(13)
	CreateDynamicObject(18779,-1764.63305664,-172.73101807,22.92968750,0.00000000,0.00000000,282.00000000); //object(tuberamp)(5)
	CreateDynamicObject(18788,-1775.03576660,-118.83811951,7.63706589,0.00000000,346.00000000,354.00000000); //object(ramplandpad)(1)
	CreateDynamicObject(18788,-1736.33508301,-122.83140564,12.38706589,0.00000000,359.99792480,353.99597168); //object(ramplandpad)(2)
	CreateDynamicObject(18778,-1712.52050781,-124.71417236,11.65625000,0.00000000,0.00000000,84.00000000); //object(logramps)(21)
	CreateDynamicObject(10828,-1687.97973633,-97.16738129,10.27123451,0.00000000,0.00000000,313.99475098); //object(drydock1_sfse)(4)
	CreateDynamicObject(10828,-1667.07910156,-118.39062500,-2.97876549,0.00000000,0.00000000,313.99475098); //object(drydock1_sfse)(5)
	CreateDynamicObject(10828,-1667.07910156,-118.39062500,-18.22876549,0.00000000,0.00000000,313.99475098); //object(drydock1_sfse)(6)

	//San Fierro Stunt Park
	totalmaps++;
	CreateDynamicObject(4867, -2496.503174, 1493.935181, 6.212046, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(4867, -2283.925781, 1493.942505, 6.234003, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(4867, -2643.268066, 1540.505493, 6.209001, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2593.520264, 1495.303467, 6.437159, -9.45380361966, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2601.045166, 1495.728638, 9.716373, 10.3132403124, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2607.002197, 1496.058716, 15.554365, 31.7991576298, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2611.138672, 1496.295410, 23.087584, 45.5500874171, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2612.859375, 1496.383911, 31.393009, 65.3171313491, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2611.944336, 1496.330078, 39.860687, 81.6464285104, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2608.066895, 1496.115234, 47.685299, 104.851161917, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2602.267822, 1495.827759, 53.207722, 122.89938976, 0.000000, 86.8031059623); //
	CreateDynamicObject(1655, -2594.587891, 1495.394287, 56.546818, 144.385478965, 0.000000, 86.8031059623); //
	CreateDynamicObject(5400, -2491.750488, 1378.065918, 16.195683, -1.71887338539, 13.7509870831, -269.003512927); //
	CreateDynamicObject(5400, -2491.469482, 1368.932617, 16.320688, 0.000000, 11.1726770051, -269.003512927); //
	CreateDynamicObject(13592, -2436.103271, 1443.431274, 16.532654, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2431.672119, 1443.261353, 22.465273, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2427.254883, 1443.111572, 28.353844, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2422.899902, 1442.967407, 34.218102, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2418.605225, 1442.838989, 40.008575, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2414.489014, 1442.690063, 45.490875, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2410.027832, 1442.543823, 51.456116, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2405.966064, 1442.435791, 56.943367, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(13592, -2401.809082, 1442.320435, 62.558449, 54.1444543441, -0.859436692696, -77.3493023427); //
	CreateDynamicObject(4113, -2385.240479, 1421.189453, 19.512608, 0.000000, 0.000000, 25.7831007809); //
	CreateDynamicObject(18450, -2440.802734, 1410.910767, 65.107254, 0.000000, 14.6104237758, 12.8915503904); //
	CreateDynamicObject(18450, -2410.798340, 1417.780762, 57.119888, 0.000000, 8.59436692696, 12.8915503904); //
	CreateDynamicObject(3458, -2498.158691, 1397.989014, 74.021774, 0.000000, 0.000000, 12.8915503904); //
	CreateDynamicObject(3458, -2536.674561, 1389.177612, 74.021774, 0.000000, 0.000000, 12.8915503904); //
	CreateDynamicObject(3458, -2562.201660, 1401.310913, 74.021835, 0.000000, 0.000000, -74.7709922646); //
	CreateDynamicObject(3458, -2556.815430, 1435.720947, 74.021851, 0.000000, 0.000000, -122.040067659); //
	CreateDynamicObject(18450, -2539.929932, 1461.527100, 78.118515, 0.000000, 14.6104237758, -122.899504351); //
	CreateDynamicObject(18450, -2497.309082, 1527.383667, 87.572105, 0.000000, -0.859436692696, -122.899504351); //
	CreateDynamicObject(13592, -2470.259277, 1565.767822, 96.459183, 0.000000, 4.29718346348, -28.361410859); //
	CreateDynamicObject(13592, -2466.068115, 1571.363403, 96.394005, 0.000000, 4.29718346348, -28.361410859); //
	CreateDynamicObject(13592, -2464.351807, 1573.576904, 96.430206, 0.000000, 4.29718346348, -30.9397209371); //
	CreateDynamicObject(13592, -2460.563232, 1578.097534, 96.038338, 0.000000, 4.29718346348, -37.8152144786); //
	CreateDynamicObject(13592, -2456.006104, 1581.813843, 96.141197, 0.000000, 4.29718346348, -45.5501447129); //
	CreateDynamicObject(13592, -2451.651123, 1584.377930, 95.954193, 0.000000, 4.29718346348, -53.2850176514); //
	CreateDynamicObject(13592, -2445.973877, 1587.197876, 95.661079, 0.000000, 4.29718346348, -59.3010745003); //
	CreateDynamicObject(13592, -2440.645264, 1589.229370, 95.500984, 0.000000, 4.29718346348, -68.7548781199); //
	CreateDynamicObject(13592, -2435.275879, 1590.359497, 95.390594, 0.000000, 4.29718346348, -78.2086817396); //
	CreateDynamicObject(13592, -2430.057861, 1590.349609, 95.324455, 0.000000, 4.29718346348, -89.3813587446); //
	CreateDynamicObject(13592, -2423.971680, 1589.347778, 95.194244, 0.000000, 4.29718346348, -96.2568522862); //
	CreateDynamicObject(13592, -2418.846924, 1587.682861, 95.049301, 0.000000, 4.29718346348, -107.429529291); //
	CreateDynamicObject(13592, -2414.172607, 1585.264526, 94.907036, 0.000000, 4.29718346348, -119.461642989); //
	CreateDynamicObject(13592, -2410.315918, 1582.101074, 94.513367, 0.000000, 4.29718346348, -127.196630519); //
	CreateDynamicObject(3458, -2421.522705, 1559.308594, 82.928596, 0.000000, 0.000000, -127.196687815); //
	CreateDynamicObject(3458, -2444.523682, 1529.014038, 91.003601, 0.000000, -24.0642273955, -127.196687815); //
	CreateDynamicObject(3458, -2466.689697, 1499.807007, 107.381989, 0.000000, -24.0642273955, -127.196687815); //
	CreateDynamicObject(3458, -2489.642334, 1469.573608, 117.891144, 0.000000, -6.87549354157, -127.196687815); //
	CreateDynamicObject(3865, -2509.713135, 1443.140259, 123.276733, 0.000000, 0.000000, -37.8152144786); //
	CreateDynamicObject(978, -2504.426025, 1450.095337, 121.712044, 82.5058652031, 0.000000, 52.4256382545); //
	CreateDynamicObject(3865, -2514.817139, 1436.702515, 123.283592, 0.000000, 0.000000, -37.8152144786); //
	CreateDynamicObject(3865, -2519.945068, 1430.192871, 124.189484, -12.0321136977, 0.000000, -37.8152144786); //
	CreateDynamicObject(3865, -2525.081055, 1423.729126, 125.942780, -12.0321136977, 0.000000, -37.8152144786); //
	CreateDynamicObject(18450, -2549.754883, 1386.620850, 124.486008, 0.000000, 0.859436692696, -122.899504351); //
	CreateDynamicObject(1655, -2577.217529, 1352.224121, 125.185707, -0.859436692696, 0.000000, -213.999908369); //
	CreateDynamicObject(1655, -2570.112793, 1347.425415, 125.183983, -0.859436692696, 0.000000, -213.999908369); //
	CreateDynamicObject(1655, -2352.581787, 1436.021729, 7.209112, 0.000000, 0.000000, 101.413529738); //
	CreateDynamicObject(1655, -2359.221680, 1434.683716, 11.285023, 17.1887338539, 0.000000, 101.413529738); //
	CreateDynamicObject(1655, -2364.050049, 1433.717163, 16.939816, 35.2369044005, 0.000000, 101.413529738); //
	CreateDynamicObject(1655, -2367.056396, 1433.110352, 23.813868, 51.566144266, 0.000000, 101.413529738); //
	CreateDynamicObject(1655, -2368.301514, 1432.896973, 31.430899, 65.3171313491, 0.000000, 100.554093045); //
	CreateDynamicObject(1655, -2440.126221, 1525.766846, 14.537160, 32.6585943225, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2440.130615, 1520.748779, 9.112154, 16.3292971612, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2440.146973, 1515.989624, 6.463853, -4.29718346348, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2448.905762, 1515.993164, 6.462155, -4.29718346348, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2448.905518, 1520.234741, 8.590445, 16.3292971612, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2448.887207, 1525.695557, 14.404854, 32.6585943225, 0.000000, 0.000000); //
	CreateDynamicObject(18450, -2568.262939, 1560.485474, 5.027191, 0.000000, 5.15662015618, 0.000000); //
	CreateDynamicObject(18450, -2603.003418, 1560.515137, 9.900214, 0.000000, 13.7509870831, 0.000000); //
	CreateDynamicObject(18450, -2605.346436, 1560.506104, 12.043631, 0.000000, 22.3453540101, 0.000000); //
	CreateDynamicObject(18450, -2606.347900, 1560.522583, 13.535150, 0.000000, 31.7991576298, 0.000000); //
	CreateDynamicObject(18450, -2608.229736, 1560.488159, 15.334079, 0.000000, 41.2529612494, 0.000000); //
	CreateDynamicObject(18450, -2611.354004, 1560.505249, 18.665859, 0.000000, 53.2850176514, 0.000000); //
	CreateDynamicObject(18450, -2613.680420, 1560.524658, 21.576138, 0.000000, 62.738821271, 0.000000); //
	CreateDynamicObject(18450, -2616.735596, 1560.518433, 26.409275, 0.000000, 73.0520615834, 0.000000); //
	CreateDynamicObject(18450, -2618.703125, 1560.492920, 31.682762, 0.000000, 84.2247385885, 0.000000); //
	CreateDynamicObject(18450, -2619.153320, 1560.530151, 43.605587, 0.000000, 92.8191055154, 0.000000); //
	CreateDynamicObject(18450, -2618.716553, 1560.506470, 48.052135, 0.000000, 99.694599057, 0.000000); //
	CreateDynamicObject(18450, -2617.709961, 1560.521118, 53.007256, 0.000000, 108.288908688, 0.000000); //
	CreateDynamicObject(18450, -2614.544189, 1560.534546, 60.804306, 0.000000, 115.16440223, 0.000000); //
	CreateDynamicObject(18450, -2615.289551, 1560.517578, 59.856167, 0.000000, 122.89938976, 0.000000); //
	CreateDynamicObject(18450, -2612.455078, 1560.535889, 64.665558, 0.000000, 132.353250675, 0.000000); //
	CreateDynamicObject(18450, -2604.498291, 1560.520630, 72.462357, 0.000000, 141.807168886, 0.000000); //
	CreateDynamicObject(18450, -2603.679443, 1560.539063, 73.093506, 0.000000, 152.979903187, 0.000000); //
	CreateDynamicObject(18450, -2604.113037, 1560.539795, 73.468216, 0.000000, 160.714890717, 0.000000); //
	CreateDynamicObject(18450, -2599.787598, 1560.554199, 75.777870, 0.000000, 172.747061711, 0.000000); //
	CreateDynamicObject(18450, -2593.421387, 1560.267944, 76.882477, 0.000000, 179.622612548, 6.01605684887); //
	CreateDynamicObject(18450, -2586.933105, 1560.953125, 77.116783, 0.000000, 187.357600078, 6.01605684887); //
	CreateDynamicObject(17565, -2241.959717, 1462.336548, 8.217721, 0.000000, 0.000000, -92.8191628112); //
	CreateDynamicObject(16304, -2291.154053, 1518.895386, 11.194291, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2272.396973, 1515.180908, 11.419284, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2280.851807, 1529.356201, 11.419284, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2283.662842, 1508.693115, 11.444178, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13641, -2331.498779, 1466.702393, 7.653246, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13636, -2285.374756, 1450.650269, 8.214399, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13604, -2231.282715, 1528.258423, 7.867020, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13590, -2210.421875, 1469.434692, 7.334845, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(12956, -2520.450439, 1449.976563, 9.340288, 0.000000, 0.000000, 3.43774677078); //
	CreateDynamicObject(8375, -2375.995117, 1489.672363, 8.142746, 0.000000, 0.000000, -91.1002894258); //
	CreateDynamicObject(1681, -2552.489502, 1422.181641, 10.690071, 30.9397209371, -0.859436692696, 34.3774677078); //
	CreateDynamicObject(3627, -2446.779785, 1416.580078, 9.951534, 0.000000, 0.000000, -127.196687815); //
	CreateDynamicObject(1632, -2476.213379, 1444.638916, 7.237157, 0.000000, 0.000000, -132.353422563); //
	CreateDynamicObject(1632, -2472.174805, 1440.950562, 10.232885, 12.0321136977, 0.000000, -132.353422563); //
	CreateDynamicObject(8172, -2618.063232, 1645.294312, 10.753359, 0.000000, -14.6104237758, 90.2408527331); //
	CreateDynamicObject(4867, -2644.527344, 1756.413330, 15.771599, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8172, -2458.408936, 1645.532715, 10.604275, 0.000000, -14.6104237758, 90.2408527331); //
	CreateDynamicObject(4867, -2432.114014, 1756.401001, 15.718554, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8038, -2697.786377, 1707.553101, 35.586876, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(8550, -2601.603760, 1716.874023, 19.794685, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(10757, -2659.120850, 1693.465942, 18.162872, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(10763, -2359.914063, 1701.532593, 47.550121, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(10815, -2466.165771, 2144.366455, -4.113179, 6.87549354157, 6.87549354157, 135.550125989); //
	CreateDynamicObject(16098, -2529.928711, 1702.051270, 11.982086, 0.000000, 0.000000, -91.1002894258); //
	CreateDynamicObject(1682, -2534.920654, 1736.604736, 22.147770, 0.000000, 0.000000, -226.032022066); //
	CreateDynamicObject(1655, -2684.334717, 1763.410767, 16.721716, 0.000000, 0.000000, -204.546162045); //
	CreateDynamicObject(1655, -2686.639160, 1758.337158, 20.286983, 21.4859173174, 0.000000, -204.546162045); //
	CreateDynamicObject(18284, -2743.938477, 1770.464233, 18.591440, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(18284, -2743.937256, 1753.346069, 18.591440, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(7617, -2565.819580, 1626.917725, 17.218266, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(13592, -2658.062500, 1675.427246, 27.342205, 0.000000, 44.6907080202, -19.767043932); //
	CreateDynamicObject(13592, -2671.340576, 1736.453369, 27.342205, 0.000000, 44.6907080202, 22.3453540101); //
	CreateDynamicObject(1655, -2658.850830, 1679.370117, 16.695498, 0.000000, 0.000000, 69.6143721084); //
	CreateDynamicObject(1655, -2674.829590, 1738.918945, 16.671717, 0.000000, 0.000000, 111.726712755); //
	CreateDynamicObject(1632, -2480.286133, 1698.574951, 16.618666, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1632, -2416.190674, 1604.029541, 6.105851, -9.45380361966, 0.000000, -62.7388785668); //
	CreateDynamicObject(1632, -2409.655029, 1607.400269, 9.370035, 12.0321136977, 0.000000, -62.7388785668); //
	CreateDynamicObject(1632, -2404.213867, 1610.200562, 14.847307, 26.6425374736, 0.000000, -62.7388785668); //
	CreateDynamicObject(1632, -2400.662354, 1612.034424, 20.965559, 42.1123979421, 0.000000, -62.7388785668); //
	CreateDynamicObject(1632, -2399.104980, 1612.833496, 26.374514, 55.0038910368, 0.000000, -62.7388785668); //
	CreateDynamicObject(18450, -2565.269043, 1627.046997, 27.886604, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1634, -2566.166016, 1682.689087, 16.568916, 0.000000, 0.000000, -181.34125675); //
	CreateDynamicObject(1634, -2566.295410, 1677.785645, 19.807072, 14.6104237758, 0.000000, -181.34125675); //
	CreateDynamicObject(3865, -2424.993408, 1680.728149, 19.027466, -25.7831007809, 0.000000, 57.5822584106); //
	CreateDynamicObject(3865, -2429.185303, 1677.106201, 19.027475, -25.7831007809, 0.000000, 24.0642273955); //
	CreateDynamicObject(3865, -2424.233154, 1687.323853, 19.052473, -25.7831007809, 0.000000, 108.289080576); //
	CreateDynamicObject(13592, -2350.516113, 1853.142700, 25.312674, 0.000000, 0.000000, 14.6877730782); //
	CreateDynamicObject(7073, -2397.609375, 1613.309326, 47.663666, 0.000000, 0.000000, 27.5019741663); //
	CreateDynamicObject(13592, -2580.575684, 1428.643311, 15.782654, 0.000000, 0.000000, 55.0039483326); //
	CreateDynamicObject(13592, -2286.929688, 1414.786987, 16.029638, 0.000000, 0.000000, 96.256909582); //
	CreateDynamicObject(13592, -2280.615723, 1414.502075, 16.079063, 0.000000, 0.000000, 96.256909582); //
	CreateDynamicObject(13592, -2273.660400, 1414.214844, 16.060707, 0.000000, 0.000000, 96.256909582); //
	CreateDynamicObject(13592, -2266.497559, 1413.932251, 16.052275, 0.000000, 0.000000, 96.256909582); //
	CreateDynamicObject(13592, -2259.102295, 1413.618042, 16.035004, 0.000000, 0.000000, 96.256909582); //
	CreateDynamicObject(1632, -2256.965332, 1400.673706, 6.459115, -6.01605684887, 0.000000, -180.000019848); //
	CreateDynamicObject(1632, -2253.565186, 1400.675293, 6.459116, -6.01605684887, 0.000000, -180.000019848); //
	CreateDynamicObject(1632, -2256.934082, 1395.055908, 9.023918, 9.45380361966, 0.000000, -180.000019848); //
	CreateDynamicObject(1632, -2253.580322, 1395.066040, 9.017756, 9.45380361966, 0.000000, -180.000019848); //
	CreateDynamicObject(18450, -2563.020996, 1317.276001, 121.616791, 0.000000, 0.859436692696, -33.5180883109); //
	CreateDynamicObject(18450, -2566.589600, 1311.980591, 124.797615, -89.3814160404, 0.859436692696, -32.6586516182); //
	CreateDynamicObject(18450, -2566.681396, 1311.983643, 138.643570, -89.3814160404, 0.859436692696, -32.6586516182); //
	CreateDynamicObject(13592, -2532.638184, 1300.199707, 131.123383, 61.8793845783, 46.4095814056, -116.883390207); //
	CreateDynamicObject(13592, -2529.419922, 1297.733154, 136.960968, 61.8793845783, 46.4095814056, -116.883390207); //
	CreateDynamicObject(13592, -2526.290039, 1295.304688, 142.680573, 61.8793845783, 46.4095814056, -116.883390207); //
	CreateDynamicObject(13592, -2522.942871, 1292.758789, 148.707748, 61.8793845783, 46.4095814056, -116.883390207); //
	CreateDynamicObject(4726, -2504.491455, 1274.464355, 139.391891, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(1655, -2431.523193, 1442.089355, 7.512158, 12.0321136977, 24.0642273955, -134.931732641); //
	CreateDynamicObject(1655, -2530.636719, 1295.986694, 121.922485, 0.000000, 6.87549354157, -165.012074181); //
	CreateDynamicObject(8172, -2289.552490, 1705.228638, 15.637918, 0.000000, -0.859436692696, 33.9908930835); //
	CreateDynamicObject(16304, -2253.513916, 1621.301025, 18.483820, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2250.423096, 1599.815063, 18.673267, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2249.073486, 1580.045410, 13.394300, 17.1887338539, 1.71887338539, 0.000000); //
	CreateDynamicObject(16304, -2250.763916, 1567.248413, 10.169303, 6.01605684887, 2.57831007809, 0.000000); //
	CreateDynamicObject(16304, -2229.570068, 1633.550903, 20.208210, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2222.928955, 1611.934570, 19.722826, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2219.598633, 1589.063110, 18.824223, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(16304, -2213.923096, 1574.173950, 15.372831, 6.01605684887, 2.57831007809, 2.57831007809); //
	CreateDynamicObject(16304, -2212.972900, 1558.553955, 10.016254, 0.859436692696, 0.859436692696, 2.57831007809); //
	CreateDynamicObject(4113, -2171.894775, 1421.369019, 13.221230, 0.000000, 0.000000, -78.7500122644); //
	CreateDynamicObject(4113, -2170.436035, 1459.744019, 13.087622, 0.000000, 0.000000, -78.7500122644); //
	CreateDynamicObject(8881, -2159.967529, 1507.680176, 32.779266, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(8881, -2163.286621, 1583.891235, 32.860237, 0.000000, 0.000000, -112.499976595); //
	CreateDynamicObject(9078, -2358.295898, 1644.700317, 20.579948, 0.000000, 0.000000, -22.499995319); //
	CreateDynamicObject(1655, -2335.538086, 1615.418335, 19.263401, 0.000000, 0.000000, 219.070183785); //
	CreateDynamicObject(1655, -2295.712891, 1574.488525, 7.284114, 0.000000, 0.000000, 46.0230067812); //
	CreateDynamicObject(1655, -2299.518555, 1578.150146, 10.309114, 14.6104237758, 0.000000, 46.0230067812); //
	CreateDynamicObject(1655, -2228.086670, 1424.979126, 7.234114, 0.000000, 0.000000, -89.8364591213); //
	CreateDynamicObject(1655, -2221.260254, 1425.001221, 11.343248, 16.3292971612, 0.000000, -89.8364591213); //
	CreateDynamicObject(1655, -2215.590332, 1425.029785, 17.804220, 35.2369044005, 0.000000, -89.8364591213); //
	CreateDynamicObject(1655, -2217.683105, 1521.453491, 7.284114, 0.000000, 0.000000, -63.8213677292); //
	CreateDynamicObject(1655, -2212.500244, 1524.027954, 11.090099, 19.767043932, 0.000000, -63.8213677292); //
	CreateDynamicObject(3627, -2322.677246, 1703.648926, 19.558041, 0.859436692696, 85.9436692696, -179.149464001); //
	CreateDynamicObject(3627, -2342.820801, 1672.845337, 20.083033, 0.859436692696, 85.9436692696, -246.649507254); //
	CreateDynamicObject(981, -2750.070313, 1829.594116, 16.723085, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(981, -2750.254883, 1797.774658, 16.648087, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(981, -2750.028076, 1726.042969, 16.598087, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(981, -2750.004395, 1689.223145, 16.673086, 0.000000, 0.000000, -89.999981276); //
	CreateDynamicObject(981, -2728.247070, 1666.255615, 16.698086, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(4113, -2207.835938, 1388.642578, 13.165733, 0.000000, 0.000000, -168.74999354); //
	CreateDynamicObject(5005, -2296.465820, 1584.870239, 9.660522, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(5005, -2274.334229, 1717.054199, 19.352491, 0.000000, 0.000000, -56.2500169454); //
	CreateDynamicObject(5005, -2304.568848, 1691.956543, 18.348148, 0.000000, 0.000000, -56.2500169454); //
	CreateDynamicObject(4867, -2500.056641, 1636.053955, 6.193704, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(3998, -2381.777588, 1607.269043, 6.806076, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(979, -2377.628662, 1631.650269, 7.653274, -0.859436692696, -14.6104237758, 89.999981276); //
	CreateDynamicObject(979, -2377.675293, 1640.474854, 9.942514, -0.859436692696, -14.6104237758, 89.999981276); //
	CreateDynamicObject(979, -2377.726318, 1649.372192, 12.284719, -0.859436692696, -14.6104237758, 89.999981276); //
	CreateDynamicObject(4867, -2432.992188, 1938.835449, 15.717037, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(5005, -2326.654785, 1860.855835, 19.095072, 0.000000, 0.000000, -89.1405445833); //
	CreateDynamicObject(980, -2322.785400, 1780.090210, 18.511829, 0.000000, 0.000000, 33.7500216264); //
	CreateDynamicObject(5005, -2327.911621, 1950.818115, 19.093557, 0.000000, 0.000000, -89.1405445833); //
	CreateDynamicObject(5005, -2668.114990, 1846.837036, 19.071609, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(18450, -2466.068115, 2185.400879, 2.508298, 0.000000, 0.000000, 89.999981276); //
	CreateDynamicObject(1655, -2469.438232, 2212.614746, 3.659484, -7.73493023427, 0.000000, -179.999962552); //
	CreateDynamicObject(1655, -2461.887939, 2212.593506, 3.659486, -7.73493023427, 0.000000, -179.999962552); //
	CreateDynamicObject(1655, -2462.960449, 2205.614990, 3.302158, -2.57831007809, 0.000000, -359.9999824); //
	CreateDynamicObject(1655, -2469.041992, 2205.609863, 3.302159, -2.57831007809, 0.000000, -359.9999824); //
	CreateDynamicObject(5005, -2619.512207, 1846.785400, 19.073116, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(5005, -2539.378906, 1926.684326, 19.068558, 0.000000, 0.000000, -270.00005842); //
	CreateDynamicObject(5005, -2539.370850, 1947.193604, 19.101128, 0.000000, 0.000000, -270.00005842); //
	CreateDynamicObject(8881, -2514.207275, 2033.016846, 41.168262, 0.000000, 0.000000, -56.2500169454); //
	CreateDynamicObject(5005, -2406.325439, 2029.932251, 19.118549, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(1655, -2466.029541, 2042.257446, 16.675777, -2.57831007809, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2457.514160, 2042.255371, 16.670261, -2.57831007809, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2474.671875, 2042.247559, 16.683964, -2.57831007809, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2457.524414, 2036.002808, 20.346834, 16.3292971612, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2466.207275, 2035.996582, 20.348133, 16.3292971612, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2474.657227, 2035.998657, 20.347273, 16.3292971612, 0.000000, -539.999944952); //
	CreateDynamicObject(1655, -2457.888672, 2017.757324, 16.542156, -2.57831007809, 0.000000, -719.999735617); //
	CreateDynamicObject(1655, -2466.599609, 2017.777100, 16.553860, -2.57831007809, 0.000000, -719.999735617); //
	CreateDynamicObject(1655, -2475.268799, 2017.760132, 16.542149, -2.57831007809, 0.000000, -719.999735617); //
	CreateDynamicObject(1655, -2457.857666, 2024.611450, 20.523438, 16.3292971612, 0.000000, -719.999735617); //
	CreateDynamicObject(1655, -2466.577393, 2024.598389, 20.513142, 16.3292971612, 0.000000, -719.999735617); //
	CreateDynamicObject(1655, -2475.295654, 2024.583740, 20.492138, 16.3292971612, 0.000000, -719.999735617); //
	CreateDynamicObject(13592, -2351.343018, 1860.463623, 25.249275, 0.000000, 0.000000, 14.6877730782); //
	CreateDynamicObject(13592, -2352.122803, 1867.609985, 25.213223, 0.000000, 0.000000, 14.6877730782); //
	CreateDynamicObject(13592, -2352.923584, 1874.771606, 25.198029, 0.000000, 0.000000, 14.6877730782); //
	CreateDynamicObject(16141, -2370.034424, 1994.377075, 9.936005, 0.000000, 0.000000, 22.499995319); //
	CreateDynamicObject(4113, -2348.949219, 2013.458740, 46.745644, 0.000000, 0.000000, -29.3754888606); //
	CreateDynamicObject(1655, -2516.368164, 1908.471069, 16.792152, 0.000000, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.947998, 1915.793213, 21.096109, 15.4698604685, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.619873, 1921.566528, 27.274912, 32.6585943225, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.421875, 1925.174194, 34.752232, 49.8472708806, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.360840, 1926.463623, 42.797916, 66.1765680418, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.414307, 1925.489258, 51.248455, 81.6464285104, 0.000000, -3.35145932684); //
	CreateDynamicObject(1655, -2515.602051, 1922.290649, 58.701847, 98.8351623643, 0.000000, -3.35145932684); //
	CreateDynamicObject(18450, -2515.091309, 1870.696533, 52.546658, 0.000000, -0.859436692696, -89.1494827249); //
	CreateDynamicObject(18450, -2513.913086, 1792.017578, 53.724293, 0.000000, -0.859436692696, -89.1494827249); //
	CreateDynamicObject(18450, -2512.782471, 1714.903809, 62.439785, 0.000000, -12.0321136977, -89.1494827249); //
	CreateDynamicObject(979, -2510.953369, 1591.208130, 72.122162, 88.5219793477, 0.859436692696, 89.999981276); //
	CreateDynamicObject(18450, -2511.610596, 1635.880493, 71.373840, 0.000000, -0.859436692696, -89.1494827249); //
	CreateDynamicObject(1632, -2510.791748, 1582.333496, 73.211952, 0.000000, 0.000000, -179.999962552); //
	CreateDynamicObject(1632, -2510.795898, 1575.403442, 77.684891, 19.767043932, 0.000000, -179.999962552); //
	CreateDynamicObject(17310, -2581.060547, 1815.828857, 20.843208, 0.000000, -143.52592768, 0.000000); //
	CreateDynamicObject(17310, -2618.983398, 1815.712646, 20.843208, 0.000000, -143.52592768, -180.000019848); //
	CreateDynamicObject(17310, -2411.895508, 1847.905518, 20.790163, 0.000000, -143.52592768, -134.999971914); //
	CreateDynamicObject(17310, -2508.071533, 1952.460205, 20.788647, 0.000000, -143.52592768, -56.2499596496); //
	CreateDynamicObject(17310, -2385.470215, 1958.429565, 20.788647, 0.000000, -143.52592768, -134.999971914); //
	CreateDynamicObject(17310, -2538.551025, 1844.219849, 20.790163, 0.000000, -143.52592768, -56.2499596496); //
	CreateDynamicObject(17310, -2390.335693, 1845.881958, 20.790163, 0.000000, -143.52592768, -56.2499596496); //
	CreateDynamicObject(17310, -2545.483398, 1854.425537, 49.906807, 0.000000, -82.5057506115, -56.2499596496); //
	CreateDynamicObject(1632, -2480.341064, 1704.980713, 16.643671, 0.000000, 0.000000, -179.999962552); //
	CreateDynamicObject(5005, -2749.535156, 1548.798462, 9.385523, 0.000000, 0.000000, -270.000001124); //
	CreateDynamicObject(16304, -2741.265137, 1458.433472, 10.709005, 0.000000, 0.000000, 0.000000); //
	CreateDynamicObject(18450, -2451.873535, 1887.972534, 31.410240, 0.000000, 24.9236640882, -100.399509032); //
	CreateDynamicObject(18450, -2438.952148, 1958.437378, 64.681274, 0.000000, 24.9236640882, -100.399509032); //
	CreateDynamicObject(18450, -2425.955566, 2029.291748, 98.130737, 0.000000, 24.9236640882, -100.399509032); //
	CreateDynamicObject(18450, -2413.019775, 2099.820557, 131.438171, 0.000000, 24.9236640882, -100.399509032); //
	CreateDynamicObject(18450, -2400.105957, 2170.253662, 164.698303, 0.000000, 24.9236640882, -100.399509032); //
	CreateDynamicObject(8661, -2387.817871, 2214.846191, 181.856323, 0.000000, 0.000000, -10.3905896147); //
	CreateDynamicObject(8661, -2385.988281, 2224.924805, 191.754532, 88.5219793477, 0.000000, -10.3905896147); //
	CreateDynamicObject(18450, -2382.678711, 2164.285156, 181.474258, 0.000000, 0.000000, -96.9528241199); //
	CreateDynamicObject(18450, -2390.861816, 2096.632080, 153.411194, 0.000000, 44.6907080202, -96.9528241199); //
	CreateDynamicObject(18450, -2397.608398, 2041.102295, 98.058609, 0.000000, 44.6907080202, -96.9528241199); //
	CreateDynamicObject(18450, -2401.222412, 2011.355469, 68.436638, 0.000000, 44.6907080202, -96.9528241199); //
	CreateDynamicObject(1655, -2404.827148, 1979.586304, 37.175594, -58.4416378076, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2405.696289, 1972.157104, 33.284805, -42.1123979421, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2406.673096, 1963.887939, 31.634861, -25.7831007809, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2407.689453, 1955.311768, 32.770168, -5.15662015618, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2408.593506, 1947.659424, 36.406784, 10.3132403124, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2409.344727, 1941.330078, 42.169773, 28.361410859, 0.000000, -186.789225945); //
	CreateDynamicObject(1655, -2395.746582, 1735.864868, 16.718670, 0.000000, 0.000000, -149.601457548); //
	CreateDynamicObject(1655, -2392.515869, 1730.372070, 20.536137, 16.3292971612, 0.000000, -149.601457548); //
	CreateDynamicObject(981, -2733.849854, 1630.846680, 7.085487, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(981, -2713.893799, 1630.844971, 7.060488, 0.000000, 0.000000, -180.000019848); //
	CreateDynamicObject(981, -2697.755615, 1648.881958, 12.681335, 0.000000, -13.7509870831, -269.063215129); //
	CreateDynamicObject(13641, -2453.259766, 1717.528198, 17.287800, 0.000000, 0.000000, 67.499985957); //
	CreateDynamicObject(13641, -2444.855225, 1741.380127, 17.117973, 0.000000, 0.000000, 247.499948509); //
	return 1;
}

stock loadvehicles()
{
	//Big Ear
    AddStaticVehicle(562,-314.8210,1514.7047,75.0159,179.7586,125,101); //
    AddStaticVehicle(562,-317.9687,1515.2693,75.0167,179.3635,3,0); //
    AddStaticVehicle(562,-321.0188,1516.1996,75.0004,180.3000,0,0); //
    AddStaticVehicle(560,-324.1131,1516.1185,75.0640,179.2503,2,2); //
    AddStaticVehicle(560,-327.4248,1516.3153,75.0648,179.8615,0,0); //
    AddStaticVehicle(541,-330.3157,1515.9094,75.0063,179.3605,0,3); //
    AddStaticVehicle(541,-333.5182,1515.9625,75.0387,179.9557,0,1); //
    AddStaticVehicle(541,-336.4984,1516.1553,75.0061,179.6830,9,9); //
    
    //Skate Park
 	AddStaticVehicle(481,1923.4360,-1415.6572,13.0852,3.9005,3,3); //
	AddStaticVehicle(481,1922.2761,-1415.6763,13.0837,5.7064,6,6); //
	AddStaticVehicle(481,1921.1298,-1415.6224,13.0846,4.7250,46,46); //
	AddStaticVehicle(481,1919.9700,-1415.6637,13.0784,0.5917,65,9); //
	AddStaticVehicle(481,1919.0057,-1415.6708,13.0824,4.1980,14,1); //
	AddStaticVehicle(481,1917.9083,-1415.6532,13.0851,3.9416,12,9); //
	AddStaticVehicle(481,1917.1178,-1415.6733,13.0851,0.6270,26,1); //
	AddStaticVehicle(522,1915.8629,-1415.2822,13.1377,359.3351,7,79); //
	AddStaticVehicle(522,1912.9553,-1415.2861,13.1385,8.0477,36,105); //
	AddStaticVehicle(522,1911.3607,-1415.2953,13.1388,4.4576,39,106); //
	AddStaticVehicle(522,1909.7303,-1415.3042,13.1496,357.5589,51,118); //
	AddStaticVehicle(468,1923.2179,-1410.1670,13.2399,180.9651,46,46); //
	AddStaticVehicle(468,1921.7554,-1410.1973,13.2391,179.1895,53,53); //
	AddStaticVehicle(468,1920.0546,-1410.1702,13.2395,180.5183,3,3); //
	AddStaticVehicle(468,1918.5848,-1410.1381,13.2394,182.3162,6,6); //
	AddStaticVehicle(468,1916.8820,-1410.2058,13.2394,177.3225,46,46); //
	AddStaticVehicle(468,1915.1533,-1410.1624,13.2393,176.8941,3,3); //
	AddStaticVehicle(522,1914.4041,-1415.2166,13.1407,5.8082,3,8); //
	
	//SF Park
	AddStaticVehicle(568,-2619.1924,1378.3132,7.0068,208.2666,9,39); // Bandito
	AddStaticVehicle(568,-2624.9282,1377.9537,7.0045,168.1755,17,1); // Bandito
	AddStaticVehicle(494,-2632.1570,1376.1439,7.0194,194.5816,36,13); // Hotring
	AddStaticVehicle(494,-2639.5947,1376.1661,7.0363,214.8190,42,30); // Ignore the 3rd Bandito
	AddStaticVehicle(522,-2644.8530,1361.9760,6.7332,289.4984,3,8); // NRG
	AddStaticVehicle(522,-2646.6206,1366.3081,6.7430,245.4457,6,25); // NRG
	AddStaticVehicle(411,-2645.3003,1351.6985,6.8921,305.7953,64,1); // Infernus
	AddStaticVehicle(560,-2646.2207,1339.8358,6.8748,315.5476,9,39); // Sultan
	AddStaticVehicle(562,-2645.0950,1345.8474,6.8212,301.4055,35,1); // Elegy
	AddStaticVehicle(568,-2633.3352,1333.0338,7.0642,15.2146,21,1); // Bandito
	AddStaticVehicle(568,-2628.5229,1334.5607,7.0596,345.9190,33,0); // Bandito
	
	//Abandoned Airport
	AddStaticVehicle(411,387.1272,2439.6628,16.2271,276.5767,116,1); // Infernus
	AddStaticVehicle(411,387.2913,2445.7188,16.2271,272.3741,112,1); // Infernus
	AddStaticVehicle(411,388.0836,2451.4758,16.2271,257.7307,106,1); // Infernus
	AddStaticVehicle(522,386.9981,2454.9202,16.0713,266.6856,7,79); // NRG
	AddStaticVehicle(522,386.5020,2457.3477,16.0658,255.9461,8,82); // NRG
	AddStaticVehicle(522,385.7704,2460.3252,16.0615,269.6655,36,105); // NRG
	AddStaticVehicle(494,388.1299,2464.2097,16.3952,271.3116,42,33); // Hotring
	AddStaticVehicle(494,388.4583,2469.6697,16.3956,278.9113,54,36); // Hotring
	AddStaticVehicle(494,388.2724,2474.2029,16.3945,263.7628,75,79); // Hotring
	AddStaticVehicle(550,421.7881,2469.7480,16.3188,88.0985,42,42); // Sunrise
	AddStaticVehicle(550,422.1575,2474.0840,16.3152,87.1516,53,53); // Sunrise
	AddStaticVehicle(562,422.0320,2464.5625,16.1596,86.3784,17,1); // Elegy
	AddStaticVehicle(562,422.1699,2460.7783,16.1600,89.4706,11,1); // Elegy_ignore the above elegy
	AddStaticVehicle(521,421.5275,2455.5117,16.0651,91.3931,87,118); // FCR
	AddStaticVehicle(521,422.1189,2457.9817,16.0777,88.3656,92,3); // FCR
	AddStaticVehicle(521,418.1723,2435.6287,16.0716,44.9529,115,118); // FCR
	AddStaticVehicle(521,417.2465,2438.6274,16.0682,47.3425,25,118); // FCR
	AddStaticVehicle(521,416.9450,2440.5842,16.0703,48.0940,36,0); // FCR
	AddStaticVehicle(521,416.8485,2444.6472,16.0650,44.5769,118,118); // FCR
	AddStaticVehicle(451,403.0059,2436.6206,16.2077,359.9305,125,125); // Turismo
	AddStaticVehicle(451,396.6505,2436.5649,16.2067,1.4782,36,36); // Turismo
	AddStaticVehicle(451,409.9857,2436.7253,16.2085,357.7828,16,16); // Turismo
	
	//Chilliad
	AddStaticVehicle(568,-2325.7673,-1674.9362,482.6588,345.9775,37,0); // Bandito
	AddStaticVehicle(568,-2332.7544,-1673.1761,482.8981,330.7126,41,29); // Bandito
	AddStaticVehicle(451,-2336.8257,-1667.9384,483.1128,293.6018,18,18); // Turismo
	AddStaticVehicle(451,-2338.6895,-1663.1360,483.3850,286.0893,46,46); // Turismo
	AddStaticVehicle(522,-2343.4407,-1660.7122,483.2682,308.4420,39,106); // NRG
	AddStaticVehicle(522,-2344.8735,-1657.7437,483.2642,291.5557,51,118); // NRG
	AddStaticVehicle(560,-2344.9800,-1654.8403,483.4087,276.2330,17,1); // Sultan
	AddStaticVehicle(560,-2349.0535,-1650.5880,483.4106,314.2598,21,1); // Sultan
	AddStaticVehicle(560,-2351.0740,-1643.2653,483.4075,312.2560,33,0); // Sultan
	AddStaticVehicle(411,-2354.3645,-1637.5428,483.4302,286.2296,80,1); // Infernus
	AddStaticVehicle(568,-2356.1414,-1631.3431,483.5552,295.5782,56,29); // Bandito
	
	//SF Airport
	AddStaticVehicle(541,-1522.7291,-289.5692,5.6247,227.8279,58,8); // Bullet
	AddStaticVehicle(541,-1533.4792,-291.8593,5.6250,205.0033,60,1); // Bullet
	AddStaticVehicle(411,-1538.1959,-294.4925,5.7268,225.5103,116,1); // Infernuis
	AddStaticVehicle(522,-1543.9471,-296.6075,5.5611,214.4497,36,105); // NRG
	AddStaticVehicle(522,-1543.2067,-293.7289,5.5715,213.4614,39,106); // NRG
	AddStaticVehicle(521,-1547.0605,-297.0157,5.5675,196.7480,75,13); // FCR
	AddStaticVehicle(541,-1549.6630,-299.9095,5.6258,236.7826,68,8); // Bullet
	AddStaticVehicle(541,-1555.5326,-304.1257,5.6562,202.9710,2,1); // Bullet_Ignoreabove
	AddStaticVehicle(429,-1559.2891,-308.2682,5.6817,239.2331,13,13); // Banshee
	AddStaticVehicle(429,-1562.6670,-312.2238,5.6796,214.4450,14,14); // Banshee
	AddStaticVehicle(429,-1565.7740,-315.9158,5.6797,250.5822,1,2); // Banshee
	AddStaticVehicle(429,-1569.0615,-319.7289,5.6777,252.4291,2,1); // Banshee
	AddStaticVehicle(541,-1572.2018,-322.8115,5.6214,257.8297,13,8); // Bullet
	AddStaticVehicle(535,-1574.5660,-327.8018,5.7663,234.6946,28,1); // Slamvan
	AddStaticVehicle(535,-1577.6777,-332.9823,5.7645,260.8375,31,1); // Slamvan
	AddStaticVehicle(535,-1580.7749,-338.3138,5.7652,223.7840,55,1); // Slamvan
	AddStaticVehicle(535,-1585.1952,-344.7645,5.7901,278.6965,66,1); // Slamvan
	AddStaticVehicle(541,-1587.3749,-352.4762,5.6419,259.6268,22,1); // Bullet
	AddStaticVehicle(541,-1588.6309,-357.6263,5.6319,237.0509,36,8); // Bullet
	AddStaticVehicle(522,-1589.5618,-361.9643,5.5607,261.2233,51,118); // NRG
	AddStaticVehicle(522,-1590.4344,-363.7193,5.5623,267.5987,3,3); // NRG
	AddStaticVehicle(522,-1592.1039,-366.6838,5.5698,282.5143,3,8); // NRG
	AddStaticVehicle(522,-1592.5107,-369.7248,5.5638,283.8697,6,25); // NRG
	AddStaticVehicle(541,-1588.0591,-370.1880,5.6065,300.8557,51,1); // Bullet
	
	//LS Airport
	AddStaticVehicle(522,2053.5259,-2565.7734,13.1184,219.6721,3,8); // NRG
	AddStaticVehicle(522,2051.7122,-2569.0037,13.1078,221.3248,6,25); // NRG
	AddStaticVehicle(568,2046.1709,-2569.4697,13.4084,224.7961,37,0); // Bandito
	AddStaticVehicle(411,2065.9089,-2569.6829,13.2740,214.1531,116,1); // Infernus
	AddStaticVehicle(535,2076.8386,-2555.0491,13.3116,251.7420,97,1); // Slamvan
	AddStaticVehicle(522,2080.0955,-2547.5481,13.1161,219.9489,7,79); // NRG
	AddStaticVehicle(522,2085.0288,-2550.1401,13.1117,197.6188,8,82); // NRG
	AddStaticVehicle(568,2088.1387,-2625.5471,13.4119,347.9490,41,29); // Bandito
	AddStaticVehicle(568,2098.8335,-2624.8982,13.4090,49.8692,56,29); // Bandito
	AddStaticVehicle(429,2108.7810,-2620.1514,13.2265,31.6406,1,3); // Banshee
	AddStaticVehicle(429,2116.8420,-2615.1375,13.2286,79.0775,3,1); // Banshee
    return 1;
}

stock isnumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
    	if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

stock load_spawn()
{
	//NRG Pickup 4 LSAIR
	pickup[0] = CreateDynamicPickup(19132, 1, 2066.7791,-2561.6243,13.5469, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"NRG", -1, 2066.7791,-2561.6243,13.5469,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//Bullet Pickup 4 SFAIR
	pickup[1] = CreateDynamicPickup(19132, 1, -1512.4498,-322.8806,6.9006, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"Bullet", -1, -1512.4498,-322.8806,6.9006,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//Abandoned Airport Pickup 4 Infernus
	pickup[2] = CreateDynamicPickup(19132, 1, 400.2484,2451.1726,16.5000, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"Infernus", -1, 400.2484,2451.1726,16.5000,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//Skate Park Pickup 4 NRG
	pickup[3] = CreateDynamicPickup(19132, 1, 1911.3120,-1404.9818,13.5703, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"NRG", -1, 1911.3120,-1404.9818,13.5703,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//Chilliad Pickup 4 Sultan
	pickup[4] = CreateDynamicPickup(19132, 1, -2311.0464,-1681.4675,482.1659, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"Sultan", -1, -2311.0464,-1681.4675,482.1659,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//Drift 1 4 ELEGY
	pickup[5] = CreateDynamicPickup(19132, 1, -300.8336,1529.0797,75.3594, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"Elegy", -1, -300.8336,1529.0797,75.3594,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);
	//SFPARK 4 FCR
	pickup[6] = CreateDynamicPickup(19132, 1, -2618.8933,1396.1895,7.1016, -1, 0, -1);
    CreateDynamic3DTextLabel("Pick up this "red"icon "white"to receive\n"grey"FCR", -1, -2618.8933,1396.1895,7.1016,100.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, -1);

	for(new x = 0; x < sizeof(hcord); x++)
	{
		horse[hcord[x][hpickup]] = CreateDynamicPickup(954, 1, hcord[x][hx], hcord[x][hy], hcord[x][hz], -1, 0, -1);
	}
	return 1;
}

stock CheckVehicle(vehicleid)
{
    #define MAX_INVALID_NOS_VEHICLES 13

    new InvalidNOSVehicles[MAX_INVALID_NOS_VEHICLES] =
    {
 		522,481,441,468,448,446,513,521,510,430,520,476,463
    };

	for(new i = 0; i < MAX_INVALID_NOS_VEHICLES; i++)
	{
 		if(GetVehicleModel(vehicleid) == InvalidNOSVehicles[i]) return false;
	}
    return true;
}

stock load_config()
{
	skinlist = LoadModelSelectionMenu("server/data/configurations/skins.txt");
	return 1;
}

stock ShowStats(playerid, targetid)
{
	new string[250], string2[1400], count, ranks[90];
	if(IsPlayerConnected(targetid))
	{
	    if(User[targetid][accountLogged] == true)
	    {
			new Float:ratio = (float(User[targetid][accountKills])/float(User[targetid][accountDeaths]));
			new yes[4] = "Yes", no[3] = "No";

	        strcat(string2, ""grey"Player's Statistics.\n\n");
	        format(string, sizeof(string), ""white"UserID: "grey"%d\n", User[targetid][accountID]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Member Since: "grey"%s\n", User[targetid][accountDate]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Name: {%06x}%s (ID:%d)\n", GetPlayerColor(targetid) >>> 8, GetName(targetid), targetid);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Current Online Time: "grey"%02d:%02d:%02d\n", g_time[targetid][2], g_time[targetid][1], g_time[targetid][0]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Total Online Time: "grey"%02d:%02d:%02d\n", User[targetid][accountGame][2], User[targetid][accountGame][1], User[targetid][accountGame][0]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Score: "grey"%d\n", GetPlayerScore(targetid));
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Money: "grey"$%d\n", GetPlayerCash(targetid));
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Premium Points: "grey"%d\n", User[targetid][accountPP]);
	        strcat(string2, string);
	        strcat(string2, ""white"Premium Inventory:"grey" ");
	        if(User[targetid][accountJP] == 1)
	        {
	            count++;
	            strcat(string2, "Jetpack ");
	        }
	        if(User[targetid][accountVIP] == 1)
	        {
	            count++;
	            strcat(string2, "VIP ");
	        }
	        if(User[targetid][accountBrake] == 1)
	        {
	            count++;
	            strcat(string2, "Brake ");
	        }
	        if(User[targetid][accountCName] >= 1)
	        {
	            count++;
	            strcat(string2, "NameChange ");
	        }
	        if(count == 0)
	        {
	            strcat(string2, "None");
	        }
			strcat(string2, "\n");

			new remaining_seconds = gettime() - User[targetid][ExpirationVIP];
			new remaining_days = remaining_seconds / 3600 / 24;

			if(User[targetid][accountVIP] == 1)
			{
		        format(string, sizeof(string), ""white"Expiration VIP: "grey"%d\n", abs(remaining_days));
		        strcat(string2, string);
			}
			if(User[targetid][accountCName] >= 1)
			{
		        format(string, sizeof(string), ""white"Changename Counts: "grey"%d\n", User[targetid][accountCName]);
		        strcat(string2, string);
		        format(string, sizeof(string), ""white"Waiting Time: "grey"%d hours\n", User[targetid][accountCWait]);
		        strcat(string2, string);
			}

			switch(User[targetid][accountAdmin])
			{
			    case 0: ranks = "Not an Admin";
			    case 1: ranks = "Moderator";
			    case 2: ranks = "Admin";
			    case 3: ranks = "Head Admin";
			    case 4: ranks = "Manager";
			    case 5: ranks = "Owner";
			}
	        format(string, sizeof(string), ""white"Admin Rank: "grey"%s\n", ranks);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Helper: "grey"%s\n", User[targetid][accountHelper] ? yes : no);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"ReactionContest Wins: "grey"%d\n", User[targetid][accountReact]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Math Wins: "grey"%d\n", User[targetid][accountMath]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Checkpoint Found: "grey"%d\n", User[targetid][accountCP]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Moneybag Found: "grey"%d\n", User[targetid][accountMB]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Horseshoe Found: "grey"%d/30\n", User[targetid][accountHS]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"No Wets (DGW): "grey"%d\n", User[targetid][accountWet]);
	        strcat(string2, string);
	        new wins = User[targetid][accountReact]+User[targetid][accountCP]+User[targetid][accountMB]+User[targetid][accountMath]+User[targetid][accountHS]+User[targetid][accountWet];
	        format(string, sizeof(string), ""white"Overall Wins: "grey"%d\n", wins);
	        strcat(string2, string);
	        format(string, sizeof(string), ""red"Warnings: "grey"%d\n", User[targetid][accountWarn]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Kills: "grey"%d\n", User[targetid][accountKills]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Deaths: "grey"%d\n", User[targetid][accountDeaths]);
	        strcat(string2, string);
	        format(string, sizeof(string), ""white"Ratio (K/D): "grey"%.3f\n", ratio);
	        strcat(string2, string);
	        strcat(string2, "\n"yellow"Self Description:"grey"\n");
	        format(string, sizeof(string), "%s", User[targetid][accountDescp]);
	        strcat(string2, string);

			format(string, sizeof string, "{%06x}%s", GetPlayerColor(targetid) >>> 8, GetName(targetid));
			ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, string, string2, "Close", "");
		}
	}
	return 1;
}

stock ResetPlayerCash(playerid)
{
	money_anti[playerid] = 0;
	return ResetPlayerMoney(playerid);
}
stock GivePlayerCash(playerid, money)
{
	money_anti[playerid] = money_anti[playerid]+money;
	return GivePlayerMoney(playerid, money);
}
stock GetPlayerCash(playerid)
{
	return money_anti[playerid];
}

stock GetWeaponIDFromName(WeaponName[])
{
	if(strfind("molotov", WeaponName, true) != -1) return 18;
	for(new i = 0; i <= 46; i++)
	{
		switch(i)
		{
			case 0,19,20,21,44,45: continue;
			default:
			{
				new name[32]; GetWeaponName(i,name,32);
				if(strfind(name,WeaponName,true) != -1) return i;
			}
		}
	}
	return -1;
}

stock strtok(const string[], &index)
{
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' '))
    {
            index++;
    }

    new offset = index;
    new result[20];
    while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}

stock IsValidIP(ip[])
{
    new a;
	for (new i = 0; i < strlen(ip); i++)
	{
		if (ip[i] == '.')
		{
		    a++;
		}
	}
	if (a != 3)
	{
	    return 1;
	}
	return 0;
}

stock CheckBan(ip[])
{
	new string[20];
    new File: file = fopen("server/data/configurations/ban.cfg", io_read);
	while(fread(file, string))
	{
	    if (strcmp(ip, string, true, strlen(ip)) == 0)
	    {
	        fclose(file);
	        return 1;
	    }
	}
	fclose(file);
	return 0;
}

stock VehicleOccupied(vehicleid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerInVehicle(i, vehicleid)) return 1;
    }
    return 0;
}

stock AddBan(ip[], type)
{
	if (CheckBan(ip) == 0)
	{
		new File: file = fopen("server/data/configurations/ban.cfg", io_append);
		new string[20];
		format(string, sizeof(string), "%s", ip);
	 	fwrite(file, string);
	 	fclose(file);

		if(type == 0)
		{
		 	foreach(new playerid : Player)
			{
			    new playerIP[16];
				GetPlayerIp(playerid, playerIP, sizeof(playerIP));
				if (strcmp(playerIP, ip) == 0)
				{
		            SendClientMessage(playerid, COLOR_RED, "[BANNED] "white"You are banned from this server by an Admin/Anticheat.");
					KickDelay(playerid);
				}
			}
		}
		return 1;
	}
	return 0;
}

stock RemoveBan(ip[])
{
    if (CheckBan(ip) == 1)
	{
	    new string[20];
		new File: file = fopen("server/data/configurations/ban.cfg", io_read);
		fcreate("server/data/configurations/tempBan.cfg");
		new File: file2 = fopen("server/data/configurations/tempBan.cfg", io_append);
		while(fread(file, string))
		{
			if (strcmp(ip, string, true, strlen(ip)) != 0 && strcmp("\n", string) != 0)
		    {
				fwrite(file2, string);
			}
		}
		fclose(file);
		fclose(file2);
		file = fopen("server/data/configurations/ban.cfg", io_write);
		file2 = fopen("server/data/configurations/tempBan.cfg", io_read);
		while(fread(file2, string))
		{
			fwrite(file, string);
		}
		fclose(file);
		fclose(file2);
		fremove("server/data/configurations/tempBan.cfg");
		return 1;
    }
	return 0;
}

stock BanAccEx(name[], ip[], admin[] = "Anticheat", reason[] = "None")
{
	new
		Query[500],
		DBResult:result,
		ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years, when[128]
	;

	gettime(ban_hr, ban_min, ban_sec);
	getdate(ban_years, ban_month, ban_days);

	format(when, 128, "%02d/%02d/%d %02d:%02d:%02d", ban_month, ban_days, ban_years, ban_hr, ban_min, ban_sec);
	format(sInfo[last_bwhen], 256, "%s", when);
	savestatistics();

	format(Query, 600, "SELECT * FROM `bans` WHERE `username` = '%s'", DB_Escape(name));
	result = db_query(Database, Query);
	if(!db_num_rows(result))
	{
		format(Query, 500, "INSERT INTO `bans` (`username`, `ip`, `banby`, `banreason`, `banwhen`) VALUES ('%s', '%s', '%s', '%s', '%s')", DB_Escape(name), ip, admin, reason, when);
		result = db_query(Database, Query);
	}
	db_free_result(result);
	return 1;
}

stock BanAcc(playerid, admin[] = "Anticheat", reason[] = "None")
{
	new
		Query[500],
		DBResult:result,
		ban_hr, ban_min, ban_sec, ban_month, ban_days, ban_years, when[128]
	;
	
	gettime(ban_hr, ban_min, ban_sec);
	getdate(ban_years, ban_month, ban_days);
	
	format(when, 128, "%02d/%02d/%d %02d:%02d:%02d", ban_month, ban_days, ban_years, ban_hr, ban_min, ban_sec);
	format(sInfo[last_bwhen], 256, "%s", when);
	savestatistics();
	
	format(Query, 600, "SELECT * FROM `bans` WHERE `username` = '%s'", DB_Escape(GetName(playerid)));
	result = db_query(Database, Query);
	if(!db_num_rows(result))
	{
		format(Query, 500, "INSERT INTO `bans` (`username`, `ip`, `banby`, `banreason`, `banwhen`) VALUES ('%s', '%s', '%s', '%s', '%s')", DB_Escape(GetName(playerid)), User[playerid][accountIP], admin, reason, when);
		result = db_query(Database, Query);
	}
	db_free_result(result);
	return 1;
}

stock ShowBan(playerid, admin[] = "Finn (AC)", reason[] = "Hack", when[] = "01/01/1970 00:00:00")
{
	new string[256], string2[1500];

	Clear_Chat(playerid);

    format(string, 256, "[BANNED] "white"You're banned from server by %s for the following reasons:", admin);
	SendClientMessage(playerid, COLOR_RED, string);
	format(string, 256, "(( %s ))", reason);
	SendClientMessage(playerid, -1, string);

	strcat(string2, ""grey"");
	strcat(string2, "You are banned from this server, Statistics of your ban:\n\n");
	format(string, 256, ""white"Name: "red"%s\n", GetName(playerid));
	strcat(string2, string);
	format(string, 256, ""white"Banned By: "red"%s\n", admin);
	strcat(string2, string);
	format(string, 256, ""white"Reason: "red"%s\n", reason);
	strcat(string2, string);
	format(string, 256, ""white"IP: "red"%s\n", User[playerid][accountIP]);
	strcat(string2, string);
	format(string, 256, ""white"Banned since: "red"%s\n\n", when);
	strcat(string2, string);
	strcat(string2, ""grey"");
	strcat(string2, "If you think this is a bugged, false ban or the admin abused his/her power, Please place a ban appeal on forums.\n");
	strcat(string2, "www.jake.com - Make sure to take a picture of this by pressing F8, Do not lie on your appeal.");

	ShowPlayerDialog(playerid, N, DIALOG_STYLE_MSGBOX, ""newb"You are banned from this server.", string2, "Close", "");
	return 1;
}

stock fcreate(filename[])
{
	if (fexist(filename)) return false;
	new File:fhnd;
	fhnd=fopen(filename,io_write);
	if (fhnd) {
		fclose(fhnd);
		return true;
	}
	return false;
}

stock Log(filename[], text[])
{
	new File:file;
	new string2[256];
	new string[250];
	format(string, 250, ""_LOG_"%s", filename);
	new year, month, day;
	new hour, minute, second;
	getdate(year, month, day);
	gettime(hour, minute, second);

	file = fopen(string, io_append);
	format(string2, sizeof(string2),"(%02d/%02d/%02d | %02d:%02d:%02d) %s\r\n", month, day, year, hour, minute, second, text);
	fwrite(file, string2);
	fclose(file);
	return 1;
}

stock Restriction(playerid)
{
	if(User[playerid][accountJail] == 1)
	{
	    return 1;
	}
	if(g_DM[playerid] >= 1)
	{
	    return 1;
	}
	if(g_IsPlayerDueling[playerid] == 1)
	{
	    return 1;
	}
	if(Minigamer_{ playerid } == true)
	{
	    return 1;
	}
	if(_RP[playerid] == 1)
	{
	    return 1;
	}
	else
	{
		return 0;
	}
}

/*
Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
JaKe for modifying it.
*/
stock GetVehicle2DZone(vehicleid, zone[], len)
{
	new Float:x, Float:y, Float:z;
	GetVehiclePos(vehicleid, x, y, z);
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}

stock GetPlayer2DZone(playerid, zone[], len) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}

stock GetPlayer3DZone(playerid, zone[], len) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4] && z >= gSAZones[i][SAZONE_AREA][2] && z <= gSAZones[i][SAZONE_AREA][5])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}

stock Get3DZone(Float:x, Float:y, Float:z, zone[], len) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4] && z >= gSAZones[i][SAZONE_AREA][2] && z <= gSAZones[i][SAZONE_AREA][5])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}

stock IsPlayerInZone(playerid, zone[]) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
	new TmpZone[MAX_ZONE_NAME];
	GetPlayer3DZone(playerid, TmpZone, sizeof(TmpZone));
	for(new i = 0; i != sizeof(gSAZones); i++)
	{
		if(strfind(TmpZone, zone, true) != -1)
			return 1;
	}
	return 0;
}

forward HouseUnload(playerid);
public HouseUnload(playerid)
{
	SetCameraBehindPlayer(playerid);
	GameTextForPlayer(playerid, "~g~Loaded!", 2500, 3);
	return TogglePlayerControllable(playerid, 1);
}

stock House_Load(playerid)
{
	TogglePlayerControllable(playerid, 0);
	SetCameraBehindPlayer(playerid);
	GameTextForPlayer(playerid, "~w~Loading...", 1000*FREEZE_TIME, 3);
	return SetTimerEx("HouseUnload", 1000*FREEZE_TIME, false, "d", playerid);
}

stock Player_Save(playerid)
{
	dini_IntSet(PlayerPath(playerid), "Houses", jpInfo[playerid][OwnedHouses]);
	dini_FloatSet(PlayerPath(playerid), "X", jpInfo[playerid][p_SpawnPoint][0]);
	dini_FloatSet(PlayerPath(playerid), "Y", jpInfo[playerid][p_SpawnPoint][1]);
	dini_FloatSet(PlayerPath(playerid), "Z", jpInfo[playerid][p_SpawnPoint][2]);
	dini_FloatSet(PlayerPath(playerid), "A", jpInfo[playerid][p_SpawnPoint][3]);
	dini_IntSet(PlayerPath(playerid), "Interior", jpInfo[playerid][p_Interior]);
	dini_IntSet(PlayerPath(playerid), "Spawn", jpInfo[playerid][p_Spawn]);
	return 1;
}
stock Player_Load(playerid)
{
	jpInfo[playerid][OwnedHouses] = dini_Int(PlayerPath(playerid), "Houses");
	jpInfo[playerid][p_SpawnPoint][0] = dini_Float(PlayerPath(playerid), "X");
	jpInfo[playerid][p_SpawnPoint][1] = dini_Float(PlayerPath(playerid), "Y");
	jpInfo[playerid][p_SpawnPoint][2] = dini_Float(PlayerPath(playerid), "Z");
	jpInfo[playerid][p_SpawnPoint][3] = dini_Float(PlayerPath(playerid), "A");
	jpInfo[playerid][p_Interior] = dini_Int(PlayerPath(playerid), "Interior");
	jpInfo[playerid][p_Spawn] = dini_Int(PlayerPath(playerid), "Spawn");
	return 1;
}

stock p_Name(playerid)
{
	new pName[24];
	GetPlayerName(playerid, pName, 24);
	return pName;
}

stock SaveHouse(houseid)
{
	dini_Set(HousePath(houseid), "Name", hInfo[houseid][hName]);
	dini_Set(HousePath(houseid), "Owner", hInfo[houseid][hOwner]);
	dini_Set(HousePath(houseid), "InteriorName", hInfo[houseid][hIName]);
	dini_Set(HousePath(houseid), "Notes", hInfo[houseid][hNotes]);
	dini_IntSet(HousePath(houseid), "Level", hInfo[houseid][hLevel]);
	dini_IntSet(HousePath(houseid), "Price", hInfo[houseid][hPrice]);
	dini_IntSet(HousePath(houseid), "Sale", hInfo[houseid][hSale]);
	dini_IntSet(HousePath(houseid), "Interior", hInfo[houseid][hInterior]);
	dini_IntSet(HousePath(houseid), "World", hInfo[houseid][hWorld]);
	dini_IntSet(HousePath(houseid), "Locked", hInfo[houseid][hLocked]);
	dini_FloatSet(HousePath(houseid), "xPoint", hInfo[houseid][hEnterPos][0]);
	dini_FloatSet(HousePath(houseid), "yPoint", hInfo[houseid][hEnterPos][1]);
	dini_FloatSet(HousePath(houseid), "zPoint", hInfo[houseid][hEnterPos][2]);
	dini_FloatSet(HousePath(houseid), "aPoint", hInfo[houseid][hEnterPos][3]);
	dini_FloatSet(HousePath(houseid), "enterX", hInfo[houseid][hPickupP][0]);
	dini_FloatSet(HousePath(houseid), "enterY", hInfo[houseid][hPickupP][1]);
	dini_FloatSet(HousePath(houseid), "enterZ", hInfo[houseid][hPickupP][2]);
	dini_FloatSet(HousePath(houseid), "exitX", hInfo[houseid][ExitCPPos][0]);
	dini_FloatSet(HousePath(houseid), "exitY", hInfo[houseid][ExitCPPos][1]);
	dini_FloatSet(HousePath(houseid), "exitZ", hInfo[houseid][ExitCPPos][2]);
	dini_IntSet(HousePath(houseid), "MoneySafe", hInfo[houseid][MoneyStore]);
	printf("... House ID %d from JakHouse has been saved.", houseid);
	return 1;
}

stock LoadHouse(houseid)
{
	format(hInfo[houseid][hName], 256, "%s", dini_Get(HousePath(houseid), "Name"));
	format(hInfo[houseid][hOwner], 256, "%s", dini_Get(HousePath(houseid), "Owner"));
	format(hInfo[houseid][hIName], 256, "%s", dini_Get(HousePath(houseid), "InteriorName"));
	format(hInfo[houseid][hNotes], 256, "%s", dini_Get(HousePath(houseid), "Notes"));
	hInfo[houseid][hLevel] = dini_Int(HousePath(houseid), "Level");
	hInfo[houseid][hPrice] = dini_Int(HousePath(houseid), "Price");
	hInfo[houseid][hSale] = dini_Int(HousePath(houseid), "Sale");
	hInfo[houseid][hInterior] = dini_Int(HousePath(houseid), "Interior");
	hInfo[houseid][hWorld] = dini_Int(HousePath(houseid), "World");
	hInfo[houseid][hLocked] = dini_Int(HousePath(houseid), "Locked");
	hInfo[houseid][hEnterPos][0] = dini_Float(HousePath(houseid), "xPoint");
	hInfo[houseid][hEnterPos][1] = dini_Float(HousePath(houseid), "yPoint");
	hInfo[houseid][hEnterPos][2] = dini_Float(HousePath(houseid), "zPoint");
	hInfo[houseid][hEnterPos][3] = dini_Float(HousePath(houseid), "aPoint");
	hInfo[houseid][hPickupP][0] = dini_Float(HousePath(houseid), "enterX");
	hInfo[houseid][hPickupP][1] = dini_Float(HousePath(houseid), "enterY");
	hInfo[houseid][hPickupP][2] = dini_Float(HousePath(houseid), "enterZ");
	hInfo[houseid][ExitCPPos][0] = dini_Float(HousePath(houseid), "exitX");
	hInfo[houseid][ExitCPPos][1] = dini_Float(HousePath(houseid), "exitY");
	hInfo[houseid][ExitCPPos][2] = dini_Float(HousePath(houseid), "exitZ");
	hInfo[houseid][MoneyStore] = dini_Int(HousePath(houseid), "MoneySafe");

	new string[256];

	if(hInfo[houseid][hSale] == 0)
	{
		format(string, 256, ""white"HouseID: "red"%d\n"green"House for Sale!\n"white"Price: "red"$%d\n"white"Interior: "green"%s\n"white"Level: "red"%d\n\n"white"/buyhouse to buy the house.", houseid, hInfo[houseid][hPrice], hInfo[houseid][hIName], hInfo[houseid][hLevel]);
		hInfo[houseid][hMapIcon] = CreateDynamicMapIcon(hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], SALE_ICON, -1, 0, 0, -1, STREAM_DISTANCES, MAPICON_LOCAL);
		hInfo[houseid][hPickup] = CreateDynamicPickup(SALE_PICKUP, 1, hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], 0, 0, -1, STREAM_DISTANCES);
	}
	else
	{
	    if(hInfo[houseid][hLocked] == 0)
	    {
		    if(strcmp(hInfo[houseid][hName], "None", true) == 0)
		    {
		    	format(string, 256, ""white"HouseID: "red"%d\n"green"Unlock\n"white"House Own by: "red"%s\n"white"Interior: "green"%s\n"white"Level: "red"%d\n"white"Price: "green"$%d\n\n"white"Type /henter to enter inside.", houseid, hInfo[houseid][hOwner], hInfo[houseid][hIName], hInfo[houseid][hLevel], hInfo[houseid][hPrice]);
		    }
		    else
		    {
		    	format(string, 256, ""white"HouseID: "red"%d\n"green"Unlock\n"white"House Own by: "red"%s\n"white"Name: "green"%s\n"white"Interior: "red"%s\n"white"Level: "red"%d\n"white"Price: "green"$%d\n\n"white"Type /henter to enter inside.", houseid, hInfo[houseid][hOwner], hInfo[houseid][hName], hInfo[houseid][hIName], hInfo[houseid][hLevel], hInfo[houseid][hPrice]);
			}
		}
		else
		{
		    if(strcmp(hInfo[houseid][hName], "None", true) == 0)
		    {
		    	format(string, 256, ""white"HouseID: "red"%d\n"red"Locked\n"white"House Own by: "red"%s\n"white"Interior: "green"%s\n"white"Level: "red"%d\n"white"Price: "green"$%d\n\n"white"Type /henter to enter inside.", houseid, hInfo[houseid][hOwner], hInfo[houseid][hIName], hInfo[houseid][hLevel], hInfo[houseid][hPrice]);
		    }
		    else
		    {
		    	format(string, 256, ""white"HouseID: "red"%d\n"red"Locked\n"white"House Own by: "red"%s\n"white"Name: "green"%s\n"white"Interior: "red"%s\n"white"Level: "red"%d\n"white"Price: "green"$%d\n\n"white"Type /henter to enter inside.", houseid, hInfo[houseid][hOwner], hInfo[houseid][hName], hInfo[houseid][hIName], hInfo[houseid][hLevel], hInfo[houseid][hPrice]);
			}
		}
		hInfo[houseid][hMapIcon] = CreateDynamicMapIcon(hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], NOTSALE_ICON, -1, 0, 0, -1, STREAM_DISTANCES, MAPICON_LOCAL);
		hInfo[houseid][hPickup] = CreateDynamicPickup(NOTSALE_PICKUP, 1, hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], 0, 0, -1, STREAM_DISTANCES);
	}
    hInfo[houseid][hLabel] = CreateDynamic3DTextLabel(string, -1, hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], STREAM_DISTANCES, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, STREAM_DISTANCES);
	hInfo[houseid][hCP] = CreateDynamicCP(hInfo[houseid][ExitCPPos][0], hInfo[houseid][ExitCPPos][1], hInfo[houseid][ExitCPPos][2], 1.0, hInfo[houseid][hWorld], hInfo[houseid][hInterior], -1, 15.0);
	return 1;
}

stock HexToInt(string[])
{
    if (string[0] == 0)
    {
        return 0;
    }
    new i;
    new cur = 1;
    new res = 0;
    for (i = strlen(string); i > 0; i--)
    {
        if (string[i-1] < 58)
        {
            res = res + cur * (string[i - 1] - 48);
        }
        else
        {
            res = res + cur * (string[i-1] - 65 + 10);
            cur = cur * 16;
        }
    }
    return res;
}

stock HousePath(houseid)
{
	new hfile[128];
	format(hfile, 128, HOUSE_PATH, houseid);
	return hfile;
}

stock PlayerPath(playerid)
{
	new pfile[128];
	format(pfile, 128, USER_PATH, p_Name(playerid));
	return pfile;
}

stock StartSpectate(playerid, specplayerid)
{
	for(new x=0; x<MAX_PLAYERS; x++) {
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] == playerid) {
	       AdvanceSpectate(x);
		}
	}
	SetPlayerInterior(playerid, GetPlayerInterior(specplayerid));
	TogglePlayerSpectating(playerid, 1);

	if(IsPlayerInAnyVehicle(specplayerid))
	{
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specplayerid));
		User[playerid][SpecID] = specplayerid;
		User[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
	}
	else
	{
		PlayerSpectatePlayer(playerid, specplayerid);
		User[playerid][SpecID] = specplayerid;
		User[playerid][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
	}
	return 1;
}

stock StopSpectate(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	User[playerid][SpecID] = INVALID_PLAYER_ID;
	User[playerid][SpecType] = ADMIN_SPEC_TYPE_NONE;
	GameTextForPlayer(playerid,"~n~~n~~n~~w~Spectate mode ended",1000,3);
	return 1;
}

stock AdvanceSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && User[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=User[playerid][SpecID]+1; x<=MAX_PLAYERS; x++)
		{
	    	if(x == MAX_PLAYERS) x = 0;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

stock ReverseSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && User[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=User[playerid][SpecID]-1; x>=0; x--)
		{
	    	if(x == 0) x = MAX_PLAYERS;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && User[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

stock ConnectedPlayers()
{
	new Connected;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) Connected++;
	return Connected;
}

forward PosAfterSpec(playerid);
public PosAfterSpec(playerid)
{
	SetPlayerPos(playerid, SpecPos[playerid][0], SpecPos[playerid][1], SpecPos[playerid][2]);
	SetPlayerFacingAngle(playerid, SpecPos[playerid][3]);
	SetPlayerInterior(playerid, SpecInt[playerid][0]);
	SetPlayerVirtualWorld(playerid, SpecInt[playerid][1]);
}

stock InitializeDuel(playerid)
{
    g_DuelTimer[playerid]  = SetTimerEx("DuelCountDown", 1000, 1, "i", playerid);

    SetPlayerHealth(playerid, 100);
    SetPlayerArmour(playerid, 100);

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, g_Weapon, 999999);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 129);
    SetPlayerPos(playerid, 278.9104, 2105.4985, 24.1094);
    SetPlayerFacingAngle(playerid, 89.7311);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 0);
    g_DuelCountDown[playerid] = 11;
    return 1;
}

stock InitializeDuelEx(playerid)
{
    g_DuelTimer[playerid]  = SetTimerEx("DuelCountDown", 1000, 1, "i", playerid);

    SetPlayerHealth(playerid, 100);
    SetPlayerArmour(playerid, 100);

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, g_Weapon, 999999);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 129);
    SetPlayerPos(playerid, 255.3640, 2105.5791, 24.1094);
    SetPlayerFacingAngle(playerid, 270.2128);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 0);
    g_DuelCountDown[playerid] = 11;
    return 1;
}

forward DuelCountDown(playerid);
public DuelCountDown(playerid)
{
    new
       tString[128] ;

    g_DuelCountDown[playerid] --;

    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

    format(tString, sizeof(tString), "~w~%d", g_DuelCountDown[playerid]);
    GameTextForPlayer(playerid, tString, 900, 3);

    if(g_DuelCountDown[playerid] == 0)
    {
        KillTimer(g_DuelTimer[playerid]);
        TogglePlayerControllable(playerid, 1);
        GameTextForPlayer(playerid,"~g~GO GO GO", 900, 3);
        return 1;
    }
    return 1;
}

stock SniperSpawn(playerid)
{
	new rand = random(sizeof(gRandomSpawns2));
	SetPlayerArmour(playerid, 20.0);
	SetPlayerHealth(playerid, 100.0);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 68);
	SetPlayerPos(playerid, gRandomSpawns2[rand][PlayerX], gRandomSpawns2[rand][PlayerY], gRandomSpawns2[rand][PlayerZ]);
	SetPlayerFacingAngle(playerid, gRandomSpawns2[rand][PlayerAngle]);
	GivePlayerWeapon(playerid, 34, 500);
	return 1;
}

stock MinigunSpawn(playerid)
{
	new rand = random(sizeof(gRandomSpawns));
	SetPlayerArmour(playerid, 20.0);
	SetPlayerHealth(playerid, 100.0);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 67);
	SetPlayerPos(playerid, gRandomSpawns[rand][PlayerX], gRandomSpawns[rand][PlayerY], gRandomSpawns[rand][PlayerZ]);
	SetPlayerFacingAngle(playerid, gRandomSpawns[rand][PlayerAngle]);
	GivePlayerWeapon(playerid, 38, 500);
	return 1;
}

stock LeaveRP(playerid, reason[])
{
	new string[150];
	if(_RP[playerid] == 1)
	{
		format(string, 150, "[RP] "white"%s has left the Roleplay World. (%s)", GetName(playerid), reason);
		rp_ --;
		SendClientMessage(playerid, COLOR_RED, "You have left the Roleplay World.");
	}
	return 1;
}

stock LeaveDM(playerid, reason[])
{
	new string[150];
	if(g_DM[playerid] == 1)
	{
		format(string, 150, "[ARENA] "white"%s has left the Minigun Arena. (%s)", GetName(playerid), reason);
		minigun_ --;
		SendClientMessage(playerid, COLOR_RED, "You have left the Minigun Arena.");
	}
	else if(g_DM[playerid] == 2)
	{
		format(string, 150, "[ARENA] "white"%s has left the Sniper Arena. (%s)", GetName(playerid), reason);
		sniper_ --;
		SendClientMessage(playerid, COLOR_RED, "You have left the Sniper Arena.");
	}
	SendClientMessageToAll(COLOR_LIGHTBLUE, string);
	return 1;
}

stock g_date( g_char[ ] )
{
    new
        g_s_date[ 50 char ],
        g_d_date[ 3 ]
    ;
    getdate( g_d_date[ 0 ], g_d_date[ 1 ], g_d_date[ 2 ] );

    format( g_s_date, sizeof g_s_date, "%02d%s%02d%s%02d", g_d_date[ 0 ], g_char, g_d_date[ 1 ], g_char, g_d_date[ 2 ] );
    return ( g_s_date );
}

stock g_hour( g_char[ ], bool:g_Sec = false )
{
    new
        g_s_hour[ 50 char ],
        g_d_hour[ 3 ]
    ;
    if( !g_Sec )
    {
        gettime( g_d_hour[ 0 ], g_d_hour[ 1 ] );

        format( g_s_hour, sizeof g_s_hour, "%02d%s%02d", g_d_hour[ 0 ], g_char, g_d_hour[ 1 ] );
    }
    else
    {
        gettime( g_d_hour[ 0 ], g_d_hour[ 1 ], g_d_hour[ 2 ] );

        format( g_s_hour, sizeof g_s_hour, "%02d%s%02d%s%02d", g_d_hour[ 0 ], g_char, g_d_hour[ 1 ], g_char, g_d_hour[ 2 ] );
    }
    return ( g_s_hour );
}

stock SaveRec()
{
    new s_DB[ 500 ];
    db_query_set( Database, s_DB, "DELETE FROM `records`", 0 );
    db_query_set( Database, s_DB, "INSERT INTO `records` ( `Name`, `Number`, `Date`, `Hour` ) VALUES ( '%s', '%d', '%s', '%s' )", s_Name, Iter_Count(ON_Player), g_date( #. ), g_hour( #: ) );
    return ( 1 * 1 );
}
stock LoadRec()
{
    new s_DB[ 500 ];
    db_query_get( Database, s_DB, s_Name,       "Name"          );
    db_query_get( Database, s_DB, i_Number,	   "Number"         );
    db_query_get( Database, s_DB, s_Date,       "Date"          );
    db_query_get( Database, s_DB, s_Hour,       "Hour"          );
    return ( 1 * 1 );
}

#if CHRISTMAS_SPIRIT == true
	stock CreateSnow(playerid)
	{
	    if(snowOn{playerid}) return 0;
	    new Float:pPos[3];
	    GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	    for(new i = 0; i < MAX_SNOW_OBJECTS; i++) snowObject[playerid][i] = CreateDynamicObject(18864, pPos[0] + random(25), pPos[1] + random (25), pPos[2] - 5 + random(10), random(280), random(280), 0, -1, -1, playerid);
	    snowOn{playerid} = true;
	    updateTimer{playerid} = SetTimerEx("UpdateSnow", UPDATE_INTERVAL, true, "i", playerid);
	    return 1;
	}

	stock DeleteSnow(playerid)
	{
	    if(!snowOn{playerid}) return 0;
	    for(new i = 0; i < MAX_SNOW_OBJECTS; i++) DestroyDynamicObject(snowObject[playerid][i]);
	    KillTimer(updateTimer{playerid});
	    snowOn{playerid} = false;
	    return 1;
	}
#endif

ProxDetector(Float: f_Radius, playerid, string[],col1,col2,col3,col4,col5)
{
	new
		Float: f_playerPos[3];

	GetPlayerPos(playerid, f_playerPos[0], f_playerPos[1], f_playerPos[2]);
	foreach(new i : Player)
	{
		if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
		{
			if(IsPlayerInRangeOfPoint(i, f_Radius / 16, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
				SendClientMessage(i, col1, string);
			}
			else if(IsPlayerInRangeOfPoint(i, f_Radius / 8, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
				SendClientMessage(i, col2, string);
			}
			else if(IsPlayerInRangeOfPoint(i, f_Radius / 4, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
				SendClientMessage(i, col3, string);
			}
			else if(IsPlayerInRangeOfPoint(i, f_Radius / 2, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
				SendClientMessage(i, col4, string);
			}
			else if(IsPlayerInRangeOfPoint(i, f_Radius, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
				SendClientMessage(i, col5, string);
			}
		}
	}
	return 1;
}

stock IsVehicleRCVehicle(vehicleid)
{
    switch(GetVehicleModel(vehicleid))
    {
         case 441,464,465,501,564,594: return 1;
    }
    return 0;
}

//============================================================================//
//  End of the Line    //
//============================================================================//
