/*
Green 1: 1272.528076, -94.223465, 16.010805
Green 2: 1434.697876, -101.254517, 16.010805
Green 3: 1600.393677, -103.242691, 16.010805
Green 4: 1761.597778, -112.073822, 16.010805

Yellow 1: 1270.693481, -2918.785400, 16.011347
Yellow offset from green: 0, 2824, 0

Blue 1: 1270.031250, -1023.449341, 16.011347
Blue offset from green: 0, 929, 0

Red 1: 1270.031250, -1960.031250, 16.011339
Red offset from green: 0, 1866, 0

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

Vector vYellowOffset = Vector(0.0f, 2824.0f, 0.0f);
Vector vYellowRandomizer = vGreenRandomizer - vYellowOffset;
Vector vYellowUpgrader = vGreenUpgrader - vYellowOffset;
array<Vector> vYellowStations = {
	vGreenStations[0] - vYellowOffset,
	vGreenStations[1] - vYellowOffset,
	vGreenStations[2] - vYellowOffset,
	vGreenStations[3] - vYellowOffset,
};

Vector vYellowCenter = vGreenCenter - vYellowOffset;
Vector vYellowMin = vGreenMin - vYellowOffset;
Vector vYellowMax = vGreenMax - vYellowOffset;

Vector vBlueOffset = Vector(0.0f, 940.0f, 0.0f);
Vector vBlueRandomizer = vGreenRandomizer - vBlueOffset;
Vector vBlueUpgrader = vGreenUpgrader - vBlueOffset;
array<Vector> vBlueStations = {
	vGreenStations[0] - vBlueOffset,
	vGreenStations[1] - vBlueOffset,
	vGreenStations[2] - vBlueOffset,
	vGreenStations[3] - vBlueOffset,
};

Vector vBlueCenter = vGreenCenter - vBlueOffset;
Vector vBlueMin = vGreenMin - vBlueOffset;
Vector vBlueMax = vGreenMax - vBlueOffset;

Vector vRedOffset = Vector(0.0f, 1890.0f, 0.0f);
Vector vRedRandomizer = vGreenRandomizer - vRedOffset;
Vector vRedUpgrader = vGreenUpgrader - vRedOffset;
array<Vector> vRedStations = {
	vGreenStations[0] - vRedOffset,
	vGreenStations[1] - vRedOffset,
	vGreenStations[2] - vRedOffset,
	vGreenStations[3] - vRedOffset,
};

Vector vRedCenter = vGreenCenter - vRedOffset;
Vector vRedMin = vGreenMin - vRedOffset;
Vector vRedMax = vGreenMax - vRedOffset;

array<EHandle> greenSpecimen;
array<EHandle> yellowSpecimen;
array<EHandle> blueSpecimen;
array<EHandle> redSpecimen;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Liam Swift");
	g_Module.ScriptInfo.SetContactInfo("liam.swift.wooooooof@gmail.com");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
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
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "Playing STS green AI..\n" );
			DoSTSRound(greenSpecimen, vGreenMin, vGreenMax, vGreenUpgrader, vGreenRandomizer, vGreenStations);
		}

		if (pArguments[0] == "!yellow") {
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "Playing STS yellow AI..\n" );
			DoSTSRound(yellowSpecimen, vYellowMin, vYellowMax, vYellowUpgrader, vYellowRandomizer, vYellowStations);
		}

		if (pArguments[0] == "!blue") {
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "Playing STS blue AI..\n" );
			DoSTSRound(blueSpecimen, vBlueMin, vBlueMax, vBlueUpgrader, vBlueRandomizer, vBlueStations);
		}

		if (pArguments[0] == "!red") {
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "Playing STS red AI..\n" );
			DoSTSRound(redSpecimen, vRedMin, vRedMax, vRedUpgrader, vRedRandomizer, vRedStations);
		}
	}
	
	return HOOK_CONTINUE;
}

void DoSTSRound(array<EHandle> &specimenArray, Vector min, Vector max, Vector upgrader, Vector randomizer, array<Vector> &stations)
{
	ReloadSpecimen(specimenArray, min, max);
	EmptyUpgrader(upgrader, stations[0]);

	float delayUnit = 3.0f;

	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, specimenArray.length());
	for (uint i = 0; i < specimenArray.length(); i++)
	{
		g_Scheduler.SetTimeout(
			"MoveSpecimenToUpgrader", delayUnit + delayUnit * 2.0f * i, specimenArray[i], upgrader
		);
		g_Scheduler.SetTimeout(
			"EmptyUpgrader", 2.0f * delayUnit + delayUnit * 2.0f * i, upgrader, stations[0]
		);
	}

	g_Scheduler.SetTimeout("ReloadSpecimen", 9.0f * delayUnit, specimenArray, min, max);

	for (uint i = 0; i < specimenArray.length(); i++)
	{
		g_Scheduler.SetTimeout(
			"MoveSpecimenToRandomizer", 10.0f * delayUnit + delayUnit * 2.0f * i, specimenArray[i], randomizer
		);
		g_Scheduler.SetTimeout(
			"MoveSpecimenToStation", 11.0f * delayUnit + delayUnit * 2.0f * i, specimenArray[i], stations[i]
		);	
	}

	g_Scheduler.SetTimeout("ReadyUp", 20.0f * delayUnit, min, max);
}

void MoveSpecimenToUpgrader(EHandle specimen, Vector upgrader) 
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Move specimen to upgrader\n" );

	Teleport(specimen.GetEntity(), upgrader);
}

void MoveSpecimenToRandomizer(EHandle specimen, Vector randomizer)
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Move specimen to randomizer\n" );

	Teleport(specimen.GetEntity(), randomizer);
}

void MoveSpecimenToStation(EHandle specimen, Vector station)
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Move specimen to station\n" );

	Teleport(specimen.GetEntity(), station);
}

void ReloadSpecimen(array<EHandle> &specimenArray, Vector min, Vector max)
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Reload specimen\n" );

	array<CBaseEntity@> nearbyBrushEntities(24);
	int r = g_EntityFuncs.BrushEntsInBox(@nearbyBrushEntities, min, max);

	specimenArray.resize(0);
	for (uint i = 0; i < nearbyBrushEntities.length(); i++)
	{
		if (nearbyBrushEntities[i] !is null && nearbyBrushEntities[i].GetClassname() == 'func_pushable') {
			specimenArray.insertLast(nearbyBrushEntities[i]);
		}
	}
}

void EmptyUpgrader(Vector upgrader, Vector targetStation) 
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Empty upgrader\n" );

	array<CBaseEntity@> nearbyBrushEntities(24);
	int r = g_EntityFuncs.BrushEntsInBox(
		@nearbyBrushEntities, upgrader - vUpgraderFindBox, upgrader + vUpgraderFindBox
	);

	for (uint i = 0; i < nearbyBrushEntities.length(); i++)
	{
		if (nearbyBrushEntities[i] !is null && nearbyBrushEntities[i].GetClassname() == 'func_pushable') {
			MoveSpecimenToStation(nearbyBrushEntities[i], targetStation);
		}
	}
}

void ReadyUp(Vector min, Vector max)
{
	g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "> Ready up\n" );

	array<CBaseEntity@> nearbyBrushEntities(24);
	int r = g_EntityFuncs.BrushEntsInBox(@nearbyBrushEntities, min, max);

	for (uint i = 0; i < nearbyBrushEntities.length(); i++)
	{
		if (nearbyBrushEntities[i] !is null && nearbyBrushEntities[i].GetClassname() == 'func_rot_button') {
			nearbyBrushEntities[i].Use(null, null, USE_ON, 0.0f);
		}
	}
}

void Teleport(EHandle specimen, Vector upgrader)
{
	Vector vTeleportOffset = Vector(0.0f, 0.0f, 5.0f);

	specimen.GetEntity().SetOrigin(upgrader);
	specimen.GetEntity().Touch(specimen);
	specimen.GetEntity().Blocked(specimen);
}