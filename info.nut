/*
	Simpleton City Builder info.nut
	SimpletonCBInfo class - information and settings

	Origin - Novapolis team, https://novapolis.net
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
	function GetVersion()     { return 14; }
	function GetDate()        { return "2024-04-13"; }
	function CreateInstance() { return "SimpletonCB"; }
	function GetShortName()   { return "SMCB"; }
	function GetAPIVersion()  { return "1.11"; }
	function GetUrl()         { return "https://www.novapolis.net"; }

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
			flags = CONFIG_NONE | CONFIG_INGAME
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
			flags = CONFIG_BOOLEAN | CONFIG_INGAME
		});
		AddSetting({
			name = "xMapgen",
			description = "Generate Power Plant, Water Tower industries for each town (climate dependant)",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN
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
			max_value = 1000000
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
			max_value = 1000
		});
		AddSetting({
			name = "changetownname",
			description = "Town name - change town name according to its company owner and population",
			easy_value = 1,
			medium_value = 1,
			hard_value = 1,
			custom_value = 1,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME
		});
		AddSetting({
			name = "goalprogress",
			description = "Goal progress messages. Informs players about game end and goal progress of all companies.",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME
		});
		AddSetting({
			name = "townarea",
			description = "Town area - place signs around town. Set 0 to disable.",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 50
		});

		AddSetting({
			name = "dyngrowth",
			description = "Dynamic change of town growth rate. Every X years is increased by 1 up to maximum 4. Set to 0 to disable.",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_NONE,
			min_value = 0,
			max_value = 100
		});
		
		AddSetting({
			name = "cityPopLimit",
			description = "Limit cities population to percentage of the biggest claimed town on map. Set to 0 to disable.",
			easy_value = 50,
			medium_value = 50,
			hard_value = 50,
			custom_value = 50,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 1000
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
			flags = CONFIG_NONE | CONFIG_INGAME
		});
		AddLabels(
			"growmechanism", {_0 = "Normal", _1 = "Expand"} //, _2 = "diversified"
		);
		
		AddSetting({
			name = "townshrink",
			description = "Town will shrink slightly when not supplied",
			easy_value = 0,
			medium_value = 0,
			hard_value = 0,
			custom_value = 0,
			flags = CONFIG_BOOLEAN | CONFIG_INGAME
		});

		AddSetting({
			name = "claimpop",
			description = "Max claimable town population",
			easy_value = 800,
			medium_value = 500,
			hard_value = 250,
			custom_value = 250,
			flags = CONFIG_NONE | CONFIG_INGAME,
			min_value = 0,
			max_value = 50000
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
			max_value = 100
		});
		

		AddSetting({
			name = "div000", description = "City Builder Economy - Choose between various cargosets and climates presets. If you choose this, you don't have to set anything else regarding cargo requirements.", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_BOOLEAN
		});
		AddSetting({
			name = "div001", description = "If you choose CUSTOM and want your own settins you need to configure the individual cargo requirements in the next settings.", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_BOOLEAN
		});
		AddSetting({
			name = "div002", description = "If you choose any PRESET, changing values in cargo settings will have no effect. See readme for each PRESET values.", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_BOOLEAN
		});
		
		AddSetting({
			name = "cbeconomy",
			description = "City Builder Economy Preset",
			easy_value = 1,
			medium_value = 1,
			hard_value = 1,
			custom_value = 1,
			min_value = 0,
			max_value = 18,
			flags = CONFIG_NONE | CONFIG_INGAME
		});
		AddLabels(
			"cbeconomy", {
				_0 = "Custom",
				_1 = "Vanilla Temperate",
				_2 = "Vanilla Arctic",
				_3 = "Vanilla Tropic",
				_4 = "Vanilla Toyland",
				_5 = "ECS",
				_6 = "XIS"
				_7 = "YETI",
				
				_8  = "FIRS 3 Temperate",
				_9 = "FIRS 3 Arctic",
				_10 = "FIRS 3 Tropic",
				_11 = "FIRS 3 Hot Country",
				_12 = "FIRS 3 Steel Town",
				_13 = "FIRS 3 Extreme",
				
				_14 = "FIRS 4 Temperate",
				_15 = "FIRS 4 Arctic",
				_16 = "FIRS 4 Tropic",
				_17 = "FIRS 4 Hot Country",
				_18 = "FIRS 4 Steel Town"
			} 
		);

		AddSetting({
			name = "div002", description = "", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = CONFIG_BOOLEAN
		});
		AddSetting({
			name = "category000", description = " >>> TOWN REQUIREMENTS PER 1000 INHABITANTS <<< ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN
		});
		AddSetting({
			name = "category001", description = "   > Different cargosets are marked like this: empty:Vannila | E:ECS | F2=FIRS2 | F3T=FIRS3 TEMP | F3S=FIRS3 STEEL | F4T=FIRS4 TEMP | F4S=FIRS4 STEEL | Y=YETI | X=XIS  < ",
				easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN
		});

		local cargoDef = [
/* CARGOID  REQ   FROM  DEC  CARGO NAME (NORMAL, E=ECS, F2=FIRS2, F3T=FIRS3 TEMP, F3S=FIRS3 STEEL, F4T=FIRS4 TEMP, F4S=FIRS4 STEEL, Y=YETI, X=XIS) */
/* 00 */ [  200,   500,   0, "Passengers" ],
/* 01 */ [  100,   250,   0, "Coal / F2:Sugar / F3T:Alcohol / F3S:Cement / F4T:Alcohol / F4S:Acid / Y:Stone / X:Acid" ],
/* 02 */ [   40,  1000,   0, "Mail" ],
/* 03 */ [    0,     0,   0, "Oil/Toys / E:Oil / F2:Oil / F3T:Chemicals / F3S:Quicklime / F4T:Chemicals / F4S:Alloy Steel / Y:Wood / X:Alcohol" ],
/* 04 */ [    0,     0,   0, "Livestock /Fruit/Batteries / E:Livestock  / F2:Livestock  / F3T:Clay / F3S:Engineering Supplies / F4T:Coal / F4S:Aluminium / Y:Building Materials / X:Bauxite" ],
/* 05 */ [  200,  1500, 100, "Goods/ Sweets / E:Goods / F2:Goods / F3T:Goods / F3S:Vehicles / F4T:Goods / F4S:Vehicles / X:Goods" ],
/* 06 */ [    0,     0,   0, "Grain/Wheat/Maize/Toffee / E:Cereals / F2:Grain / F3T:Coal / F3S:Farm Supplies / F4T:Engineering Supplies / F4S:Carbon Black / Y:Grain / X:Soy" ],
/* 07 */ [    0,     0,   0, "Wood/Cola / E:Wood / F2:Wood / F3T:Engineering Supplies / F3S:Steel / F4T:Farm Supplies / F4S:Carbon Steel / Y:Fruits and Vegetable / X:Building Materials" ],
/* 08 */ [    0,     0,   0, "Iron Ore/-/Copper Ore/Cotton Candy  / E:Iron Ore / F2:Iron Ore / F3T:Farm Supplies / F3S:Slag / F4T:Fish / F4S:Cast Iron / Y:Food / X:Cement" ],
/* 09 */ [    0,     0,   0, "Steel/Paper/Water/Bubbles / E:Steel / F2:Metal / F3T:Fish / F3S:Limestone / F4T:Fruit / F4S:Cement / X:Petrochemicals" ],
/* 10 */ [   10,  2500, 100, "Valuables/Gold/Diamonds/Plastic / E:Gold / F2:Milk / F3T:Fruit / F3S:Sand / F4T:Iron Ore / F4S:Chlorine / Y:Oil / X:Chlorine" ],
/* 11 */ [    0,     0,   0, "Food/Fizzy Drinks / E:Food / F2:Food / F3T:Food / F3S:Food / F4T:Food / F4S:Food / X:Food" ],
/* 12 */ [    0,     0,   0, "E:Paper / F2:Sugar Cane (Beet) / F3T:Iron Ore / F3S:Manganese / F4T:Kaolin / F4S:Cleaning Agents / Y:Steel / X:Clay" ],
/* 13 */ [    0,     0,   0, "E:Fruit / F2:Fruit / F3T:Livestock / F3S:Coal / F4T:Livestock / F4S:Coal / Y:Refined Products / X:Coal Tar" ],
/* 14 */ [    0,     0,   0, "E:Fish / F2:Fish / F3T:Milk / F3S:Iron Ore / F4T:Milk / F4S:Coal Tar / Y:Batteries / X:Coke" ],
/* 15 */ [    0,     0,   0, "E:Wool / F2:Wool / F3T:Sand / F3S:Pig Iron / F4T:Sand / F4S:Coke / Y:Machinery / X:Copper" ],
/* 16 */ [    0,     0,   0, "E:Clay / F2:Clay / F3T:Scrap Metal / F3S:Coke / F4T:Scrap Metal / F4S:Electrical Parts / Y:YETI dudes / X:Copper Ore" ],
/* 17 */ [    0,     0,   0, "E:Sand / F2:Sand / F3T:Steel / F3S:Petroleum Fuels / F4T:Steel / F4S:Engineering Supplies / Y:Clay / X:Edible Oil" ],
/* 18 */ [    0,     0,   0, "E:Glass / F2:Manufacturing Supplies / F3S:Sulphur / F4S:Farm Supplies / Y:PigCows / X:Electrical Machines" ],
/* 19 */ [    0,     0,   0, "E:Wood Products / F2:Lumber / F3S:Scrap Metal / F4S:Ferrochrome / Y:Uranium / X:Engineering Supplies" ],
/* 20 */ [    0,     0,   0, "E:Dyes / F2:Scrap Metal / F3S:Soda Ash / F4S:Glass / Y:Iron ore / X:Explosives" ],
/* 21 */ [    0,     0,   0, "E:Fertiliser / F2:Farm Supplies / F3S:Zinc / F4S:Iron Ore / X:Farm Supplies" ],
/* 22 */ [    0,     0,   0, "E:Oil seed / F2:Plant Fibres / F3S:Copper / F4S:Limestone / X:Fertiliser" ],
/* 23 */ [    0,     0,   0, "E:Refined products / F2:Chemicals / F3S:Rubber / F4S:Sodium Hydroxide / X:Fish" ],
/* 24 */ [    0,     0,   0, "E:Vehicles / F2:Engineering Supplies / F3S:Pipe / F4S:Manganese / X:Fruit" ],
/* 25 */ [    0,     0,   0, "E:Gasoline / F2:Petrol / F3S:Salt / F4S:Oxygen / X:Grain" ],
/* 26 */ [    0,     0,   0, "E:Bauxite / F2:Stone / F3S:Acid / F4S:Paints and Coatings / X:Iron Ore" ],
/* 27 */ [    0,     0,   0, "E:Water / F2:Bauxite / F3S:Chlorine / F4S:Pig Iron / X:Lithium" ],
/* 28 */ [    0,     0,   0, "E:Cement / F2:Building Materials / F3S:Electrical Machines / F4S:Pipe / X:Limestone" ],
/* 29 */ [    0,     0,   0, "E:Fibre Crops / F2:Alcohol / F3S:Vehicle Parts / F4S:Plastics / X:Livestock" ],
/* 30 */ [    0,     0,   0, "E:Lime stone / F3S:Vehicle Bodies / F4S:Quicklime / X:Timber" ],
/* 31 */ [    0,     0,   0, "E:Tourists / F2:Recyclables / F4S:Rubber / X:Manganese" ],

/* 32 */ [    0,     0,   0, "F4S:Salt / X:Aluminium" ],
/* 33 */ [    0,     0,   0, "F4S:Sand / X:Milk" ],
/* 34 */ [    0,     0,   0, "F4S:Scrap Metal / X:Nitrates" ],
/* 35 */ [    0,     0,   0, "F4S:Slat / X:Oil" ],
/* 36 */ [    0,     0,   0, "F4S:Soda Ash / X:Packaging" ],
/* 37 */ [    0,     0,   0, "F4S:Stainless Steel / X:Paper" ],
/* 38 */ [    0,     0,   0, "F4S:Steel Sections / X:Biomass" ],
/* 39 */ [    0,     0,   0, "F4S:Steel Sheet / X:Petroleum Fuels" ],
/* 40 */ [    0,     0,   0, "F4S:Steel Wire Rod / X:Oil Sands" ],
/* 41 */ [    0,     0,   0, "F4S:Sulphur / X:Pig Iron" ],
/* 42 */ [    0,     0,   0, "F4S:Tyres / X:Pipe" ],
/* 43 */ [    0,     0,   0, "F4S:Vehicle Bodies / X:Fibres" ],
/* 44 */ [    0,     0,   0, "F4S:Vehicle Engines / X:Zinc Ore" ],
/* 45 */ [    0,     0,   0, "F4S:Vehicle Parts / X:Quicklime" ],
/* 46 */ [    0,     0,   0, "F4S:Zinc / X:Recyclables" ],
/* 47 */ [    0,     0,   0, "F4S:Potash / X:Rubber" ],
/* 48 */ [    0,     0,   0, "X:Salt" ],
/* 49 */ [    0,     0,   0, "X:Sand" ],
/* 50 */ [    0,     0,   0, "X:Scrap Metal" ],
/* 51 */ [    0,     0,   0, "X:Slag" ],
/* 52 */ [    0,     0,   0, "X:Soda Ash" ],
/* 53 */ [    0,     0,   0, "X:Steel" ],
/* 54 */ [    0,     0,   0, "X:Sugar Beet" ],
/* 55 */ [    0,     0,   0, "X:Sulphur" ],
/* 56 */ [    0,     0,   0, "X:Vehicle Bodies" ],
/* 57 */ [    0,     0,   0, "X:Parts" ],
/* 58 */ [    0,     0,   0, "X:Vehicles" ],
/* 59 */ [    0,     0,   0, "X:Wood" ],
/* 60 */ [    0,     0,   0, "X:Wool" ],
/* 61 */ [    0,     0,   0, "X:Zinc" ],
/* 62 */ [    0,     0,   0, "" ],
/* 63 */ [    0,     0,   0, "" ]
		];

		local var = "";
		for(local i = 0; i < 64; i++){
			AddSetting({ name = "cat"+i, description = " #" + (i + 1) + " >>> " + cargoDef[i][3] + " <<< ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = CONFIG_BOOLEAN });
			var = "req" + i;
			AddSetting({ name = var, description = "Requirements ", min_value = 0, max_value = 10000, easy_value = cargoDef[i][0], medium_value = cargoDef[i][0], hard_value = cargoDef[i][0], custom_value = cargoDef[i][0], flags = CONFIG_NONE | CONFIG_INGAME });
			var = "pop" + i;
			AddSetting({ name = var, description = "From", min_value = 0, max_value = 50000, easy_value = cargoDef[i][1], medium_value = cargoDef[i][1], hard_value = cargoDef[i][1], custom_value = cargoDef[i][1], flags = CONFIG_NONE | CONFIG_INGAME });
			var = "store" + i;
			AddSetting({ name = var, description = "% Stored per month", min_value = 0, max_value = 100, easy_value = cargoDef[i][2], medium_value = cargoDef[i][2], hard_value = cargoDef[i][2], custom_value = cargoDef[i][2], flags = CONFIG_NONE | CONFIG_INGAME });
		}
	}
}

RegisterGS(SimpletonCBInfo());