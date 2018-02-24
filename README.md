# Start Menu Fix for Windows 10 Creator Update
#### PowerShell Scripts that can potentially fix the shortcut problems in Start Menu for those who installed softwares on another drive before the update.
\
**Please check out the article written here to make sure you understand what it's for.**  
[Article Link](#)

If you have any questions, feel free to comment on the article, I'll try my best to be responsive.

===================================================

### TL;DR Summary:

if you’re on a laptop with 2+ drives (HD/SSD combo or more), chances are you installed your Windows 10 on your C drive and most of your other programs on other drives to conserve space on your SSD. If this is what you did, after the "Windows 10 Creator Update" you might have noticed a lot of your start menu items have duplicates.

This is because for some reason the update pointed all previous installations you had to the C Drive
(The problem could be more complex than this, but this is my understanding right now)

The following scripts are automation to remove those duplicates from your Start Menu.

===================================================

### Instructions:

Your start menu is made up of entries from 2 directories (unless you changed it):

`C:\ProgramData\Microsoft\Windows\Start Menu`  
`C:\Users\“username”\AppData\Roaming\Microsoft\Windows\Start Menu`

Investigate those directories and figure out which case you fall under:  
\
**case 1**: your current installation designated shortcuts from previous Windows version as the duplicate (the 'correct shortcut' has '(1)' at the end of filename)  

**case 2**: your current installation designated shortcuts from current Windows version as the duplicate (the 'incorrect shortcut' has '(1)' at the end of filename

If you're **case 1**, use **"startmenu_fix.ps1"**  
If you're **case 2**, use **"startmenu_fix_alt.ps1"**


### How to Use?

    IMPORTANT:

    a. MAKE BACKUPS OF YOUR START MENU FOLDERS AND OPERATE ON THOSE BACKUPS ONLY,
       IN CASE THE SCRIPT DOES SOMETHING WRONG.
       I'M NOT RESPONSIBLE IF YOUR START MENU BECOMES MORE MESSED UP.
        
    b. The removed duplicates will be in your recycle bin if you need to recover them.
     
1) Create copies of these folders (e.g., to desktop)
2) Copy this script inside backup 'Start Menu' Folders
3) Open the backup 'Start Menu' Folder
4) Shift + Right Click at blank space in the folder
5) In the contextual menu, choose **"Open PowerShell Window here"**
6) Copy and paste the following into the commandline:

    **case 1**: `powershell.exe -noprofile -executionpolicy bypass -file .\startmenu_fix.ps1`

    **case 2**: `powershell.exe -noprofile -executionpolicy bypass -file .\startmenu_fix_alt.ps1`
     
7) Press Enter

After the script is run, check that things are fixed appropriately in the folder.  
If everything looks good, you can copy the folder back and delete the script.
If you open your start menu right now, you'll notice you may have to rearrange your icons, but other than that everything should work.

