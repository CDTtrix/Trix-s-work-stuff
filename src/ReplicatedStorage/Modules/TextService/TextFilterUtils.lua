--- Utility functions for filtering text
-- @module TextFilterUtils

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Engine"))

local TextService = game:GetService("TextService")

local Promise = require("Promise")

local TextFilterUtils = {}

function TextFilterUtils.promiseNonChatStringForBroadcast(str, fromUserId, textContext)
	assert(type(str) == "string")
	assert(type(fromUserId) == "number")
	assert(typeof(textContext) == "EnumItem")

	return TextFilterUtils._promiseTextResult(
		TextFilterUtils.getNonChatStringForBroadcastAsync,
		str,
		fromUserId,
		textContext)
end

function TextFilterUtils.promiseNonChatStringForUserAsync(str, fromUserId, toUserId, textContext)
	assert(type(str) == "string")
	assert(type(fromUserId) == "number")
	assert(type(toUserId) == "number")
	assert(typeof(textContext) == "EnumItem")

	return TextFilterUtils._promiseTextResult(
		TextFilterUtils.getNonChatStringForUserAsync,
		str,
		fromUserId,
		toUserId,
		textContext)
end

function TextFilterUtils.getNonChatStringForBroadcastAsync(str, fromUserId, textContext)
	assert(type(str) == "string")
	assert(type(fromUserId) == "number")
	assert(typeof(textContext) == "EnumItem")

	local text = nil
	local ok, err = pcall(function()
		local result = TextService:FilterStringAsync(str, fromUserId, textContext)
		if not result then
			error("No TextFilterResult")
		end

		text = result:GetNonChatStringForBroadcastAsync()
	end)

	if not ok then
		return false, err
	end

	return text
end

function TextFilterUtils.getNonChatStringForUserAsync(str, fromUserId, toUserId, textContext)
	assert(type(str) == "string")
	assert(type(fromUserId) == "number")
	assert(type(toUserId) == "number")
	assert(typeof(textContext) == "EnumItem")

	local text = nil
	local ok, err = pcall(function()
		local result = TextService:FilterStringAsync(str, fromUserId, textContext)
		if not result then
			error("No TextFilterResult")
		end

		text = result:GetNonChatStringForUserAsync(toUserId)
	end)

	if not ok then
		return false, err
	end

	return text
end

function TextFilterUtils._promiseTextResult(getResult, ...)
	local args = {...}

	local promise = Promise.spawn(function(resolve, reject)
		local text, err = getResult(unpack(args))
		if not text then
			return reject(err or "Pcall failed")
		end

		if type(text) ~= "string" then
			return reject("Bad text result")
		end

		resolve(text)
	end)

	return promise
end

return TextFilterUtils