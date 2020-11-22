# shift-snapshot
A bash script to automate backups for [**shift-lisk**](https://github.com/ShiftNrg/shift-lisk) blockchain

🎉 **v1.1**

For more information about Shift Community Project please visit: https://ShiftNRG.org

### Upgrade

If you are in a version prior to **v1.1** you can upgrade with the following commands:

```
cd ~/shift-snapshot/ 
git fetch
git reset --hard origin/master
```

## Requisites
    - This script works with postgres and shift_db, configured with shift user
    - You need to have sudo privileges

## Installation

Execute the following commands:
```
cd ~/
git clone https://github.com/MxShift/shift-snapshot
cd shift-snapshot/
chmod +x snap.sh
./snap.sh help
```

## Available commands

    - create
    - create [1-9]
    - create --best
    - create --verified
    - create -v
    - restore
    - log
    - help

**TODO**

    - schedule
		- hourly
		- daily
		- weekly
		- monthly

### create

Command _create_ is for create new snapshot, example of usage:<br>
`bash snap.sh create`<br>
Automaticly will create a snapshot file in new folder called snapshot/.<br>
Don't require to stop you node app.js instance.<br>
Example of output:<br>
```
   + Creating snapshot                                
  -------------------------------------------------- 
  OK snapshot created successfully at block  4632000 (718MB).
```
Also will create a line in the log, there you can see your snapshot at what block height was created.<br>

By default, snapshots are created with a compression level of 1. You can select a compression level from 1 to 9.

Example:
```
./shap.sh create 6
```

for a compression level of 9 can be usable:
```
./shap.sh create 9
```
or
```
./shap.sh create --best
```

### create --verified

Now you can create a **verified snapshot**.

Script creates a compressed dump of the shift-lisk database, then moves it to a local folder of your node, and restores it using `./shift_manager.bash rebuild`. 

After that, it's checked whether the node was able to synchronize with the blockchain.

Use:

```
./shap.sh create --verified
```

or

```
./shap.sh create -v
```

### restore

Command _restore_ is for restore the last snapshot found it in snapshot/ folder.<br>
Example of usage:<br>
`bash snap.sh restore`<br>
<br>
Automaticly will pick the last snapshot file in snapshot/ folder to restore the shift_db.<br>
If you want to restore a specific file please (for this version) delete or move the other files in snapshot/ folder.<br>
You can use the _log_ command to better pick up your restore file.<br>
<br>

### log
Display all the snapshots created. <br>
Example of usage:<br>
`bash snap.sh log`<br>
<br>
Example of output:<br>
```
   + Snapshot Log                                                                  
  --------------------------------------------------                               
  21-11-2020 - 20:59:06 -- Snapshot created successfully at block  4632000 (718MB)  
  21-11-2020 - 21:36:07 -- Snapshot created successfully at block  4633001 (785MB)  
  --------------------------------------------------END                            
```

### Schedule

To create scheduled snapshots, you can add one of these commands to `cronatab -e`:

```
@hourly cd ~/shift-snapshot && bash snap.sh create

@daily cd ~/shift-snapshot && bash snap.sh create

@weekly cd ~/shift-snapshot && bash snap.sh create

@monthly cd ~/shift-snapshot && bash snap.sh create
```

## What's new in version 1.0

+ Added check for synchronization with the blockchain before creating a snapshot.

+ Now snapshots are restored automatically, without the need to manually stop and start your node.

+ Improved stability during recovery. Previously, if the shift-lisk database was broken, the snapshot couldn't be restored. Now the old database is deleted and a new one is created, just like when `./shift_manager.bash rebuild` is called. Now a snapshot is restored under any conditions.

+ Snapshots are now created with compression, which has significantly reduced their size, but slightly increased the time it takes to create a snapshot. However, the recovery time has not changed.

+ The compression level can be selected from 1 (default) to 9. 
  * Compression with level 1 is three times faster than with level 9. 
  * The size of the database per moment at compression:
    *  1: 785MB
    *  9: 718MB

+ Snapshots are fully compatible with **./shift_manager.bash**

+ Executable file renamed from `shift-snapshot.sh` to `snap.sh`

+ Added visualization using color for: error messages, the need for user input, messages about successful completion.

+ Added a warning about closing the program during tasks execution.

+ Now you can create a **verified snapshot**.
Script creates a compressed dump of the shift-lisk database, then moves it to a local folder of your node, and restores it using `./shift_manager.bash rebuild`. 
After that, it's checked whether the node was able to synchronize with the blockchain.




## TODO

- Make it possible to choose which snapshot to recover from

### schedule

Schedule snapshot creation periodically, with the available parameters:

    - hourly
    - daily
    - weekly
    - monthly

Example: `bash snap.sh schedule daily`
<br>

-------------------------------------------------------------

### Notice

You will have a folder in ~/shift-snapshot/ called `snapshot/` where all your snapshots will be created and stored.
If you want to use a snapshot from different place (official snapshot for example or other node) you will need to download the snapshot file (with prefix: shift_db*) and copy it to the `~/shift-snapshot/snapshot/` folder.
After you copy the shift_db*.tar file you can restore the blockchain with: `bash snap.sh restore` and will use the last file found in the snapshot/ folder.<br>
If you use the `schedule` command be aware you will have a log file located in `~/shift-snapshot/cron.log` with this you will know what is happened with your schedule.