# Changelog

## 1.2 (24-11-2020)

+ Added a feature to upload verified snapshots to a release section of a GitHub repository

## 1.1 (22-11-2020)

+ Added check for synchronization with the blockchain after restoring a snapshot.

+ Added changelog :)

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