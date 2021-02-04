IF %5 == 1 (
start tshark-i.bat %3 %6
)

IF %4 == 1 (
start tcpdump-i.bat
)

choice /C X /T 1 /D X > nul

IF %1 == 1 (
FTP -s:FTP_VzWDallasFTPget.txt 2>&1 | wtee %2 -a
)
IF %1 == 2 (
FTP -s:FTP_VzWIrvineFTPget.txt 2>&1 | wtee %2 -a
)
IF %1 == 3 (
FTP -s:FTP_VzWDallasFTPput.txt 2>&1 | wtee %2 -a
)
IF %1 == 4 (
FTP -s:FTP_VzWIrvineFTPput.txt 2>&1 | wtee %2 -a
)
IF %1 == 5 (
FTP -s:FTP_TestBedFTP.txt 2>&1 | wtee %2 -a
)
IF %1 == 6 (
FTP -s:FTP_ftp.lgmobilecomm.com.txt 2>&1 | wtee %2 -a
)


