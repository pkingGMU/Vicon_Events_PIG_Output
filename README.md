# Vicon_Events_PIG_Output

Authors: Patrick King

## Overview

This project processes and analyzes `.csv` files exported by **Vicon**, using various signal and motion analysis techniques in MATLAB. It is designed to help users extract meaningful insights from motion capture data with minimal technical setup.

## What It Does

The project provides a user-friendly pipeline to parse `.csv` files from Vicon and perform different types of processing and analysis. It was created with non-coders in mind to be used in the GMU Smart Lab.

# Vicon Output PIG Output

## Installation

### Option 1: GitHub Users (Familiar with Git)

1. Open your terminal or command prompt.
2. Clone the repository:
   ```bash
   git clone https://github.com/pkingGMU/Vicon_Events_PIG_Output.git
   ```
3. Open MATLAB and navigate to the cloned project folder.

### Option 2: Non-GitHub Users (Unfamiliar with Git)

1. Visit the GitHub page: [https://github.com/pkingGMU/Vicon\_Events\_PIG\_Output](https://github.com/pkingGMU/Vicon_Events_PIG_Output)
2. Click the green **Code** button and choose **Download ZIP**.
3. Extract the ZIP file to a location on your computer.
4. Open MATLAB and navigate to the extracted project folder.

## How to Use

### 1. Organize Your Data

Place your `.csv` files inside the `Data` folder following this structure:

```
Data/
  └── SubjectName/
        └── TrialName.csv
```

Each trial should be a separate `.csv` file inside its respective subject folder.

### 2. Launch the Application

Open MATLAB and make sure you are in the project directory. Then run:
```matlab
app
```
This will start the application interface.

### 3. Importing Data

Once the application is open, navigate to:
```
File -> Import Data
```

There are four main import options. Please follow the instructions carefully for each:

- **Import Single Trial**: Select only one `.csv` file from a single trial.
- **Import Multiple Trials**: Select multiple `.csv` files from different trials within the same subject folder.
- **Import Single Subject**: Select one subject folder containing multiple trial files.
- **Import Multiple Subjects**: Select multiple subject folders, each containing their respective trial files.

> Be sure to only select the correct number of trials or folders as indicated by each import option. The application does not check for import mismatches and may not function as expected if the wrong number or type of files is selected.

### 4. Navigating Subjects and Trials

After importing, the **Subjects** panel will populate with the subjects you selected. Clicking on a subject name will:
- Display the associated trials in the **Trials** panel
- Populate the **Subject Info** panel with relevant metadata

Similarly, clicking on a trial in the **Trials** panel will populate the **Trial Info** panel with detailed information about that trial.

---

### 5. Processing Trials

Before running any parsing or analysis, **you must enter the correct frame rate (FR)** of the trial in the provided frame rate input field within the application.

- If using **batch processing**, make sure that **all selected trials have the same frame rate** to avoid errors or inconsistencies.


Each trial listed in the **Trials** panel shows its processing status:
- **Green** means the specific analysis or parser has already been run.
- **Red** means the process has *not* been run.
- The label will also indicate "Run" or "Not Run" accordingly.

If a trial has not been processed yet, a button will appear allowing you to run the corresponding analysis for that selected trial directly.

If you want to batch process multiple trials, you can:
- Add selected trials from the **Trials** panel to the **Ready to Process** panel
- Click the **Batch Processing** button

This will automatically run the selected parser or analysis on all trials in the Ready to Process panel.

---

## Requirements

- MATLAB (version TBD)
- Signal Processing Toolbox

### CSV File Requirements

To work correctly with this project, each `.csv` file exported from Vicon must include the following sections:

- **Devices** section
- **Model Outputs** section
- **Trajectories** section

The following is optional but recommended:

- **Force Plate Data** – required if you want to analyze clean foot strike data

> Note: An **Events** section is *not required* in the Vicon export.

- MATLAB (version TBD)
- Signal Processing Toolbox

## Saving and Loading Sessions

The application provides functionality to **save** your current session and **load** it later. This helps preserve your imported data, processing states, and analysis results between MATLAB sessions.

- When saving, be sure to use the `.mat` file format.
- To load a saved session, use the appropriate option from the File menu.

---

## Notes

- Please ensure your `.csv` files are in the correct format as exported by Vicon.
- More details and functionality breakdowns will be added here as the project grows.

---

*This README is a living document. Updates will be made as more features are added or clarified.*



