# Vicon_Events_PIG_Output

**Authors:** Patrick

## Description

This project is split into two parts. 
* The first is processing raw Vicon Data from PIG to calculate both gen, foot strike, and foot off events from Vicon's csv export. This will create an xlsx file with the events listed as well as the devices, model output, and trajectory data.
* The second part is running and analysis located in the `Gait_Analysis_Code` Folder to get a full analysis on the data. 

**ISSUES**: see issues tab

--------------------------------------------------------------------------------------------------

Exporting from Vicon

* Must export as CSV



## Setting Up and Running This Project

* Download this repo by either cloning it using GitHub or clicking `<> Code` -> `Download ZIP`
* Take your Vicon export csvs and put them in the `Data` folder provided. The structure should look like `Data` Folder -> `SubjectID` Folder -> `Trial` Files .csv
* Run app.m (Will take n files * 45 seconds amount of time so be patient) and choose `Process Data`
* All completed .xlsx files will appear in the provided `Gait_Analysis_Data` Folder
* Run app.m  and choose `Analyze Data`
* When it asks for project folder select .../Vicon_Events_PIG_Output
* When it asks for data folder select .../Vicon_Events_PIG_Output/Gait_Analysis_Data
* When it asks for code folder select .../Vicon_Events_PIG_Output/Gait_Analysis_Code
* When it asks for Overground folder select .../Vicon_Events_PIG_Output/Gait_Analysis_Data/Overground
* When it asks for directional XX or YY select `XX`
* Ouput will appear in .../Vicon_Events_PIG_Output/Gait_Analysis_Data/Processed Data






