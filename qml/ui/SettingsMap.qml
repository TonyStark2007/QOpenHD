import QtQuick 2.12

/*
 * These are mappings for the raw settings key/value pairs provided by the ground station. We
 * give certain settings full readable titles, type information, and limits or ranges in order
 * to make them more visible and easier to deal with.
 *
 * Any settings not listed in these mappings will still end up in the "other" tab, allowing graceful
 * fallback if new settings are added on the ground station. Any settings that are *removed* from the
 * ground station will simply not show up anymore, even if there is a mapping for it, preventing
 * the app from being fragile and dependent on specific versions of the ground station.
 *
 */
Item {
    id: settingsMap
    property var generalSettingsMap: ({
        "DEBUG":           {title: "Enable debug mode",
                            info: "Enable collection of extra debug logs, allow SSH, and on Airpi turn on the framebuffer for the text console",
                            itemType: "bool",
                            trueValue: "Y",
                            falseValue: "N"},
        "QUIET":           {title: "Enable quiet mode",
                            info: "Disables text messages about Display and Wifi card setup etc",
                            itemType: "bool",
                            trueValue: "Y",
                            falseValue: "N"},
        "ENABLE_SCREENSHOTS": {title: "Enable OSD screenshots",
                            info: "Blank",
                            itemType: "bool",
                            trueValue: "Y",
                            falseValue: "N"},
        "DISPLAY_OSD":     {title: "Display OSD",
                            info: "Controls whether the OSD is shown on the ground station display",
                            itemType: "bool",
                            trueValue: "Y",
                            falseValue: "N"},
        "ENABLE_QOPENHD":  {title: "Use QOpenHD as OSD",
                            info: "Select between QOpenHD and the older OSD. If disabled, you must edit the config file to enable QOpenHD again.",
                            itemType: "bool",
                            trueValue: "Y",
                            falseValue: "N"},

    })

    property var videoSettingsMap: ({
        "BITRATE_PERCENT": {title: "Bitrate percent",
                            info: "On congested channels set lower value like 60% to avoid a delayed video stream. On free channels you may set this to a higher value like 75% to get a higher bitrate and thus image quality.",
                            itemType: "number",
                            lowerLimit: 0,
                            upperLimit: 100,
                            interval: 1,
                            unit: "%"},
        "VIDEO_BITRATE":   {title: "Video bitrate",
                            info:  "Setting AUTO the AirPi reads available bandwidth to determine bitrate. A number value forces fixed bitrate",
                            itemType: "string"},
        "VIDEO_BLOCKLENGTH": {title: "Block length",
                            info:  "Blocklength, Blocks, and fec are tightly connected. Recommended Maximum: blocklength Ralink = 2278, Atheros = 1550 Recommended Minimum: 700",
                            itemType: "string"},
        "VIDEO_BLOCKS":    {title: "Blocks",
                            info:  "Blocklength, Blocks, and fec are tightly connected. For better range reduce blocks to 10",
                            itemType: "number",
                            lowerLimit: 1,
                            upperLimit: 20,
                            interval: 1,
                            unit: ""},
        "VIDEO_FECS":      {title: "FECs",
                            info: "Blocklength, Blocks, and fec are tightly connected. For better range reduce FEC to 2",
                            itemType: "number",
                            lowerLimit: 1,
                            upperLimit: 20,
                            interval: 1,
                            unit: ""},
        "WIDTH":           {title: "Width",
                            info: "Camera Resolution",
                            itemType: "string"},
        "HEIGHT":          {title: "Height",
                            info: "Camera Resolution",
                            itemType: "string"},
        "FPS":             {title: "Frames per second",
                            info: "Values above 60 are experimental",
                            itemType: "choice",
                            choiceValues: [{title: "30 FPS", value: 30},
                               {title: "48 FPS", value: 48},
                               {title: "59.9 FPS", value: 59.9}]},
        "KEYFRAMERATE":    {title: "Keyframe interval",
                            info: "Lower values mean faster glitch-recovery, but also lower video quality",
                            itemType: "number",
                            lowerLimit: 1,
                            upperLimit: 60,
                            interval: 1,
                            unit: ""},
        "EXTRAPARAMS":     {title: "Extra parameters",
                            info: "Blank",
                            itemType: "string"},
        "FORWARD_STREAM": {title: "Hotspot video format",
                           info: "Hotspot video can either be RTP encapsulated, or \"raw\" h264. RTP is recommended, as it helps the receiver prevent video distortion caused by minor RF interference. This setting must match on the receiver.",
                           itemType: "choice",
                           choiceValues: [{title: "RTP", value: "rtp"},
                                          {title: "Raw", value: "raw"}]},
        "VIDEO_UDP_PORT": {title: "Main video port",
                           itemType: "number",
                           lowerLimit: 5600,
                           upperLimit: 5610,
                           interval: 1,
                           unit: ""},
        "VIDEO_UDP_PORT2": {title: "Secondary video port",
                           itemType: "number",
                           lowerLimit: 5600,
                           upperLimit: 5610,
                           interval: 1,
                           unit: ""},
    })

    property var radioSettingsMap: ({
        "Bandwidth":       {title: "Radio bandwidth",
                            info: "For Atheros ONLY! Choose between 20mhz, 10mhz or 5mhz bandwidth at the expense of 1/4 or 1/2 of total available Datarate/Bitrate. Range can be increased significantly with 5/10mhz Narrowband",
                            itemType: "choice",
                            choiceValues:  [{title: "5MHz", value: 5},
                                            {title: "10MHz", value: 10},
                                            {title: "20MHz", value: 20}]},
        "EncryptionOrRange": {title: "Encryption/range mode",
                            info: "Encryption is a more secure means of RC uplink but may Result in higher packet loss at longer ranges",
                            itemType: "choice",
                            choiceValues:  [{title: "Encryption", value: "Encryption"},
                                            {title: "Range", value: "Range"}]},
        "FREQ":            {title: "Frequency",
                            info: "REALTEK RTL8812/14AU cards DO NOT work with 2.4GHZ frequency. For those cards use a 5.8GHZ frequency",
                            itemType: "choice",
                            choiceValues:  [{title: "2312 (Atheros)", value: 2312},
                                            {title: "2317 (Atheros)", value: 2317},
                                            {title: "2322 (Atheros)", value: 2322},
                                            {title: "2327 (Atheros)", value: 2327},
                                            {title: "2332 (Atheros)", value: 2332},
                                            {title: "2337 (Atheros)", value: 2337},
                                            {title: "2342 (Atheros)", value: 2342},
                                            {title: "2347 (Atheros)", value: 2347},
                                            {title: "2352 (Atheros)", value: 2352},
                                            {title: "2357 (Atheros)", value: 2357},
                                            {title: "2362 (Atheros)", value: 2362},
                                            {title: "2367 (Atheros)", value: 2367},
                                            {title: "2372 (Atheros)", value: 2372},
                                            {title: "2377 (Atheros)", value: 2377},
                                            {title: "2382 (Atheros)", value: 2382},
                                            {title: "2387 (Atheros)", value: 2387},
                                            {title: "2392 (Atheros)", value: 2392},
                                            {title: "2397 (Atheros)", value: 2397},
                                            {title: "2402 (Atheros)", value: 2402},
                                            {title: "2407 (Atheros)", value: 2407},
                                            {title: "2412 (Ralink/Atheros)", value: 2412},
                                            {title: "2417 (Ralink/Atheros)", value: 2417},
                                            {title: "2422 (Ralink/Atheros)", value: 2422},
                                            {title: "2427 (Ralink/Atheros)", value: 2427},
                                            {title: "2432 (Ralink/Atheros)", value: 2432},
                                            {title: "2437 (Ralink/Atheros)", value: 2437},
                                            {title: "2442 (Ralink/Atheros)", value: 2442},
                                            {title: "2447 (Ralink/Atheros)", value: 2447},
                                            {title: "2452 (Ralink/Atheros)", value: 2452},
                                            {title: "2457 (Ralink/Atheros)", value: 2457},
                                            {title: "2462 (Ralink/Atheros)", value: 2462},
                                            {title: "2467 (Ralink/Atheros)", value: 2467},
                                            {title: "2472 (Ralink/Atheros)", value: 2472},
                                            {title: "2484 (Ralink/Atheros)", value: 2484},
                                            {title: "2477 (Atheros)", value: 2477},
                                            {title: "2482 (Atheros)", value: 2482},
                                            {title: "2487 (Atheros)", value: 2487},
                                            {title: "2489 (Atheros)", value: 2489},
                                            {title: "2492 (Atheros)", value: 2492},
                                            {title: "2494 (Atheros)", value: 2494},
                                            {title: "2497 (Atheros)", value: 2497},
                                            {title: "2499 (Atheros)", value: 2499},
                                            {title: "2512 (Atheros)", value: 2512},
                                            {title: "2532 (Atheros)", value: 2532},
                                            {title: "2572 (Atheros)", value: 2572},
                                            {title: "2592 (Atheros)", value: 2592},
                                            {title: "2612 (Atheros)", value: 2612},
                                            {title: "2632 (Atheros)", value: 2632},
                                            {title: "2652 (Atheros)", value: 2652},
                                            {title: "2672 (Atheros)", value: 2672},
                                            {title: "2692 (Atheros)", value: 2692},
                                            {title: "2712 (Atheros)", value: 2712},
                                            {title: "5180", value: 5180},
                                            {title: "5200", value: 5200},
                                            {title: "5220", value: 5220},
                                            {title: "5240", value: 5240},
                                            {title: "5260 (DFS RADAR)", value: 5260},
                                            {title: "5280 (DFS RADAR)", value: 5280},
                                            {title: "5300 (DFS RADAR)", value: 5300},
                                            {title: "5320 (DFS RADAR)", value: 5320},
                                            {title: "5500 (DFS RADAR)", value: 5500},
                                            {title: "5520 (DFS RADAR)", value: 5520},
                                            {title: "5540 (DFS RADAR)", value: 5540},
                                            {title: "5560 (DFS RADAR)", value: 5560},
                                            {title: "5580 (DFS RADAR)", value: 5580},
                                            {title: "5600 (DFS RADAR)", value: 5600},
                                            {title: "5620 (DFS RADAR)", value: 5620},
                                            {title: "5640 (DFS RADAR)", value: 5640},
                                            {title: "5660 (DFS RADAR)", value: 5660},
                                            {title: "5680 (DFS RADAR)", value: 5680},
                                            {title: "5700 (DFS RADAR)", value: 5700},
                                            {title: "5745", value: 5745},
                                            {title: "5765", value: 5765},
                                            {title: "5785", value: 5785},
                                            {title: "5805", value: 5805},
                                            {title: "5825", value: 5825}]},
        "CTS_PROTECTION": {title: "CTS", itemType: "bool", trueValue: "Y", falseValue: "N"},
        "DATARATE": {title: "Data rate",
                     itemType: "choice",
                     choiceValues: [{title: "5.5Mbps/6.5Mbps (MCS)", value: 1},
                                    {title: "11Mbps/13Mbps (MCS)", value: 2},
                                    {title: "12Mbps/13Mbps (MCS)", value: 3},
                                    {title: "19.5Mbps", value: 4},
                                    {title: "24Mbps/26Mbps (MCS)", value: 5},
                                    {title: "36Mbps/39Mbps (MCS)", value: 6}]},
        "txpower": {title: "TX power", itemType: "string"},
        "TxPowerAir": {title: "TX power (air)", itemType: "string"},
        "TxPowerGround": {title: "TX power (ground)", itemType: "string"},
        "aifs": {title: "Arbitrated Interframe Space",
                 itemType: "number",
                 lowerLimit: 0,
                 upperLimit: 5,
                 interval: 1,
                 unit: ""},
        "cwmin": {title: "Contention Window Min",
                 itemType: "number",
                 lowerLimit: 0,
                 upperLimit: 10,
                 interval: 1,
                 unit: ""},
        "cwmax": {title: "Contention Window Max",
                 itemType: "number",
                 lowerLimit: 0,
                 upperLimit: 10,
                 interval: 1,
                 unit: ""},
        "cck_sifs": {title: "CCK SIFS",
                     itemType: "number",
                     lowerLimit: 0,
                     upperLimit: 20,
                     interval: 1,
                     unit: ""},
        "ofdm_sifs": {title: "OFDM SIFS",
                      itemType: "number",
                      lowerLimit: 0,
                      upperLimit: 50,
                      interval: 1,
                      unit: ""},
        "slottime": {title: "Slot time",
                     itemType: "number",
                     lowerLimit: 1,
                     upperLimit: 20,
                     interval: 1,
                     unit: ""},
        "thresh62": {title: "Clear Channel Assessment Thresh.",
                 itemType: "number",
                 lowerLimit: 20,
                 upperLimit: 62,
                 interval: 1,
                 unit: ""},

        "UseLDPC": {title: "Use LDPC", itemType: "bool", trueValue: "Y", falseValue: "N"},
        "UseMCS": {title: "Use MCS", itemType: "bool", trueValue: "Y", falseValue: "N"},
        "UseSTBC": {title: "Use STBC", itemType: "bool", trueValue: "Y", falseValue: "N"},
    })

    property var rcSettingsMap: ({

    })


    property var smartSyncSettingsMap: ({
        "SmartSync_StartupMode": {title: "SmartSync Startup Mode",
                                  itemType: "choice",
                                  choiceValues: [{title: "Quick", value: "0"},
                                                 {title: "Wait for air at boot", value: "1"}]},

        "SmartSyncRC_Channel": {title: "SmartSync RC Channel",
                                itemType: "number",
                                lowerLimit: 1,
                                upperLimit: 10,
                                interval: 1,
                                unit: ""},
    })

    property var hotspotSettingsMap: ({
        "ETHERNET_HOTSPOT": {title: "Enable ethernet hotspot",
                             itemType: "bool",
                             trueValue: "Y",
                             falseValue: "N"},
        "WIFI_HOTSPOT": {title: "Enable WiFi hotspot",
                         itemType: "choice",
                         choiceValues: [{title: "Automatic", value: "auto"},
                                        {title: "Yes", value: "Y"},
                                        {title: "No", value: "N"}]},
        "HOTSPOT_BAND": {title: "WiFi band",
                         itemType: "choice",
                         choiceValues: [{title: "5GHz", value: "a"},
                                        {title: "2.4GHz", value: "g"}]},
        "HOTSPOT_CHANNEL": {title: "WiFi channel",
                itemType: "choice",
                choiceValues: [{title: "1 (2412Mhz)", value: 1},
                               {title: "2 (2417Mhz)", value: 2},
                               {title: "3 (2422Mhz)", value: 3},
                               {title: "4 (2427Mhz)", value: 4},
                               {title: "5 (2432Mhz)", value: 5},
                               {title: "6 (2437Mhz)", value: 6},
                               {title: "7 (2442Mhz)", value: 7},
                               {title: "8 (2447Mhz)", value: 8},
                               {title: "9 (2452Mhz)", value: 9},
                               {title: "10 (2457Mhz)", value: 10},
                               {title: "11 (2462Mhz)", value: 11},
                               {title: "12 (2467Mhz)", value: 12},
                               {title: "13 (2472Mhz)", value: 13},
                               {title: "14 (2484Mhz)", value: 14},


                               {title: "32 (5160Mhz)", value: 32},
                               {title: "34 (5170Mhz)", value: 34},
                               {title: "36 (5180Mhz)", value: 36},
                               {title: "38 (5190Mhz)", value: 38},
                               {title: "40 (5200Mhz)", value: 40},
                               {title: "42 (5210Mhz)", value: 42},
                               {title: "44 (5220Mhz)", value: 44},
                               {title: "46 (5230Mhz)", value: 46},
                               {title: "48 (5240Mhz)", value: 48},
                               {title: "50 (5250Mhz)", value: 50},
                               {title: "52 (5260Mhz)", value: 52},
                               {title: "54 (5270Mhz)", value: 54},
                               {title: "56 (5280Mhz)", value: 56},
                               {title: "58 (5290Mhz)", value: 58},
                               {title: "60 (5300Mhz)", value: 60},
                               {title: "62 (5310Mhz)", value: 62},
                               {title: "64 (5320Mhz)", value: 64},
                               {title: "68 (5340Mhz)", value: 68},
                               {title: "96 (5480Mhz)", value: 96},

                               {title: "100 (5500Mhz)", value: 100},
                               {title: "102 (5510Mhz)", value: 102},
                               {title: "104 (5520Mhz)", value: 104},
                               {title: "106 (5530Mhz)", value: 106},
                               {title: "108 (5540Mhz)", value: 108},
                               {title: "110 (5550Mhz)", value: 110},
                               {title: "112 (5560Mhz)", value: 112},
                               {title: "114 (5570Mhz)", value: 114},
                               {title: "116 (5580Mhz)", value: 116},
                               {title: "118 (5590Mhz)", value: 118},

                               {title: "120 (5600Mhz)", value: 120},
                               {title: "122 (5610Mhz)", value: 122},
                               {title: "124 (5620Mhz)", value: 124},
                               {title: "126 (5630Mhz)", value: 126},
                               {title: "128 (5640Mhz)", value: 128},

                               {title: "132 (5660Mhz)", value: 132},
                               {title: "134 (5670Mhz)", value: 134},
                               {title: "136 (5680Mhz)", value: 136},
                               {title: "138 (5690Mhz)", value: 138},

                               {title: "140 (5700Mhz)", value: 140},
                               {title: "142 (5710Mhz)", value: 142},
                               {title: "144 (5720Mhz)", value: 144},
                               {title: "149 (5745Mhz)", value: 149},

                               {title: "151 (5755Mhz)", value: 151},
                               {title: "153 (5765Mhz)", value: 153},
                               {title: "155 (5775Mhz)", value: 155},
                               {title: "157 (5785Mhz)", value: 157},
                               {title: "159 (5795Mhz)", value: 159},

                               {title: "161 (5805Mhz)", value: 161},
                               {title: "165 (5825Mhz)", value: 165},
                               {title: "169 (5845Mhz)", value: 169},

                               {title: "173 (5865Mhz)", value: 173}
                               ]},

        "HOTSPOT_TXPOWER": {title: "WiFi TX power",
                            itemType: "choice",
                            choiceValues: [{title: "1dBm", value: 100},
                                           {title: "3dBm", value: 300},
                                           {title: "9dBm", value: 900},
                                           {title: "15dBm", value: 1500},
                                           {title: "24dBm", value: 1800},
                                           {title: "31dBm", value: 3100}]},

        "HOTSPOT_TIMEOUT": {title: "WiFi disabled after",
                            itemType: "choice",
                            choiceValues: [{title: "Always on", value: 0},
                                           {title: "60 seconds", value: 60},
                                           {title: "5 minutes", value: 300},
                                           {title: "30 minutes", value: 1800}]},
    })

    // these settings wont show up at all
    property var blacklistMap: ({
        // Settings from older OSD
        "Imperial": {},
        "Copter": {},
        // Settings from joystick config file which can't be saved easily
        "UPDATE_NTH_TIME": {},
        // txpower settings, may need to be unblacklisted and added to one
        // of the maps but can't be saved yet due to the way RemoteSettings.py works
        // on the ground station
        "txpowerA": {},
        "txpowerR": {},
    })

    // these settings will simply be disabled and uneditable in the UI
    property var disabledMap: ({

    })
}
