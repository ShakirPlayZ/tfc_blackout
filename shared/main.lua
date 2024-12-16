--[[ Define the Power Status at Server Start (Default: true = Power is On / false = Power is Off) ]]
CONFIG_POWER_OFF_AT_SERVER_START = false

POSSIBLE_FUSE_POS = {
    vector3(2811.04, 1510.7, 24.03),
    vector3(2807.97, 1504.13, 24.03),
    vector3(2808.52, 1496.01, 24.03),
    vector3(2807.2, 1491.09, 24.03),
    vector3(2810.45, 1489.49, 24.03),
    vector3(2814.46, 1489.42, 24.03),
    vector3(2817.74, 1498.85, 24.03),
    vector3(2828.48, 1497.94, 24.03),
    vector3(2831.78, 1497.38, 24.03),
    vector3(2834.87, 1496.63, 24.03)
}

MIN_REPAIR_TIME = 1000 -- Min. Reparaturzeit in Millisekunden
MAX_REPAIR_TIME = 5000 -- Max. Reparaturzeit in Millisekunden
MAX_REPAIR_FUSES = 9 -- Sollte maximal dieselbe länge -1 , wie die anzahl der Items in der POSSIBLE_FUSE_POS List sein