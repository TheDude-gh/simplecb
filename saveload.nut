/*
	Simpleton City Builder   saveload.nut
	Save and Load functions
*/

function SimpletonCB::Save() {
	GSLog.Info("Saving data");
	this.data = {
		sv_goal = this.goal,
		sv_game_length = this.game_length,
		sv_last_month = this.last_month,
		sv_firstrun = this.firstrun,
		sv_companies = [],
		sv_goals = [],
		sv_towns = [],
		sv_cargos = [],
		sv_signs = [],
		sv_claim = this.claim_pop,
		sv_logs = this.log,
		sv_storage = this.max_storage,
		sv_townarea = this.townarea,
		sv_townstring = this.townstring,
		sv_growmech = this.growmech,
		sv_goalprogress = this.goalprogress,
		sv_dyngrowth = this.dyn_growth,
		sv_townstring = this.townstring,
	};

	foreach(company in this.companies){
		data.sv_companies.append([company.id, company.hq, company.town_id, company.score_last_year]);
		Log("Saving data for company #" + company.id, 2);
	}
	foreach(goal_id in this.goals){
		data.sv_goals.append(goal_id);
		//Log("Saving data for goal id #" + goal_id, 2);
	}
	foreach(cargo in this.CBcargo){
		data.sv_cargos.append([cargo.id, cargo.req, cargo.from, cargo.decay]);
		Log("Saving data for cargo id #" + cargo.id, 2);
	}
	foreach(town in this.townlistCB){
		data.sv_towns.append([town.id, town.owner, town.city, town.growing, town.storage, town.delivered, town.notgrowinrow,
			town.growinrow, town.growtotal, town.monthstotal, town.grow_counter, town.delta,
			town.nameid, town.president, town.service, town.prevgrowed, town.funddur, town.fundedtotal]);
		Log("Saving data for town id #" + town.id + " owned by " + town.owner, 2);
	}
	foreach (signid, signtile in this.signlist) {
		data.sv_signs.append([signid, signtile]);
		//Log("Saving data for sign id #" + signid, 2);
	}
	return this.data;
}

function SimpletonCB::Load(version, tbl) {
	GSLog.Info("Loading data");
	foreach(key, val in tbl)	{
		if(key == "sv_game_length") this.game_length = val;
		else if(key == "sv_goal")	this.goal = val;
		else if(key == "sv_last_month")	this.last_month = val;
		else if(key == "sv_firstrun")	this.firstrun = val;
		else if(key == "sv_claim")	this.claim_pop = val;
		else if(key == "sv_logs") this.log = val;
		else if(key == "sv_storage") this.max_storage = val;
		else if(key == "sv_townarea") this.townarea = val;
		else if(key == "sv_townstring") this.townstring = val;
		else if(key == "sv_growmech") this.growmech = val;
		else if(key == "sv_goalprogress") this.goalprogress = val;
		else if(key == "sv_dyngrowth") this.dyn_growth = val;
		else if(key == "sv_townstring") this.townstring = val;
		else if(key == "sv_companies"){
			foreach(company in val){
				//company.id, company.hq, company.town_id
				this.companies.append( Company(company[0], company[1], company[2]) );
				local company2 = GetCompanyByID(company[0]);
				company2.score_last_year = company[3];
				Log("loading company " + company[0] + " who owns " + company[2], 2);
			}
		}
		else if(key == "sv_goals"){
			foreach(goal_id in val){
				this.goals.append(goal_id);
				//Log("loading goal " + key + " => " + goal_id, 2);
			}
		}
		else if(key == "sv_cargos"){
			foreach(cargo in val){
				//cargo.id, cargo.req, cargo.from, cargo.decay
				this.CBcargo.append( Cargo(cargo[0], cargo[1], cargo[2], cargo[3]) );
				Log("loading cargoid " + cargo[0] + " req: " + cargo[1], 2);
			}
		}
		else if(key == "sv_towns"){
			foreach(svtown in val){
				//town.id, town.owner, town.city, town.growing, town.storage, town.delivered, town.growinrow, town.growtotal, town.monthstotal
				this.townlistCB.append( Town(svtown[0], svtown[1], svtown[2]) );
				local town = this.GetTownByID(svtown[0]);
				town.growing = svtown[3];
				town.storage = svtown[4];
				town.delivered = svtown[5];
				town.notgrowinrow = svtown[6];
				town.growinrow = svtown[7];
				town.growtotal = svtown[8];
				town.monthstotal = svtown[9];
				town.grow_counter = svtown[10];
				town.delta = svtown[11];
				town.nameid = svtown[12];
				town.president = svtown[13];
				town.service = svtown[14];
				town.prevgrowed = svtown[15];
				town.funddur = svtown[16];
				town.fundedtotal = svtown[17];

				Log("loading townid " + town.id, 2);
			}
		}
		else if(key == "sv_signs"){
			foreach(sign in val){
				this.signlist.AddItem(sign[0], sign[1])
				//Log("loading sign " + sign[0] + " at " + sign[1], 2);
			}
		}
	}
	this.from_save = true;

	foreach(town in this.townlistCB){
		this.StartTownMonitor(town.owner, town.id); //start accepting cargo
	}
}