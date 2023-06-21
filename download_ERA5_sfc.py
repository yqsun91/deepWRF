# download ERA5 surface-level data, change xxxxxxxx to 20160801 for one day, can also do e.g., '20160801/to/20160831' for longer times 

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
