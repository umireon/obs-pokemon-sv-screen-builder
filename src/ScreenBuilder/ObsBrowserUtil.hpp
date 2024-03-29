#pragma once

#include <string>

#include <obs.h>

struct SendEventToAllBrowserSourcesParam {
	const char *eventName;
	const char *jsonString;
};

const std::string browserSourceId = "browser_source";

static bool sendEventToAllBrowserSourcesHandler(void *data,
						obs_source_t *source)
{
	auto *param = static_cast<SendEventToAllBrowserSourcesParam *>(data);
	auto *id = obs_source_get_id(source);
	if (id == nullptr || id != browserSourceId) {
		return true;
	}
	proc_handler_t *ph = obs_source_get_proc_handler(source);
	calldata_t cd;
	calldata_init(&cd);
	calldata_set_string(&cd, "eventName", param->eventName);
	calldata_set_string(&cd, "jsonString", param->jsonString);
	proc_handler_call(ph, "javascript_event", &cd);
	calldata_free(&cd);
	return true;
}

static void sendEventToAllBrowserSources(const char *eventName,
					 const char *jsonString)
{
	SendEventToAllBrowserSourcesParam param{eventName, jsonString};
	obs_enum_sources(&sendEventToAllBrowserSourcesHandler, &param);
}
