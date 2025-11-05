@ECHO OFF
REM ----------------------------------------------------------------------------
REM Apache Maven Wrapper startup script for Windows
REM Based on Maven Wrapper 3.2.0
REM ----------------------------------------------------------------------------

SETLOCAL

SET MVNW_VERBOSE=%MVNW_VERBOSE%
IF "%MVNW_VERBOSE%"=="" SET MVNW_VERBOSE=false

SET APP_BASE=%~dp0
SET MAVEN_PROJECTBASEDIR=%APP_BASE%

SET WRAPPER_DIR=%MAVEN_PROJECTBASEDIR%.mvn\wrapper
SET WRAPPER_JAR=%WRAPPER_DIR%\maven-wrapper.jar
SET WRAPPER_PROPERTIES=%WRAPPER_DIR%\maven-wrapper.properties

REM Find Java
IF NOT "%JAVA_HOME%"=="" (
  SET JAVA_EXE=%JAVA_HOME%\bin\java.exe
) ELSE (
  WHERE java >NUL 2>&1
  IF ERRORLEVEL 1 (
    ECHO Error: Java executable not found. Please install Java 17+ or set JAVA_HOME.
    EXIT /B 1
  )
  FOR /F "delims=" %%i IN ('WHERE java') DO SET JAVA_EXE=%%i
)

IF NOT EXIST "%WRAPPER_PROPERTIES%" (
  ECHO Error: %WRAPPER_PROPERTIES% not found. Please ensure Maven Wrapper is configured.
  EXIT /B 1
)

FOR /F "tokens=1,* delims==" %%a IN (%WRAPPER_PROPERTIES%) DO (
  IF "%%a"=="distributionUrl" SET DISTRIBUTION_URL=%%b
  IF "%%a"=="wrapperUrl" SET WRAPPER_URL=%%b
)

IF NOT EXIST "%WRAPPER_JAR%" (
  IF "%MVNW_VERBOSE%"=="true" ECHO Downloading Maven Wrapper JAR from: %WRAPPER_URL%
  IF EXIST "%WRAPPER_DIR%" (
  ) ELSE (
    MKDIR "%WRAPPER_DIR%"
  )
  WHERE curl >NUL 2>&1
  IF NOT ERRORLEVEL 1 (
    curl -fsSL -o "%WRAPPER_JAR%" "%WRAPPER_URL%"
  ) ELSE (
    WHERE wget >NUL 2>&1
    IF NOT ERRORLEVEL 1 (
      wget -q -O "%WRAPPER_JAR%" "%WRAPPER_URL%"
    ) ELSE (
      ECHO Error: curl or wget required to download Maven Wrapper JAR.
      EXIT /B 1
    )
  )
)

SET WRAPPER_LAUNCHER=org.apache.maven.wrapper.MavenWrapperMain
SET CLASSPATH=%WRAPPER_JAR%

"%JAVA_EXE%" %MAVEN_OPTS% -classpath "%CLASSPATH%" "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" %WRAPPER_LAUNCHER% %*
ENDLOCAL
