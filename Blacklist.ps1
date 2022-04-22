Import-Module UMN-Google

############################ CHANGE THIS PATH TO MATCH YOUR SavedVariables location ############################
$PathToSavedVariables = "D:\World of Warcraft\_classic_\WTF\Account\USERNAME\SavedVariables\PersonalBlackList.lua"
############################ CHANGE THIS PATH TO MATCH YOUR SavedVariables location ############################


# Set security protocol to TLS 1.2 to avoid TLS errors
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Google API Authorization
$scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file"
$certPath = "PATH_TO_CERT"
$iss = 'GOOGLE_ADMIN_ACCOUNT_NAME'
$certPswd = 'notasecret'
$accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $iss

#set initial player position to 1
$count=1

#Google Sheets ID
$SpreadsheetID = "SPREADSHEET_ID_HERE"

#Start iterating through the sheets
#Check which realm (server) is in question
for ($scope=0; $scope -le 2; $scope++){
    if($scope -eq 0){
        $sheetname = 'Dragonfang'
    } elseif($scope -eq 1){
        $sheetname = 'ZandalarTribe'
    } elseif($scope -eq 2){
        $sheetname = 'Earthshaker'
    }
    #get data from a sheet
    $results = Get-GSheetData -accessToken $accessToken -cell 'AllData' -sheetName $sheetname -spreadSheetID $spreadSheetID

    #parse each row of the results
    foreach($row in $results){
       
        #get player information
        $playerName = $row.name.toUpper()
        $playerReason = $row.reason
        $playerClass = $row.Class.toUpper()
        $playerRealm = $sheetname.toUpper()
        
        #parse reasons for blacklisting
        if($playerReason -gt ""){
            if($playerReason.contains("Toxic")){
                $playerReason = "14"
            }elseif($playerReason.contains("Stealing")){
                $playerReason = "13"
            } else {
                $playerReason = "1"
            }
        }

        #check if class is specified
        if($playerClass -gt ""){
            if($playerClass -eq "-"){
                $playerClass = "UNSPECIFIED"
            }
        }
        #generate an entry to the .lua file
        $newdataset += '{'+ "`n`t`t`t`t" + '["reaIdx"] = '+ $playerReason +','+ "`n`t`t`t`t" + '["name"] = "' + $playerName + '",'+ "`n`t`t`t`t" + '["catIdx"] = 1,'+ "`n`t`t`t`t" + '["classFile"] = "' + $playerClass + '",'+ "`n`t`t`t`t" + '["realm"] = "' + $playerRealm + '",'+ "`n`t`t`t" + '}, -- [' + $count + ']'+ "`n`t`t`t"
        $count++
    }
}

#wrap the results of the list
$finalDataSet = '"] = {'+ "`n`t`t" + '["blackList"] = {'+ "`n`t`t`t" + $newdataset + ''+ "`n`t`t" + '}'+ "`n`t" + '},'+ "`n`t" + '["'

#Update the .lua file
$OutputFile = Get-Content $PathToSavedVariables -Raw
$OutputFile -replace "(?s)(?<=global).*(?=profile)","$finalDataSet"|Out-File $PathToSavedVariables