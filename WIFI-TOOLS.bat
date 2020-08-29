@echo off
color f0
:inicio
title Simple_WIFI
goto ip
:ini2
cls
echo.
echo IP publica : %ip_pub%    IP privada : %ipp%
echo.
echo ---------------------------------------------------------
echo.
echo.
echo 1-Crear hotspot
echo 2-Apagar hotspot
echo 3-Reanudar hotspot
echo 4-Ver claves wifi guardadas
echo 5-Escanear redes visibles actualmente
echo 6-Actualizar ip's
echo 7-Cambiar DNS (ADMINISTRADOR)
echo 8-Desactivar/Activar reconocimiento por "ping" (ADMINISTRADOR)
echo 9-Salir
echo.
choice /c 123456789 /n /m "Elija el numero : "
if %errorlevel%==1 goto crear
if %errorlevel%==2 goto apagar
if %errorlevel%==3 goto encender
if %errorlevel%==4 goto recordar
if %errorlevel%==5 goto escan
if %errorlevel%==6 goto ip
if %errorlevel%==7 goto DNS
if %errorlevel%==8 (goto ping) else (exit)
:crear
cls
title CREAR HOTSPOT
echo Introduce el nombre de la red a crear
set/p "nombre=>"
echo Introduce la clave de la red a crear
set/p "pass=>"
netsh wlan set hostednetwork mode=allow ssid=%nombre% key=%pass%
if %errorlevel%==1 cls & echo "La clave debe constar de 8 o mas carateres ASCII (intro continuar)" & pause>nul & goto crear
netsh wlan start hostednetwork
if %errorlevel%==1 echo ERROR & pause>nul & goto ini2
echo.
echo -------------------------------
echo LA RED FUE CREADA EXITOSAMENTE
echo -------------------------------
pause>nul
goto ini2


:apagar
cls
title Apagar HOTSPOT
echo Estas de seguro de cerrar? (y/n)
set/p "respuesta=>"
if %respuesta%==n exit
netsh wlan stop hostednetwork
if %errorlevel%==1 echo ERROR & pause>nul & goto ini2
echo.
echo --------------------------------
echo LA RED FUE DETENIDA EXITOSAMENTE
echo --------------------------------
pause>nul
goto ini2


:encender
cls
netsh wlan start hostednetwork
if %errorlevel%==1 echo ERROR & pause>nul & goto inicio
echo.
echo ---------------------------------
echo LA RED FUE REANUDADA EXITOSAMENTE
echo ---------------------------------
pause>nul
goto ini2


:recordar
cls
title Recordar claves WIFI
netsh wlan show profile > %tmp%\wifi-1.txt
find /i "Perfil de todos" %tmp%\wifi-1.txt > %tmp%\wifi.txt
find /n "Perfil de todos" %tmp%\wifi.txt > %tmp%\wifi-3.txt
type %tmp%\wifi-3.txt
echo.
echo --------------------------------------------------
echo.
echo Selecciona el numero de la red
set /p "num=>"
find "[%num%]" %tmp%\wifi-3.txt > %tmp%\wifi-4.txt
for /f "skip=2 tokens=8,9" %%a in (%tmp%\wifi-4.txt) do (set essid=%%a)
cls
netsh wlan show profile name=%essid% key=clear > %tmp%\wifi_psk.txt
find /i "Contenido de la clave" %tmp%\wifi_psk.txt
del %tmp%\wifi.txt
del %tmp%\wifi-1.txt
del %tmp%\wifi-3.txt
del %tmp%\wifi-4.txt
del %tmp%\wifi_psk.txt
:menu
echo.
echo 1. Mostrar mas detalles de la red
echo 2. Introducir otra red
echo 3. Inicio
choice /c 123 /n
if %errorlevel%==1 cls & netsh wlan show profile name=%essid% key=clear & echo. & echo. & pause & cls & goto menu
if %errorlevel%==2 (goto recordar) else (goto ini2)


:escan
cls
title Escanear redes
netsh wlan show networks mode=bssid
if %errorlevel%==1 echo ERROR & pause>nul & goto ini2
echo.
echo -------------------------------------------------
echo.
pause
:menu2
cls
echo 1. mostrar menos detalles
echo 2. inicio
choice /c 12 /n
if %errorlevel%==1 (cls & netsh wlan show networks & echo. & echo --------------------------------------- & echo. & pause & goto menu2) else (goto ini2)


:ip
cls
nslookup myip.opendns.com. resolver1.opendns.com > %tmp%\ip_sw.txt
for /f "skip=4 tokens=2,3" %%a in (%tmp%\ip_sw.txt) do (set ip_pub=%%a)
cls
ipconfig > %tmp%\ipp.txt
find "IPv4" %tmp%\ipp.txt > %tmp%\ipp2.txt
for /f "skip=2 tokens=17,18" %%a in (%tmp%\ipp2.txt) do (set ipp=%%a)
del %tmp%\ip*.txt
goto ini2

:DNS
title DNS 
cls
echo.
echo EJECTAR COMO ADMINISTRADOR
echo.
echo Cambiar DNS
netsh interface show interface > %tmp%\dns1.txt
find /V "Desconectado" %tmp%\dns1.txt > %tmp%\dns2.txt
for /f "skip=4 tokens=4,5" %%a in (%tmp%\dns2.txt) do (set interfaz=%%a)
del %tmp%\dns1.txt %tmp%\dns1.txt
ipconfig /flushdns

echo 1 - Open Nic Project - DNS_1 87.98.175.85 (FR) DNS_2 5.135.183.146 (FR)
echo 2 - Open DNS - DNS_1 208.67.222.222 DNS_2 208.67.220.220
echo 3 - DHCP DNS
echo 4 - DNS personalizado
choice /c 1234 /n
if %errorlevel%==1 (netsh interface IPv4 set dnsserver "%interfaz%" static 87.98.175.85 & netsh interface IPv4 add dnsserver "%interfaz%" 5.135.183.146 index=2 & goto ini2)
if %errorlevel%==2 (netsh interface IPv4 set dnsserver "%interfaz%" static 208.67.222.222 & netsh interface IPv4 add dnsserver "%interfaz%" 208.67.220.220 index=2 & goto ini2)
if %errorlevel%==3 (netsh interface IPv4 set dnsserver ethernet dhcp & goto ini2)
echo Direccion del DNS primario ?
set/p "dns1=>"
echo Direccion del DNS secundario ?
set/p "dns2=>"
netsh interface IPv4 set dnsserver "%interfaz%" static %dns1%
netsh interface IPv4 add dnsserver "%interfaz%" %dns2% index=2
goto ini2

:ping
title ping
cls
echo.
echo Oculta el dispositivo en la red local
echo.
echo 1 - Desactivar respuesta ping
echo 2 - Activar respuesta ping
echo 3 - Menu
choice /c 123 /n
if %errorlevel%==1 (netsh advFirewall Firewall add rule name="Bloquear ping IPv4" protocol=icmpv4:8,any dir=in action=block) & pause & goto ini2
if %errorlevel%==2 (netsh advFirewall Firewall add rule name="Bloquear ping IPv4" protocol=icmpv4:8,any dir=in action=allow) & pause & goto ini2
else goto ini2