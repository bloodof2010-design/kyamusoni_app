@echo off
setlocal

set APP_HOME=%~dp0
set CLASSPATH=%APP_HOME%gradle\wrapper\gradle-wrapper.jar

if not exist "%CLASSPATH%" (
    echo ERROR: gradle-wrapper.jar not found: %CLASSPATH%
    exit /b 1
)

java -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

endlocal
