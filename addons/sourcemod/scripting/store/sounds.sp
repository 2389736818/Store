enum Sound
{
	String:szSound[PLATFORM_MAX_PATH],
	String:szShortcut[64],
	unPrice
}

new g_eSounds[STORE_MAX_ITEMS][Sound];
new g_iSounds = 0;

public Sounds_OnPluginStart()
{
	Store_RegisterHandler("sound", "path", Sounds_OnMapStart, Sounds_Reset, Sounds_Config, Sounds_Equip, Sounds_Remove, false);

	HookEvent("player_say", Sounds_PlayerSay);
}

public Sounds_OnMapStart()
{
	decl String:tmp[PLATFORM_MAX_PATH];
	for(new i=0;i<g_iSounds;++i)
	{
		strcopy(tmp, sizeof(tmp), g_eSounds[i][szSound]);
		PrecacheSound(tmp[6], true);
		Downloader_AddFileToDownloadsTable(g_eSounds[i][szSound]);
	}
}

public Sounds_Reset()
{
	g_iSounds = 0;
}

public Sounds_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, g_iSounds);
	
	KvGetString(kv, "path", g_eSounds[g_iSounds][szSound], PLATFORM_MAX_PATH);
	KvGetString(kv, "trigger", g_eSounds[g_iSounds][szShortcut], 64);
	g_eSounds[g_iSounds][unPrice] = KvGetNum(kv, "price");
	
	if(FileExists(g_eSounds[g_iSounds][szSound], true))
	{
		++g_iSounds;
		return true;
	}
	
	return false;
}

public Sounds_Equip(client, id)
{
	new m_iData = Store_GetDataIndex(id);
	LoopIngamePlayers(i)
	{
		ClientCommand(i, "play %s", g_eSounds[m_iData][szSound][6]);
	}
	return 1;
}

public Sounds_Remove(client, id)
{
	return 0;
}

public Action:Sounds_PlayerSay(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientInGame(client))
		return Plugin_Continue;
	
	new String:msg[256];
	GetEventString(event, "text", msg, sizeof(msg));

	for(new i=0;i<g_iSounds;++i)
	{
		if(strcmp(msg, g_eSounds[i][szShortcut])==0)
		{
			new c = Store_GetClientCredits(client);
			if(c>=g_eSounds[i][unPrice])
			{
				Store_SetClientCredits(client, c-g_eSounds[i][unPrice]);
				decl String:tmp[PLATFORM_MAX_PATH];
				strcopy(tmp, sizeof(tmp), g_eSounds[i][szSound]);
				LoopIngamePlayers(a)
				{
					ClientCommand(a, "play %s", tmp[6]);
				}
			}
			else
			{
				CPrintToChat(client, "%t", "Credit Not Enough");
			}
			break;
		}
	}

	return Plugin_Continue;
}