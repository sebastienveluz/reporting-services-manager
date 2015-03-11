# Reporting Services Manager
Base on powershell this (basic) tool is used to manage reporting services (SSRS).

## Commands decription

### Create a folder
> CreateFolder -ReportServerUri reportServerUri -folderName foldername -folderPath "/"

with parameters:
* ReportServerUri: web service url
* folderName: name of the folder
* folderpath: path of the folder ("/" for root)

### Create a report (get online with a rdl file, local to server)
> UploadReport -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -reportPath "/" -reportName "Report Name" -rdlFile "report.rdl"

with parameters:
* ReportServerUri: web service url
* reportPath: path of the report
* reportName: Name of the report
* rdlFile: SSRS report (*.rdl file)

### List all folders on a specific path (non recursive)
> ListFolder -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -targetPath "/";

with parameters:
* ReportServerUri: web service url
* targetPath: path

### List all reports on a specific path (non recursive)
> ListReport -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -targetPath "/"

with parameters:
* ReportServerUri: web service url
* targetPath: path

### List all reports on a specific path (recursive)
> ListAllReports -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl"

with parameters:
* ReportServerUri: web service url
* targetPath: path

### List all datasources for a specific report
> ListDataSourceReport -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl" -report "report_path"

with parameters:
* ReportServerUri: web service url
* report: the complete path of the report

### List all datasources on the server
> ListDataSource -ReportServerUri "https://server/service_path/ReportService2010.asmx?wsdl"

with parameters:
* ReportServerUri: web service url

