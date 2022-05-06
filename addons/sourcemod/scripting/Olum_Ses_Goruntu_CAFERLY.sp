#include <sdktools>
#include <clientprefs>

public Plugin myinfo =
{
	name = "[GENEL] Ölünce Ekran ve Ses Efektir",
	description = ".",
	author = "Caferly",
	version = "1.1",
	url = "hovn.com"
};

ConVar	overlay,
		sound,
		overlaytime;

Handle g_hCookie;
float lifetime;
char g_sPath[2][128];
bool g_bSett[66][2];

public void OnPluginStart()
{
	HookEvent("round_start",  Events,EventHookMode_PostNoCopy);
	HookEvent("player_death", Events,EventHookMode_Pre);

	RegConsoleCmd("sm_os", Overlay);

	overlay = CreateConVar("sm_olum_goruntu", "caferly/dead","Ölünce çıkacak ekran.");
	sound = CreateConVar("sm_olum_ses", "caferly/wasted.mp3","Ölünce çıkacak ses");
	overlaytime = CreateConVar("sm_olum_goruntu_sure", "5.0","Ekranda kaç saniye görüntü duracak.");

	overlay.AddChangeHook(OnCvarChanged);
	sound.AddChangeHook(OnCvarChanged);
	overlaytime.AddChangeHook(OnCvarChanged);

	AutoExecConfig(true, "OlumSesGoruntu");

	g_hCookie = RegClientCookie("overlay_settings", "",  CookieAccess_Private);
}
///////////////////////////////// 
public void OnConfigsExecuted()
{
	char bufi[128];
	overlay.GetString(g_sPath[0],128);
	sound.GetString(g_sPath[1],128);
	lifetime = overlaytime.FloatValue;

	FormatEx(bufi, sizeof(bufi), "materials/%s.vmt", g_sPath[0]);
	AddFileToDownloadsTable(bufi);
	PrecacheDecal(bufi);

	FormatEx(bufi, sizeof(bufi), "materials/%s.vtf", g_sPath[0]);
	AddFileToDownloadsTable(bufi);
	PrecacheDecal(bufi,true);

	FormatEx(bufi, sizeof(bufi), "sound/%s", g_sPath[1]);
	AddFileToDownloadsTable(bufi);
	PrecacheSound(bufi,true);

	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
}
///////////////////////////////// 
Action Overlay(int client,int argc)
{
	if(client)
	{
		char bufi[64];
		Menu menu = new Menu(MenuHandler);

		menu.SetTitle("- - - AYARLAR - - - ");
		menu.ExitButton = true;

		FormatEx(bufi, sizeof(bufi), "Görüntü [%Devre dışı]", g_bSett[client][0]? "":"s");
		menu.AddItem(NULL_STRING, bufi);
		FormatEx(bufi, sizeof(bufi), "Ses [%Devre Dışı]", g_bSett[client][1]? "":"s");
		menu.AddItem(NULL_STRING, bufi);

		menu.Display(client, MENU_TIME_FOREVER);
	}
}
///////////////////////////////// 
int MenuHandler(Menu menu, MenuAction action,int client, int a)
{
	if(action == MenuAction_Select)
	{
		g_bSett[client][a] = !g_bSett[client][a];
		Overlay(client,0);
	}
	else if(action == MenuAction_End)
		delete menu;
}
///////////////////////////////// 
public void OnClientCookiesCached(int client)
{
	char bufi[4];
	GetClientCookie(client, g_hCookie, bufi,4);
	g_bSett[client][0] = bufi[0] ? (bufi[0] == '1'):true;
	g_bSett[client][1] = bufi[1] ? (bufi[1] == '1'):true;
}
///////////////////////////////// 
void OnCvarChanged(ConVar convar, char[] old, char[] neww)
{
	if(convar == overlay)
	{
		strcopy(g_sPath[0], 128, neww);
		return;
	}
	else if (convar == sound)
	{
		strcopy(g_sPath[1], 128, neww);
		return;
	}
	else if (convar == overlaytime)
	{
		lifetime = StringToFloat(neww);
		return;
	}
}
///////////////////////////////// 
void Events(Event event, char[] name, bool dontBroadcast)
{
	if(name[0] == 'r')
	{
		for(int i = 1; i <= MaxClients;i++) if(IsClientInGame(i))
		ClientCommand(i, "r_screenoverlay \"\"");
	}
	else
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (client > 0 && IsClientInGame(client) && !IsFakeClient(client))
		{
			if(g_bSett[client][0])
			{
				ClientCommand(client, "r_screenoverlay %s", g_sPath[0]);
				CreateTimer(lifetime,RemoveOverlay,client);
			}
			if(g_bSett[client][1])
				ClientCommand(client, "playgamesound *%s", g_sPath[1]);
		}
	}
}
///////////////////////////////// 
Action RemoveOverlay(Handle Timer, int client)
{
	if(IsClientInGame(client))
		ClientCommand(client, "r_screenoverlay \"\"");
}
///////////////////////////////// 
public void OnClientDisconnect(int client)
{
	if (AreClientCookiesCached(client))
	{
		char bufi[4];
		FormatEx(bufi, sizeof(bufi), "%d%d", g_bSett[client][0], g_bSett[client][1]);
		SetClientCookie(client, g_hCookie,bufi);
	}
}



///////////////////////////////// 
///////////////////////////////////////////////// vututututut bebeğim sen rx7 değilsin VUTUTUTUTUTUTU!!!!!!!!!
///////////////////////////////////////////////// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿
///////////////////////////////////////////////// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣉⣁⣤⣤⣶⣾⣿⣿⣶⡄⢲⣯⢍⠁⠄⢀⢹⣿
///////////////////////////////////////////////// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⣾⣿⣿⣏⣉⣹⠿⠇⠄⠽⠿⢷⡈⠿⠇⣀⣻⣿⡿⣻
///////////////////////////////////////////////// ⣿⣿⡿⠿⠛⠛⠛⢛⡃⢉⢣⡤⠤⢄⡶⠂⠄⠐⣀⠄⠄⠄⠄⠄⡦⣿⡿⠛⡇⣼
///////////////////////////////////////////////// ⡿⢫⣤⣦⠄⠂⠄⠄⠄⠄⠄⠄⠄⠄⠠⠺⠿⠙⠋⠄⠄⠄⠢⢄⠄⢿⠇⠂⠧⣿
///////////////////////////////////////////////// ⠁⠄⠈⠁⠄⢀⣀⣀⣀⣀⣠⣤⡤⠴⠖⠒⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⢠⡞⠄⣸
///////////////////////////////////////////////// ⡀⠄⠄⠄⠄⠄⠤⠭⠦⠤⠤⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⣂⣿
///////////////////////////////////////////////// ⣷⡀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢳⠄⠄⢀⠈⣠⣤⣤⣼⣿
///////////////////////////////////////////////// ⣿⣿⣷⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣴⣶⣶⣶⣄⡀⠄⠈⠑⢙⣡⣴⣿⣿⣿⣿⣿
///////////////////////////////////////////////// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
