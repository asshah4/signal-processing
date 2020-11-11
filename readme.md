# Heart rate variability (HRV)

## Tools
### MATLAB

Using the Physionet HRV Toolbox, available on MATLAB. Will be using this for analysis of data from ECG patch systems, such as MC10 and Biostamp. The MATLAB toolbox is open-source. Has time, frequency, and non-linear domain creation.

### R

HRV package also available in R, called [RHRV](http://rhrv.r-forge.r-project.org/). Currently unfamiliar with how it compares to other mechanisms of measuring HRV (and whether it takes alternative signal, e.g. PPG or BP time series).

### Python

Python package is available as well called [hrvanalysis](https://pypi.org/project/hrv-analysis/). Built on SciPy, AstroPy, NumPy. Not familiar myself with utility.

### Closed source options

- [Kubios](https://www.kubios.com/): haven't used, not sure of quality, aimed at sports/athletic HRV
- [HRVAnalysis](https://anslabtools.univ-st-etienne.fr/en/index.html): developed via MATLAB, but is free-standing software, appears to be aimed at research/ANS measurements
- [SinusCor](http://rhenanbartels.github.io/SinusCor/): haven't used, free
- [ACKHRV](https://www.biopac.com/product/heart-rate-variability-analysis-software/): paid software, not clear of quality

## Input

The input system is limited to two equal-length vectors. RR intervals in seconds and time series information in seconds is needed. Alternatively, can use raw ECG signal with sampling frequency.

## VivaLNK

This may be the most commonly used mechanism for obtaining RR intervals for the current project. They have a complex format of producing the data (text file from the log that contains much more than just RR and time series).

### File Format

File Format - every line separated by Newline

  SampleData{} <- contains date and time
  RWL <- unsure what this is
  RRI <- contains RR interval
  ECG <- raw ECG signal amplitude in milivolts (?)
  XYZ <- accelorometer data in 3D space (x, y, z axis)

Sample format is...

  SampleData{time=1565027207098, date=2019/08/05 13:46:47.098, leadOn=true, flash=true, HR=88, RR=0.0, activity=false, magnification=1000}
  RWL : -1, -1, -1, -1, -1
  RRI : 0, 0, 0, 0, 0
  ECG : -4, 1, -1, 2, 7, 7, 10, 12, 11, 6, 4, 4, 2, 4, 8, 7, 5, 5, 8, 6, 5, 2, -2, -1, 1, 1, 3, 1, 3, 1, 3, 5, 6, 3, 4, 4, 6, 10, 11, 15, 12, 7, 9, 4, 2, 5, 8, 2, 4, 5, 10, 17, -12, -67, -72, 9, 100, 101, 75, 70, 71, 53, 20, 1, -7, -11, -10, -6, -13, -14, -16, -14, -12, -14, -17, -18, -10, -9, -14, -13, -12, -6, -8, -7, 0, 0, 5, 6, 13, 13, 6, 3, -1, 4, 2, -3, -10, -4, -6, -2, -9, -10, -10, -15, -18, -13, -18, -17, -16, -24, -25, -14, -19, -23, -29, -33, -35, -27, -33, -29, -26, -27, -30, -44, -41, -34, -44, -38
  XYZ : acc = 5
  -1624 1200 -77, -1630 1193 -92, -1643 1194 -102, -1640 1184 -115, -1650 1151 -121

### Patch Application

VivaLNK has an SDK app for androids (and for iPhones) for cnotrolling the device. Its bluetooth-connected. App is in this folder (but just the android one).

# Global electrical heterogeneity (GEH)

Looking at this in time-series data. 

# T-wave amplitude (TWA)

The code here is to analyze T wave fiducial points. This is based on single-lead analysis, and can generate not only amplitude, but T-wave shape (e.g. end-points, area, etc).

# Impedance cardiography (ICG)
## VU-DAMS

_The VU-AMS (VU University Ambulatory Monitoring System) Data, Analysis & Management Software_

This device measures multiple recordings on different channels:

- Heart Rate / Inter beat Interval (IBI)
- Heart Rate Variability (SDNN, RMSSD, IBI power spectrum: HF, LF)
- Respiratory Sinus Arrhythmia (RSA)
- Pre-Ejection Period (PEP)
- Left Ventricular Ejection Time (LVET)
- Respiration Rate (RR)
- Stroke Volume (SV) and Cardiac Output (CO)
- Skin Conductance Level (SCL) and Skin Conductance Responses (SCRs)
- Tri-Axial Accelerometry (Body Movement)

Using the BIMI dataset, will be measuring PEP using both ECG and ICG signal. All code credit goes to [Nil](https://www.nzgurel.com/). Need VUDAMS software to see/interact with the actual raw data. 


# Muscle sympathetic nerve activity (MSNA)

## Research ideas

Does BRS correlate with HRV?
How does MSNA lead to changes in BP (e.g. neuromuscular transduction)?
Are there noninvasive correlates to MSNA (e.g. LF/HF, TWA)
What are the effects of ACEI, ARB, BB on sympathovagal balance?

# Venous occlusion plethysmography (VOP)

## Logistics

Hokanson is the company that produces the VOP devices. Strong literature by Larry Sinoway and Holly Middlekauff showing association with sympathetic tone. The device itself is owned by Arshed Quyyumi here at Emory.

## Research ideas

Will venous occlusion plethysmography serve as a useful clinical measure for SNS outflow?

# Skin sympathetic nerve activity (SKNA)

## Logistics

Headed up by Dr. PS Chen at Indiana University. Known to correlate with AF and VT/VF events. The device setup guide, and videos, have been shared with our lab group.

# Holter data

## Raw Data

MARS Holter ECG system has raw binary files stores in the MIT-BIH signal format (a header and signal file), supported on by [Physionet](http://physionet.org). 

Need to assess how to read-in the .sig and .hdr filetypes, currently stored in the raw data folder.


