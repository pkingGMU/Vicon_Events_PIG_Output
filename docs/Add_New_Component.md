# Documentation: Added Outcome to GUI

## Overview
This MATLAB GUI is designed for students in a lab environment to analyze and interact with experimental data. Users interact with the GUI via a structured interface that reads and processes data stored locally in a predefined format. The GUI was recently updated to include an 'Added Outcome' feature, allowing for additional data insights.

## Data Structure and Requirements
The GUI expects data to be organized within the `Data` folder included with the application. This folder should follow this format:

```
/Data
  ├── Subject01
  │     ├── Trial1
  │     └── Trial2
  ├── Subject02
  │     └── Trial1
  └── ...
```

Each subject should have a folder containing one or more trial folders. Inside each trial folder, the data should be formatted as expected by the application (CSV, MAT, or otherwise defined format). The GUI reads from this folder structure to populate options and load data.

## Global Variable: `r01`
The primary way the GUI communicates and shares processed information across functions is through the global variable `r01`.

### Format
`r01` contains structured data accessible across the application:
- `r01.files.ready_to_process`: All trials that are available for processing.
- `r01.files.selected_trial`: The currently selected trial (as an `n x 4` matrix, each row containing subject info and CSV path).
- `r01.files.selected_subject`: The currently selected subject (same format as above).

### Example Usage
```matlab
% Accessing the currently selected trial's metadata
global r01;
selected_trial_info = r01.files.selected_trial;

% Extracting the file path from the selected trial (column 4)
csv_path = selected_trial_info{1, 4};

% Reading the CSV and calculating an outcome
trial_data = readtable(csv_path);
trial_data.outcome = calculateOutcome(trial_data);

% Optionally store processed data back into r01
r01.processed_data = trial_data;
```

## Extending the GUI
To add new features or outcomes:

### 1. Add an Outcome to the Routing System
Edit the file located at:
```
Functions -> Selection Routing -> selection_routing.m
```
Within this file, locate the main `switch` statement. Add a new `case` corresponding to the name of your outcome. This case should call your custom function and pass in the `outcome_selection` argument provided.

### 2. Register for Batch Processing
To include your new outcome in the batch processing functionality:
- Open the file:
```
Main -> Process -> process_callback.m
```
- Add the name of your outcome (the same string used in the switch statement) to the batch processing list. This ensures your code runs during multi-trial operations.

### 3. Add a Button for Manual Triggering (Optional)
To allow users to manually trigger your outcome processing from the GUI:
- Find an unused trial info button within:
```
Main -> r01.gui
```
- Replace the callback function with the following:
```matlab
@(src, event) selection_routing(src, event, 'YOUR OUTCOME', 0)
```
Replace `'YOUR OUTCOME'` with the actual string used in your routing case.

### 4. Process and Store Results
Once your function is called, use the metadata in `r01.files.selected_trial` to read data, compute outcomes, and store results.

**Recommended Practice:**
- Save output files into the provided `Output` folder.
- Organize results by subject and trial within that folder.
- At the top of your function, include:
```matlab
global r01;
```
This gives you access to project-wide parameters, such as framerate and data structure.

Include UI components (buttons, tables, axes) in the GUI layout using MATLAB’s `guide`, `App Designer`, or programmatically. Link callbacks to interact with the `r01` structure appropriately.

---
Let me know what more you want added or clarified, especially around the outcome structure, callback details, or UI components.

