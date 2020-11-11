# VivaLink_parser
Matlab code that parses VivaLink data in .mat format.

Notes : 
ECG, Sampling rate: 128 Hz, Resolution: 16 bits, gain 1000 
Accelerometer, Sampling rate: 5 Hz Resolution: 14 bit resolution over +/- 4G range.  


## Inputs : 
          - dataDir : path to file that need to be converted
          - fileName: file name of the file to convert, without extansion (must be a '.txt' file first)
## Outputs:

           - file containing ECG signal and time stamps, saved as fileName with .mat extansion in the same directory (dir) of raw data
           - file containing 3 axis acc signal (xyz)  and time stamps, saved as structur in fileName with .mat extansion in the same directory (dir) of raw data

## Example :
             VivaLink_parser_beta('/Users/gdapoia/data', 'demo')


# Note:
	The output file will be save in matlab format, the HRV toolbox input is usually a txt raw data or WFDB format
