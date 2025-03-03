/*
	Simpleton City Builder   town.nut
	Town class - town pool of claimed towns
*/

class Town
{
	id = INVALID_TOWN;
	owner = INVALID_COMPANY;
	city = null;
	growing = false; //is town growing?
	supplied = false; //is town supplied? Supplied does not equal growing (because service)
	grow_counter = 320; //when <0 build a house
	delta = 0; //date of last growth check, updates grow_counter
	nameid = 0; //town string name
	president = ""; //president name for change name check
	storage =   [];
	delivered = [];
	missing = 0; //mask of missing cargos
	service = false; //has town transport service?
	
	notgrowinrow = 0; //consecutive months when town did not grew
	growinrow = 0; //consecutive months when town did grew
	growtotal = 0; //total months when town did grew
	monthstotal = 0; //total months in game
	prevgrowed = false; //did town grew last month?
	funddur = 0;  //duratio nof funding buildings
	fundedtotal = 0; //total funded months
	
	growth_last = NO_GROWTH; //last growth when town was growing
	demolish_counter = NO_GROWTH; //counter for demolish house every x days
	demolished = 0;  //demolished house count
	popchange  = 0;  //population from last month
	percentage_delivered = 0;  //percentage of least delivered cargo

	constructor(id, owner, city = null){
		this.id = id;
		this.owner = owner;
		this.city = city;
		this.delta = GSDate.GetCurrentDate();
		this.nameid = 0;
		this.president = "";
		this.storage = [
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		]; //64x
		this.delivered = [
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		]; //64x

		this.missing = 0;
		this.service = false;
		this.grow_counter = 320;
		this.growing = false;
		this.supplied = false;
		this.notgrowinrow = 0;
		this.growinrow = 0;
		this.growtotal = 0;
		this.monthstotal = 0;
		this.prevgrowed = false;
		this.funddur = 0;
		this.fundedtotal = 0;
	}

	function Grow(growmech);
	function Service();
	function Demolish_House();
}

function Town::Grow(growmech){
	this.monthstotal++;

	//not growing
	if(!this.growing){
		if(this.prevgrowed){
			GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
		}
		this.grow_counter = 0;
		this.notgrowinrow++;
		this.growinrow = 0;
		this.prevgrowed = false;
		return 0;
	}

	//growing
	this.notgrowinrow = 0;
	this.growinrow++;
	this.growtotal++;

	//fund building counter
	local current_fund = GSTown.GetFundBuildingsDuration(this.id);
	//if previous fund was zero add extra increment.
	//This is because the month, where funding starts, is not counted, as this funcion is only evaluated on 1st of every month
	if(current_fund == 2 && this.funddur == 0) {
		this.fundedtotal++;
	}

	this.funddur = current_fund;

	if(this.funddur > 0) {
		this.fundedtotal++;
	}

	//mechanism NORMAL
	if(growmech == Growth.GROW_NORMAL) {
		if(!this.prevgrowed) {
			GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NORMAL);
			this.grow_counter = 0;
		}
		this.prevgrowed = true;
		return GSTown.GetGrowthRate(this.id);
	}
	
	
	//mechanism EXPAND
	if(growmech == Growth.GROW_EXPAND){
		// Try to get close to OpenTTD native grow mechanics
		local service = this.Service(); 

		local growrate = GSGameSettings.GetValue("economy.town_growth_rate");
		local funded = this.funddur > 0 ? 0 : 1;
		local grow_values = [
			[120, 120, 120, 100,  80,  60],  //with fund buildings
			[320, 420, 300, 220, 160, 100]   //normal growth
		];
		
		local grow_value = grow_values[funded][min(service, 5)];

		if (service == 0 && !( (GSBase.RandRange(12) + 1) / 12) == 1) {
			return 0;
		}
		growrate = (growrate != 0) ? (growrate - 1) : 1;
		growrate = grow_value >> growrate;
		growrate /= (GSTown.GetHouseCount(this.id) / 50 + 1);
		if(growrate == 0) {
			growrate++;
		}
		GSTown.SetGrowthRate(this.id, growrate);
		if(this.grow_counter > growrate) {
			this.grow_counter = growrate;
		}
		this.prevgrowed = true;
		return growrate;
	}
}

function Town::Service(){
	local stlist = GSStationList(GSStation.STATION_ANY);
	local service = 0; //serviced stations of our town
	local vstate;
	foreach(stid, _ in stlist){ //cycle through stations
		if(service >= 5) {
			break; //we dont need more than 5
		}
		//is station ours and is close to town centre?
		if(GSStation.IsValidStation(stid) && GSStation.GetOwner(stid) == this.owner
			&& GSStation.GetDistanceManhattanToTile(stid, GSTown.GetLocation(this.id)) < 20
		){
			local StationVehicleList = GSVehicleList_Station(stid); //get vehicles in station
			if(!StationVehicleList.IsEmpty()){
				foreach(vehicleid, _ in StationVehicleList){
					vstate = GSVehicle.GetState(vehicleid);
					//if there is at least one active vehicle, increment service
					if(vstate == GSVehicle.VS_RUNNING || vstate == GSVehicle.VS_AT_STATION){
						service++;
						break;
					}
				}
			}
		}
	}
	return service;
}

function Town::Demolish_House() {
	GSCompanyMode(GSCompany.COMPANY_INVALID);
	
	local population = GSTown.GetPopulation(this.id);

	this.demolish_counter--;
	//GSLog.Info("DC = " + this.demolish_counter);
	//if population lower, or demolish counter no zero or at least 25% of least delivered cargo, do not demolish
	if(population < 500 || this.demolish_counter > 0 || this.percentage_delivered > 25) {
		return;
	}
	this.demolish_counter = SHRINK_FACTOR * this.growth_last;

	local demoresult = 0;
	local tcenter = GSTown.GetLocation(this.id);
	local cX = GSMap.GetTileX(tcenter);
	local cY = GSMap.GetTileY(tcenter);
	
	
	local size = (sqrt(GSTown.GetHouseCount(this.id) * 2.5)).tointeger();
	if(size % 2 == 1) {
		size++;
	}
	//GSLog.Info("SQ = " + size);
	
	//local start = -(size / 2);
	//local end = (size / 2);

	local x, y, maxtries = 25; //max tries to demolish house. Higher number means more success in demolishing
	
	//for(local x = -start; x <= end; x++) {
		//for(local y = -start; y <= end; y++) {
	while(true) {
			x = GSBase.RandRange(size + 1) - (size >> 1);
			y = GSBase.RandRange(size + 1) - (size >> 1);
			//local ti = GSMap.GetTileIndex(locationX + x, locationY + y);
			local ti = GSMap.GetTileIndex(cX + x, cY + y);
			local tiowner = GSTile.GetOwner(ti);
			
			//GSLog.Info("TRY  " + maxtries + "  tile " + x + ":" + y);
			
			maxtries--;
			if(maxtries == 0) {
				break;
			}

			//skip if not house - there is no direct function to know a tile has house, so it's guessed with another functions
			if(tiowner == -1
				&& !GSTile.IsBuildable(ti)
				&& !GSTile.HasTransportType(ti, GSTile.TRANSPORT_ROAD)
				&& !GSIndustry.IsValidIndustry(GSIndustry.GetIndustryID(ti))
				&& !GSTile.IsStationTile(ti)
				&& !GSTile.IsWaterTile(ti)
				&& !GSTile.HasTreeOnTile(ti)
				&& !GSTile.IsFarmTile(ti)
				&& !GSTile.IsRockTile(ti)
				&& !GSTile.IsRoughTile(ti)
				&& !GSTile.IsSnowTile(ti)
				&& !GSTile.IsDesertTile(ti)
			) {
				demoresult = GSTile.DemolishTile(ti);
				//GSLog.Info("tile " + x + ":" + y + " Owner=" + tiowner + " demo=" + (demoresult ? 1 : 0) + " ERR = " + GSError.GetLastErrorString());
				if(demoresult) {
					population = population - GSTown.GetPopulation(this.id);
					this.demolished++;
					//GSLog.Info("POP reduced : " + population + ",   counter every " + this.demolish_counter + " days");
					return demoresult;
				}
			}
		//}
	}
	return demoresult;
}