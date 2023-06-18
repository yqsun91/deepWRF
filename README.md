# deepWRF
This is a tutorial for using WRF (Deep configuration with model top at 1 Pa) to generate high resolution simulation of GWs.




**Basic Steps for running WRF**


1. data preparation
    WRF is regional model. After we decide the domain location and the simulation period, we need to provide initial condition (IC) and boundary condition (BC) for the simulation. The IC and BC usually come from global re-analysis data. In our example, we use ERA5 data (137 model level, with model top also set 1 Pa). The model top of WRF is limited by the top boundary of the global re-analysis data.

   ERA5 data can be downloaded from the Climate Data Store (CDS) https://cds.climate.copernicus.eu/#!/home
   There is detailed instruction on this here. https://confluence.ecmwf.int/display/CKB/How+to+download+ERA5
   I will work on more details regarding our application in the upcoming days.


2. Compile WRF and WPS Model


3. Running WPS


4. Running real.exe to generate IC/BC

5. Running wrf.exe



**A few Tricks**

1. saving I/O time
   Output file on each processer and join them later
  
  
2. Model stability
   
   a. METGRID.TBL file

   b. cfl instability

   c. wrffdda file

   d. terrain

3. Domain Size limit


