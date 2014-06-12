function [bedTimeArray,getupTimeArray] = generatebedlog(timeArray,bedTime,getupTime)
%GENERATEBEDLOG Create arrays of bed and get up times from singular values
%   timeArray is a vector of datenums with a span of at least 1 day
%   bedTime and getupTime are singular values in fractions of a day

minTime = min(timeArray);
maxTime = max(timeArray);

% Check that there is a large enough time span
duration = maxTime - minTime;
if duration < 1
    error('The "timeArray" variable must have a span of at least 1 day.');
end

% Check that bed and get up time is in fraction of days
if bedTime < 0 || bedTime > 1
    bedTime = mod(bedTime,1);
end
if getupTime < 0 || getupTime > 1
    getupTime = mod(getupTime,1);
end

% Make sure get up is after bed time
if getupTime <= bedTime
    getupTime = getupTime + 1;
end

% Create bed and get up time arrays
dayArray = unique(floor(timeArray));
dayArray(end+1) = dayArray(end) + 1; % Add on an extra day
bedTimeArray	= dayArray + bedTime;
getupTimeArray	= dayArray + getupTime;

% Find bed and get up times that are out of bounds
idxBedOutBounds   = bedTimeArray   <  minTime | bedTimeArray   >= maxTime;
idxGetupOutBounds = getupTimeArray <= minTime | getupTimeArray >  maxTime;
idxOutBounds      = idxBedOutBounds | idxGetupOutBounds;

% Remove out of bounds times
bedTimeArray(idxOutBounds) = [];
getupTimeArray(idxOutBounds) = [];

end

