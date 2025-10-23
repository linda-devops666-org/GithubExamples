@echo off
echo --- Restarting WMI and RPC services ---
net stop winmgmt /y
net stop rpcss
net start rpcss
net start winmgmt

echo --- Recompiling MOF and MFL files ---
cd /d %windir%\System32\wbem
for %%f in (*.mof) do mofcomp %%f
for %%f in (*.mfl) do mofcomp %%f

echo --- Verifying WMI repository ---
winmgmt /verifyrepository
if %errorlevel% neq 0 (
    echo Repository is inconsistent. Attempting salvage...
    winmgmt /salvagerepository
    if %errorlevel% neq 0 (
        echo Salvage failed. Resetting repository...
        winmgmt /resetrepository
    )
)

echo --- Running System File Checker ---
sfc /scannow

echo --- Running DISM Health Restore ---
DISM /Online /Cleanup-Image /RestoreHealth

echo --- WMI Repair Completed ---
pause
