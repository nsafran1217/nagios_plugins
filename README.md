# nagios_plugins
# check_arcserve.ps1

Since NCPA runs as SYSTEM, permission must be granted to SYSTEM to access the arcserve tool.
I create an arcserve local user that is an Arcserve Administrator:
ca_auth -user add nagiosxi long_password_here -assignrole 8

Then add SYSTEM as an equivalent:
ca_auth -equiv add "NT AUTHORITY\SYSTEM" hostname_here nagiosxi

Info about equivalence:
https://documentation.arcserve.com/Arcserve-Backup/Available/R17/ENU/Bookshelf_Files/HTML/cmndline/index.htm?toc.htm?cl_ca_auth_equiv_args.htm
