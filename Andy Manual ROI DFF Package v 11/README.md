Instructions

For simple analysis of dF/F from an 8-bit multitiff--

1) First, convert whatever your image is to 8-bit .tiff in FIJI

2) Perform any registration if necessary (i.e. x/y movement correction) using StackReg, then save your new .tiff. IMPORTANT: the code is looking for a filename of the format "XXX Y.tiff" where XXX can be whatever, the space MUST be present, and Y is a number. This will be important later and save you some agony.

3) Using the polygon tool and the ROI manager in FIJI, select ROIs. You MUST use the polygon tool.

4) Save your ROIs as a .roi file (you do this from the ROI manager).

5) Repeat if you want to have multiple "sets" (i.e. dorsal and ventral CSF-cNs) in your analysis. The ensuing code will treat the different sets differently and group them with each other. Save each set of ROIs as a seperate .roi file.

6) In Matlab, run apmask2.m. It will prompt you to select a file, first select your .tiff. It will then prompt you again to select a file. Shift-click to select all .roi files you want to use for this .tiff

7) The code will now run and generate a binary mask and some other variables. Don't fuck around with other windows and stuff during this time as Matlab will use a screengrab function several times to generate the mask.

8) Now run apdff2.m. If everything is cool, individual dF/F plots will individually pop up. You are being prompted using the ginput function of Matlab to select a F0 interval. Select TWO points from left to right of an area where the cell is not active, then press enter.

9) Repeat until you run out of cells.

10) The script will generate: a map of your ROIs superimposed over the .tiff stack, a grouped cell plot, an individual cell plot (i.e. the "Joy Division" plot), and a data.m file. These will automatically be saved in a new folder in your Matlab directory called "Y", where "Y" is the number in your .tiff filename, see how nice that is?!

Known Issues

1) The code doesn't like pointy ROIS, if they are too pointy, individual pixels get segregated from their ROI, the code detects them as separate ROIs, and the code will throw an error about a mismatch in nROIs or something like that.

2) The code also doesn't like overlapping ROIs for the same reason as above.

3) Sometimes the code fails to detect a baseline for autobleaching correction and everything gets screwed up. This can be fixed by turning down the delta value in line 46.
