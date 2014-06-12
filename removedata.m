function [timeArray,luxArray,claArray,csArray,activityArray] = removedata(cropStart,cropStop,timeArray,luxArray,claArray,csArray,activityArray)
%CROPDATA Summary of this function goes here
%   Detailed explanation goes here

idx = timeArray >= cropStart & timeArray <= cropStop;

timeArray(idx) = [];
luxArray(idx) = [];
claArray(idx) = [];
csArray(idx) = [];
activityArray(idx) = [];


end

