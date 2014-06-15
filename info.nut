/*
	Simpleton City Builder info.nut
	SimpletonCBInfo class - information and settings

	Origin - Novapolis team, http://novapolis.net
	Author - The Dude
	Licence - GPLv2
	Purpose - Simple city builder script, towns require cargos to grow
	Special Thanks
		- xOR, Knogle and Frank for help and Sign management part
		- Zuu, frosch and OpenTTD Development team for GS and all (openttd.org)
*/

class SimpletonCBInfo extends GSInfo {
	function GetAuthor()      { return "TheDude"; }
	function GetName()        { return "Simpleton's City Builder"; }
	function GetDescription() { return "Easily configured City Builder simulation script"; }
	function GetVersion()     { return 8; }
	function GetDate()        { return "2014-05-11"; }
	function CreateInstance() { return "SimpletonCB"; }
	function GetShortName()   { return "SMCB"; }
	function GetAPIVersion()  { return "1.4"; }
	function GetUrl()         { return "http://novapolis.net"; }

	function GetSettings() {
		AddSetting({
			name = "morelogs",
			description = "Print more logs to Script console",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			min_value = 0,
			max_value = 2,
			flags = CONFIG_NONE | CONFIG_INGAME,
		});
		AddLabels(
			"morelogs", {_0 = "Normal", _1 = "More", _2 = "More more"}
		);

		AddSetting({
			name = "startpause",
			description = "Pause game on start. Unpause when first company starts",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN,
		});
		AddSetting({
			name = "xMapgen",
			description = "Generate Power Plant, Water Tower industries for each town (climate dependant)",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN,
		});
		AddSetting({
			name = "goal",
			description = "City Builder Goal (population)",
			easy_value = 5000,
			medium_value = 10000,
			hard_value = 50000,
			custom_value = 10000,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 1000000,
		});
		AddSetting({
			name = "gamelength",
			description = "Game Length in Years. If set to 0, game ends when goal reached",
			easy_value = 12,
			medium_value = 12,
			hard_value = 12,
			custom_value = 12,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 1000,
		});
		AddSetting({
			name = "changetownname",
			description = "Town name - change town name according to its company owner and population",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME,
		});
		AddSetting({
			name = "goalprogress",
			description = "Goal progress messages. Informs players about game end and goal progress of all companies.",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME,
		});
		AddSetting({
			name = "townarea",
			description = "Town area - place signs around town, set 0 to disable",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 50,
		});

		AddSetting({
			name = "dyngrowth",
			description = "Dynamic change of town growth rate. Every 5 years is increased by 1 up to maximum 4",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME,
		});

		AddSetting({
			name = "growmechanism",
			description = "Town Growth mechanism",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			min_value = 0,
			max_value = 1,
			flags = CONFIG_NONE | CONFIG_INGAME,
		});
		AddLabels(
			"growmechanism", {_0 = "Normal", _1 = "Expand"} //, _2 = "diversified"
		);

		AddSetting({
			name = "claimpop",
			description = "Max claimable town population",
			easy_value = 800,
			medium_value = 500,
			hard_value = 250,
			custom_value = 250,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 50000,
		});

		AddSetting({
			name = "storage",
			description = "Town storage (x times requirements)",
			easy_value = 4,
			medium_value = 4,
			hard_value = 4,
			custom_value = 4,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 100,
		});

		AddSetting({
			name = "div000", description = "", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN,
		});
		AddSetting({
			name = "category000", description = " >>> TOWN REQUIREMENTS PER 1000 INHABITANTS <<< ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN,
		});
		AddSetting({
			name = "category001", description = "   > ECS and FIRS cargos are marked E: or F: when they are different from original cargos < ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN,
		});

		local cargoDef = [
/* CARGOID  REQ   FROM  DEC  CARGO NAME (NORMAL, E=ECS, F=FIRS) */
/* 00 */ [  200,     0,   0, "Passengers" ],
/* 01 */ [  100,   250,   0, "Coal / Rubber / Sugar" ],
/* 02 */ [   40,   500,   0, "Mail" ],
/* 03 */ [    0,     0,   0, "Oil / Toys" ],
/* 04 */ [    0,     0,   0, "Livestock / Fruit / Batteries" ],
/* 05 */ [  150,  1500,   0, "Goods/ Sweets" ],
/* 06 */ [    0,     0,   0, "Grain / Wheat / Maize / Toffee / E:Cereals" ],
/* 07 */ [    0,     0,   0, "Wood / Cola" ],
/* 08 */ [    0,     0,   0, "Iron Ore / - / Copper Ore / Cotton Candy" ],
/* 09 */ [    0,     0,   0, "Steel / Paper / Water / Bubbles / F:Metal" ],
/* 10 */ [   20,  2500,   0, "Valuables / Gold / Diamonds / Plastic / F:Milk" ],
/* 11 */ [    0,     0,   0, "Food / Fizzy Drinks" ],
/* 12 */ [    0,     0,   0, " - / E:Paper / F:Sugar Cane (Beet)" ],
/* 13 */ [    0,     0,   0, " - / E:F:Fruit" ],
/* 14 */ [    0,     0,   0, " - / E:F:Fish" ],
/* 15 */ [    0,     0,   0, " - / E:F:Wool" ],
/* 16 */ [    0,     0,   0, " - / F:F:Clay" ],
/* 17 */ [    0,     0,   0, " - / E:F:Sand" ],
/* 18 */ [    0,     0,   0, " - / E:Glass / F:Manufacturing Supplies" ],
/* 19 */ [    0,     0,   0, " - / E:Wood Products / F:Lumber" ],
/* 20 */ [    0,     0,   0, " - / E:Dyes / F:Scrap Metal" ],
/* 21 */ [    0,     0,   0, " - / E:Fertiliser / F:Farm Supplies" ],
/* 22 */ [    0,     0,   0, " - / E:Oil seed / F:Plant Fibres" ],
/* 23 */ [    0,     0,   0, " - / E:Refined products / F:Chemicals" ],
/* 24 */ [    0,     0,   0, " - / E:Vehicles / F:Engineering Supplies" ],
/* 25 */ [    0,     0,   0, " - / E:F:Petrol" ],
/* 26 */ [    0,     0,   0, " - / E:Bricks / F:Stone" ],
/* 27 */ [    0,     0,   0, " - / E:Water / F:Bauxite" ],
/* 28 */ [    0,     0,   0, " - / E:Cement / F:Building Materials" ],
/* 29 */ [    0,     0,   0, " - / E:Lime stone / F:Alcohol" ],
/* 30 */ [    0,     0,   0, " - / E:Lime stone" ],
/* 31 */ [    0,     0,   0, " - / E:Tourists / F:Recyclables" ]
		];

		local var = "";
		for(local i = 0; i < 32; i++){
			AddSetting({ name = "cat"+i, description = " >>> "+cargoDef[i][3]+" <<< ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN, });
			var = "req" + i;
			AddSetting({ name = var, description = "Requirements ", min_value = 0, max_value = 10000, easy_value = cargoDef[i][0], medium_value = cargoDef[i][0], hard_value = cargoDef[i][0], custom_value = cargoDef[i][0], flags = CONFIG_NONE | CONFIG_INGAME, });
			var = "pop" + i;
			AddSetting({ name = var, description = "From", min_value = 0, max_value = 50000, easy_value = cargoDef[i][1], medium_value = cargoDef[i][1], hard_value = cargoDef[i][1], custom_value = cargoDef[i][1], flags = CONFIG_NONE | CONFIG_INGAME, });
			var = "dec" + i;
			AddSetting({ name = var, description = "Decay", min_value = 0, max_value = 100, easy_value = cargoDef[i][2], medium_value = cargoDef[i][2], hard_value = cargoDef[i][2], custom_value = cargoDef[i][2], flags = CONFIG_NONE | CONFIG_INGAME, });
		}
	}
}

RegisterGS(SimpletonCBInfo());