Param([string]$process, [string]$inputDir, [string]$outputDir)

$processParameters = @{
    "import_scopes" = @{ "fileName" = "scopes.csv"; "url" = "/api/apps/alerthub/scopes"; "replaceParameter" = $null; "method" = "Post"; "nameParameter" = $null }
    "import_actions" = @{ "fileName" = "actions.csv"; "url" = "/api/apps/alerthub/actions"; "replaceParameter" = $null; "method" = "Post"; "nameParameter" = $null }
    "import_mute_schedules" = @{ "fileName" = "mute_schedules.csv"; "url" = "/api/apps/alerthub/scopes/{scopeId}/mute-schedules"; "replaceParameter" = "scopeId"; "method" = "Post"; "nameParameter" = $null }
    "export_scopes" = @{ "fileName" = "scopes.csv"; "url" = "/api/apps/alerthub/scopes"; "replaceParameter" = $null; "method" = "Get"; "nameParameter" = $null }
}

. ".\config\config.ps1"

function preprocess($hashObject) {
    $scriptedParameters = @("parameters.headers", "parameters.to", "parameters.cc", "parameters.bcc")
    $arrayParameters = @("parameters.to", "parameters.cc", "parameters.bcc")

    foreach ($name in $hashObject.psobject.properties.name) {
        #convert string to int
        if ([int]::TryParse($hashObject.$name, [ref]$null)) {
            $hashObject.$name = [int]$hashObject.$name
        }

        #convert structured value
        if ($scriptedParameters -contains $name) {
            $hashObject.$name = Invoke-Expression $hashObject.$name
        }

        #array wrapping
        if ($arrayParameters -contains $name -And ($hashObject.$name) -And !($hashObject.$name.GetType().Name -contains "[]") ) {
            $array = @()
            $array += $hashObject.$name
            $hashObject.$name = $array
        }

        #dig period separated property
        if ($name.Contains(".")) {
            $parentName, $childName = $name.Split(".")
            $childValue = $hashObject.$name
            $child = [PSCustomObject]@{
                $childName = $childValue
            }

            if ($hashObject.$parentName) {
                $hashObject.$parentName | Add-Member -MemberType NoteProperty -Name $childName -Value $childValue
            } else {
                $hashObject | Add-Member -MemberType NoteProperty -Name $parentName -Value $child
            }
            $hashObject.psobject.properties.remove($name)
        }
    }
}

function replaceURL($url, $replaceValue) {
    return $url -replace "{.*}",$replaceValue
}

function import($inputFilePath, $outputFilePath, $url, $replaceParameter, $method, $nameParameter) {
    #check input file exists
    if (!(Test-Path -LiteralPath $inputFilePath)) {
        Write-Host "ERROR: 一括登録するCSVファイルを配置してください。[$inputFilePath]"
        exit 1
    }

    $importData = Import-CSV -Encoding Default $inputFilePath
    $results = [System.Collections.ArrayList]::new()
    $httpHeaders = @{"Content-type"="application/json"; "X-Authorization"="Token "+$apiToken}

    #import each row
    $importData | ForEach-Object {
        preprocess $_
        if ($replaceParameter) {
            $fixedURL = replaceURL $url $_.$replaceParameter
        } else {
            $fixedURL = $url
        }
        if ($nameParameter) {
            $fixedURL = createAttributeURL $fixedURL $_.$nameParameter
        } else {
            $fixedURL = $fixedURL
        }
        $jsonText = $_ | ConvertTo-Json -Compress -Depth 5
        $body = [Text.Encoding]::UTF8.GetBytes($jsonText)
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Headers $httpHeaders -Method $method -Body $body ($targetSpaceDomain+$fixedURL)
            $statusCode = $response.StatusCode
            $responseBody = $response.Content
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $reader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
        }
        $result = [PSCustomObject]@{"Json" = $jsonText; "StatusCode" = $statusCode; "Response" = $responseBody}
        $results.Add($result)
        
        Start-Sleep -Milliseconds 500
    }
    $results | Export-Csv -NoTypeInformation $outputFilePath -Encoding Default
}

function export($outputFilePath, $url, $method) {
    $httpHeaders = @{"Content-type"="application/json"; "X-Authorization"="Token "+$apiToken}

    try {
        $response = Invoke-WebRequest -UseBasicParsing -Headers $httpHeaders -Method $method ($targetSpaceDomain+$url)
        $responseBody = $response.Content
    } catch {
        $reader = New-Object System.IO.StreamReader $_.Exception.Response.GetResponseStream()
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
    }
    $resultData = ConvertFrom-Json -InputObject $responseBody
    $resultData."Items" | Export-Csv -NoTypeInformation $outputFilePath -Encoding Default
}

function setProxy() {
    if ($proxyServer) {
        $proxy = New-Object System.Net.WebProxy $proxyServer, $True
        if ($proxyUser -And $proxyPassword) {
            $securePassword = ConvertTo-SecureString $proxyPassword -AsPlainText -Force
            $proxy.Credentials = New-Object -TypeName System.Management.Automation.PSCredential $proxyUser,$securePassword
        }
        [System.Net.WebRequest]::DefaultWebProxy = $proxy
    }
}

#main
$ErrorActionPreference = "Stop"

setProxy

if ($process.Contains("import")) {

    $private:inputFilePath = Join-Path $inputDir $processParameters[$process]."fileName"
    $private:outputFilePath = Join-Path $outputDir $resultFileName
    $private:url = $processParameters[$process]."url"
    $private:replaceParameter = $processParameters[$process]."replaceParameter"
    $private:method = $processParameters[$process]."method"
    $private:nameParameter = $processParameters[$process]."nameParameter"
    import $inputFilePath $outputFilePath $url $replaceParameter $method $nameParameter
}
if ($process.Contains("export")) {

    $private:outputFilePath = Join-Path $outputDir $processParameters[$process]."fileName"
    $private:url = $processParameters[$process]."url"
    $private:method = $processParameters[$process]."method"
    export $outputFilePath $url $method
}