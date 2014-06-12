function [timeArray,luxArray,claArray,csArray,activityArray] = cropdata(startTime,stopTime,timeArray,luxArray,claArray,csArray,activityArray)
%CROPDATA Summary of this function goes here
%   Detailed explanation goes here

idx = timeArray >= startTime & timeArray <= stopTime;

timeArray(~idx) = [];
luxArray(~idx) = [];
claArray(~idx) = [];
csArray(~idx) = [];
activityArray(~idx) = [];


end

