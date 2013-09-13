Telstra Billing Reporter
------------------------

Version 1.0

This program parses monthly billing files produced in accordance with Telstra 
On Line Billing Service technical specfication version 6.4 and produces 
detailed and summary billing reports in PDF format as deterimined by a user 
defined configuration file.

The main window consists of a menu bar, a text field labelled 'File path' into
which the path of the billing file is entered or selected from the file system
using the associated file-browser button, a button to initiate processing, and 
a text window and progress bar which displays progress of the processing job.  
Data is read from the selected billing file and reports written to a directory 
structure under the application's data directory as follows:

- data 
  |
  +- yyyymm         (eg. 201306)     
     |
     +- details     (detailed reports for each service)
     |
     +- summaries   (summary information grouped according to configuration)
     |
     +- Service Totals - Month yyyy.pdf    (one line summary of each service)
     
Once complete, the billing file is moved into the application's archive 
directory.

Configuration
-------------
Configuration is managed in two ways:
- services.csv is a comma separated list which allows services to be grouped 
  for summary purposes.  It is maintained outside the program and imported via 
  the Configuration menu.  Each record consists of the service number, group 
  name, service description and cost centre where required.  Services which do 
  not appear in services.csv are grouped as "Unassigned".  
- internal configuration determines directories for location of various data
  files.  This is described further under menu options.
  
Menu Options
------------
- File > Rebuild Directory Structure
  Used to recreate the directory structure required by the application.

- File > Delete Current Reports
  Allows previously produced reports to be overwritten.  This allows reports
  to be re-run in the event, for example, that an incorrect services file was
  used.
  
- Edit - normal Cut/Copy/Paste functions

- Configuration > Review services file
  Displays grouped services in a tree structure
  
- Configuration > Initialise services file
  Resets the imported services file to zero length.  All services will be 
  grouped under "Unassigned"

- Configuration > Import services file
  Imports a new services.csv file.  This function opens a file browser at the
  directory set in the "Services" entry in the configuration file.
  
- Configuration > Initialise configuration file
  Resets the configuration file to zero length.  Configuration is reset to
  installation defaults.
  
- Configuration > Edit configuration file
  Configuration data is stored in the application's "config" directory in 
  config.yaml.  Although this file may be edited manually it is usually
  maintained via this menu item.  It opens a dialog browser which allows the
  user to select directory paths for the following:
  - Data: The base directory for report output.  This is also used as the 
    default directory for the location of the telstra billing file.  The "File 
    path" field on the main window defaults to the most recent .csv file in
    this directory.  The default setting is <app base>/data
  - Archive: The directory to which billing files are moved following 
    processing.  Archived billing files are renamed <date>.<time>.csv.  The
    default setting is <app base>/data/archive
  - Config:  The default directory to be used when importing a new services.csv
    file.  The default setting is <app base>/config.
    
- Logs > Review log file
  Displays a text window containing timestamped information written to the 
  application's log file.  This includes all progress messages written to the
  main window during the current and previous sessions plus any error messages.
  
- Logs > Initialise log file
  Resets the log file to zero length
  
- Help > About
  Displays copyright and version information
  
Issues
------
- The program does not display a flash screen during initialisation and can 
  take a minute or more to start up.  Be patient - it will get there 
  eventually! 
- The "Data" configuration variable should probably be split into two variables
  in a future version.  This would allow easy selection of billing files while
  allowing report files to be output to the directory from which they will 
  usually be accessed.
- This readme file is the only documentation available.  Access to it from the 
  Help menu will be provided in a future version. 

Release Notes
-------------
Version 1.1
- Commas now allowed in service descriptions as long as description is 
  enclosed in "".  This is done automatically by Excel when using 'Save as'
  csv.
- Non-data rows ignored in services configuration file.  This relies on
  valid services containing at least one character in the range 0-9.
- Empty rows ignored in services configuration file.
  
