rem @echo off
set database=database.xml

set basedir=..\example\northwind

if NOT x%1==x set basedir=%1

set dir=%basedir%\xml
set output=%basedir%\output


if EXIST Working goto Working_exists
mkdir Working
:Working_exists

if EXIST %output%\Graphs goto graphs_exists
rem mkdir %output%\Graphs
:graphs_exists

rem del Working\Graphs\*.* /Q
rem del %output%\Graphs\*.* /Q

set nxslt=..\lib\nxslt\nxslt.exe
set graphviz=..\lib\GraphViz-2.38\bin
set dotml=..\lib\dotml-1.4
set bootstrap=..\lib\bootstrap-3.3.5
set jquery=..\lib\jquery-1.11.3

xcopy "%bootstrap%" %output%\lib\bootstrap /E /Y /I
xcopy "%jquery%" %output%\lib\jquery /E /Y /I
xcopy "css" %output%\css /E /Y /I

@echo === Apply Templates ===
%nxslt% %dir%\%database% Stylesheets\consolidate.xslt -o Working\database.xml 2> working\errors1.txt 
%nxslt% Working\database.xml Stylesheets\add-meta-data.xslt -o Working\database-meta-data.xml 
%nxslt% Working\database-meta-data.xml Stylesheets\extract-link-data.xslt -o Working\linkdata.xml 

%nxslt% Working\linkdata.xml StyleSheets\render-html.xslt -o "%output%\index.html" 

%nxslt% Working\linkdata.xml StyleSheets\excel-output.xslt -o "%output%\Excel.Output.xls" 
rem %nxslt% Working\linkdata.xml StyleSheets\excel-report.xslt -o "%output%\Excel.Reports.xls" 

rem %nxslt% Working\linkdata.xml StyleSheets\render-link-dotml.xslt -o Working\links.dotml
rem %nxslt% Working\links.dotml %dotml%\dotml2dot.xsl -o "Working\links.gv" 
rem %graphviz%\dot.exe -Tpng "Working\links.gv"  -o "%output%\dot.png"
rem %graphviz%\circo.exe -Tpng "Working\links.gv"  -o "%output%\circo.png"


