Backup-Wordpress
================

Scripts to backup WordPress via (cPanel / Plesk) cron(tab)
----------------------------------------------------------

There are plenty of plugins available to take backups within WordPress. However, the scripts mentioned here work outside WordPress making them much more effective and efficient!

## Features

- No plugin to install. So, no plugin conflicts!
- Single script to take backups of multiple sites.
- Separate script to take (nightly) files backup without uploads directory!
- Local and offline backups are supported.
- Support for sub-directory installation of WordPress!

## Requirements in the server

- wp-cli
- aws-cli (to take offline backups)
- SSH access
- mysqldump
- tar
- enough disk space to hold local backups

## What does each backup script do?

- [db-backup.sh](https://github.com/pothi/backup-wordpress/blob/master/db-backup.sh) can take database backup with --add-drop-table option.
- [files-no-uploads-backup.sh](https://github.com/pothi/backup-wordpress/blob/master/files-no-uploads-backup.sh) can take files backups without uploads folder to reduce the overall size of the backup. Ideal for nightly backups!
- [full-backup.sh](https://github.com/pothi/backup-wordpress/blob/master/full-backup.sh) can take full backup including database (that is named db.sql and is available at the WordPress core directory). Ideal for a weekly routine!

## Where are the backups stored?

- the local backups are stored in the directory named `~/backups/`. If it doesn't exist, the script/s would attempt to create it before execution.
- the optional offline backups can be stored in AWS (for now). Support for other storage engines (especially for GCP) is coming soon!

## How to take backups?

- firstly, go through each script and fill-in the variables to fit your particular environment. Currently, it is assumed that the WordPress core is available at `~/sites/example.com/public`.
- most importantly, adjust the number of days to keep the backup, depending on the remaining hard disk space in your server!
- test the scripts using SSH before implementing it in system cron.

### Can you implement it on my server?

Yes, of course. But, for a small fee of USD 5 per server per site. [Reach out to me now!](https://www.tinywp.in/contact/).

### I have a unique situation. Can you customize it to suit my particular environment?

Possibly, yes. My hourly rate is USD 25 per hour, though.

### Have questions or just wanted to say hi?

Please ping me on [Twitter](https://twitter.com/pothi]) or [send me a message](https://www.tinywp.in/contact/).

Suggestions, bug reports, issues, forks are always welcome!
