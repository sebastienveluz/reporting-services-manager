function ConnectionWB ($ReportServerUri){
    return New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential ;
    
}

function GetItemType($item){
        if($item.TypeName -eq "Folder"){
            return "folder";
        } elseif($item.TypeName -eq "Report"){
            return "report";
        } else {
            return "other";
        }
}

function CreateFolder ($ReportServerUri, $folderName, $folderPath){
    #$Proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential ;
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
            $_;
        }
    }
}

function CreateCatalogItem($ReportServerUri, $reportPath, $reportName, $rdlFile){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $cat = Get-Content $rdlFile -Encoding byte;
    $warnings= @();
    $proxy.CreateCatalogItem("Report", $reportName, $reportPath, $true, $cat, $null, [ref]$warnings)
}

function ListReport($ReportServerUri, $targetPath){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items = $proxy.ListChildren($targetPath, $false)
    $items | ForEach-Object {
        $typeItem = GetItemType -item $_;
        if($typeItem -eq "report"){
            $_;
        }
    }
}

function ListDataSourceReport($ReportServerUri, $report){
    $Proxy = ConnectionWB -ReportServerUri $ReportServerUri;
    $items=$Proxy.GetItemDataSources($report);
    $items | ForEach-Object {
        $_.name;
    }
}

