ftp -in ftp.webofscience.com <<SCRIPTEND
user nete %6lB,Bznnf
lcd /Users/avon/git/ERNIE/Pubs/Automation/Updates_Download/update_files
binary
get WOS2017256.del.gz
get WOS2017257.del.gz
get WOS2017258.del.gz
get WOS2017261.del.gz
get WOS2017262.del.gz
get WOS2017265.del.gz
get WOS2017268.del.gz
get WOS2017269.del.gz
get WOS2017270.del.gz
get WOS2017271.del.gz
get WOS2017272.del.gz
get WOS2017275.del.gz
get WOS_RAW_201738_CORE.tar.gz
get WOS_RAW_201739_CORE.tar.gz
get WOS_RAW_201740_CORE.tar.gz
quit
SCRIPTEND

