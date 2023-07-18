REM Arduino über USB Bus anschliessen
REM %AVRPATH%\listComPorts.exe aufrufen um COM Port zu bestimmen
REM erhaltenen COM Port anstatt COM7 eintragen

SET AVRPATH=flush\avrdude
SET COMPORT=COM4

REM install Firmware
%AVRPATH%\avrdude.exe -C%AVRPATH%\avrdude.conf -v -patmega328p -carduino -P%COMPORT% -b115200 -D -Uflash:w:bin\FillingController.ino.hex:i 