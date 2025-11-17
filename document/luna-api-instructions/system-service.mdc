**_ Begin Patch
_** Update File: /Users/Inyoung/Desktop/26-2/lg-capstone/2025_sogang_6/document/luna-api-instructions/system-service.md
@@

```markdown
# System Service (통합형 문서)

serviceUri: luna://com.palm.systemservice

description: |
시스템 시간 정보를 제공하는 서비스입니다. 앱은 구독(subscribe)하여 시간대 변경 또는 시스템 시간이 크게(기본 5분) 변경될 때 알림을 받을 수 있습니다.

schema: - title: System Service
serviceUri: luna://com.palm.systemservice
methods: - name: time/getSystemTime
description: 시스템 시간 및 시간대 정보를 요청합니다. subscribe=true이면 시간/시간대 변경 이벤트를 계속 수신합니다.
parameters: - name: subscribe
type: boolean
required: false
description: true일 경우 구독을 생성 (기본 false)
payloadExample:
{ "subscribe": false }
returnExample:
{
"returnValue": true,
"utc": 1418745990,
"localtime": { "year":2014, "month":12, "day":16, "hour":11, "minute":6, "second":30 },
"offset": -300,
"timezone": "Asia/Seoul",
"TZ": "EST",
"timeZoneFile": "/var/luna/preferences/localtime"
}
subscriptionReturnExample:
{
"returnValue": true,
"subscribed": true,
"utc": 1418745990,
"localtime": { "year":2014, "month":12, "day":16, "hour":11, "minute":6, "second":30 }
}
notes: | - 구독 시 `subscribed` 필드로 구독 성공 여부를 확인하세요. - 응답에는 `utc`(Epoch ms), `localtime`(year/month/day/hour/minute/second), `offset`, `timezone`, `TZ`, `timeZoneFile` 등이 포함됩니다.
usage: - exampleJS: |
var request = webOS.service.request('luna://com.palm.systemservice', {
method: 'time/getSystemTime',
parameters: { subscribe: true },
onSuccess: function (inResponse) { /_ ... _/ }
});

objects: - name: LocalTime
description: 시스템의 로컬 시간 구성 객체
properties: - name: year
type: number - name: month
type: number - name: dayOfWeek
type: number
optional: true - name: day
type: number - name: hour
type: number - name: minute
type: number - name: second
type: number

notes: | - 구독을 중단하려면 요청 객체의 `cancel()`을 호출하면 됩니다. - NITZ 관련 필드는 레거시/비권장으로 현재는 의미가 제한적일 수 있습니다.

errors: | - 실패 시 응답에 `returnValue: false`와 함께 `errorCode`/`errorText`가 포함될 수 있습니다.
```

\*\*\* End Patch
