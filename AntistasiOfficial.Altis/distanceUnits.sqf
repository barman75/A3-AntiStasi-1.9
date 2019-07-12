/* TODO proper comments
    _distance = _this select 0;//la distancia requisito, normalmente distanceSPWN)
    _mode = _this select 1;//lo que devuelve la función, 0 un array, un número mayor un boolean cuando la countX llegue a ese número.
    _ref = _this select 2; // posición en formatX array u objeto
    _varName = _this select 3;//"OPFORSpawn" o "BLUFORSpawn" según queramos ver unitsX de uno u otro bando
    example: _result = [distanceSPWN,0,posHQ,"OPFORSpawn"] call distanceUnits: devuelve un array con todas las que estén a menos de distanceSPWN
    example: _result = [distanceSPWN,1,posHQ,"BLUFORSpawn"] call distanceUnits: devuelve un boolean si hay una que esté a menos de distanceSPWN
*/

params ["_distance","_mode","_ref","_varName"];
private _result = false;

if (_mode == 0) then{
	_result = [];
	{
	if (_x getVariable [_varName,false]) then
		{
		if (_x distance _ref < _distance) then
			{
			_result pushBack _x;
			};
		};
	} forEach allUnits;
}else{
	{if ((_x getvariable [_varName,false]) and (_x distance _ref < _distance)) exitWith {_result = true}} count allUnits;
};

_result
