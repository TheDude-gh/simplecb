/*
	Simpleton City Builder   minot.nut
	Simpleton class - additional functions of main class
*/

function SimpletonCB::Log(string, level = 0){
	if(level <= this.log) {
		GSLog.Info(string);
	}
}

/* MAP GENERATION */
function SimpletonCB::xMapgen(){
	if(GSController.GetSetting("xMapgen") == 0) {
		return;
	}
	GSLog.Info("Mapgen starts");

	local climate = GSGame.GetLandscape();

	//temperate and arctic power plants
	if(climate == 0){
		//power plant, coal
		this.PlaceIndustry(0x01, 0x01, 10, 25, MapGenMethod.RANDOM);
		//bank,  valuables
		this.PlaceIndustry(0x0C, 0x0A,  1, 5, MapGenMethod.RANDOM, true);
	}
	else if(climate == 1){
		//power plant, coal
		this.PlaceIndustry(0x01, 0x01, 10, 25, MapGenMethod.RANDOM);
		//bank,  valuables
		this.PlaceIndustry(0x10, 0x0A,  2, 10, MapGenMethod.RANDOM);
	}
	//tropic water towers
	else if(climate == 2){
		//water tower, water
		this.PlaceIndustry(0x16, 0x09,  1, 5, MapGenMethod.RANDOM);
		//bank,  valuables
		this.PlaceIndustry(0x10, 0x0A,  2, 10, MapGenMethod.RANDOM);
	}
}

function SimpletonCB::PlaceIndustry(ind, cargo, distmin, distmax, method, onlyCity = false){
	local xtownlist = GSTownList();
	local txy, tx, rx, ry, ty, rtile, n, success, built = 0, skip = 0, towncount = 0, ntotal = 0, isCity;
	local tile_area = [], xtile_area = [], rand;
	//cycle industries, remove towns, where desired industry is already present
	local indlist = GSIndustryList_CargoAccepting(cargo);
	foreach(indid, _ in indlist){
		if(GSIndustry.GetIndustryType(indid) != ind) {
			continue; //if industry is not desired, skip
		}
		local closetownid = GSTile.GetClosestTown(GSIndustry.GetLocation(indid));
		xtownlist.RemoveItem(closetownid);
		skip++;
	}
	GSLog.Info("Mapgen will skip " + skip + " towns");
	skip = 0;

	GSCompanyMode(GSCompany.COMPANY_INVALID); //since 1.3.0 we can use GAIA company

	if(method == MapGenMethod.SQUARE){
		//create array of tiles forming square around town
		for(local i = -distmax; i <= distmax; i++){
			for(local j = -distmax; j <= distmax; j++){
				if(abs(i) + abs(j) < distmin) {
					continue;
				}
				tile_area.append([i, j]);
			}
		}
	}

	foreach(townid, _ in xtownlist){
		isCity = GSTown.IsCity(townid);
		if((isCity && !onlyCity) || (!isCity && onlyCity)) {
			continue; //skip cities
		}
		towncount++;

		success = false;
		txy = GSTown.GetLocation(townid);
		tx = GSMap.GetTileX(txy);
		ty = GSMap.GetTileY(txy);
		n = 0;

		if(method == MapGenMethod.RANDOM){
			while(success != true && n < 127){ //try 127x or until success
				//pick random tileXY in given range
				rx = GSBase.RandRange(distmax * 2 + 1) - distmax;  
				ry = GSBase.RandRange(2 * (distmax - abs(rx)) + 1) - (distmax - abs(rx));
				if(abs(rx) + abs(ry) < distmin) {
					continue;
				}

				rtile = GSMap.GetTileIndex(tx + rx, ty + ry);
				if(!GSMap.IsValidTile(rtile) || GSRoad.IsRoadTile(rtile)) {
					continue; //skip invalid
				}

				success = GSIndustryType.BuildIndustry(ind, rtile); //try building here
				if(success){
					built++;
				}
				n++;
			}
		}
		else if(method == MapGenMethod.SQUARE){
			xtile_area = clone tile_area;
			//seek through square
			for(local i = 0, size = xtile_area.len(); i < size; i++){
				rand = GSBase.RandRange(size - i); //pick random tile from the square
				rx = tile_area[rand][0];
				ry = tile_area[rand][1];
				rtile = GSMap.GetTileIndex(tx + rx, ty + ry);
				xtile_area.remove(rand); //remove that one

				if(!GSMap.IsValidTile(rtile) || GSRoad.IsRoadTile(rtile)) {
					continue; //skip invalid or occupied
				}
				success = GSIndustryType.BuildIndustry(ind, rtile);
				if(success){
					built++;
					break;
				}
				n++;
			}
		}

		ntotal += n;
		if(!success) {
			skip++;
		}
	}
	GSLog.Info("Mapgen has built " + built + " " + GSIndustryType.GetName(ind) + "s failed in " + skip + (onlyCity ? " cities" : " towns") + " of all " + towncount);
}
/* /MAP GENERATION */

//function intended to remove industries which are too close to town, but it's not possible to demolish industries wiht GS
function SimpletonCB::xMapgenRem() {
	return;

	local townlist = GSTownList();
	local indlist = GSIndustryList();
	
	local txy, tx, rx, ry, ty, rtile, n, success, built = 0, skip = 0, towncount = 0, ntotal = 0, isCity;
	
	
	/*foreach(indid, _ in indlist){
		if(GSIndustry.GetIndustryType(indid) != ind) {
			continue; //if industry is not desired, skip
		}
		local closetownid = GSTile.GetClosestTown(GSIndustry.GetLocation(indid));
		xtownlist.RemoveItem(closetownid);
		skip++;
	}*/


	GSCompanyMode(GSCompany.COMPANY_INVALID); //since 1.3.0 we can use DEITY company

	//GSExecMode.GSExecMode();

	//GSCompany.ChangeBankBalance(GSCompany.COMPANY_FIRST, 1000000, GSCompany.EXPENSES_OTHER, GSMap.TILE_INVALID);


	for(local i = 0; i < 200; i++) {
	  this.Log("TICK " + GSController.GetTick() + "   OPSUSP " + GSController.GetOpsTillSuspend());
		for(local j = 0; j < 200; j++) {
			local ti = GSMap.GetTileIndex(i, j);
			if(!GSTile.IsBuildable(ti)) {
				local demoresult = GSTile.DemolishTile(ti);
				this.Log("DEMO " + i + "," + j + "   " + demoresult);
			}
		}
	}
	return;

	foreach(indid, _ in indlist) {
		local tile = GSIndustry.GetLocation(indid);
		local townid = GSTile.GetClosestTown(tile);

		local distance = GSTown.GetDistanceManhattanToTile(townid, tile);
		if(distance < 40) {
		  local demoresult = GSTile.DemolishTile(tile);
		  this.Log("CLOSE Town " + GSTown.GetName(townid) + " IID " + indid + "  " + GSIndustry.GetName(indid) + "  DEMO=" + (demoresult ? 1 : 0));
		}
		continue;

		local demoresult = GSTile.DemolishTile(tile);

		local X = GSMap.GetTileX(tile);
		local Y = GSMap.GetTileY(tile);

		local ti = GSMap.GetTileIndex(X + 1, Y + 1);
		local demoresult = GSTile.DemolishTile(ti);
		//GSIndustry.SetText(indid, GSText(GSText.STR_RAW, "IID " + indid));
		GSIndustry.SetText(indid, "IID " + indid);
		GSLog.Info("IND ITEM " + indid + "  tile " + X + ":" + Y + " demo=" + (demoresult ? 1 : 0) + " ERR = " + GSError.GetLastErrorString());
	}
}

/* SIGNS */
function SimpletonCB::PlaceSign(tileIndex, text) {
	local signid = GSSign.BuildSign(tileIndex, text);
	if (GSSign.IsValidSign(signid)) {
		this.signlist.AddItem(signid, tileIndex);
	}
	/*else{
		GSLog.Info(GSTown.GetName(GSTile.GetClosestTown(tileIndex)) + " no sign");
	}*/
}

function SimpletonCB::RemoveSign(tileIndex){
	foreach (signid, signtile in this.signlist) {
		if (signtile == tileIndex) {
			this.signlist.RemoveItem(signid);
			GSSign.RemoveSign(signid);
		}
	}
}

/*
 * The in-game coordinates *
 *         ^ Z             *
 *           |             *
 *           |             *
 *         /   \           *
 *       /       \         *
 *   X <           > Y     *
 */
function SimpletonCB::TownArea(tileIndex, companyid, place){
	if (this.townarea == 0) return;

	local locationX = GSMap.GetTileX(tileIndex);
	local locationY = GSMap.GetTileY(tileIndex);
	//get coordinates limited by map borders
	local xtop	 = max(locationX - this.townarea, 1);
	local xbot	 = min(locationX + this.townarea, this.mapX);
	local yleft	 = max(locationY - this.townarea, 1);
	local yright = min(locationY + this.townarea, this.mapY);

	if(place){
		PlaceSign(GSMap.GetTileIndex(xtop, yleft),	GSText(GSText.STR_HQAREA_TOP, companyid));
		PlaceSign(GSMap.GetTileIndex(xbot, yright),	GSText(GSText.STR_HQAREA_BOTTOM, companyid));
		PlaceSign(GSMap.GetTileIndex(xtop, yright),	GSText(GSText.STR_HQAREA_RIGHT, companyid));
		PlaceSign(GSMap.GetTileIndex(xbot, yleft),	GSText(GSText.STR_HQAREA_LEFT, companyid));
	}
	else{
		RemoveSign(GSMap.GetTileIndex(xtop, yleft));
		RemoveSign(GSMap.GetTileIndex(xtop, yright));
		RemoveSign(GSMap.GetTileIndex(xbot, yright));
		RemoveSign(GSMap.GetTileIndex(xbot, yleft));
	}
}
/* /SIGNS */

/* Set Cargo requirements based on chosen preset  */
function SimpletonCB::SelectPresetCB(cbeconomy) {

	//arrays with presets:  cargoid, req, pop, store
	local presets = [
		//0 CUSTOM TEMP - handled elsewhere, here 0 is invalid and should not happen
		[
			[0, 0, 0, 0] //invalid
		],
		//1 vannila TEMP
		[
			[0,  200,   500,   0], //pax
			[1,  100,   250,   0], //coal
			[2,   40,  1000,   0], //mail
			[5,  200,  1500, 100], //goods
			[10,  10,  2500, 100], //valuables
		],
		//2 vannila ARCTIC
		[
			[0,  150,   500,   0], //pax
			[1,  100,   250,   0], //coal
			[2,   30,  1000,   0], //mail
			[5,  125,  1500, 100], //goods
			[10,  40,  2500, 100], //gold
			[11, 100,   150, 100], //food
		],
		//3 vannila TROPIC
		[
			[0,  150,   500,   0], //pax
			[2,   30,  1000,   0], //mail
			[5,  125,  1500, 100], //goods
			[9,  100,     0,   0], //water
			[10,  50,  2500, 100], //diamonds
			[11, 100,     0, 100], //food
		],
		//4 vannila TOYLAND
		[
			[0,  160,   250,   0], //pax
			[2,   15,   750,   0], //mail
			[3,  100,  5000, 100], //toys
			[5,  200,  1500, 100], //sweets
			[11, 200,  2500, 100], //fizzy drinks
		],
		//5 ECS
		[
			[ 0,   50,   125,   0], //pax
			[ 1,   15,  9000, 100], //coal
			[ 2,   20,   500,   0], //mail
			[ 5,   70,  3000, 100], //goods
			[ 9,    5,  8000, 100], //steel
			[10,    8, 11000, 100], //gold
			[11,   30,   750, 100], //food
			[18,   20,  7500, 100], //glass
			[19,   13,  5000, 100], //wood products
			[24,    4, 10000, 100], //vehicles
			[25,   15,  4000, 100], //gasoline
			[28,   13,  6000, 100], //building materials
			[31,    4,  2000,   0], //tourists
		],
		//6 XIS
		[
			[ 0, 100,   250,   0], //pax
			[ 2,  20,   500,   0], //mail
			[ 3,  25,  5000, 100], //alcohol
			[ 5, 150,  2500, 100], //goods
			[39,  30,  7000, 100], //petroleum fuels
			[46,  50, 15000, 100], //recyclables
			[58,  10, 25000, 100], //vehicles
		],
		//7 YETI
		[
			[ 0,  150,  250,   0], //pax
			[ 2,   25,  500,   0], //mail
			[ 4,   40, 1000, 100], //building materials
			[ 8,   40, 2500, 100], //food
			[15,   30, 8000, 100], //machinery
			[16,   25, 5000,   0], //yeti dudes
		],
		//8 FIRS 3 TEMP
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[11,  50,  1000, 100], //food
		],
		//9 FIRS 3 ARCTIC
		[
			[ 0, 150,   250,   0], //pax
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[ 8,  40,  5000, 100], //alcohol
			[11,  50,  1000, 100], //food
		],
		//10 FIRS 3 TROPIC
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[ 6,  30, 10000, 100], //coffee
			[11,  50,  1000, 100], //food
		],
		//11 FIRS 3 HOT COUNTRY
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[ 8,  30, 10000, 100], //coffee
			[11,  50,  1000, 100], //food
		],
		//12 FIRS 3 STEEL TOWN
		[
			[ 0, 100,   250,   0], //pax
			[ 2,  20,   500,   0], //mail
			[ 5,  50,  7500, 100], //vehicles
			[11,  40,  1000, 100], //food
			[13, 200,  2500,   0], //coal
			[17,  50,  5000, 100], //petroleum fuels
		],
		//13 FIRS 3 EXTREME
		[
			[ 0, 100,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[11,  50,  1000, 100], //food
			[22,  30,  7500, 100], //petroleum fuels
			[24,  40, 10000, 100], //recyclables
		],

		//14 FIRS 4 TEMP
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 150,  2500, 100], //goods
			[11,  50,  1000, 100], //food
		],
		//15 FIRS 4 ARCTIC
		[
			[ 0, 150,   250,   0], //pax
			[ 2,  20,   500,   0], //mail
			[12,  80,  2500, 100], //peat
			[11,  50,  1000, 100], //food
		],
		//16 FIRS 4 TROPIC
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 120,  2500, 100], //goods
			[ 6,  30, 10000, 100], //coffee
			[11,  50,  1000, 100], //food
		],
		//17 FIRS 4 HOT COUNTRY
		[
			[ 0, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[ 2,  20,   500,   0], //mail
			[ 5, 100,  2500, 100], //goods
			[ 8,  30, 10000, 100], //coffee
			[11,  50,  1000, 100], //food
			[23,  25,  7500, 100], //petroleum fuels
		],
		//18 FIRS 4 STEEL TOWN
		[
			[ 0, 100,   250,   0], //pax
			[ 2,  20,   500,   0], //mail
			[ 5,  50,  7500, 100], //vehicles
			[11,  40,  1000, 100], //food
			[13, 150,  2500,   0], //coal
		],

		//19 FIRS 5 TEMP
		[
			[14, 150,   250,   0], //pax
			[ 0,  40,  5000, 100], //alcohol
			[12,  20,   500,   0], //mail
			[ 7, 150,  2500, 100], //goods
			[ 9,  50,  1000, 100], //food
		],
		//20 FIRS 5 ARCTIC
		[
			[11, 150,   250,   0], //pax
			[ 9,  20,   500,   0], //mail
			[12,  80,  2500, 100], //peat
			[ 6,  50,  1000, 100], //food
		],
		//21 FIRS 5 TROPIC
		[
			[17, 150,   250,   0], //pax
			[ 0,  40,  5000, 100], //alcohol
			[14,  20,   500,   0], //mail
			[11, 125,  2500, 100], //goods
			[ 3,  30, 10000, 100], //coffee
			[ 9,  50,  1000, 100], //food
		],
		//22 FIRS 5 HOT COUNTRY
		[
			[23, 150,   250,   0], //pax
			[ 1,  40,  5000, 100], //alcohol
			[18,  20,   500,   0], //mail
			[15, 100,  2500, 100], //goods
			[ 6,  30, 10000, 100], //coffee
			[13,  50,  1000, 100], //food
			[24,  25,  7500, 100], //petroleum fuels
		],
		//23 FIRS 5 STEEL TOWN
		[
			[28, 100,   250,   0], //pax
			[24,  25,   500,   0], //mail
			[ 6,  30,  1000, 100], //food
			[19,  40,  4000, 100], //goods
			[12,  15,  7500, 100], //concrete products
			[20,  20, 12500, 100], //hardware
			[54,  50, 25000, 100], //vehicles
		],

		//24 Apollo rocket IS
		[
			[ 0, 100,   250,   0], //pax
			[ 2,  25,  1000,   0], //mail
			[ 1,  50,   500,   0], //coal
			[ 5,  50,  3000, 100], //goods
			[10,   5,  5000, 100], //valuables
			[17,  40, 10000, 100], //apollo landers
			[16,  40, 10000, 100], //apollo spacecraft
			[18,  40, 10000, 100], //rocket stages
		],
		//[0,  0,   0,   0], //
	];

	//on invalid index just return first preset
	if(cbeconomy <= 0 || cbeconomy >= presets.len()) {
		return presets[0];
	}

	return presets[cbeconomy];
}

//global log
function gLog(string, level = 0){
	if(level <= ::cbloglevel) {
		GSLog.Info(string);
	}
}