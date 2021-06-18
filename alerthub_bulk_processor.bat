@echo off
setlocal

pushd "%~dp0"

openfiles > nul
if errorlevel 1 echo �Ǘ��҂Ƃ��Ď��s���Ă��������B & goto ERROR

rem �t�@�C���̑��݊m�F
if not exist .\config\config.ps1 (
    echo �uconfig\config.ps1�v������܂���B
    echo �X�N���v�g�ꎮ���Ď擾���Đݒ�t�@�C���𐳂����z�u���Ă��������B
    goto ERROR
)

echo ���s���鏈���̔ԍ�����͂��Ă��������B
echo [1] �X�R�[�v�ꊇ�o�^
echo [2] �A�N�V�����ꊇ�o�^
echo [3] �ÊσX�P�W���[���ꊇ�o�^
echo [4] �ÊσX�P�W���[���p�X�R�[�v�ꗗ�擾
echo [5] �X�R�[�v�����ꊇ�o�^
echo [9] �I��
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
    echo ���������s���܂����B�X�N���v�g���I�����܂��B
    goto ERROR
)

echo �������������܂����B�X�N���v�g���I�����܂��B
goto EXIT

:ERROR
popd
pause
exit 1

:EXIT
popd
pause
exit 0
