# App Store Metadata — Japanese

WU-10 Phase A.5で内容確定。App Store Connectへの入力・公開はowner approval後に行うこと。

文字数はAppleの[App information reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information)にあるApp Name/Subtitle各30文字上限に対して確認済みです。

## Core metadata

- App Name: `AgendaCue`（9/30文字）
- Bundle ID: `com.naoki-ko.agendacue`
- Subtitle: `予定をアラームで確実にお知らせ`（15/30文字）
- Promotional text: `iPhoneのカレンダー予定を読み取り、設定した時間前に本物のアラームを鳴らします。大切な予定の準備を、シンプルに。`
- Primary category recommendation: Utilities
- Secondary category recommendation: Productivity
- Keywords: `カレンダー,予定,アラーム,リマインダー,スケジュール,時間管理`
- Version: `1.0`
- Copyright: `© 2026 Naoki Kondo`
- Support URL: `[OWNER INPUT REQUIRED — PUBLIC HOSTING URL]`
- Privacy Policy URL/status: `[OWNER INPUT REQUIRED — PUBLIC HOSTING URL]`
- App privacy recommendation: `No data collected`

## Description

AgendaCueは、iPhoneのカレンダー予定を読み取り、設定した時間前に本物のアラームを鳴らすシンプルなアプリです。

参加させるカレンダーを選び、標準のアラーム時間を設定できます。予定ごとにアラームをオフにしたり、対応する時間へ変更したりすることもできます。

カレンダーへのアクセスは読み取り専用で使用し、予定の追加・変更・削除は行いません。アカウント登録やログインは不要です。設定と処理は端末内で完結します。

バックグラウンド更新はiOSが許可する機会に実行される補助的な仕組みです。予定を変更したあとは、アプリを開くことで最新状態へ更新できます。

対応対象は、iPhoneのカレンダーに登録され、EventKitから取得できる予定です。Googleなどの予定もiOSのカレンダーへ設定済みであれば対象になり得ますが、各サービスへ直接接続する機能ではありません。

## What's New — Version 1.0

AgendaCueの最初のリリースです。iPhoneのカレンダー予定を読み取り、選んだ時間前にAlarmKitのアラームを設定できます。使うカレンダーの選択、予定ごとのアラームON/OFFと対応する時間の変更に対応しています。

## Age-rating considerations

Audited code contains no user-generated public content, messaging, web browsing, gambling, violence, sexual content, controlled substances, or unrestricted external links. Complete the current App Store Connect questionnaire truthfully; no rating is asserted by this draft.

## App Review Notes

このアプリにアカウント登録、ログイン、バックエンドはありません。

1. 初回起動後、カレンダーへのアクセスを許可してください。予定の開始時刻を読み取るために必要です。アプリは予定を追加・変更・削除しません。
2. 続いてアラームへのアクセスを許可してください。AlarmKitのワンショットアラームを設定するために必要です。
3. iOSのカレンダーアプリで、現在より十分先の時刻に通常の時間指定予定を作成します。
4. 本アプリの「設定」→「表示するカレンダー」で対象カレンダーが選択されていることを確認します。
5. 「アラーム」画面から予定を開き、「この予定でアラームを使う」をONにして時間を確認します。標準は予定開始5分前です。
6. 作成されるAlarmKitアラームのカスタムタイトルには、空でない予定タイトルがそのまま表示されます。空タイトルは`予定`です。

終日予定は対象外です。権限を拒否・取り消した場合は、アプリ内の案内からiOSの「設定」を開いて復旧できます。バックグラウンド実行時刻はiOSが管理するため保証しません。予定を変更したあとはアプリをforegroundへ戻して同期させてください。
