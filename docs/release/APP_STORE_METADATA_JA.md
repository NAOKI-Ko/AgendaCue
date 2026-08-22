# App Store Metadata Draft — Japanese

Draft only; owner approval is required before App Store Connect entry.

文字数はAppleの[App information reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information)にあるApp Name/Subtitle各30文字上限に対して確認済みです。

## Core metadata

- App Name: `AgendaCue`（9/30文字）
- Bundle ID: `com.naoki-ko.agendacue`
- Subtitle: `予定をアラームで確実にお知らせ`（15/30文字）
- Promotional text: `iPhoneのカレンダー予定を読み取り、設定した時間前にアラームでお知らせします。`
- Primary category: Productivity
- Secondary category candidate: Utilities
- Keywords: `カレンダー,予定,アラーム,リマインダー,スケジュール,EventKit,通知`
- Version: `1.0`
- Copyright: `© 2026 [OWNER NAME]`
- Support URL: `[OWNER INPUT REQUIRED]`
- Privacy Policy URL/status: `[OWNER INPUT REQUIRED]`

## Description

AgendaCueは、iPhoneのカレンダー予定を読み取り、設定した時間前に本物のアラームを鳴らすシンプルなアプリです。

参加させるカレンダーを選び、標準のアラーム時間を設定できます。予定ごとにアラームをオフにしたり、対応する時間へ変更したりすることもできます。

カレンダーへのアクセスは読み取り専用で使用し、予定の追加・変更・削除は行いません。アカウント登録やログインは不要です。設定と処理は端末内で完結します。

バックグラウンド更新はiOSが許可する機会に実行される補助的な仕組みです。予定を変更したあとは、アプリを開くことで最新状態へ更新できます。

対応対象は、iPhoneのカレンダーに登録され、EventKitから取得できる予定です。Googleなどの予定もiOSのカレンダーへ設定済みであれば対象になり得ますが、各サービスへ直接接続する機能ではありません。

## Age-rating considerations

Audited code contains no user-generated public content, messaging, web browsing, gambling, violence, sexual content, controlled substances, or unrestricted external links. Complete the current App Store Connect questionnaire truthfully; no rating is asserted by this draft.

## App Review Notes

このアプリにアカウント登録、ログイン、バックエンドはありません。

1. 初回起動後、カレンダーへのアクセスを許可してください。予定の開始時刻を読み取るために必要です。アプリは予定を追加・変更・削除しません。
2. 続いてアラームへのアクセスを許可してください。AlarmKitのワンショットアラームを設定するために必要です。
3. iOSのカレンダーアプリで、現在より十分先の時刻に通常の時間指定予定を作成します。
4. 本アプリの設定で対象カレンダーが選択されていることを確認します。
5. アラーム画面から予定を開き、アラームONと時間を確認します。標準は予定開始5分前です。
6. 作成されるAlarmKitアラームのカスタムタイトルには、空でない予定タイトルがそのまま表示されます。空タイトルは`予定`です。

終日予定は対象外です。バックグラウンド実行時刻はiOSが管理するため保証しません。確認時はアプリをforegroundへ戻して同期させてください。
