/*
 *
 * Jake's Administration 3.1 include 
 * (c), 2013
 * Never been bitter!
 * Useful, Important functions!
 *
 native:

 native KickDelay(playerid);
 native GetName(playerid);
 native getIP(playerid);
 native split(const strsrc[], strdest[][], delimiter);
 native Cenzura(string[], words[], destch = '*');
 native stringContainsIP(string[]);
 native IsValidPassword(const password[]);
 native ReColour(text[]);
 native GetTodaysDate();
 native GetTodaysTime();
 native GetVehicleModelIDFromName(const vname[]);
 native GetWeaponIDFromName(WeaponName[]);
 native IsValidWeapon(weaponid);
 native VehicleOccupied(vehicleid);
 native GetPlayerJLevel(playerid);
 native GetPlayerCookies(playerid);
 native GetPlayerKills(playerid);
 native GetPlayerDeaths(playerid);
 native GetPlayerLogged(playerid);
 native SetPlayerLogged(playerid, logged);
 native db_Insert(account[], column[], int);
 native db_Account(account[]);
 native SetPlayerLevel(playerid, level);
 native SetPlayerKills(playerid, kills);
 native SetPlayerDeaths(playerid, deaths);
 native SetPlayerCookies(playerid, cookies);
 native IsPlayerMuted(playerid);
 native IsPlayerFrozen(playerid);
 native IsPlayerJailed(playerid);
 native SetPlayerGod(playerid, god);
 native SetPlayerGodCar(playerid, godcar);
 native GetPlayerGod(playerid);
 native GetPlayerGodCar(playerid); 

 */

#include <a_samp>
#include <dini>

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

new DB:d_Da;

public OnFilterScriptInit()
{
	d_Da = db_open("JakAdmin/Accounts/juser.db");
    #if defined jak_OnFilterScriptInit
        jak_OnFilterScriptInit();
    #endif
    return 1;
}
#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit jak_OnFilterScriptInit
#if defined jak_OnFilterScriptInit
    forward jak_OnFilterScriptInit();
#endif

public OnFilterScriptExit()
{
	db_close(d_Da);
    #if defined jak_OnFilterScriptExit
        jak_OnFilterScriptExit();
    #endif
    return 1;
}
#if defined _ALS_OnFilterScriptExit
    #undef OnFilterScriptExit
#else
    #define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit jak_OnFilterScriptExit
#if defined jak_OnFilterScriptExit
    forward jak_OnFilterScriptExit();
#endif

public OnGameModeInit()
{
	d_Da = db_open("JakAdmin/Accounts/juser.db");
    #if defined jak_OnGameModeInit
        jak_OnGameModeInit();
    #endif
    return 1;
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit jak_OnGameModeInit
#if defined jak_OnGameModeInit
    forward jak_OnGameModeInit();
#endif

public OnGameModeExit()
{
	db_close(d_Da);
    #if defined jak_OnGameModeExit
        jak_OnGameModeExit();
    #endif
    return 1;
}
#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit jak_OnGameModeExit
#if defined jak_OnGameModeExit
    forward jak_OnGameModeExit();
#endif

new KickTimer[MAX_PLAYERS];
forward KickPlayer(playerid);

stock db_Account(account[])
{
	new Buffer[240], bool:Entry, DBResult:Result;

	format(Buffer, sizeof(Buffer), "SELECT `userid` FROM `users` WHERE `name` = '%s'", account);
	Result = db_query(d_Da, Buffer);

	if(Result)
	{
		if(db_num_rows(Result))
		{
			Entry = true;
			db_free_result(Result);
		}
		else Entry = false;
	}
	return Entry;
}
stock db_Insert(account[], column[], int)
{
	new Query[100];
	format(Query, 100, "UPDATE `users` SET `%s` = '%d' WHERE `name` = '%s'", column, int, account);
	db_query(d_Da, Query);
}

stock SetPlayerGod(playerid, god)
{
	if(god < 0) god = 0;
	if(god > 1) god = 1;
	SetPVarInt(playerid, "j_God", god);
	return true;
}
stock SetPlayerGodCar(playerid, godcar)
{
	if(godcar < 0) godcar = 0;
	if(godcar > 1) godcar = 1;
	SetPVarInt(playerid, "j_GCar", godcar);
	return true;
}
stock SetPlayerLevel(playerid, level)
{
	if(level < 0) level = 0;
	if(level > dini_Int("JakAdmin/Config/script.ini", "MaxLevel")) level = dini_Int("JakAdmin/Config/script.ini", "MaxLevel");
	SetPVarInt(playerid, "j_Level", level);

	if(db_Account(GetName(playerid)))
	{
	    db_Insert(GetName(playerid), "level", level);
	}
	return true;
}
stock SetPlayerLogged(playerid, logged)
{
	if(logged < 0) logged = 0;
	if(logged > 1) logged = 1;
	SetPVarInt(playerid, "j_Logged", logged);
	return true;
}
stock SetPlayerKills(playerid, kills)
{
	if(kills < 0) kills = 0;
	SetPVarInt(playerid, "j_Kills", kills);

	if(db_Account(GetName(playerid)))
	{
	    db_Insert(GetName(playerid), "kills", kills);
	}
	return true;
}
stock SetPlayerDeaths(playerid, deaths)
{
	if(deaths < 0) deaths = 0;
	SetPVarInt(playerid, "j_Deaths", deaths);

	if(db_Account(GetName(playerid)))
	{
	    db_Insert(GetName(playerid), "deaths", deaths);
	}
	return true;
}
stock SetPlayerCookies(playerid, cookies)
{
	if(cookies < 0) cookies = 0;
	SetPVarInt(playerid, "j_Cookies", cookies);

	if(db_Account(GetName(playerid)))
	{
	    db_Insert(GetName(playerid), "cookies", cookies);
	}
	return true;
}

stock KickDelay(playerid)
{
	KickTimer[playerid] = SetTimerEx("KickPlayer", 1000, false, "d", playerid);
	return 1;
}
public KickPlayer(playerid)
{
	return Kick(playerid);
}

stock GetPlayerJLevel(playerid) return GetPVarInt(playerid, "j_Level");
stock GetPlayerCookies(playerid) return GetPVarInt(playerid, "j_Cookies");
stock GetPlayerKills(playerid) return GetPVarInt(playerid, "j_Kills");
stock GetPlayerDeaths(playerid) return GetPVarInt(playerid, "j_Deaths");
stock GetPlayerLogged(playerid) return GetPVarInt(playerid, "j_Logged");
stock IsPlayerMuted(playerid) return GetPVarInt(playerid, "j_Mute");
stock IsPlayerFrozen(playerid) return GetPVarInt(playerid, "j_Frozen");
stock IsPlayerJail(playerid) return GetPVarInt(playerid, "j_Jail");
stock GetPlayerGod(playerid) return GetPVarInt(playerid, "j_God");
stock GetPlayerGodCar(playerid) return GetPVarInt(playerid, "j_GCar");

stock IsMonth31(month)
{
 	switch (month)
	{
	    case 1: return 1;
	    case 3: return 1;
	    case 5: return 1;
	    case 7: return 1;
	    case 8: return 1;
	    case 10: return 1;
	    case 12: return 1;
	    default: return 0;
	}
	return 0;
}

stock IsMonth29(year)
{
 	new y = 2000;
 	for(new i = 4; i < 3000; i += 4) if ((y+i) == year) return 1;
 	return 0;
}

stock GetVehicleModelIDFromName(const vname[])
{
    for(new i=0; i < sizeof(VehicleName); i++)
    {
        if (strfind(VehicleName[i], vname, true) != -1) return i + 400;
    }
    return -1;
}

stock VehicleOccupied(vehicleid)
{
	foreach(new i : Player)
	{
		if(IsPlayerInVehicle(i,vehicleid)) return 1;
	}
	return 0;
}

stock IsValidWeapon(weaponid)
{
    if (weaponid > 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
    return 0;
}

stock GetWeaponIDFromName(WeaponName[])
{
	if(strfind("molotov",WeaponName,true)!=-1)
	return 18;
	for(new i = 0; i <= 46; i++)
	{
	switch(i)
	{
	case 0,19,20,21,44,45: continue;
	default:
	{
	new name[32]; GetWeaponName(i,name,32);
	if(strfind(name,WeaponName,true) != -1)
	return i;
	}
	}
	}
	return -1;
}

stock ClearChatB(playerid, lines=50)
{
	for(new i=0; i<lines; i++) SendClientMessage(playerid, -1, " ");
	return 1;
}

stock GetName(playerid)
{
	new pName[24];
	GetPlayerName(playerid, pName, 24);
	return pName;
}
stock getIP(playerid)
{
	new iP[20];
	GetPlayerIp(playerid, iP, 20);
	return iP;
}
stock split(const strsrc[], strdest[][], delimiter)
{
    new i, li;
    new aNum;
    new len;
    while(i <= strlen(strsrc))
    {
        if(strsrc[i] == delimiter || i == strlen(strsrc))
        {
            len = strmid(strdest[aNum], strsrc, li, i, 128);
            strdest[aNum][len] = 0;
            li = i+1;
            aNum++;
        }
        i++;
    }
    return 1;
}
stock Cenzura(string[], words[], destch = '*')
{
	new start_index = (-1),
	    end_index = (-1);

	start_index = strfind(string, words, true);
	if(start_index == (-1)) return false;
	end_index = (start_index+strlen(words));

	for( ; start_index < end_index; start_index++)
		string[start_index] = destch;
	return true;
}
stock AntiIP(const string[])
{
    new dotCount;
    if(string[0])
    {
        if(!strfind(string,"www.",false) || !strfind(string,"http://",false)
        || !strfind(string,".com",false) || !strfind(string,".net",false)
	  || !strfind(string,".de",false)  || !strfind(string,".org",false))
        return true;
    }
    for(new i; string[i] != EOS; ++i)
    {
        if(('0' <= string[i] <= '9') || string[i] == '.' || string[i] == ':')
        {
            if((string[i] == '.') && (string[i + 1] != '.') && ('0' <= string[i - 1] <= '9'))
            {
                ++dotCount;
            }
            continue;
        }
    }
    return (dotCount > 2);
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
stock ReColour(text[])
{
	new
	pos = -1;
	while ((pos = strfind(text, "(", false, pos + 1)) != -1)
	{
		new
		c = pos + 1,
		n = 0,
		ch;
		while ((ch = text[c]) && n != 6)
		{
			if (!('a' <= ch <= 'f' || 'A' <= ch <= 'F' || '0' <= ch <= '9'))
			{
				break;
			}
			++c;
			++n;
		}
		if (n == 6 && ch == ')')
		{
			text[pos] = '{';
			text[c] = '}';
		}
	}
}
stock GetTodaysDate()
{
	new
		str[35]
	;
	new y, m, d;
	getdate(y, m, d);
	format(str, sizeof str, "%d-%d-%d", m, d, y);
	return str;
}

stock GetTodaysTime()
{
	new
		str[35]
	;
	new hs, ms, ss;
	gettime(hs, ms, ss);
	format(str, sizeof str, "%d:%d:%d", hs, ms, ss);
	return str;
}