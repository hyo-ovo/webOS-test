#include "luna_channel.h"

#include "logger.h"

#include <flutter/binary_messenger.h>

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <algorithm>
#include <utility>

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

void WriteEncodableValue(const EncodableValue& value,
                         rapidjson::Writer<rapidjson::StringBuffer>& writer) {
  if (std::holds_alternative<std::monostate>(value)) {
    writer.Null();
    return;
  }

  if (const auto* bool_value = std::get_if<bool>(&value)) {
    writer.Bool(*bool_value);
    return;
  }

  if (const auto* int32_value = std::get_if<int32_t>(&value)) {
    writer.Int(*int32_value);
    return;
  }

  if (const auto* int64_value = std::get_if<int64_t>(&value)) {
    writer.Int64(*int64_value);
    return;
  }

  if (const auto* double_value = std::get_if<double>(&value)) {
    writer.Double(*double_value);
    return;
  }

  if (const auto* string_value = std::get_if<std::string>(&value)) {
    writer.String(string_value->c_str(),
                  static_cast<rapidjson::SizeType>(string_value->length()));
    return;
  }

  if (const auto* list_value = std::get_if<EncodableList>(&value)) {
    writer.StartArray();
    for (const auto& element : *list_value) {
      WriteEncodableValue(element, writer);
    }
    writer.EndArray();
    return;
  }

  if (const auto* map_value = std::get_if<EncodableMap>(&value)) {
    writer.StartObject();
    for (const auto& pair : *map_value) {
      const auto* key = std::get_if<std::string>(&pair.first);
      if (!key) {
        continue;
      }
      writer.Key(key->c_str(),
                 static_cast<rapidjson::SizeType>(key->length()));
      WriteEncodableValue(pair.second, writer);
    }
    writer.EndObject();
    return;
  }

  writer.Null();
}

EncodableValue RapidjsonToEncodableValue(const rapidjson::Value& value) {
  if (value.IsNull()) {
    return EncodableValue();
  }

  if (value.IsBool()) {
    return EncodableValue(value.GetBool());
  }

  if (value.IsInt()) {
    return EncodableValue(static_cast<int32_t>(value.GetInt()));
  }

  if (value.IsInt64()) {
    return EncodableValue(static_cast<int64_t>(value.GetInt64()));
  }

  if (value.IsUint64()) {
    return EncodableValue(static_cast<int64_t>(value.GetUint64()));
  }

  if (value.IsDouble()) {
    return EncodableValue(value.GetDouble());
  }

  if (value.IsString()) {
    return EncodableValue(
        std::string(value.GetString(), value.GetStringLength()));
  }

  if (value.IsArray()) {
    EncodableList list;
    list.reserve(value.Size());
    for (const auto& element : value.GetArray()) {
      list.emplace_back(RapidjsonToEncodableValue(element));
    }
    return EncodableValue(std::move(list));
  }

  if (value.IsObject()) {
    EncodableMap map;
    for (auto iterator = value.MemberBegin(); iterator != value.MemberEnd();
         ++iterator) {
      const auto key = std::string(iterator->name.GetString(),
                                   iterator->name.GetStringLength());
      map.emplace(EncodableValue(key),
                  RapidjsonToEncodableValue(iterator->value));
    }
    return EncodableValue(std::move(map));
  }

  return EncodableValue();
}

std::string ComposeUri(const std::string& service,
                       const std::string& method) {
  if (method.empty()) {
    return service;
  }

  if (!service.empty() && service.back() == '/') {
    return service + method;
  }

  if (service.empty()) {
    return method;
  }

  return service + "/" + method;
}

bool ExtractBool(const EncodableValue& value, bool* out) {
  if (const auto* bool_ptr = std::get_if<bool>(&value)) {
    *out = *bool_ptr;
    return true;
  }
  if (const auto* int_ptr = std::get_if<int32_t>(&value)) {
    *out = (*int_ptr != 0);
    return true;
  }
  if (const auto* int64_ptr = std::get_if<int64_t>(&value)) {
    *out = (*int64_ptr != 0);
    return true;
  }
  return false;
}

}  // namespace

LunaChannelBridge::LunaChannelBridge(flutter::BinaryMessenger* messenger)
    : messenger_(messenger) {}

LunaChannelBridge::~LunaChannelBridge() {
  ShutdownSubscriptions();

  if (channel_) {
    channel_->SetMethodCallHandler(nullptr);
  }

  if (loop_) {
    g_main_loop_quit(loop_);
  }

  if (loop_thread_.joinable()) {
    loop_thread_.join();
  }

  if (loop_) {
    g_main_loop_unref(loop_);
    loop_ = nullptr;
  }

  if (handle_) {
    LSError lserror;
    LSErrorInit(&lserror);
    if (!LSUnregister(handle_, &lserror)) {
      LOG_ERROR("LSUnregister failed: %s", lserror.message);
      LSErrorFree(&lserror);
    } else {
      LSErrorFree(&lserror);
    }
    handle_ = nullptr;
  }
}

bool LunaChannelBridge::Initialize() {
  if (initialized_) {
    return true;
  }

  if (!messenger_) {
    LOG_ERROR("Binary messenger is null; cannot initialize Luna channel.");
    return false;
  }

  channel_ = std::make_unique<
      flutter::MethodChannel<flutter::EncodableValue>>(
      messenger_, "com.lg.homescreen/luna",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        HandleCall(call, std::move(result));
      });

  LSError lserror;
  LSErrorInit(&lserror);

  if (!LSRegister("com.lg.homescreen.flutterbridge", &handle_, &lserror)) {
    LOG_ERROR("LSRegister failed: %s", lserror.message);
    LSErrorFree(&lserror);
    handle_ = nullptr;
    return false;
  }

  loop_ = g_main_loop_new(nullptr, FALSE);
  if (!loop_) {
    LOG_ERROR("Failed to create GMainLoop.");
    LSErrorFree(&lserror);
    return false;
  }

  if (!LSGmainAttach(handle_, loop_, &lserror)) {
    LOG_ERROR("LSGmainAttach failed: %s", lserror.message);
    LSErrorFree(&lserror);
    return false;
  }

  loop_thread_ = std::thread([this]() {
    g_main_loop_run(loop_);
  });

  initialized_ = true;
  LSErrorFree(&lserror);
  return true;
}

void LunaChannelBridge::HandleCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (!initialized_) {
    result->Error("not-initialized", "Luna channel not initialized.");
    return;
  }

  if (call.method_name() == "callLunaService") {
    HandleCallLunaService(call, std::move(result));
    return;
  }

  if (call.method_name() == "cancelLunaService") {
    HandleCancel(std::move(result));
    return;
  }

  result->NotImplemented();
}

void LunaChannelBridge::HandleCancel(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  ShutdownSubscriptions();
  result->Success(flutter::EncodableValue(true));
}

void LunaChannelBridge::HandleCallLunaService(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto* args = std::get_if<EncodableMap>(call.arguments());
  if (!args) {
    result->Error("invalid-argument", "Arguments must be a map.");
    return;
  }

  const auto service_iter = args->find(EncodableValue("service"));
  const auto method_iter = args->find(EncodableValue("method"));

  if (service_iter == args->end() || method_iter == args->end()) {
    result->Error("invalid-argument", "Missing service or method.");
    return;
  }

  const auto* service_ptr = std::get_if<std::string>(&service_iter->second);
  const auto* method_ptr = std::get_if<std::string>(&method_iter->second);

  if (!service_ptr || !method_ptr) {
    result->Error("invalid-argument", "Service and method must be strings.");
    return;
  }

  std::string event_name;
  const auto event_iter = args->find(EncodableValue("event"));
  if (event_iter != args->end()) {
    if (const auto* event_ptr = std::get_if<std::string>(&event_iter->second)) {
      event_name = *event_ptr;
    }
  }

  EncodableValue parameters_value;
  const auto parameters_iter = args->find(EncodableValue("parameters"));
  if (parameters_iter != args->end()) {
    parameters_value = parameters_iter->second;
  } else {
    parameters_value = EncodableMap{};
  }

  bool subscribe = false;
  if (const auto* parameter_map = std::get_if<EncodableMap>(&parameters_value)) {
    const auto subscribe_iter =
        parameter_map->find(EncodableValue("subscribe"));
    if (subscribe_iter != parameter_map->end()) {
      ExtractBool(subscribe_iter->second, &subscribe);
    }
  }

  const std::string uri = ComposeUri(*service_ptr, *method_ptr);
  const std::string payload = BuildPayload(parameters_value);

  auto context = std::make_unique<LunaRequestContext>();
  context->bridge = this;
  context->event_name = event_name;
  context->subscribe = subscribe;
  context->result = std::move(result);

  LSMessageToken token = LSMESSAGE_TOKEN_INVALID;
  LSError lserror;
  LSErrorInit(&lserror);

  const bool call_result = subscribe
                               ? LSCall(handle_, uri.c_str(), payload.c_str(),
                                        &LunaChannelBridge::HandleLunaResponse,
                                        context.get(), &token, &lserror)
                               : LSCallOneReply(handle_, uri.c_str(),
                                                payload.c_str(),
                                                &LunaChannelBridge::
                                                    HandleLunaResponse,
                                                context.get(), &token, &lserror);

  if (!call_result) {
    std::string error_message =
        lserror.message ? lserror.message : "LSCall failed";
    if (context->result) {
      context->result->Error("luna-call-failed", error_message);
      context->result.reset();
    }
    LSErrorFree(&lserror);
    return;
  }

  context->token = token;

  if (subscribe) {
    RegisterSubscription(token, std::move(context));
  } else {
    context.release();  // Ownership transferred to LS callback.
  }

  LSErrorFree(&lserror);
}

bool LunaChannelBridge::HandleLunaResponse(LSHandle* /*handle*/,
                                           LSMessage* message,
                                           void* user_data) {
  auto* context = static_cast<LunaRequestContext*>(user_data);
  if (!context || !context->bridge) {
    return true;
  }

  const char* payload_cstr = LSMessageGetPayload(message);
  EncodableValue payload = context->bridge->ParsePayload(payload_cstr);

  if (context->result && !context->result_sent) {
    context->result->Success(payload);
    context->result.reset();
    context->result_sent = true;
    if (!context->subscribe) {
      delete context;
      return true;
    }
  }

  if (context->subscribe && !context->event_name.empty()) {
    context->bridge->EmitEvent(context->event_name, payload);
  }

  if (!context->subscribe) {
    delete context;
  }

  return true;
}

void LunaChannelBridge::EmitEvent(
    const std::string& event_name,
    const flutter::EncodableValue& payload) {
  if (!channel_ || event_name.empty()) {
    return;
  }

  auto arguments =
      std::make_unique<flutter::EncodableValue>(payload);
  channel_->InvokeMethod(event_name, std::move(arguments));
}

std::string LunaChannelBridge::BuildPayload(
    const flutter::EncodableValue& parameters) const {
  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);

  if (std::holds_alternative<std::monostate>(parameters)) {
    writer.StartObject();
    writer.EndObject();
    return buffer.GetString();
  }

  WriteEncodableValue(parameters, writer);
  return buffer.GetString();
}

flutter::EncodableValue LunaChannelBridge::ParsePayload(
    const char* payload) const {
  if (!payload) {
    return EncodableValue();
  }

  rapidjson::Document document;
  document.Parse(payload);
  if (document.HasParseError()) {
    LOG_WARNING("Failed to parse Luna response: %s", payload);
    return EncodableValue();
  }

  return RapidjsonToEncodableValue(document);
}

void LunaChannelBridge::RegisterSubscription(
    LSMessageToken token,
    std::unique_ptr<LunaRequestContext> context) {
  std::lock_guard<std::mutex> lock(mutex_);
  subscriptions_.emplace(token, std::move(context));
}

void LunaChannelBridge::ShutdownSubscriptions() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (!handle_) {
    subscriptions_.clear();
    return;
  }

  LSError lserror;
  LSErrorInit(&lserror);

  for (auto& entry : subscriptions_) {
    const LSMessageToken token = entry.first;
    if (token != LSMESSAGE_TOKEN_INVALID) {
      if (!LSCallCancel(handle_, token, &lserror)) {
        LOG_WARNING("LSCallCancel failed: %s", lserror.message);
        LSErrorFree(&lserror);
        LSErrorInit(&lserror);
      }
    }
  }

  LSErrorFree(&lserror);
  subscriptions_.clear();
}


