function ConnectionWB ($ReportServerUri){
    return New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential ;
    
}

function CreateFolder ($ReportServerUri, $folderName, $folderPath){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;

    $type = $Proxy.GetType().Namespace
    $datatype = ($type + '.Property')
            
    $property =New-Object ($datatype);
    $property.Name = $folderName
    $property.Value = $folderName
            
    $numproperties = 1
    $properties = New-Object ($datatype + '[]')$numproperties 
    $properties[0] = $property;
     
    $newFolder = $proxy.CreateFolder($folderName, $folderPath, $properties);
}

function ListFolder($ReportServerUri, $targetPath){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $Proxy.ListChildren($targetPath, $false) | 
            Where TypeName -eq "Folder" | 
            Select Name, Path, Description, CreationDate |
            Format-Table -AutoSize
}

function UploadReport($ReportServerUri, $reportPath, $reportName, $rdlFile){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $cat = Get-Content $rdlFile -Encoding byte;
    $warnings= @();
    $report = $proxy.CreateCatalogItem("Report", $reportName, $reportPath, $true, $cat, $null, [ref]$warnings)

    $dtSources= "";
    $datasources=$Proxy.GetItemDataSources($report.path);
    $datasources | ForEach-Object {
        $dtSources+=$_.name+ "(" + $_.Item.reference + ") | ";
    }
    write-output "Report is created: $($report.name) !";
    $disp = New-Object PSObject;
    $disp | Add-Member NoteProperty Report ($report.name);
    $disp | Add-Member NoteProperty Path ($report.path);
    $disp | Add-Member NoteProperty Description ($report.description);
    $disp | Add-Member NoteProperty Datasources ($dtSources);
    write-output $disp;

}

function ListReport($ReportServerUri, $targetPath){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items = $proxy.ListChildren($targetPath, $true);
    $items | ForEach-Object {
        if($_.TypeName -eq "report"){
            $disp = New-Object PSObject;

            
            $dtSources= "";
            $datasources=$Proxy.GetItemDataSources($_.path);
            $datasources | ForEach-Object {
                $dtSources+=$_.name+ " | ";
            }
            
            $disp | Add-Member NoteProperty Report ($_.name);
            $disp | Add-Member NoteProperty Path ($_.path);
            $disp | Add-Member NoteProperty Description ($_.description);
            $disp | Add-Member NoteProperty Datasources ($dtSources);
            write-output $disp;
        }
    }
}

function ListAllReports($ReportServerUri, $targetPath){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $proxy.ListChildren($targetPath, $true) | Where TypeName -eq "Report" | Select Name, Path, CreationDate |  Format-Table -AutoSize
}

function ListDataSourceReport($ReportServerUri, $report){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items=$Proxy.GetItemDataSources($report);
    $items | ForEach-Object {
        
        $dsDef = $Proxy.GetDataSourceContents($_.Item.reference);        

        $disp = New-Object PSObject;
        $disp | Add-Member NoteProperty Report ($report);
        $disp | Add-Member NoteProperty Datasource ($_.name);
        $disp | Add-Member NoteProperty Reference ($_.Item.reference);
        $disp | Add-Member NoteProperty Type ($dsDef.Extension);
        $disp | Add-Member NoteProperty ConnectString ($dsDef.ConnectString);
        $disp | Add-Member NoteProperty Credential ($dsDef.CredentialRetrieval);
        $disp | Add-Member NoteProperty Enabled ($dsDef.Enabled);
        write-output $disp;
    }
}

function ListDataSource($ReportServerUri){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $Proxy.ListChildren("/", $true) |
        Where TypeName -eq "DataSource" |
        Select Name, Path, Description, CreationDate, CreatedBy, ModifiedBy, ModifiedDate |
        Format-Table -AutoSize
        
}

function CreateDataSource($ReportServerUri, $DataSourceName, $ConnectionString, $CredType, $CredUsername, $CredPassword){
    #CredType #0:(p)rompt, 1:(s)tore, 2:(i)ntegrated, 3:(n)one
    
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $DataSource = New-Object ($Proxy.GetType().Namespace + '.DataSourceDefinition');
    $Cred = New-Object ($Proxy.GetType().Namespace + '.CredentialRetrievalEnum');
    
    $DataSource.ConnectString = $ConnectionString;
    $DataSource.enabled = $true;
    $DataSource.EnabledSpecified = $true;
    $DataSource.Extension = "SQL";
    $DataSource.Prompt = $null;

    $DataSource.ImpersonateUserSpecified = $false;
    $DataSource.WindowsCredentials = $false

    if ($CredType -eq 'p'){
        $Cred.value__ = 0;
    } elseif ($CredType -eq 's'){
        $Cred.value__ = 1;
    } elseif ($CredType -eq 'i') {
        $Cred.value__ = 2;    
    } elseif ($CredType -eq 'n') {
        $Cred.value__ = 3;
    }

    $DataSource.CredentialRetrieval = $Cred;

    if ($CredUsername){
        $DataSource.UserName = $CredUsername;
    }

    if ($CredPassword){
        $DataSource.Password =$CredPassword;
    }

    $dtCreated = $Proxy.CreateDataSource($DataSourceName,"/DataSources",$true,$DataSource,$null);
    $dtDefCreated = $Proxy.GetDataSourceContents($dtCreated.path);
    
    $disp = New-Object PSObject;
    $disp | Add-Member NoteProperty Datasource ($dtCreated.name);
    $disp | Add-Member NoteProperty Path ($dtCreated.path);
    $disp | Add-Member NoteProperty Type ($dtDefCreated.Extension);
    $disp | Add-Member NoteProperty ConnectString ($dtDefCreated.ConnectString);
    $disp | Add-Member NoteProperty Credential ($dtDefCreated.CredentialRetrieval);
    $disp | Add-Member NoteProperty Enabled ($dtDefCreated.Enabled);
    write-output $disp;
    
}
