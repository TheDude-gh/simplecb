/*
	Simpleton City Builder   classes.nut
	Company class - company pool of playing companies
	Cargo class - cargo list of cargos required for CB
*/

class Company
{
	id = INVALID_COMPANY;
	hq = INVALID_TILE;
	town_id = INVALID_TOWN;
	score_last_year = 0;

	constructor(id, hq = INVALID_TILE, town_id = INVALID_TOWN) {
		this.id = id;
		this.hq = hq;
		this.town_id = town_id;
	}
}

class Cargo
{
	id = 0xFF;
	req = 0;
	from = 0;
	store = 0;

	constructor(id, req = 0, from = 0, store = 0){
		this.id = id;
		this.req = req;
		this.from = from;
		this.store = store;
	}
}