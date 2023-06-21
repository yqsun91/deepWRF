# deepWRF  (part of [DataWave](https://datawaveproject.github.io/) project)
This is a tutorial for using WRF (Deep configuration with model top at 1 Pa) to generate high resolution simulation of GWs.

WRF is a very good community model. This tutorial is based on many online materials. Here are just a few references that should be useful for understanding the WRF system.

[WRF user Guide (**"the" guide for running WRF**)](https://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/v4.2/WRFUsersGuide_v42.pdf)

[WRF online tutorial (official)](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/index.php)

[WRF Tech Note (Model equation and Physics)](https://opensky.ucar.edu/islandora/object/opensky:2898)

In this tutorial, I mainly focus on the part that is related to DeepWave project. Nonetheless, the statements here are based on my personal experience of running the model only.


# Basic Steps for running WRF


**1. data preparation**
    
WRF is a regional model. After we decide the domain location and the simulation period, we need to provide initial condition (IC) and boundary condition (BC) for the simulation. The IC and BC usually come from global re-analysis data. In our example, we use ERA5 data (137 model level, with model top also set 1 Pa). The model top of WRF is limited by the top boundary of the global re-analysis data.

ERA5 data can be downloaded from the Climate Data Store (CDS) https://cds.climate.copernicus.eu/#!/home
There is detailed instruction on this here. https://confluence.ecmwf.int/display/CKB/How+to+download+ERA5

*I will work on more details regarding our application in the upcoming days.

One sample Python script I am using for downloading ERA5 file.

    # This is for model-level data
    
    import cdsapi
    c = cdsapi.Client()
    c.retrieve('reanalysis-era5-complete',{
        'class':'ea',
        'date':'xxxxxxxx',
        'area':'90/-180/-90/180',
        'expver':'1',
        'levelist': '1/to/137',
        'levtype':'ml',
        'param':'129/130/131/132/133/152',
        'stream':'oper',
        'time':'00/to/23/by/1',
        'type':'an',
        'grid':"0.25/0.25",
    },'ERA5-xxxxxxxx-ml.grb')


    # script for surface level data
    import cdsapi
    c = cdsapi.Client()
    c.retrieve('reanalysis-era5-complete',{
        'class':'ea',
        'date':'xxxxxxxx',
        'area':'90/-180/-90/180',
        'expver':'1',
        'levtype':'sfc',
        'param':'msl/sp/skt/2t/10u/10v/2d/z/lsm/sst/ci/sd/stl1/stl2/stl3/stl4/swvl1/swvl2/swvl3/swvl4',
        'stream':'oper',
        'time':'00/to/23/by/1',
        'type':'an',
        'grid':"0.25/0.25",
    },'ERA5-xxxxxxxx-sfc.grb')

**2. Compile WRF and WPS Model**
    
We use WRF model (based on WRF version 4.0) that is modified by Chris Kruse [(Kruse et al. 2022)](https://doi.org/10.1175/JAS-D-21-0252.1)
    
[WRF source file provided by Dr. Kruse](https://drive.google.com/file/d/19nsFJ1gtRHfsx6oYj86WwuyxuTz7QDxJ/view?usp=share_link)

A detailed introduction on compiling the WRF and WPS model is also provided by NCAR.
I also put that in the [configure_compiling_WRF.pdf](https://github.com/yqsun91/deepWRF/blob/main/configure_compiling_WRF.pdf)

It could take some time to compile both in a new system.

Here I provide the script I use on Stampede2

a. script for installing required libraries on Stampede
[install_libs.sh](https://github.com/yqsun91/deepWRF/blob/main/install_libs.sh)

b. script for configure and compile WRF on Stampede2
[compile_WRF_stampede2.sh](https://github.com/yqsun91/deepWRF/blob/main/compile_WRF_stampede2.sh)


If compiled successfully, one will find wrf.exe and real.exe in the **main** folder and **run** folder.
Here is one example for the output.

    ==========================================================================
    build started:   Sun Jun 18 12:01:26 CDT 2023
    build completed: Sun Jun 18 12:46:08 CDT 2023
    
    --->                  Executables successfully built                  <---
    
    -rwx------ 1 tg882446 G-819272 51661680 Jun 18 12:46 main/ndown.exe
    -rwx------ 1 tg882446 G-819272 51705272 Jun 18 12:46 main/real.exe
    -rwx------ 1 tg882446 G-819272 50979016 Jun 18 12:46 main/tc.exe
    -rwx------ 1 tg882446 G-819272 58497392 Jun 18 12:44 main/wrf.exe
    
    ==========================================================================




**After** WRF is compiled, then WPS can be compiled fairly easily. Any version of WPS after 4.0 released by NCAR will be good as no modification is made for WPS.

You will get geogrid.exe, ungrib.exe, and metgrid.exe after WPS is successfully compiled.




**3. Running WPS**

WPS is short for WRF Pre-Processing System. It prepares the input to WRF for real-data simulations. 
Here is the figure from NCAR for understanding.

<img width="833" alt="Screenshot 2023-06-18 at 12 25 21 PM" src="https://github.com/yqsun91/deepWRF/assets/85260799/d4cc78ab-8211-454d-91f5-0a3783b06514">

All the parameters are set in namelist.wps

a. GEOGRID

change namelist.wps to set the domain. More on this in WRF user guide released by NCAR

run geogrid.exe

b. UNGRIB

link downloaded ERA5 file (need some processing)

link correct Vtable (IMPORTANT)

[Vtable_for_ERA5_ml](https://github.com/yqsun91/deepWRF/blob/main/Vtable_for_ERA5_ml)

run ungrib.exe (do not support parrallal, use 1 processor for this)

If ERA5 model level data is used, use ecmwf_coeffs and then run ./calc_ecmwf_p.exe

c. METGRID 

change METGRID.TBL

Kruse et al. 2022 have more details on this, changing the default sixteen point averaging to 4 point averaging when doing the interpolation helps remove the unphysical extrapolation, especially in regions with complex terrain

run metgrid.exe



**4. Running real.exe to generate IC/BC**

**Modify the namelist.input** before running real.exe.

The namelist.input file, in my personal opinion, is the most important file for running WRF simulations. It contains all the setting for runing WRF. A detailed description of this file can be found [here](https://esrl.noaa.gov/gsd/wrfportal/namelist_input_options.html)



**5. Running wrf.exe**



# A few Tricks

**1. saving I/O time**
   
Output file on each processer and join them later
  
  
**2. Model stability**
   
   a. METGRID.TBL file
   
   replace sixteen point average to 4 point average

   b. cfl instability
   
   There is not many options for this one. One can only reduce time-step if cfl is the casue of model crash.

   c. wrffdda file
   
   It is possible to have unphysical values in wrffdda file sometimes. It is a good practice to check all the variables (especially Q humidity) are reasonable (1e-6 < Q < 0.03)
   

   d. terrain
   
   use epssm between 0.3-0.5 when handling complex terrain with large gradient.

**3. Domain Size limit**

When using ERA5, it seems that real.exe have issues processing large domain (over 2000 x 2000 for example).

The error message is like


    -------------- FATAL CALLED ---------------
    FATAL CALLED FROM FILE: <stdin> LINE: 1199
    p_top_requested < grid%p_top possible from data
    -------------------------------------------

This is misleading. It should be a memory issue.


