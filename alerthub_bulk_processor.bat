@echo off
setlocal

pushd "%~dp0"

openfiles > nul
if errorlevel 1 echo 管理者として実行してください。 & goto ERROR

rem ファイルの存在確認
if not exist .\config\config.ps1 (
    echo 「config\config.ps1」がありません。
    echo スクリプト一式を再取得して設定ファイルを正しく配置してください。
    goto ERROR
)

echo 実行する処理の番号を入力してください。
echo [1] スコープ一括登録
echo [2] アクション一括登録
echo [3] 静観スケジュール一括登録
echo [4] 静観スケジュール用スコープ一覧取得
echo [5] スコープ属性一括登録
echo [9] 終了
set /p processCode=">"

if /i {%processCode%}=={1} (set process="import_scopes")
if /i {%processCode%}=={2} (set process="import_actions")
if /i {%processCode%}=={3} (set process="import_mute_schedules")
if /i {%processCode%}=={4} (set process="export_scopes")
if /i {%processCode%}=={5} (set process="import_attributes")
if /i {%processCode%}=={9} (goto EXIT)

echo. > .\script\alerthub_bulk_processor.ps1:Zone.Identifier
powershell -ExecutionPolicy RemoteSigned -File .\script\alerthub_bulk_processor.ps1 %process% "%~dp0input\\" "%~dp0output\\"

if not %errorlevel% equ 0 (
    echo 処理が失敗しました。スクリプトを終了します。
    goto ERROR
)

echo 処理が完了しました。スクリプトを終了します。
goto EXIT

:ERROR
popd
pause
exit 1

:EXIT
popd
pause
exit 0
