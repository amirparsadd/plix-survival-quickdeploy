@echo off

:: SETTINGS
:: Path to file used to communicate from restart script
set "restart_flag=.restart_flag"
:: How long (in seconds) to wait before restarting
set "restart_delay=5"
:: Whether to restart on crash or not
:: The `settings.restart-on-crash` setting in spigot.yml doesn't always work
:: but also sometimes server might not return proper exit code,
:: so it's best to keep both options enabled
:: Accepted values: y/yes/true/n/no/false
set "restart_on_crash=yes"
:: The name of your server jar
set "server_jar=craftbukkit.jar"
:: What will be passed to `-Xms` and `-Xmx`
set "heap_size=3500M"
:: JVM startup flags
:: NOTE: -Xms and -Xmx are set separately
:: These are mostly "Aikar flags"
:: taken from: https://mcflags.emc.gs/
:: TODO try to add one per line for better readability
set "jvm_flags=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"
:: Minecraft args you might want to start your server with
:: Usually there isn't much to configure here:
set "mc_args=--nogui"

:: END OF SETTINGS

:: Parse yes
if %restart_on_crash% == yes (set "should_restart_on_crash=1")
if %restart_on_crash% == y (set "should_restart_on_crash=1")
if %restart_on_crash% == true (set "should_restart_on_crash=1")
:: Parse no
if %restart_on_crash% == no (set "should_restart_on_crash=0")
if %restart_on_crash% == n (set "should_restart_on_crash=0")
if %restart_on_crash% == false (set "should_restart_on_crash=0")
:: If we can't initialise %restart_on_crash%, then user input is incorrect
if not defined should_restart_on_crash (
  echo ERROR: Invalid value for ^"restart_on_crash^" variable: %restart_on_crash%
  exit /b 1
)

:: The arguments that will be passed to java:
set jvm_args=-Xms%heap_size% -Xmx%heap_size% %jvm_flags% -jar %server_jar% %mc_args%

:: Remove restart flag, if it exists,
:: so that we won't restart the server after first stop,
:: unless restart script was called
del %restart_flag% 2>nul

:: Loop infinitely
:loop
  :: Run server
  java %jvm_args% || (
    :: Oops, server didn't exit gracefully
    echo Detected server crash ^(exit code: %ERRORLEVEL%^)
    :: Check if we should restart on crash or not
    if %should_restart_on_crash% == 1 (
      type nul > %restart_flag%
    )
  )

  touch .restart_flag

  :: Check if restart file exists or exit
  if exist %restart_flag% (
    :: The flag exists - try to remove it
    del %restart_flag% 2>nul || (
      :: If we can't remove it (permissions?), then exit to avoid endless restart loop
      echo Error removing restart flag ^(exit code: %ERRORLEVEL%^)
      exit /b 1
    )
  ) else (
    :: Flag doesn't exist, so break out of the loop
    exit /b 0
  )

  :: Restart server with delay
  echo Restarting server in %restart_delay% seconds, press Ctrl+C to abort.
  timeout /T %restart_delay% /NOBREAK > nul || exit /b 0 REM Exit if timeout is interrupted (for example Ctrl+C)
goto loop

echo Server stopped.