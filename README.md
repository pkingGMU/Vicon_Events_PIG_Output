# Vicon_Events_PIG_Output

**Authors:** Patrick

## Description

This code will allow a user to select a data folder. The code will then determine GAIT events from both PIG parameters as well as force plate parameters. It will then return an excel file with GAIT events, PIG outputs, and trajectories.

**ISSUES**: see issues tab

--------------------------------------------------------------------------------------------------

Exporting from Vicon

* Must export as CSV
* DO NOT EXPORT DUPLICATE MODEL OUTPUT DATA AS ACCELERATIONS


Preferred folder structure -> Data FOLDER -> Subject FOLDER -> Subject data FILE (1 csv file export)


**Current Build** Run `Main.m` and choose the data folder

**Outpus:** 

A .xlsx file will appear in the subject folder alongside its previous csv file.

There should be no reason to interact with the code or the variables in the workspace.





