if (!isServer and hasInterface) exitWith {};

private ["_tipo","_posbase","_potentials","_sitios","_exists","_sitio","_pos","_cityX"];

_tipo = _this select 0;

_posbase = getMarkerPos guer_respawn;
_potentials = [];
_sitios = [];
_exists = false;

_excl = [posStranger];

_fnc_info = {
	params ["_text", ["_hint", "none"]];
	{
		[[["Stranger", _text]],"DIRECT",0.15] remoteExec ["createConv",_x];
		if !(_hint == "none") then {[_hint] remoteExec ["hint",_x];}
	} forEach ([15,0,position Stranger,"BLUFORSpawn"] call distanceUnits);
};

_silencio = false;
if (count _this > 1) then {_silencio = true};

if (_tipo in missionsX) exitWith {
	if (!_silencio) then {
		["I already gave you a mission of this type"] call _fnc_info;
	};
};
if ((server getVariable "civActive") > 1) exitWith {
	if (!_silencio) then {
		["How about you prove yourself first by doing what I told you to do..."] call _fnc_info;
	};
};

if (_tipo == "ASS") then {
	_sitios = citiesX - mrkFIA - _excl;
	if (count _sitios > 0) then {
		for "_i" from 0 to ((count _sitios) - 1) do {
			_sitio = _sitios select _i;
			_pos = getMarkerPos _sitio;
			if ((_pos distance _posbase < 4000) and (not(spawner getVariable _sitio))) then {_potentials = _potentials + [_sitio]};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no assassination missions for you. Move our HQ closer to the enemy or finish some other assasination missions in order to have better intel.", "Assassination Missions require AAF cities, Observation Posts or bases closer than 4Km from your HQ."] call _fnc_info;
		};
	}
	else {
		_sitio = _potentials call BIS_fnc_selectRandom;
		[_sitio, "civ"] remoteExec ["ASS_Traitor", call AS_fnc_getNextWorker];
	};
};

if (_tipo == "CON") then {
	_sitios = power - mrkFIA - _excl;
	if (count _sitios > 0) then {
		for "_i" from 0 to ((count _sitios) - 1) do {
			_sitio = _sitios select _i;
			_pos = getMarkerPos _sitio;
			if ((_pos distance _posbase < 4000) and (_sitio in mrkAAF)) then {_potentials = _potentials + [_sitio]};
		};
	};
	if (_potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no Conquest missions for you. Move our HQ closer to the enemy or finish some other conquest missions in order to have better intel.", "Conquest Missions require AAF power plants closer than 4Km from your HQ."] call _fnc_info;
		};
	}
	else {
		_sitio = _potentials call BIS_fnc_selectRandom;
		[_sitio, "civ"] remoteExec ["CON_Power", call AS_fnc_getNextWorker];
	};
};


if (_tipo == "CONVOY") then {
	_tempSit = citiesX + bases;
	_sitios = _tempSit - mrkFIA - _excl;
	if (count _sitios > 0) then {
		for "_i" from 0 to ((count _sitios) - 1) do {
			_sitio = _sitios select _i;
			_pos = getMarkerPos _sitio;
			_base = [_sitio] call AS_fnc_findBaseForConvoy;
			if ((_pos distance _posbase < 4000) and (_base !="")) then {
				_potentials = _potentials + [_sitio];
			};
		};
	};
	if ( _potentials isEqualTo []) then {
		if (!_silencio) then {
			["I have no Convoy missions for you. Move our HQ closer to the enemy or finish some other convoy missions in order to have better intel.", "Convoy Missions require AAF Airports, Bases or Cities closer than 4Km from your HQ, and they must have an idle friendly base in their surroundings."] call _fnc_info;
		};
	}
	else {
		_sitio = _potentials call BIS_fnc_selectRandom;
		_base = [_sitio] call AS_fnc_findBaseForConvoy;
		[_sitio,_base,"civ"] remoteExec ["CONVOY", call AS_fnc_getNextWorker];
	};
};

if ((count _potentials > 0) and (!_silencio)) then {
	["I have a mission for you..."] call _fnc_info;
};
