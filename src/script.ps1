function ConnectionWB ($ReportServerUri){
    return New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential ;
    
}

function GetItemType($item){
        if($item.TypeName -eq "Folder"){
            return "folder";
        } elseif($item.TypeName -eq "Report"){
            return "report";
        } elseif($item.TypeName -eq "DataSource"){
            return "datasource";
        } else {
            return "other";
        }
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
    $items = $Proxy.ListChildren($folderPath, $false);
    $items | ForEach-Object {
        $typeItem = GetItemType -item $_;
        if($typeItem -eq "folder"){
            $disp = New-Object PSObject;
            $disp | Add-Member NoteProperty Report ($_.name);
            $disp | Add-Member NoteProperty Path ($_.path);
            $disp | Add-Member NoteProperty Description ($_.description);
            write-output $disp;
        }
    }
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
    $items = $proxy.ListChildren($targetPath, $false)
    $items | ForEach-Object {
        $typeItem = GetItemType -item $_;
        if($typeItem -eq "report"){
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
    $items = $proxy.ListChildren($targetPath, $true)
    $items | ForEach-Object {
        $typeItem = GetItemType -item $_;
        if($typeItem -eq "report"){
            $disp = New-Object PSObject;
            $disp | Add-Member NoteProperty Report ($_.name);
            $disp | Add-Member NoteProperty Path ($_.path);
            $disp | Add-Member NoteProperty Description ($_.description);
            write-output $disp;
        }
    }
}

function ListDataSourceReport($ReportServerUri, $report){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items=$Proxy.GetItemDataSources($report);
    $items | ForEach-Object {
        $disp = New-Object PSObject;
        $disp | Add-Member NoteProperty Report ($report);
        $disp | Add-Member NoteProperty Datasource ($_.name);
        $disp | Add-Member NoteProperty Reference ($_.Item.reference);
        write-output $disp;
    }
}

function ListDataSource($ReportServerUri){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items=$Proxy.ListChildren("/", $true);
    $items | ForEach-Object {
        $typeItem = GetItemType -item $_;
        if($typeItem -eq "datasource"){
            $disp = New-Object PSObject;
            $disp | Add-Member NoteProperty Datasource ($_.name);
            $disp | Add-Member NoteProperty Path ($_.path);
            $disp | Add-Member NoteProperty Description ($_.description);
            write-output $disp;
        }
    }
}

