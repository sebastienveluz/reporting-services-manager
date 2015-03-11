# Reporting Services Manager
Base on powershell this tools is used to manage reporting services (SSRS).

## Commands decription

* CreateFolder -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -folderName "NewFolder" -folderPath "/";
* ListFolder -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -targetPath "/";
* CreateCatalogItem -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -reportPath "/" -reportName "Report Name" -rdlFile "report.rdl"
* ListReport -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -targetPath "/"