-- Calculates sunrise or sunset time on a given location
-- Algorithm from: http://williams.best.vwh.net/sunrise_sunset_algorithm.htm

local floor = math.floor
local sin  = function(a) return math.sin(math.rad(a)) end
local cos  = function(a) return math.cos(math.rad(a)) end
local tan  = function(a) return math.tan(math.rad(a)) end
local atan = function(a) return math.deg(math.atan(a)) end
local asin = function(a) return math.deg(math.asin(a)) end
local acos = function(a) return math.deg(math.acos(a)) end

-- zenith:
--   offical      = 90 degrees 50'
--   civil        = 96 degrees
--   nautical     = 102 degrees
--   astronomical = 108 degrees
local function calcUTC(args)
   local day = args.day
   local month = args.month
   local year = args.year
   local latitude = args.latitude
   local longitude = args.longitude
   local zenith = args.zenith
   local sunrise = args.sunrise
   
   local N1 = floor(275 * month / 9)
   local N2 = floor((month + 9) / 12)
   local N3 = (1 + floor((year - 4 * floor(year / 4) + 2) / 3))
   local N = N1 - (N2 * N3) + day - 30

   local lngHour = longitude / 15

   local t = sunrise and N + ((6 - lngHour) / 24) or N + ((18 - lngHour) / 24)

   local M = (0.9856 * t) - 3.289
   local L = M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634

   local RA = atan(0.91764 * tan(L))
   local Lquadrant  = (floor( L/90)) * 90
   local RAquadrant = (floor(RA/90)) * 90
   RA = RA + (Lquadrant - RAquadrant)
   RA = RA / 15
   local sinDec = 0.39782 * sin(L)
   local cosDec = cos(asin(sinDec))
   local cosH = (cos(zenith) - (sinDec * sin(latitude))) / (cosDec * cos(latitude))
	if cosH > 1 then
       -- the sun never rises on this location (on the specified date)
       return nil
    end
	if cosH < -1 then
       -- the sun never sets on this location (on the specified date)
       return nil
    end
    local H = sunrise and 360 - acos(cosH) or acos(cosH)
	H = H / 15
	local T = H + RA - (0.06571 * t) - 6.622
    -- UTC
	local UT = T - lngHour
    -- convert UT value to local time zone of latitude/longitude
	-- localT = UT + localOffset
    return UT % 24
end

return { calcUTC = calcUTC }
