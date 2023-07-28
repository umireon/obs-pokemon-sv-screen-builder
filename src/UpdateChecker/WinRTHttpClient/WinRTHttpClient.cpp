#include <functional>

#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Web.Http.Headers.h>
#include <winrt/windows.storage.streams.h>

using winrt::Windows::Foundation::Uri;
using winrt::Windows::Storage::Streams::IBuffer;
using winrt::Windows::Web::Http::HttpClient;
using winrt::Windows::Web::Http::HttpResponseMessage;
using winrt::Windows::Web::Http::IHttpContent;

void fetchStringFromUrl(const char *urlString,
			std::function<void(std::string, int)> callback)
{
	HttpClient httpClient;
	auto headers(httpClient.DefaultRequestHeaders());
	headers.UserAgent().TryParseAdd(L"obs-pokemon-sv-screen-builder/0.1.1");
	Uri requestUri(winrt::to_hstring(urlString));
	HttpResponseMessage httpResponseMessage;
	IBuffer httpResponseBuffer;
	try {
		httpResponseMessage = httpClient.GetAsync(requestUri).get();
		httpResponseMessage.EnsureSuccessStatusCode();
		IHttpContent httpContent = httpResponseMessage.Content();
		httpResponseBuffer = httpContent.ReadAsBufferAsync().get();

		uint8_t *data = httpResponseBuffer.data();
		std::string str((const char *)data,
				httpResponseBuffer.Length());
		callback(str, 0);
	} catch (winrt::hresult_error const &ex) {
		std::string str(winrt::to_string(ex.message()));
		callback(str, 0);
	}
}