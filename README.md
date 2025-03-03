# Vicon_Events_PIG_Output

**Authors:** Patrick

## Description

This project is a multi use application for dealing with PIG outputs.
* **Gait Event Detection:** processing raw Vicon Data from PIG to calculate both gen, foot strike, and foot off events from Vicon's csv export. This will create an xlsx file with the events listed as well as the devices, model output, and trajectory data.
* **Gait Analysis:** Step Length, Step Width, Gait Speed, MoS etc.  
* **Obstacle Crossing Analysis** Distances

**ISSUES**: see issues tab

--------------------------------------------------------------------------------------------------

Exporting from Vicon

* Must export as CSV



## Setting Up and Running This Project for Gait Event Preprocess and Analysis

### Gait Event Deteciton 
* Download this repo by either cloning it using GitHub or clicking `<> Code` -> `Download ZIP`
* Take your Vicon export csvs and put them in the `Data` folder provided. The structure should look like `Data` Folder -> `SubjectID` Folder (You will need to create this) -> `Trial` Files .csv
* Run app.m (Will take n files * 45 seconds amount of time so be patient) and choose `Gait Events` or `Gait Events with Clean Foot Strikes` (for force plate events).
* All completed .xlsx files will appear in the provided `Output` -> `Gait_Events` or `Gait_Events_Strikes` Folder

### Gait Analysis
* Run app.m  and select `R01 Analysis`
* Follow the prompts for selecting you AP direction and what subjects you would like to test
* Ouput will appear `Output` -> `R01_Analysis`

## Setting up and Running Obstacle Crossing 
* Download this repo by either cloning it using GitHub or clicking `<> Code` -> `Download ZIP`
* Take your Vicon export csvs and put them in the `Data` folder provided. The structure should look like `Data` Folder -> `SubjectID` Folder (You will need to create this) -> `Trial` Files .csv
* Run app.m and select `Obstacle Crossing Outcomes`
* Ouput will appear `Output` -> `Obstacle_Crossing`





