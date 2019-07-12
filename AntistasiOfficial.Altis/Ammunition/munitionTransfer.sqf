if (!isServer) exitWith {};
private ["_subObject","_ammunition"];
_origen = _this select 0;
_destinationX = _this select 1;

_ammunition= [];
_items = [];
_ammunition = magazineCargo _origen;
_items = itemCargo _origen;
_weaponsX = [];
_weaponsItemsCargo = weaponsItemsCargo _origen;
_backpcks = [];

if (count backpackCargo _origen > 0) then
	{
	{
	_backpcks pushBack (_x call BIS_fnc_basicBackpack);
	} forEach backpackCargo _origen;
	};
_containers = everyContainer _origen;
if (count _containers > 0) then
	{
	for "_i" from 0 to (count _containers) - 1 do
		{
		_subObject = magazineCargo ((_containers select _i) select 1);
		if (!isNil "_subObject") then {_ammunition = _ammunition + _subObject} else {diag_log format ["Error from %1",magazineCargo (_containers select _i)]};
		//_ammunition = _ammunition + (magazineCargo ((_containers select _i) select 1));
		_items = _items + (itemCargo ((_containers select _i) select 1));
		_weaponsItemsCargo = _weaponsItemsCargo + weaponsItemsCargo ((_containers select _i) select 1);
		};
	};
if (!isNil "_weaponsItemsCargo") then
	{
	if (count _weaponsItemsCargo > 0) then
		{
		{
			_weapon = [(_x select 0)] call BIS_fnc_baseWeapon;
		_weaponsX pushBack ([(_x select 0)] call BIS_fnc_baseWeapon);

		if ((activeAFRF) && (isNumber (configFile >> "CfgWeapons" >> (_x select 0) >> "rhs_disposable"))) then {
			_ammo = (getArray (configFile >> "CfgWeapons" >> (_x select 0) >> "magazines")) select 0;
			_ammunition pushBack _ammo;
		}
		else {
			_ammunition pushBack ((_x select 4) select 0);
		};
		for "_i" from 1 to (count _x) - 1 do
			{
			_cosa = _x select _i;
			if (typeName _cosa == typeName "") then
				{
				if (_cosa != "") then {_items pushBack _cosa};
				};
			/*
			else
				{
				if (typeName _cosa == typeName []) then
					{
					if (count _cosa > 0) then
						{
						_subObject = _cosa select 0;
						if (!isNil "_subObject") then {_ammunition pushBack _subObject; Slowhand sidechat format ["%1,%2",_ammunition,_subObject];} else {diag_log format ["Error transfering ammo on %1",_cosa]};
						};
					};
				}
			*/
			};
		} forEach _weaponsItemsCargo;
		};
	};

_weaponsFinal = [];
_weaponsFinalCount = [];
{
	_arma = _x;
	if ((not(_arma in _weaponsFinal)) and (not(_arma in unlockedWeapons))) then {
		if (_arma in blockedWeapons) then {
			_weaponsFinal pushBack ([_arma] call AS_fnc_weaponReplacement);
		} else {
			_weaponsFinal pushBack _arma;
		};
		_weaponsFinalCount pushBack ({_x == _arma} count _weaponsX);
	};
} forEach _weaponsX;

if (count _weaponsFinal > 0) then
	{
	for "_i" from 0 to (count _weaponsFinal) - 1 do
		{
		_destinationX addWeaponCargoGlobal [_weaponsFinal select _i,_weaponsFinalCount select _i];
		};
	};


_ammunitionFinalX = [];
_ammunitionFinalCount = [];
if (isNil "_ammunition") then {
	diag_log format ["Error en transmisión de munición. Tenía esto: %1 y estos containers: %2, el origen era un %3", magazineCargo _origen, everyContainer _origen,typeOf _origen];
} else {
	if (count _ammunition > 0) then {
		{
			_arma = _x;
			if ((not(_arma in _ammunitionFinalX)) and (not(_arma in unlockedMagazines))) then {
				_ammunitionFinalX pushBack _arma;
				_ammunitionFinalCount pushBack ({_x == _arma} count _ammunition);
			};
		} forEach  _ammunition;
	};
};


if (count _ammunitionFinalX > 0) then
	{
	for "_i" from 0 to (count _ammunitionFinalX) - 1 do
		{
		_destinationX addMagazineCargoGlobal [_ammunitionFinalX select _i,_ammunitionFinalCount select _i];
		};
	};

_itemsFinal = [];
_itemsFinalCount = [];
if (count _items > 0) then {
	{
		_arma = _x;
		if ((not(_arma in _itemsFinal)) and (not(_arma in unlockedItems))) then {
			_itemsFinal pushBack _arma;
			_itemsFinalCount pushBack ({_x == _arma} count _items);
		};
	} forEach _items;
};


if (count _itemsFinal > 0) then
	{
	for "_i" from 0 to (count _itemsFinal) - 1 do
		{
		_destinationX addItemCargoGlobal [_itemsFinal select _i,_itemsFinalCount select _i];
		};
	};

_backpcksFinal = [];
_backpcksFinalCount = [];
if (count _backpcks > 0) then {
	{
		_arma = _x;
		if ((not(_arma in _backpcksFinal)) and (not(_arma in unlockedBackpacks))) then {
			_backpcksFinal pushBack _arma;
			_backpcksFinalCount pushBack ({_x == _arma} count _backpcks);
		};
	} forEach _backpcks;
};

if (count _backpcksFinal > 0) then
	{
	for "_i" from 0 to (count _backpcksFinal) - 1 do
		{
		_destinationX addBackpackCargoGlobal [_backpcksFinal select _i,_backpcksFinalCount select _i];
		};
	};

if (count _this == 3) then
	{
	deleteVehicle _origen;
	}
else
	{
	clearMagazineCargoGlobal _origen;
	clearWeaponCargoGlobal _origen;
	clearItemCargoGlobal _origen;
	clearBackpackCargoGlobal _origen;
	};

if (_destinationX == caja) then {
	if (isMultiplayer) then {{if (_x distance caja < 10) then {[petros,"hint","Ammobox Loaded"] remoteExec ["commsMP",_x]}} forEach playableUnits} else {hint "Ammobox Loaded"};
	if !(activeJNA) then {_updated = [] call AS_fnc_updateArsenal};
	if (count _updated > 0) then
		{
		_updated = format ["Arsenal Updated<br/><br/>%1",_updated];
		[[petros,"income",_updated],"commsMP"] call BIS_fnc_MP;
		};
	}
else
	{
	[petros,"hint","Truck Loaded"] remoteExec ["commsMP",driver _destinationX];
	};
