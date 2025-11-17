```markdown
# Camera (통합형 문서)

serviceUri: luna://com.webos.service.camera2

description: |
  webOS의 카메라 관련 서비스 호출 예와 Flutter(예: camera-example)에서의 호출 흐름을 정리한 문서입니다.

schema:
  - title: Camera (camera-example)
    serviceUri: luna://com.webos.service.camera2
    description: 카메라 초기화(모델 설치 → 목록 조회 → 권한 설정 → 오픈 → 포맷 설정) 순서 예시
    methods:
      - name: installModel
        serviceUri: luna://com.webos.service.aiinferencemanager
        description: AI inference manager에 모델을 설치
        parameters:
          - name: id
            type: string
            required: true
            description: 모델 ID (예: "FACE")
        payloadExample:
          { "id": "FACE" }
        returnExample:
          { "returnValue": true }
        usage:
          - file: lib/services/camera_service.dart
            method: CameraService.intallModel

      - name: getCameraList
        serviceUri: luna://com.webos.service.camera2
        description: 연결된 카메라 및 마이크 목록을 반환 (구독 가능)
        parameters:
          - name: subscribe
            type: boolean
            required: false
            description: true일 경우 구독 모드
        payloadExample:
          { }
        returnExample:
          { "returnValue": true, "deviceList": [ { "id": "camera1", "type": "camera" } ] }
        notes: 응답 필드명이 `deviceList` 또는 `uriList`일 수 있으므로 코드에서 확인 필요
        usage:
          - file: lib/services/camera_service.dart
            method: CameraService.getCameraList

      - name: setPermission
        serviceUri: luna://com.webos.service.camera2
        description: 앱 ID에 대해 카메라 권한을 설정
        parameters:
          - name: appId
            type: string
            required: true
            description: 앱 식별자 (예: "com.webos.app.camera")
        payloadExample:
          { "appId": "com.webos.app.camera" }
        returnExample:
          { "returnValue": true }
        usage:
          - file: lib/services/camera_service.dart
            method: CameraService.setPermission

      - name: open
        serviceUri: luna://com.webos.service.camera2
        description: 카메라를 열고 handle을 반환
        parameters:
          - name: appId
            type: string
            required: true
          - name: id
            type: string
            required: true
          - name: mode
            type: string
            required: false
        payloadExample:
          { "appId": "com.webos.app.camera", "id": "<cameraId>", "mode": "primary" }
        returnExample:
          { "returnValue": true, "handle": 123 }
        notes: handle은 이후 setFormat/startPreview에 사용
        usage:
          - file: lib/services/camera_service.dart
            method: CameraService.openCamera

      - name: setFormat
        serviceUri: luna://com.webos.service.camera2
        description: handle에 대해 포맷(이미지/비디오) 설정
        parameters:
          - name: handle
            type: number
            required: true
          - name: params
            type: object
            required: true
            description: format, fps, width, height 등
        payloadExample:
          {
            "handle": 123,
            "params": { "format": "JPEG", "fps": 30, "height": 720, "width": 1280 }
          }
        returnExample:
          { "returnValue": true }
        usage:
          - file: lib/services/camera_service.dart
            method: CameraService.setFormat

notes: |
  - camera-example에서는 startPreview, setSolutions, getEventNotification 등이 TODO로 남아 있습니다.
  - webOS 호출은 `webos_service_helper/utils.dart`의 `callOneReply`로 래핑되어 있으며, 이 헬퍼가 Luna 요청/응답 처리를 수행합니다.

examples:
  - flutter-summary: |
      await CameraService.intallModel();
      final res = await CameraService.getCameraList();
      final cameraId = res?['deviceList']?[0]?['id'];
      await CameraService.setPermission();
      final openRes = await CameraService.openCamera(cameraId);
      final handle = openRes?['handle'];
      await CameraService.setFormat(handle);

errors: |
  - 호출 실패 시 응답에 `returnValue: false` 및 `errorCode`/`errorText` 포함 (webOS 표준)

```
isCovered
Description

Returns the cover status of the built-in camera. You need to put URI as a parameter which is given by getList().

Parameters

Name	Required	Type	Description
uri	Required	string	Device URI
subscribe	Optional	boolean	Flag that decides whether to subscribe or not.
true: Subscribe.
false: Do not subscribe. Call the method only once. (Default)
Call returns

Name	Required	Type	Description
returnValue	Required	boolean	Flag that indicates success/failure of the request.
true: Success
false: Failure
errorCode	Optional	number	errorCode contains the error code if the method fails. The method will return errorCode only if it fails.
See the Error Codes Reference of this method for more details.
errorText	Optional	string	errorText contains the error text if the method fails. The method will return errorText only if it fails.
See the Error Codes Reference of this method for more details.
covered	Optional	boolean	Flag that indicates whether the built-in camera is covered or not.
true: Covered
false: Not covered
subscribed	Optional	boolean	Flag that indicates whether the subscription is enabled or not.
true: Enabled
false: Not enabled.
Error reference

Error Code	Error Message
1	Can not close
2	Can not open
3	Can not set
4	Can not start
5	Can not stop
6	Camera device is already closed
7	Camera device is already opened
8	Camera device is already started
9	Camera device is already stopped
10	Camera device is being updated
11	Camera device is busy
12	Camera device is not opened
13	Camera device is not started
14	There is no device
15	No response from device
16	Parsing error
17	Out of memory
18	Out of parameter range
19	Parameter is missing
20	Service is not ready
21	Some parameters are not set
22	Too many requests
23	Request timeout
24	Unknown service
25	Unsupported device
26	Unsupported format
27	Unsupported sampling rate
28	Unsupported video size
29	Camera firmware is being updated
30	Wrong device number
31	Session ID error
32	Wrong parameter
33	Wrong type
34	Already acquired
35	Unknown error
36	Fail to Special effect
37	Fail to photo view effect
38	Fail to open file
39	Fail to remove file
40	Fail to create directory
41	Lack of storage
42	Already exists file
Subscription Returns

Name	Required	Type	Description
covered	Required	Boolean	Flag that indicates whether the built-in camera is covered or not.
true: Covered
false: Not covered
Example

// One-time call
var request = webOS.service.request('luna://com.webos.service.camera', {
  method: 'isCovered',
  parameters: { id: 'camera://com.webos.service.camera/camera1' },
  onSuccess: function (inResponse) {
    console.log('Result: ' + JSON.stringify(inResponse));
    // To-Do something
  },
  onFailure: function (inError) {
    console.log('Failed to get camera cover state');
    console.log('[' + inError.errorCode + ']: ' + inError.errorText);
    // To-Do something
    return;
  },
});

// Subscription
var subscriptionHandle;

subscriptionHandle = webOS.service.request('luna://com.webos.service.camera', {
  method: 'isCovered',
  parameters: {
    id: 'camera://com.webos.service.camera/camera1',
    subscribe: true,
  },
  onSuccess: function (inResponse) {
    if (typeof inResponse.subscribed != 'undefined') {
      if (!inResponse.subscribed) {
        console.log('Failed to subscribe the camera cover state');
        return;
      }
    }
    console.log('Result: ' + JSON.stringify(inResponse));
    // To-Do something
  },
  onFailure: function (inError) {
    console.log('Failed to get camera cover state');
    console.log('[' + inError.errorCode + ']: ' + inError.errorText);
    // To-Do something
    return;
  },
});
...
// If you need to unsubscribe the data, use cancel() method as below
subscriptionHandle.cancel();
Return example

// One-time call return
{
  'returnValue': true,
  'covered': true
}

// Subscription return
{
  'returnValue': false,
  'covered': false,
  'subscribed': true
}
See also

getList
Object
deviceInfo object
The object that holds the detailed information of camera or microphone devices.

{
  'name': string,
  'type': string,
  'builtin': boolean,
  'details': deviceDetail object
} 
Name	Required	Type	Description
name	Required	string	Device name
type	Required	string	Device type (camera or microphone)
builtin	Required	boolean	Flag that indicates whether the device is built in or not.
details	Required	object	Object that holds information about recording resolution, supported video format, sampling rate, and audio code.
uriList object
List of devices which are connected to webOS TV. This object holds device type and URI.

{
    'uri': string,
    'type': string
}
Name	Required	Type	Description
uri	Required	string	URI of device
type	Required	string	Type of device that distinguishes between camera and microphone.
deviceDetail object
The object that holds more detailed information for a camera and microphone.

{
  'video': videoDetail Object,
  'picture': pictureDetail Object,
  'format': String,
  'samplingRate': String,
  'codec': String
} 
Name	Required	Type	Description
video	Optional	object	Object that holds a supported maximum video frame size for video recording.
picture	Optional	object	Object that holds a supported maximum image size for picture taking.
format	Optional	string	Supported Video format for video recording. In return string, pipe character (|) is used as a delimiter to distinguish multi-formats.
samplingRate	Optional	string	Supported sampling rate for audio recording.
codec	Optional	string	Supported audio codec for audio recording.
videoDetail object
The object that holds a supported maximum video frame size for video recording. This object has maximum width and height.

{
  'maxWidth': Number,
  'maxHeight': Number
} 
Name	Required	Type	Description
maxWidth	Required	number	Maximum width that camera device supports for video recording
maxHeight	Required	number	Maximum height that camera device supports for video recording.
pictureDetail object
The object that holds a supported maximum image size for picture taking. This object has maximum width and height.

{
  'maxWidth': Number,
  'maxHeight': Number
} 
Name	Required	Type	Description
maxWidth	Required	number	Maximum width that camera device supports for picture taking
maxHeight	Required	number	Maximum height that camera device supports for picture taking
