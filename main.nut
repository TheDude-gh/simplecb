/*
	Simpleton City Builder   main.nut
	Simpleton class - main class
*/

require("town.nut");
require("classes.nut");

scriptInstance <- null;
const SCRIPT_VERSION = 16; //the same as in info.nut. For save/load
const NUMCARGO = 64; //number of cargos in OpenTTD
const INVALID_TOWN = 0xFFFF; //invalid town id
const INVALID_COMPANY = 0xFF; //invalid company id
const INVALID_TILE = -1;
const CLAIM_DISTANCE = 30;
const NEIGHBOUR_DISTANCE_MAX = 2500; //50 tiles (squared)
const NO_GROWTH = 0x3FFF;
const TOWNGUI_LIMIT = 6;
const BREAKDAYS = 1; //daily process period in days
const TOWNTICKS = 70;
const DAYTICKS = 74;
const SHRINK_FACTOR = 5; // how fast town will shrink in multiplication of growth. Higher number = slower demolishing

cbloglevel <- 1;

/* grow mechanics */
enum Growth {
	GROW_NORMAL, // = 0
	GROW_EXPAND,
	GROW_DIVERS,
	GROW_END,
}
/* mapgen methods */
enum MapGenMethod {
	RANDOM, // = 0
	SQUARE,
}

// This is the main Class
class SimpletonCB extends GSController
{
	data = null; //data to save
	companies = []; //company pool

	mapX = 0;
	mapY = 0;
	townstring = 0;
	townarea = 0;

	last_date = 0;
	sleeptime = 74; //refresh
	firstrun = true;
	from_save = false; //flag to cancel things doing only in map generation
	current_month = 0;
	current_year = 0;
	last_month = 0;
	current_date = 0;
	flow_days = 0;
	game_length = 0;
	dyn_growth = 0;
	maxCityPop = 0;
	goalprogress = 0;
	goalstatus = 0;

	goals = []; //goals pool
	goal = 0; //game goal
	scorelist = null; //score pool
	cityList = []; //only used when limit cities growth enabled

	townnames = [];
	CBcargo = []; //required cargos pool
	townlistCB = []; //owned towns pool
	growmech = 0;
	townshrink = false;
	claim_pop = 250;
	max_storage = 4;
	
	story = []; //storypage ids
	storyElement = []; //storypage elements ids

	signlist = null; //sings pool

	log = 0;

	constructor()
	{
		this.scorelist = GSList();
		this.signlist = GSList();
		//                Settlement  Resort Village Town   City  Metropolis
		this.townnames = [0,          250,   500,    1500,  2500, 10000];
	}

	function Process();
	function DailyLoop();
	function MonthlyLoop();
	function YearlyLoop();
	function ChangeTownString();
	function HQClaimTown();
	function GetCompanyByID(id);
	function GetCompanyByTownID(townid);
	function CompanyRemoveByID(companyid);
	function GetTownByID(townid);
	function TownRemoveByID(townid);
	function TownHasOwner(townid);
	function ClaimedTownNearby(townid, companyid);
	function PrepareCB();
	function SelectPresetCB(cbeconomy);
	function PrepareTown(townid);
	function TownsUpdate(goal_gui_update);
	function TownUpdate(companyid, townid, update);
	function PlaceSign(tileIndex, text);
	function RemoveSign(tileIndex);
	function TownArea(tileIndex, companyid, place);
	function CargoGetNext(population);
	function xMapgenRem();
	function xMapgen();
	function PlaceIndustry(ind, cargo, distmin, method, distmax);
	function Log(string, level = 0);

	function BestCompany(goal = 0);
	function GoalProgress(checkgamelength = 0);
	function SendGlobalMessage(txt);
	function StoryStart();
	function Story();
}

//script start
function SimpletonCB::Start() {
	this.Log("### Simpleton city Builder STARTS ###");
	/* load settings */
	this.log = GSController.GetSetting("morelogs");

	this.PrepareGame();

	//PrepareCB reloads settings
	this.PrepareCB();

	this.StoryStart();

	//debug - show cargo ID list
	this.CargoDetailsDebug();

	// day tick = 74
	// 31 ticks ~= 1 second,	 1 game day ~= 2,3s, 1 game month ~= 75s
	sleeptime = TOWNTICKS;

	//game loop
	while (true) {
		this.Process();
		this.Sleep(sleeptime);
	}
}

//main loop handle - time, events
function SimpletonCB::Process() {
	this.current_date = GSDate.GetCurrentDate();
	this.current_month = GSDate.GetMonth(this.current_date);

	this.CheckEvents();

	//daily loop
	if(this.current_date != this.last_date) {
		this.flow_days += (this.current_date - this.last_date);
	}

	this.last_date = this.current_date;

	//every x days
	if(this.flow_days >= BREAKDAYS) {
		this.flow_days = 0;
		this.DailyLoop();
		if(this.current_month == this.last_month) { //skip if new month, so we dont do the same twice as it is in montly loop
			this.TownsUpdate(false); //only update deliveries and town gui
		}
	}

	//monthly loop
	if(this.current_month == this.last_month) {
		return;
	}
	this.current_year = GSDate.GetYear(this.current_date);

	this.last_month = this.current_month;
	this.MonthlyLoop();

	if(this.current_month == 1) {
		this.YearlyLoop();
	}

	this.TownsUpdate(true); //update all
}


function SimpletonCB::PrepareGame() {
	this.mapX = GSMap.GetMapSizeX() - 2;
	this.mapY = GSMap.GetMapSizeY() - 2;

	//new game
	if(this.from_save == false) {
		//if there are alrady some companies and goals at start, fill pools
		for(local id = 0; id < 16; id++) {
			if(GSCompany.ResolveCompanyID(id) != GSCompany.COMPANY_INVALID) {
				this.companies.append( Company(id) );
			}
		}
		for(local id = 0; id < 256; id++) {
			if(GSGoal.IsValidGoal(id)) {
				GSGoal.Remove(id);
			}
		}

		//this.xMapgenRem();
		this.xMapgen();
	}
}

//debug - show cargo ID list
function SimpletonCB::CargoDetailsDebug() {
	if(this.log == 0) return;

	for(local i = 0; i < NUMCARGO; i++) {
		if(GSCargo.IsValidCargo(i)) {
			//local ll = " TE=" + GSCargo.GetTownEffect(i) + " PAX=" + GSCargo.HasCargoClass(i, GSCargo.CC_PASSENGERS) + " MAIL=" + GSCargo.HasCargoClass(i, GSCargo.CC_MAIL);
			this.Log("CARGO   " + i + "   " + GSCargo.GetCargoLabel(i) + "   " + GSCargo.GetName(i));
		}
	}
}

function SimpletonCB::CheckEvents() {
	if(this.firstrun == true && GSController.GetSetting("startpause") == 1) {
		GSGame.Pause();
		GSLog.Info("GS pausing");
	}
	/* company pool changes */
	while(GSEventController.IsEventWaiting()) {
		local event = GSEventController.GetNextEvent();
		if(event == null) {
			continue;
		}
		local eventType = event.GetEventType();
		switch(eventType) {
			case GSEvent.ET_COMPANY_BANKRUPT:	{
				// Delete the company from the company pool and unclaim town
				local deadcompany = GSEventCompanyBankrupt.Convert(event);
				this.CompanyRemoveByID(deadcompany.GetCompanyID());
				GSLog.Info("Found bankrupted company!");
				break;
			}
			case GSEvent.ET_COMPANY_MERGER: {
				// Merge the companies, remove old company and unclaim town
				local merge = GSEventCompanyMerger.Convert(event);
				this.CompanyRemoveByID(merge.GetOldCompanyID());
				GSLog.Info("Company merge of company " + merge.GetOldCompanyID() + " into " + GSCompany.GetName(merge.GetNewCompanyID()));
				break;
			}
			case GSEvent.ET_COMPANY_NEW: {
				//new company
				local newcompany = GSEventCompanyNew.Convert(event);
				local cid = newcompany.GetCompanyID();
				//if company already exists, do not add it to list. Can happen with scenarios
				if(this.GetCompanyByID(cid)) {
					continue;
				}
				this.companies.append( Company(cid) );
				if(this.log == 0) {
					GSGoal.Question(0, cid, GSText(GSText.STR_WELCOME), GSGoal.QT_INFORMATION, GSGoal.BUTTON_START);
				}
				GSLog.Info("Found new company! " + cid);

				if(GSGame.IsPaused()) {
					GSGame.Unpause();
					GSLog.Info("GS unpausing");
				}
				break;
			}
			case GSEvent.ET_TOWN_FOUNDED: {
				//new town funded
				local newtown = GSEventTownFounded.Convert(event);
				local townid = newtown.GetTownID();
				this.PrepareTown(townid);
				if(this.maxCityPop != 0 && GSTown.IsCity(townid)) {
					this.cityList.append(townid);
				}
				break;
			}
		}
	}
}

function SimpletonCB::DailyLoop() {
	if(this.firstrun) { //workaround for GS bug, when in firstrun all GSGOAL returns ID = 0, should be ok in 1.4
		/*for (local i = 1; i < 10; i++) {
			if(GSGoal.IsValidGoal(i)) GSGoal.Remove(i);
		}*/
		this.firstrun = false;
		return;
	}

	this.HQClaimTown();
	if(this.townstring == 1) {
		this.ChangeTownString();
	}

	if(this.goalprogress == 1) {
		this.GoalProgress(); //check for game end
	}
}

function SimpletonCB::MonthlyLoop() {
	this.log = GSController.GetSetting("morelogs");

	local goal_id;
	this.LimitCityPopulation(); //check for overgrown cities

	//clear goals to show new info
	for (local i = 0; i < this.goals.len(); i++) {
		if(GSGoal.IsValidGoal(this.goals[i])) {
			GSGoal.Remove(this.goals[i]);
		}
	}
	this.goals.clear();
	
	//main goal
	//global goal
	goal_id = GSGoal.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_GLOBAL_GOAL_CB, this.goal), GSGoal.GT_NONE, 0);
	this.goals.append(goal_id);

	//ADDITIONAL GOAL INFO
	if(this.game_length != 0) {
		local end_in = GSGameSettings.GetValue("game_creation.starting_year") + this.game_length - this.current_year;
		goal_id = GSGoal.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_GAME_LENGTH, end_in), GSGoal.GT_NONE, 0);
		this.goals.append(goal_id);
	}

	//Clear Score to make new one
	scorelist.Clear();
	foreach(company in this.companies) {
		if(company.town_id != INVALID_TOWN) { //if proper town is claimed, save to scorelist
			scorelist.AddItem(company.id, GSTown.GetPopulation(company.town_id) );
		}
		else{  //tell player to claim town
			GSGoal.Question(0, company.id, GSText(GSText.STR_PLACE_HQ_INFO, this.claim_pop), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
		}
	}

	scorelist.Sort(GSList.SORT_BY_VALUE, GSList.SORT_DESCENDING); //sort by best

	local rank = 1, company, textobj;
	foreach (companyid, score in scorelist) {
		company = GetCompanyByID(companyid);
		textobj = null;

		if(!company || company.hq == GSMap.TILE_INVALID || company.town_id == INVALID_TOWN) {
			continue;
		}

		if(this.goal != 0) {
			textobj = GSText(GSText.STR_SCORE_GOAL_CB, rank, (100 * score / this.goal), company.id, score, company.town_id);
		}
		else {
			textobj = GSText(GSText.STR_SCORE_NOGOAL_CB, rank, company.id, score, company.town_id);
		}

		goal_id = GSGoal.New(GSCompany.COMPANY_INVALID, textobj, GSGoal.GT_TOWN, company.town_id);
		this.goals.append(goal_id);

		rank++;
	}
}

function SimpletonCB::YearlyLoop() {
	local year_run_time = this.current_year - GSGameSettings.GetValue("game_creation.starting_year");
	if(this.dyn_growth > 0) {
		if(year_run_time > 0 && (year_run_time % this.dyn_growth == 0)) {
			local growrate = GSGameSettings.GetValue("economy.town_growth_rate");
			if(growrate < 4) {
				GSGameSettings.SetValue("economy.town_growth_rate", ++growrate);
			}
		}
	}

	this.Story();
	foreach(company in this.companies) {
		company.score_last_year = (company.town_id != INVALID_TOWN) ? GSTown.GetPopulation(company.town_id) : 0;
	}
	this.GoalProgress(year_run_time); //check for game end
}

function SimpletonCB::HQClaimTown() {
	//HQ claims
	foreach(company in this.companies) {
		if(company.id == INVALID_COMPANY) {
			continue;
		}

		local hq_tile = GSCompany.GetCompanyHQ(company.id);	//get HQ position

		if(company.hq != hq_tile) { //check for change

			company.hq = hq_tile;	 //save new position

			local closest_town_id = GSTile.GetClosestTown(hq_tile); //get closest town

			if(!GSTown.IsValidTown(closest_town_id)) {
				continue; //skip invalid towns
			}
			if(company.town_id == closest_town_id) {
				continue; //skip if HQ moved within current town
			}

			/* if town is too far away, send warning */
			if(GSTown.GetDistanceManhattanToTile(closest_town_id, hq_tile) > CLAIM_DISTANCE) {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}
				company.town_id = INVALID_TOWN;
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TOWN_NOTCLAIMED, company.id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				GSGoal.Question(0, company.id, GSText(GSText.STR_TOWN_NOTCLAIMED_INFO), GSGoal.QT_WARNING, GSGoal.BUTTON_OK);
				GSLog.Info(GSCompany.GetName(company.id) + " found no town nearby");
			}
			/* if closest is city, save null and send warning */
			else if(GSTown.IsCity(closest_town_id)) {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}
				company.town_id = INVALID_TOWN;
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_CITY_NOTCLAIMED, company.id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				GSGoal.Question(0, company.id, GSText(GSText.STR_CITY_NOTCLAIMED_INFO), GSGoal.QT_WARNING, GSGoal.BUTTON_OK);
				GSLog.Info(GSCompany.GetName(company.id) + " tried claiming a city " + GSTown.GetName(closest_town_id));
			}
			/* if town is already owned, send warning */
			else if(this.TownHasOwner(closest_town_id)) {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}
				local other_company = this.GetCompanyByTownID(closest_town_id);
				company.town_id = INVALID_TOWN;
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TOWN_HAS_OWNER, closest_town_id, other_company.id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				GSGoal.Question(0, company.id, GSText(GSText.STR_TOWN_HAS_OWNER_INFO, closest_town_id, other_company.id), GSGoal.QT_WARNING, GSGoal.BUTTON_OK);
				GSLog.Info(GSCompany.GetName(company.id) + " tried to claim owned town: " + GSTown.GetName(closest_town_id) + " owned by " + GSCompany.GetName(other_company.id));
			}
			/* There is somebody in neighbourhood */
			else if(this.ClaimedTownNearby(closest_town_id, company.id)) {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}
				company.town_id = INVALID_TOWN;
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TOWN_NEIGHBOUR_CLOSE, company.id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				GSGoal.Question(0, company.id, GSText(GSText.STR_TOWN_NEIGHBOUR_CLOSE_INFO, closest_town_id), GSGoal.QT_WARNING, GSGoal.BUTTON_OK);
				GSLog.Info(GSCompany.GetName(company.id) + " tried to claim " + GSTown.GetName(closest_town_id) + "which is too close to another company's town");
			}
			/* if town has bigger population than allowed to claim */
			else if(GSTown.GetPopulation(closest_town_id) > this.claim_pop) {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}
				company.town_id = INVALID_TOWN;
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TOWN_POPLIMIT, company.id, closest_town_id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				GSGoal.Question(0, company.id, GSText(GSText.STR_TOWN_POPLIMIT_INFO, closest_town_id, this.claim_pop), GSGoal.QT_WARNING, GSGoal.BUTTON_OK);
				GSLog.Info(GSCompany.GetName(company.id) + " tried to claim town " + GSTown.GetName(closest_town_id) + "which has too high population");
			}
			/* TOWN CLAIMED */
			/* if town is close enough (30), claim it */
			else {
				if(company.town_id != INVALID_TOWN) {
					this.TownRemoveByID(company.town_id); //unclaim old first if any
				}

				company.town_id = closest_town_id; //claim town
				this.townlistCB.append( Town(company.town_id, company.id) ); //add to pool
				this.StartTownMonitor(company.id, company.town_id); //start accepting cargo
				
				if(this.townarea > 0) {
				  local town_location = GSTown.GetLocation(company.town_id);
					this.TownArea(town_location, company.id, true);
					if(this.townstring != 1) {
						this.PlaceSign(town_location, GSText(GSText.STR_HQTOWN, company.id));
					}
				}

				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.STR_TOWN_CLAIMED, company.id, company.town_id), GSCompany.COMPANY_INVALID, GSNews.NR_TOWN, closest_town_id);
				//inform about claiming town
				if(this.log == 0) {
					GSGoal.Question(0, company.id, GSText(GSText.STR_TOWN_CLAIMED_INFO, company.town_id), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
				}
				GSLog.Info(GSCompany.GetName(company.id) + " claimed " + GSTown.GetName(closest_town_id));
				//point to storybook for cargo requirements
				GSGoal.Question(0, company.id, GSText(GSText.STR_POINT_TO_STORY_REQ), GSGoal.QT_INFORMATION, GSGoal.BUTTON_OK);
			}
		}
	}
}

function SimpletonCB::ChangeTownString() {
	local townpop = 0;
	local town_president = "";
	foreach(town in this.townlistCB) {
		townpop = GSTown.GetPopulation(town.id);
		town_president = GSCompany.GetPresidentName(town.owner);
		for(local i = this.townnames.len() - 1; i >= 0; i--) {
			if(townpop > this.townnames[i]) {
				if(town.nameid != i || town_president != town.president) { //check if pop id or president name was changed
					GSTown.SetName(town.id, GSText(GSText.STR_TOWNNAME_PRESIDENT, town.owner, GSText(GSText.STR_TOWNNAME_POP0 + i)));
					town.nameid = i;
					town.president = town_president;
				}
				break;
			}
		}
	}
}

function SimpletonCB::GetCompanyByID(id) {
	foreach(company in this.companies) {
		if(id == company.id) {
			return company;
		}
	}
	return null;
}

function SimpletonCB::GetCompanyByTownID(townid) {
	foreach(company in this.companies) {
		if(townid == company.town_id) {
			return company;
		}
	}
	return null;
}

function SimpletonCB::CompanyRemoveByID(companyid) {
	for(local i = 0, size = this.companies.len(); i < size; i++) {
		if(this.companies[i].id == companyid) {
			if(this.companies[i].town_id != INVALID_TOWN) {
				this.TownRemoveByID(this.companies[i].town_id);
			}
			this.companies.remove(i);
			break;
		}
	}
}

function SimpletonCB::GetTownByID(townid) {
	foreach(town in this.townlistCB) {
		if(townid == town.id) {
			return town;
		}
	}
	return null;
}
/* unclaim town, stop monitor, remove signs */
function SimpletonCB::TownRemoveByID(townid) {
	for(local i = 0, size = this.townlistCB.len(); i < size; i++) {
		if(this.townlistCB[i].id == townid) {
			GSTown.SetText(townid, GSText(GSText.STR_EMPTY0));
			this.StopTownMonitor(this.townlistCB[i].owner, this.townlistCB[i].id);
			local town_location = GSTown.GetLocation(this.townlistCB[i].id);
			GSTown.SetName(townid, null);
			if(this.townarea) {
				this.RemoveSign(town_location);
				this.TownArea(town_location, INVALID_COMPANY, false);
			}
			this.townlistCB.remove(i);
			break;
		}
	}
}

function SimpletonCB::TownHasOwner(townid) {
	foreach(company in this.companies) {
		if(company.town_id == townid) {
			return true;
		}
	}
	return false;
}

function SimpletonCB::ClaimedTownNearby(townid, companyid) {
	local tileA, tileB = GSTown.GetLocation(townid);
	foreach(town in this.townlistCB) {
		tileA = GSTown.GetLocation(town.id);
		if(GSTile.GetDistanceSquareToTile(tileA, tileB) < NEIGHBOUR_DISTANCE_MAX && town.owner != companyid) {
			return true;
		}
	}
	return false;
}

function SimpletonCB::CargoGetNext(population) {
	foreach(cargo in this.CBcargo) {
		if(cargo.from > population) return cargo;
	}
	return null;
}

/* load cargo settings */
function SimpletonCB::PrepareCB() {

	local cargoid, ireq, ipop, istore, iself;
	local cbeconomy = GSController.GetSetting("cbeconomy");
	this.Log("preparing CB");
	//CUSTOM cargo settings
	if(cbeconomy == 0) {
		for(local i = 0; i < NUMCARGO; i++) {
			ireq = GSController.GetSetting("req"+i);
			if(!GSCargo.IsValidCargo(i) || ireq == 0) {
				continue; //only valid and required
			}
			ipop = GSController.GetSetting("pop"+i);
			istore = GSController.GetSetting("store"+i);
			iself = (GSCargo.HasCargoClass(i, GSCargo.CC_PASSENGERS) || GSCargo.HasCargoClass(i, GSCargo.CC_MAIL)) ? 1 : 0;

			this.CBcargo.append( Cargo(i, ireq, ipop, istore, iself) ); //add new cargo
		}
	}
	//chosen Preset
	else {
		local cbpreset = this.SelectPresetCB(cbeconomy);
		foreach(preset in cbpreset) {
		  cargoid = preset[0];
			ireq = preset[1];
			if(!GSCargo.IsValidCargo(cargoid) || ireq == 0) {
				continue; //only valid and required
			}
			ipop = preset[2];
			istore = preset[3];
			iself = (GSCargo.HasCargoClass(cargoid, GSCargo.CC_PASSENGERS) || GSCargo.HasCargoClass(cargoid, GSCargo.CC_MAIL)) ? 1 : 0;

			this.CBcargo.append( Cargo(cargoid, ireq, ipop, istore, iself) ); //add new cargo
		}
	}

	this.CBcargo.sort(arrcmp); //sort by from population

	foreach(cargo in this.CBcargo) {
		this.Log("load " + GSCargo.GetCargoLabel(cargo.id) + " req: " + cargo.req + " pop " + cargo.from + " store " + cargo.store + (cargo.self ? " (self)" : ""), 1);
	}
	
	this.goal         = GSController.GetSetting("goal");
	this.game_length  = GSController.GetSetting("gamelength");
	this.max_storage  = GSController.GetSetting("storage");
	this.claim_pop    = GSController.GetSetting("claimpop");
	this.townarea     = GSController.GetSetting("townarea");
	this.townstring   = GSController.GetSetting("changetownname");
	this.growmech     = GSController.GetSetting("growmechanism");
	this.townshrink   = GSController.GetSetting("townshrink");
	this.dyn_growth   = GSController.GetSetting("dyngrowth");
	this.goalprogress = GSController.GetSetting("goalprogress");
	this.maxCityPop   = GSController.GetSetting("cityPopLimit");

	if(this.growmech < Growth.GROW_NORMAL || this.growmech >= Growth.GROW_END) {
		this.growmech = Growth.GROW_NORMAL;
	}

	//adjust some game settings
	//disable this stupid feature
	if(GSGameSettings.IsValid("economy.fund_roads")) {
		GSGameSettings.SetValue("economy.fund_roads", 0);
	}
	//disable this, it would be bad, if someone else bought exclusivity in else's claimed town
	if(GSGameSettings.IsValid("economy.exclusive_rights")) {
		GSGameSettings.SetValue("economy.exclusive_rights", 0);
	}

	//prepare towns
	local townlist = GSTownList();
	foreach(townid, _ in townlist) {
	  if(this.from_save == false) {
			this.PrepareTown(townid);
		}
		
		//cities for limiting pop later
		if(this.maxCityPop != 0 && GSTown.IsCity(townid)) {
			this.cityList.append(townid);
		}
	}
	
}

/* Prepare towns at start or new funded town */
function SimpletonCB::PrepareTown(townid) {
	if(GSTown.IsCity(townid)) {
		this.PlaceSign(GSTown.GetLocation(townid), GSText(GSText.STR_CITY)); // add a sign to each city
	}
	else {
		GSTown.SetGrowthRate(townid, GSTown.TOWN_GROWTH_NONE); //stop growing towns
	}
	//disable default TOWN_EFFECT goals
	GSTown.SetCargoGoal(townid, GSCargo.TE_PASSENGERS, 0);
	GSTown.SetCargoGoal(townid, GSCargo.TE_MAIL, 0);
	GSTown.SetCargoGoal(townid, GSCargo.TE_WATER, 0);
	GSTown.SetCargoGoal(townid, GSCargo.TE_GOODS, 0);
	GSTown.SetCargoGoal(townid, GSCargo.TE_FOOD, 0);
}

/* start monitoring town once claimed */
function SimpletonCB::StartTownMonitor(companyid, townid) {
	if (companyid == GSCompany.COMPANY_INVALID || !GSTown.IsValidTown(townid)) {
		return;
	}

	foreach(cargo in this.CBcargo) {
		GSCargoMonitor.GetTownDeliveryAmount(companyid, cargo.id, townid, true); //return value is not important
		if(cargo.self) {
			GSCargoMonitor.GetTownPickupAmount(companyid, cargo.id, townid, true);
		}
	}
}

/* stop monitoring town if unclaimed */
function SimpletonCB::StopTownMonitor(companyid, townid) {
	if (companyid == GSCompany.COMPANY_INVALID || !GSTown.IsValidTown(townid)) {
		return;
	}

	foreach(cargo in this.CBcargo) {
		GSCargoMonitor.GetTownDeliveryAmount(companyid, cargo.id, townid, false);
		if(cargo.self) {
			GSCargoMonitor.GetTownPickupAmount(companyid, cargo.id, townid, false);
		}
	}
}

//limit city growing if population is too big
function SimpletonCB::LimitCityPopulation() {
	if(this.maxCityPop == 0) {
		return; //disabled
	}

	local maxTownPop = 0;
	foreach(town in this.townlistCB) {
		maxTownPop = max(maxTownPop, GSTown.GetPopulation(town.id)); //get max town pop
	}
	//least allowable city size
	maxTownPop = max(maxTownPop * this.maxCityPop / 100, 2000);

	foreach(townid in this.cityList) {
		local growrate = GSTown.GetGrowthRate(townid);
		if(GSTown.GetPopulation(townid) > maxTownPop) { //if bigger
			//Log(GSTown.GetName(townid) + " NOT growing " + GSTown.GetPopulation(townid));
			if(growrate != GSTown.TOWN_GROWTH_NONE) { //check if already not growing
				GSTown.SetGrowthRate(townid, GSTown.TOWN_GROWTH_NONE);
			}
		}
		else if(growrate == GSTown.TOWN_GROWTH_NONE) { //lower, check if we need to set to normal
			//Log(GSTown.GetName(townid) + " growing " + GSTown.GetPopulation(townid));
			GSTown.SetGrowthRate(townid, GSTown.TOWN_GROWTH_NORMAL);
		}
	}
}

//update town gui and deliveries
function SimpletonCB::TownsUpdate(goal_gui_update) {
	foreach(company in this.companies) {
		if(company.town_id != INVALID_TOWN) {
			this.TownUpdate(company.id, company.town_id, goal_gui_update);
		}
	}
}
/*
	show info in town gui
	1 - company index
	2 - town index
	3 - update goal gui flag
*/
function SimpletonCB::TownUpdate(companyid, townid, update) {

	local town = this.GetTownByID(townid);
	if(!town) {
		return;
	}

	local townpop = GSTown.GetPopulation(townid);
	local delivered = 0, missing = 0, req = 0, goal_id, act_cargo, missing_cargo = 0, txt, towngui = [], deltadays, service_good = true, grow_ratio = 0;
	local pickup = 0;
	local cargoSize = this.CBcargo.len(); //how much cargos we need
	local growrate = GSTown.GetGrowthRate(town.id); //curent growth rate

	/* expand town if supplied and grow counter zeroed */
	deltadays = (this.current_date - town.delta); //how many days from last check
	town.grow_counter -= deltadays; //update grow_counter
	town.delta = this.current_date;

	if(town.grow_counter <= 0) {
		if(this.growmech == Growth.GROW_EXPAND && town.growing) {
			local houses = (growrate < deltadays) ? (deltadays / growrate).tointeger() : 1;
			GSTown.ExpandTown(town.id, houses); //grow a house
		}
		town.grow_counter = max(town.grow_counter + growrate, 1); //save new value
	}

	/* UPDATE */
	if(update) {
		//grow by default, check later
		town.growing = true;
		town.service = true;
		town.supplied = true;
		town.percentage_delivered = 100; //default value for perc delivered

		goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_CB_TOWN_INFO, townid, townpop, GSTown.GetHouseCount(townid)), GSGoal.GT_TOWN, townid);
		this.goals.append(goal_id);

		goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_CB_HEADER), GSGoal.GT_TOWN, townid);
		this.goals.append(goal_id);
	}
	/* /UPDATE */

	//when cargosize is less or more than towngui limit, add owned string, if equal, we display all cargos instead
	//if less add also cargo missing title, because cargos will be displayed
	if(cargoSize < TOWNGUI_LIMIT) {
		towngui.append(GSText(GSText.STR_TOWN_OWNED_COMPANY_MISSING, companyid, GSText(GSText.STR_EMPTY0))); //2
	}
	//when more, display just owner, since cargos wont be displayed
	else if(cargoSize > TOWNGUI_LIMIT) {
		towngui.append(GSText(GSText.STR_TOWN_OWNED_COMPANY, companyid, GSText(GSText.STR_EMPTY0))); //2
	}

	/* MONTHLY DELIVERY CHECK */
	foreach(cargo in this.CBcargo) {
		delivered = GSCargoMonitor.GetTownDeliveryAmount(companyid, cargo.id, townid, true); //deliver since last check

		//when passenger or mail class, get pickup from within town and substract it from delivery
		if(cargo.self) {
			pickup = GSCargoMonitor.GetTownPickupAmount(companyid, cargo.id, townid, true);
			//if cargo is picked up in claimed town and delivered to another town, it could increase requirements
			//to prevent that, do not allow negative values, but delivering elsewhere can still go against valid deliveries
			delivered = max(delivered - pickup, 0);
		}

		req = townpop * cargo.req / 1000; //current requirements
		town.delivered[cargo.id] += delivered; //add to total month deliveries

		/* UPDATE */
		//update storage and growth
		if(update) {
			local act_cargo = town.delivered[cargo.id] + town.storage[cargo.id]; //how much we have
			if(townpop >= cargo.from) {
				act_cargo -= req; //how much is left after req substracted - only if required

				//when required, get percentage delivered, clamp between 0 - last value - 100
				town.percentage_delivered = max( min( (100 * town.delivered[cargo.id] / req),  town.percentage_delivered), 0);
			}

			if(act_cargo >= 0 || townpop < cargo.from) { //positive - delivered enough OR not required yet -> just store
				if(this.max_storage > 0 && cargo.store > 0) { //add to storage if enabled and not stored is bigger than 0%
					town.storage[cargo.id] = min(act_cargo, req * this.max_storage); //limit storage by its size
					town.storage[cargo.id] *= cargo.store; //store %
					town.storage[cargo.id] /= 100;
				}
			}
			else if(townpop >= cargo.from) { //if required but not delivered, stop growth and empty storage
				town.supplied = false;
				town.growing = false;
				town.storage[cargo.id] = 0;
				missing_cargo = missing_cargo | (1 << cargo.id);
			}
			
			//show in goal gui if required
			if(townpop >= cargo.from) {
				if(this.max_storage == 0 || cargo.store == 0) {
					txt = GSText(GSText.STR_TOWN_REQ_GUI_NOSTORAGE, 1 << cargo.id, town.delivered[cargo.id], req);
				}
				else{
					txt = GSText(GSText.STR_TOWN_REQ_GUI,
						1 << cargo.id, town.storage[cargo.id], 100 * town.storage[cargo.id] / (this.max_storage * req + 1), town.delivered[cargo.id], req);
				}
				//cargo detail in goal gui
				goal_id = GSGoal.New(companyid, txt, GSGoal.GT_NONE, 0);
				this.goals.append(goal_id);
			}
			town.delivered[cargo.id] = 0; //clear deliveries for new month
		}
		/* /UPDATE */

		//town gui
		if(townpop >= cargo.from) { //if cargo is required
			missing = max(req - (town.delivered[cargo.id] + town.storage[cargo.id]), 0); //how much cargo is missing to satisfy town
			
			if(missing > 0) {
				txt = GSText.STR_TOWN_CARGO_YES; //if still missing
			}
			else {
				txt = GSText.STR_TOWN_CARGO_GOOD; //if all delivered, show OK
			}

			if(cargoSize <= TOWNGUI_LIMIT) { //if more, skip - will not fit in town gui
				towngui.append(GSText(txt, 1 << cargo.id, missing));
			}
		}
	}

	if(update) {
		growrate = town.Grow(this.growmech); //grow grow grow, or not
	}

	//bad service
	if(growrate == GSTown.TOWN_GROWTH_NONE && town.supplied == true) {
		//Log("service");
		town.growing = false;
		town.service = false;
	}
	
	//Log("PD = " + town.percentage_delivered);
	if(this.townshrink) {
		if(update && town.growing) {
			town.growth_last = GSTown.GetGrowthRate(town.id);
			town.demolish_counter = SHRINK_FACTOR * town.growth_last;
		}
		//if town does not grow and it is monthly update, try to demolish house
		if(!town.growing) {
		 	town.Demolish_House();
		}
	}
	
	//GSLog.Info("GROWTH LAST " + town.growth_last);
	

	//TOWN GUI display
	//next required cargo
	local cargonext = this.CargoGetNext(townpop);
	if(cargonext) {
		towngui.append(GSText(GSText.STR_TOWNW_NEXT_CARGO, 1 << cargonext.id, cargonext.from));
	}

	//ratio of maximum growth
	if(town.growing) {
		grow_ratio = (growrate < 420) ? (abs(growrate - 420) * 100 / 419) : 1;
	}
	
	if(cargoSize > TOWNGUI_LIMIT) { //if more, point to goal gui guide and add some other info
		if(town.growing) {
			towngui.append(GSText(GSText.STR_TOWNW_GROWTH_RATE, grow_ratio, town.grow_counter)); //percentage or maximum possible growth
		}
		//missing cargo
		if(update) {
			town.missing = missing_cargo;
		}
		if(town.missing) {
			towngui.append(GSText(GSText.STR_TOWNW_MISSING_CARGO, town.missing, GSText(GSText.STR_EMPTY0)));
		}
	 	towngui.append(GSText(GSText.STR_SEE_GOAL_GUI, GSText(GSText.STR_EMPTY0), GSText(GSText.STR_EMPTY0)));
	}

	while(towngui.len() < TOWNGUI_LIMIT) { //feed pool with empty string to satisfy town gui
		towngui.append(GSText(GSText.STR_EMPTY2, GSText(GSText.STR_EMPTY0), GSText(GSText.STR_EMPTY0)));
	}

	if(cargoSize != TOWNGUI_LIMIT) {
		if(!town.service) {
			txt = GSText.STR_TOWNW_GROWTYPE_NOTGROW_SRV;
		}
		else if(town.growing) {
			txt = GSText.STR_TOWNW_GROWTYPE_GROW;
		}
		else {
			txt = GSText.STR_EMPTY0; //GSText.STR_TOWNW_GROWTYPE_NOTGROW;
		}
	}
	else{
		txt = town.growing ? GSText.STR_TOWNW_GROWTYPE_GROW_PLUS : GSText.STR_TOWNW_GROWTYPE_NOTGROW_PLUS;
	}

	//town gui limit is 20 string parameters. Each entry counts as parameter as they go deeper
	GSTown.SetText( //19
		townid,
		GSText(GSText.STR_TOWNGUI,	//7
			GSText(txt), //0  STR_TOWNW_GROWTYPE_NOTGROW_SRV / STR_TOWNW_GROWTYPE_GROW / STR_EMPTY0 / STR_TOWNW_GROWTYPE_GROW_PLUS / STR_TOWNW_GROWTYPE_NOTGROW_PLUS
			towngui[0], //2  STR_TOWN_OWNED_COMPANY / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
			towngui[1], //2  STR_TOWNW_NEXT_CARGO / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
			towngui[2], //2  STR_TOWNW_GROWTH_RATE / STR_TOWNW_NEXT_CARGO / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
			towngui[3], //2  STR_SEE_GOAL_GUI / STR_TOWNW_MISSING_CARGO / STR_TOWNW_NEXT_CARGO / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
			towngui[4], //2  STR_EMPTY2 / STR_SEE_GOAL_GUI / STR_TOWNW_NEXT_CARGO / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
			towngui[5]  //2  STR_EMPTY2 / STR_TOWNW_NEXT_CARGO / STR_TOWN_CARGO_GOOD / STR_TOWN_CARGO_YES
		)
	);


	/* UPDATE GOAL GUI */
	if(update) { //update grow and display in goal gui
		//growrate = town.Grow(this.growmech); //grow grow grow, or not
		//least delivered cargo percentage info


		goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_DELIVERED_PERCENT, town.percentage_delivered), GSGoal.GT_NONE, 0);
		this.goals.append(goal_id);

		//growth info
		if(town.growing) {
			txt = GSText(GSText.STR_TOWN_GROWTYPE_GROW, town.growinrow, town.growtotal, town.monthstotal);
		}
		else{
			txt = GSText(GSText.STR_TOWN_GROWTYPE_NOTGROW, town.notgrowinrow, (town.monthstotal - town.growtotal), town.monthstotal);
		}
		goal_id = GSGoal.New(companyid, txt, GSGoal.GT_NONE, 0);
		this.goals.append(goal_id);

		//funded buildings
		if(GSGameSettings.GetValue("economy.fund_buildings")) {
			goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_FUNDED, town.funddur, town.fundedtotal), GSGoal.GT_NONE, 0);
			this.goals.append(goal_id);
		}

		//growth rate
		if(town.growing) {
			goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_GROWTH_RATE, growrate, grow_ratio, town.grow_counter), GSGoal.GT_NONE, 0);
			this.goals.append(goal_id);
		}
		//pop change and demoslished houses
		local popchange = townpop - town.popchange;
		town.popchange = townpop;
		local STR_change = popchange >= 0 ? GSText.STR_TOWN_CHANGE_POS : GSText.STR_TOWN_CHANGE_NEG;
		goal_id = GSGoal.New(companyid, GSText(STR_change, popchange, town.demolished), GSGoal.GT_NONE, 0);
		this.goals.append(goal_id);
		//missing cargo
		if(missing_cargo) {
			goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_MISSING_CARGO, missing_cargo), GSGoal.GT_NONE, 0);
			this.goals.append(goal_id);
		}
		//next required cargo
		if(cargonext) {
			goal_id = GSGoal.New(companyid, GSText(GSText.STR_TOWN_NEXT_CARGO, 1 << cargonext.id, cargonext.from), GSGoal.GT_NONE, 0);
			this.goals.append(goal_id);
		}
	}
	/* UPDATE */
}

//sorting cargo array
function arrcmp(a, b) {
	if(a.from > b.from) {
		return 1;
	}
	else if(a.from < b.from) {
		return -1;
	}
	return 0;
}

require("minor.nut");
require("saveload.nut");
require("goalprogress.nut");
