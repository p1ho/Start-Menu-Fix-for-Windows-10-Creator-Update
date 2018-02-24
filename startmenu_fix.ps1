#*******************************************************************************************#
# IMPORTANT: This version is for the case where Windows designated shortcuts from PREVIOUS  #
# Windows version as the duplicate (with ‘(1)’ at the end of filename)                      #
#*******************************************************************************************#
#
# Instruction: 
#
#     Your start menu is made up of entries from 2 directories (unless you changed it):
#        C:\ProgramData\Microsoft\Windows\Start Menu
#        C:\Users\“username”\AppData\Roaming\Microsoft\Windows\Start Menu
#
# 0) IMPORTANT:
#     a. MAKE BACKUPS OF YOUR START MENU FOLDERS AND OPERATE ON THOSE BACKUPS ONLY,
#        IN CASE THE SCRIPT DOES SOMETHING WRONG.
#        I'M NOT RESPONSIBLE IF YOUR START MENU BECOMES MORE MESSED UP.
#
#     b. It won't work if you just copy it to the 2 directories because they are protected and it won't allow the script to rename the files
#
#     c. The removed duplicates will be in your recycle bin if you need to recover them.
#
# 1) Create copies of these folders (e.g., to desktop)
# 2) Copy this script inside backup 'Start Menu' Folders
# 3) Open the backup 'Start Menu' Folder
# 4) Shift + Right Click at blank space in the folder
# 5) In the contextual menu, choose "Open PowerShell Window here"
# 6) Copy and paste the following into the commandline:
#
#      powershell.exe -noprofile -executionpolicy bypass -file .\startmenu_fix.ps1
#
# 7) Press Enter
#
# After the script is run, check that things are fixed appropriately in the folder.  
# If everything looks good, you can copy the folder back and delete the script.
# If you open your start menu right now, you'll notice you may have to rearrange your icons, but other than that everything should work.


Write-Host "Start Menu Fix Starting..."
Write-Host "==============================`n"
Add-Type -AssemblyName Microsoft.VisualBasic # Import VisualBasic Assembly for moving files to trash instead of permanent deletion

# Moves the file passed as a parameter in the current directory to trash. 
# Takes a single string argument representing the name of the file to be removed
# Returns nothing.
function move-to-trash {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateScript({ Test-Path ("{0}/{1}" -f $pwd,$filename) })] # Tests if file to be deleted exists
        [string]$filename
    )
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(("{0}/{1}" -f $pwd,$filename),'OnlyErrorDialogs','SendToRecycleBin')
}

# Recursively navigate the folder tree structure. At every level, it first cleans out the duplicate files, then it checks each folder in that level for any duplicates
# If there are no more existing folders, after cleaning out duplicates in that level, it traverses back up one level.
# Takes in 2 arguments:
# 1. $existing-folders which is an array containing folders to be traversed
# 2. $level which is just an int indicate how deep you are in the folder tree structure. Root folder has level 0
# Returns nothing.
function navigate-folders {
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.Array]$existing_folders,
        [int]$level
    )
    # Cleans out duplicates at this level
    cleaning-folder $level
    # If folders exist at this level, traverse them all
    if ($existing_folders) {
        Write-Host $("    "*$level + "There are $($existing_folders.Length) folders at this level")
        foreach ($folder in $existing_folders) {
            $folder_name = $folder.toString()
            Write-Color-Host yellow $("    "*$level + "Entering Folder '$($folder_name)'")
            cd $folder_name
            $folders_in_folder = dir -Directory
            navigate-folders $folders_in_folder ($level + 1)
            cd..
        }
        Write-Host $("    "*$level + "All folders scanned at this level")
    } else {
        Write-Host $("    "*$level + "Folder has no deeper Directories")
    }
}

# Cleans out duplicates at the current level.
# Takes in 1 argument:
# 1. $level which is just an int indicate how deep you are in the folder tree structure. Root folder has level 0
# Returns nothing.
function cleaning-folder {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$level
    )
    $good_files = dir -Filter "* (1).lnk*"
    if ($good_files.Length -gt 0) {
        Write-Host $("    "*$level + "Duplicate Found! Cleaning Folder...")
        $bad_filenames = @()
        # Get files with (1) suffix, remove (1) and add it to bad file list
        foreach ($good_file in $good_files){
            $good_file_str = $good_file.toString()
            $bad_filenames += ,("{0}.lnk" -f $good_file_str.Substring(0,$good_file_str.Length - 8))
        }
        # remove files added to bad file list
        foreach ($bad_filename in $bad_filenames){
            move-to-trash $bad_filename
        }
        Write-Color-Host red $("    "*$level + ("Removed {0} Duplicates!" -f $bad_filenames.Length))
        # remove (1) from original file names
        $good_files | Rename-Item -NewName { $_.Name -Replace " \(1\)", ""}
    } else {
        Write-Color-Host green $("    "*$level + "No Duplicate Found at this level.")
    }
}

# This function prints out colored texts for readability
# Takes in 2 arguments:
# 1. the color to be set
# 2. the text to be printed
# Consulted https://stackoverflow.com/questions/4647756/is-there-a-way-to-specify-a-font-color-when-using-write-output
function Write-Color-Host {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ForegroundColor,
        [string]$print_msg
    )
    $color_backup = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Host $print_msg
    $host.UI.RawUI.ForegroundColor = $color_backup
}

# Main Process
navigate-folders (dir -Directory) 0

Write-Host "`n=============================="
Write-Color-Host green "Duplicate Cleaning Completed!!"
Write-Host "=============================="