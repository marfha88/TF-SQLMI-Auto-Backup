<#
.SYNOPSIS
This script sets the backup configuration retention for Azure SQL Managed Instances (SQLMI) databases.

.DESCRIPTION
The script connects to Azure and retrieves a list of Azure SQL Managed Instances. For each instance, it retrieves the databases and checks if the Long Term Retention Policy is set. If the policy is not set, it sets the Short Term Retention Policy and the Long Term Retention Policy for each database.

.PARAMETER None

.INPUTS
None. You need to provide the necessary Azure credentials when prompted.

.OUTPUTS
None. The script sets the backup configuration retention for Azure SQL Managed Instances databases.

.EXAMPLE
.\sqlmi.ps1
Runs the script and sets the backup configuration retention for Azure SQL Managed Instances databases.

#>

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

####### Here you can set the retention days for short term and long term retention #######

$RetentionDays = 30

$WeeklyRetention = 0

$MonthlyRetention = 12

#$YearlyRetention =5

#$WeekOfYear =1

#Set backup configuration retention for Azure MI databases

$AzureSQLMIS = Get-AzResource | Where-Object ResourceType -EQ Microsoft.Sql/managedInstances

foreach ($AzureSQLMI in $AzureSQLMIS){

[string]$instancename = $AzureSQLMI.Name
[string]$resourcename = $AzureSQLMI.ResourceGroupName

$AzureSQLServerDataBases = Get-AzSqlInstanceDatabase -InstanceName $instancename -ResourceGroupName $resourcename | Where-Object Name -NE “master”



foreach ($AzureSQLServerDataBase in $AzureSQLServerDataBases) {
    # Retrieve the Long Term Retention Policy
    $longTermPolicy = Get-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourcename -InstanceName $instancename -DatabaseName $($AzureSQLServerDataBase.Name)

    # Check if the Long Term Retention Policy is set
    if ($longTermPolicy.MonthlyRetention -eq "P12M"){ #Here we are checking if the Long Term Retention Policy is set to 12 months
        Write-Output "Long Term Retention Policy is set for database $($AzureSQLServerDataBase.Name) in SQLMI $instancename. Skipping Long Term Retention and Short Term Retention."
    } else {
        # If the Long Term Retention Policy is not set, proceed with setting the policies
        # Short Term Retention Policy
        Set-AzSqlInstanceDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $resourcename -InstanceName $instancename -DatabaseName $($AzureSQLServerDataBase.Name) -RetentionDays $RetentionDays

        # Long Term Retention Policy
        Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -WeeklyRetention "P$($WeeklyRetention)W" -MonthlyRetention "P$($MonthlyRetention)M" -InstanceName $instancename -DatabaseName $($AzureSQLServerDataBase.Name) -ResourceGroupName $resourcename
        }
    }
}
