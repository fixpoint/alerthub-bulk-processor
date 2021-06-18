# alerthub-bulk-processor
AlertHub の設定を一括登録するためのスクリプトです。
本リポジトリのスクリプトを Windows 上で実行することで、CSV ファイルを元にした一括登録が行えます。

本スクリプトでは **スコープ / アクション / 静観スケジュール / スコープ属性** の一括登録が行えます。

## スクリプトファイルのダウンロード
[Releasesページ](https://github.com/fixpoint/alerthub-bulk-processor/releases) より最新のファイルをダウンロードし、スクリプトを実行する AlertHub にアクセス可能なWindows端末に配置してください。

## スクリプト実行の前提条件
- PowerShell 5.1 以降が実行可能であること
- bat ファイルを管理者権限で実行可能であること

## スクリプトの実行方法
### 事前準備
AlertHub へのアクセス情報などを設定ファイルに記述します。  
`config` ディレクトリ内の `config.ps1` を編集します。
<br>
<br>
- インポートを行う対象のスペース ID を含めたアドレスを設定します
    ```
    # target space domain
    # ex) https://spaceid.cloud.kompira.jp
    $targetSpaceDomain = "https://someone.cloud.kompira.jp"
    ```

<br>

- 対象スペースで発行した API トークンを設定します
    ```
    # API token
    $apiToken = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    ```
    > API トークンの発行方法については、以下の記事の「APIトークンの発行」を参考にしてください。
    https://blog.cloud.kompira.jp/entry/manual/pigeon-tutorial  

<br>

- 実行結果を出力するファイル名を変更したい場合は、以下を設定します
    ```
    # result file name
    $resultFileName = "result.csv"
    ```

<br>

- プロキシサーバを経由させたい場合は、以下を設定します
    ```
    # proxy
    $proxyServer = "proxy.server:8080"
    $proxyUser = "username"
    $proxyPassword = "password"
    ```
    > プロキシサーバを経由させる必要がない場合は、設定を削除してください。

<br>

### 一括インポート
1. インポートするデータを CSV で作成し、`input` ディレクトリに配置します。
    > `sample` ディレクトリ内の各データのサンプル CSV ファイルを参考に作成してください。
    > CSV ファイル名は一括登録する内容毎に以下の通りとしてください。

    | 一括登録内容 | CSV ファイル名 |
    | - | - |
    | スコープ | scopes.csv |
    | アクション | actions.csv |
    | 静観スケジュール | mute_schedules.csv |
    | スコープ属性 | attributes.csv |

<br>

2. 配置後に、 `alerthub_bulk_processor.bat` を管理者権限で実行します。

3. 表示されたメニューから、実行したい一括登録処理の番号を入力します。続けて処理が実行されます。
    ```
    実行する処理の番号を入力してください。
    [1] スコープ一括登録
    [2] アクション一括登録
    [3] 静観スケジュール一括登録
    [4] 静観スケジュール用スコープ一覧取得
    [5] スコープ属性一括登録
    [9] 終了
    ```
4. 以下のメッセージが表示されたら処理が完了です。
    ```
    処理が完了しました。スクリプトを終了します。
    続行するには何かキーを押してください . . .
    ```
5. 実行結果は、`output` ディレクトリ内の `result.csv(デフォルト)` に出力されます。

### 一括エクスポート
1.  `alerthub_bulk_processor.bat` を管理者権限で実行します。
2. 表示されたメニューから、実行したい一覧取得処理の番号を入力します。続けて処理が実行されます。
    ```
    実行する処理の番号を入力してください。
    [1] スコープ一括登録
    [2] アクション一括登録
    [3] 静観スケジュール一括登録
    [4] 静観スケジュール用スコープ一覧取得
    [5] スコープ属性一括登録
    [9] 終了
    ```
3. 以下のメッセージが表示されたら処理が完了です。
    ```
    処理が完了しました。スクリプトを終了します。
    続行するには何かキーを押してください . . .
    ```
4. 実行結果として取得されたデータは CSV ファイルとして `output` ディレクトリに出力されます。
