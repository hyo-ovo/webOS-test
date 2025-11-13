#ifndef FRONTEND_WEBOS_RUNNER_LUNA_CHANNEL_H_
#define FRONTEND_WEBOS_RUNNER_LUNA_CHANNEL_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <glib.h>
#include <luna-service2/lunaservice.h>

#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>

class LunaChannelBridge {
 public:
  explicit LunaChannelBridge(flutter::BinaryMessenger* messenger);
  ~LunaChannelBridge();

  bool Initialize();

 private:
  struct LunaRequestContext {
    LunaChannelBridge* bridge;
    std::string event_name;
    bool subscribe;
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
    LSMessageToken token{LSMESSAGE_TOKEN_INVALID};
    bool result_sent{false};
  };

  void HandleCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void HandleCallLunaService(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void HandleCancel(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  static bool HandleLunaResponse(LSHandle* handle,
                                 LSMessage* message,
                                 void* user_data);

  void EmitEvent(const std::string& event_name,
                 const flutter::EncodableValue& payload);

  std::string BuildPayload(const flutter::EncodableValue& parameters) const;
  flutter::EncodableValue ParsePayload(const char* payload) const;

  void RegisterSubscription(LSMessageToken token,
                            std::unique_ptr<LunaRequestContext> context);
  void ShutdownSubscriptions();

  flutter::BinaryMessenger* messenger_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

  LSHandle* handle_{nullptr};
  GMainLoop* loop_{nullptr};
  std::thread loop_thread_;
  bool initialized_{false};

  mutable std::mutex mutex_;
  std::unordered_map<LSMessageToken, std::unique_ptr<LunaRequestContext>>
      subscriptions_;
};

#endif  // FRONTEND_WEBOS_RUNNER_LUNA_CHANNEL_H_


