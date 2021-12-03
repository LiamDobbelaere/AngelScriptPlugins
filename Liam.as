/*
Green 1: 1272.528076, -94.223465, 16.010805
Green 2: 1434.697876, -101.254517, 16.010805
Green 3: 1600.393677, -103.242691, 16.010805
Green 4: 1761.597778, -112.073822, 16.010805

Green center area: 1515.575317, -286.405975, 16.010805
Green randomizer: 1884.461670, -209.567810, 16.010805
Green upgrader: 1880.806152, -371.189728, 16.010805
*/

Vector vUpgraderFindBox = Vector(35.0f, 35.0f, 64.0f);

Vector vGreenRandomizer = Vector(1884.461670f, -209.567810f, 16.010805f);
Vector vGreenUpgrader = Vector(1880.806152f, -371.189728f, 16.010805f);
array<Vector> vGreenStations = {
	Vector(1272.528076f, -94.223465f, 16.010805f),
	Vector(1434.697876f, -101.254517f, 16.010805f),
	Vector(1600.393677f, -103.242691f, 16.010805f),
	Vector(1761.597778f, -112.073822f, 16.010805f)
};

Vector vGreenCenter = Vector(1515.575317f, -286.405975f, 16.010805f);
Vector vGreenMin = Vector(1100.461670f, -480.567810f, 0.0f);
Vector vGreenMax = Vector(1900.012451f, -85.968750f, 64.0f);

// TODO: Reset on map load
array<CBaseEntity@> greenSpecimen;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Liam Swift");
	g_Module.ScriptInfo.SetContactInfo("liam.swift.wooooooof@gmail.com");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @OnMapChange);
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();
	
	if( pArguments.ArgC() >= 0 )
	{
		CBasePlayer@ pPlayer = pParams.GetPlayer();
		
		if( pArguments[ 0 ] == "ent?" )
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(pPlayer, 4096);
			
			if (pEntity !is null) {
				g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Class is \"" + pEntity.GetClassname() + "\"\n");
				g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Index is \"" + pEntity.entindex() + "\"\n");
				g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Origin is\"" + pEntity.GetOrigin().ToString() + "\"\n");
			} else {
				g_EngineFuncs.ClientPrintf(pPlayer, print_console, "No entity found at looktarget.\n");
			}

			pParams.ShouldHide = true;
			
			return HOOK_HANDLED;
		}

		if (pArguments[0] == "!green") {
			g_EngineFuncs.ClientPrintf(pPlayer, print_console, "Playing STS green AI..\n");
			ReloadGreenSpecimen();
			EmptyUpgrader(vGreenUpgrader);

			float delayUnit = 1.0f;

			for (uint i = 0; i < greenSpecimen.length(); i++)
			{
				g_Scheduler.SetTimeout(
					"MoveSpecimenToUpgrader", delayUnit + delayUnit * 2.0f * i, @greenSpecimen[i], vGreenUpgrader
				);
				g_Scheduler.SetTimeout(
					"EmptyUpgrader", 2.0f * delayUnit + delayUnit * 2.0f * i, vGreenUpgrader
				);
			}

			g_Scheduler.SetTimeout("ReloadGreenSpecimen", 9.0f * delayUnit);

			for (uint i = 0; i < greenSpecimen.length(); i++)
			{
				g_Scheduler.SetTimeout(
					"MoveSpecimenToRandomizer", 10.0f * delayUnit + delayUnit * 2.0f * i, @greenSpecimen[i], vGreenRandomizer
				);
				g_Scheduler.SetTimeout(
					"MoveSpecimenToStation", 11.0f * delayUnit + delayUnit * 2.0f * i, @greenSpecimen[i], vGreenStations[i]
				);	
			}
		}
	}
	
	return HOOK_CONTINUE;
}

void MoveSpecimenToUpgrader(CBaseEntity@ specimen, Vector upgrader) 
{
	specimen.SetOrigin(upgrader);
}

void MoveSpecimenToRandomizer(CBaseEntity@ specimen, Vector randomizer)
{
	specimen.SetOrigin(randomizer);
}

void MoveSpecimenToStation(CBaseEntity@ specimen, Vector station)
{
	specimen.SetOrigin(station);
}

void ReloadGreenSpecimen()
{
	array<CBaseEntity@> nearbyBrushEntities(24);
	int r = g_EntityFuncs.BrushEntsInBox(@nearbyBrushEntities, vGreenMin, vGreenMax);

	greenSpecimen.resize(0);
	for (uint i = 0; i < nearbyBrushEntities.length(); i++)
	{
		if (nearbyBrushEntities[i] !is null && nearbyBrushEntities[i].GetClassname() == 'func_pushable') {
			greenSpecimen.insertLast(nearbyBrushEntities[i]);
		}
	}
}

void EmptyUpgrader(Vector upgrader) 
{
	array<CBaseEntity@> nearbyBrushEntities(24);
	int r = g_EntityFuncs.BrushEntsInBox(
		@nearbyBrushEntities, upgrader - vUpgraderFindBox, upgrader + vUpgraderFindBox
	);

	for (uint i = 0; i < nearbyBrushEntities.length(); i++)
	{
		if (nearbyBrushEntities[i] !is null && nearbyBrushEntities[i].GetClassname() == 'func_pushable') {
			MoveSpecimenToStation(nearbyBrushEntities[i], vGreenStations[0]);
		}
	}
}

HookReturnCode OnMapChange()
{
	return HOOK_CONTINUE;
}
