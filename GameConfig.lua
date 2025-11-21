local DATASTORE_VERSION = "TESTING_32902008"

local Configuration = {

	---------------
	-- DATASTORE --
	---------------
	DATASTORE = {
		STATS_KEY = string.format("STATS_%s", DATASTORE_VERSION),
		GIFTS_KEY = string.format("GIFTS_%s", DATASTORE_VERSION),

		RAISED_ORDERED_KEY = string.format("RAISED_ORDERED_%s", DATASTORE_VERSION),
		DONATED_ORDERED_KEY = string.format("DONATED_ORDERED_%s", DATASTORE_VERSION),
		WINS_ORDERED_KEY = string.format("WINS_ORDERED_%s", DATASTORE_VERSION),
	},

	------------------
	-- MONETIZATION --
	------------------
	
	MONETIZATION = {
		PRODUCT_IDS = {
			3458594078,
		},
		
		PASSES = {
			STAND_ACCESS = 0,
			CAR_KEYS = 0,
		}
	},
	
	--------------
	-- GAMEPASS --
	--------------
	GAMEPASS_CONFIG = {
		BUYABLE_PASSES = {
			STAND = 28833041,
		},
		
		REFRESH_COOLDOWN = 30,
		PLACE_LIMIT = 10,
		PULL_LIMIT = 50,

		-- Pagination limits
		UNIVERSES_PAGE_LIMIT = 50,
		GAMEPASSES_PAGE_LIMIT = 100,
		GAMEPASSES_CHECK_LIMIT = 1, -- Used to check if universe has passes

		CREATION_PAGE_URL = "https://create.roblox.com/dashboard/creations",
		PASSES_PAGE_URL = "https://create.roblox.com/dashboard/creations/experiences/%s/passes/create",

		NO_EXPERIENCES_STRING = "You don't have any active experiences. To start earning Robux, copy the link from the field above and make one of your experiences public. Then, click the refresh button in the top-left corner of this window.",

		NO_PASSES_STRING = "None of your active experiences have passes for sale. To create a pass, copy the link from the field above and go to the experience's page. Then, click the refresh button in the top-left corner of this window.",

		--API endpoints for fetching user universes and passes
		GAMES_FETCH_ROOT_URL = "https://games.rotunnel.com/v2/users/%s/games?limit=%s&cursor=%s",
		GAMEPASS_FETCH_ROOT_URL = "https://apis.rotunnel.com/game-passes/v1/universes/%s/game-passes?passView=Full&pageSize=%s&pageToken=%s",

		-- Existing flag to gate kicking on cache failures (InventoryHandler)
		KICK_ON_CACHE_FAILURE = true,
	},

	----------------------
	-- PLAYER DATA FLOW --
	----------------------
	PLAYER_DATA_CONFIG = {
		-- New: Gate player kicks for init failures (DataHandler_Script.lua)
		-- Set to false in production if you want to avoid kicking players on transient errors.
		KICK_ON_INIT_FAILURE = true,
	},

	-----------------
	-- LEADERBOARD --
	-----------------
	LEADERBOARD_CONFIG = {
		DISPLAY_COUNT = 100,
		TOP_DISPLAY_AMOUNT = 3,

		UPDATE_INTERVAL = 60,
		UPDATE_MAX_ATTEMPTS = 3,
		UPDATE_RETRY_PAUSE_CONSTANT = 1,
		UPDATE_RETRY_PAUSE_EXPONENT_BASE = 2,

		COLORS = {
			[1] = {
				BACKGROUNDCOLOR = Color3.fromRGB(175, 128, 0),
				STROKECOLOR = Color3.fromRGB(164, 81, 0),
			},

			[2] = {
				BACKGROUNDCOLOR = Color3.fromRGB(90, 90, 180),
				STROKECOLOR = Color3.fromRGB(22, 23, 49),
			},

			[3] = {
				BACKGROUNDCOLOR = Color3.fromRGB(92, 59, 41),
				STROKECOLOR = Color3.fromRGB(40, 32, 0),
			},
		},
	},

	-------------------
	-- LIVE DONATION --
	-------------------
	LIVE_DONATION_CONFIG = {
		DEFAULT_LIFETIME = 10,

		LEVEL_THRESHOLD_CUSTOMIZATION = {
			[1] = { Threshold = 100, Lifetime = 30, Color = Color3.fromRGB(255, 255, 255) },
			[2] = { Threshold = 1000, Lifetime = 60, Color = Color3.fromRGB(255, 240, 127) },
			[3] = { Threshold = 10000, Lifetime = 60 * 2, Color = Color3.fromRGB(255, 192, 0) },
			[4] = { Threshold = 25000, Lifetime = 60 * 3, Color = Color3.fromRGB(255, 96, 64) },
			[5] = { Threshold = 50000, Lifetime = 60 * 4, Color = Color3.fromRGB(255, 0, 255) },
			[6] = { Threshold = 100000, Lifetime = 60 * 5, Color = Color3.fromRGB(64, 64, 255) },
			[7] = { Threshold = 500000, Lifetime = 60 * 6, Color = Color3.fromRGB(0, 255, 0) },
			[8] = { Threshold = 1000000, Lifetime = 60 * 7, Color = Color3.fromRGB(255, 127, 127) },
		},
	},

	-----------------------
	-- MESSAGING SERVICE --
	-----------------------
	MESSAGING_SERVICE_CONFIG = {
		LARGE_DONATION_TOPIC = "LARGE_DONATION",
		LIVE_DONATION_TOPIC = "LIVE_DONATION",
		LEADERBOARD_UPDATE = "UPDATE_LEADERBOARD",

		DONATION_THRESHOLD = 10000,
	},

	--------------------
	-- OTHER SETTINGS --
	--------------------
	ROBUX_ICON_UTF = utf8.char(0xe002),
	AVATAR_HEADSHOT_URL = "rbxthumb://type=AvatarHeadShot&id=%s&w=420&h=420",

	-- RichText-expected format string with one placeholder; UI uses string.format on this
	AMOUNT_RAISED_RICHTEXT = "<font face='Montserrat' size='55' weight='Heavy'>$%s </font>raised",
}

return Configuration