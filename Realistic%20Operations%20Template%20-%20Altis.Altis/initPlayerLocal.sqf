disableRemoteSensors true;

//------------------------------ Headless Client
if !(isServer or hasInterface) then {
    if (profileName == "HCAOs") then {

        derp_HCAOsConnected = true;
        publicVariableServer "HCAOsConnected";
        format ["HCAOs connected: %1", derp_HCAOsConnected] remoteExec ["diag_log", 2];
    };
} else {//-------------------------------- Player stuff

    #include "defines.hpp"
    enableSentences false;

    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups; // Dynamic groups init

    //---------------- class specific stuff
    if (player getUnitTrait "derp_pilot") then {
        [player, pilotRespawnMarker] call BIS_fnc_addRespawnPosition;
    };

     // Disable arty computer for non FSG members
    if (player getUnitTrait "derp_mortar") then {
        enableEngineArtillery true;
    } else {
        enableEngineArtillery false;
    };

    //---------------- EHs and addactions
    player addEventHandler ["GetInMan", {
        _this call derp_fnc_pilotCheck;
        call derp_fnc_crewNames;
    }];

    player addEventHandler ["SeatSwitchedMan", {
        if !((_this select 3) isKindOf "Air") exitWith {};
        _this params ["_unit1", "", "_vehicle"];
        private _seat = ((fullCrew _vehicle) select {_x select 0 == _unit1}) select 0;
        [(_seat select 0), (_seat select 1), _vehicle, (_seat select 3)] call derp_fnc_pilotCheck;

    }];

    if ("ArsenalFilter" call BIS_fnc_getParamValue == 1) then {
        player addEventHandler ["Take", {
            params ["_unit", "_container", "_item"];

            [_unit, 1, _item, _container] call derp_fnc_gearLimitations;
        }];

        player addEventHandler ["InventoryClosed", {
            params ["_unit"];

            [_unit, 0] call derp_fnc_gearLimitations;
        }];
    };
};

// Init arsenal boxes, waitAndExec needed for players present at mission start to wait for the server remoteExec
[{[_this select 0, ("ArsenalFilter" call BIS_fnc_getParamValue)] call derp_fnc_VA_filter}, [ArsenalBoxes], 3] call derp_fnc_waitAndExecute;
