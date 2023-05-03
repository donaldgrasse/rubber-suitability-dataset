
#packages 
packs = c('raster', 'dplyr', 'sf', 'purrr') 
lapply(packs, require, character.only = T) 

#----------------------------------------------------------------------------------------------------------------------------------------------
#we will now construct the data set of suitability for the Hevea brasiliensis (rubber) crop 
#in Southern Thailand

#### Define Suitability Parameters #### 
#first, query the parameter values from ECOCROP (https://gaez.fao.org/pages/ecocrop-find-plant) 
#define them below
#we will focus on soil ph, temperature, precipitation, and elevation, 
#but one can use other parameters (soil salinity, soil depth, latitude)

#rain suitability 
p_max = 6000 
p_min = 1200
pop_max = 4000
pop_min = 2000

#temperature suitability 
t_max = 45
t_min = 10
top_max = 33
top_min = 24

#soil ph suitability 
sop_max = 6
sop_min = 4.5
s_max = 8
s_min = 3.5

#### define the study area ####

tha_grid = read_sf(dsn = 'tha_adm_rtsd_itos_20210121_shp/tha_admbnda_adm3_rtsd_20220121.shp') %>% 
  filter(ADM1_EN == 'Pattani' | ADM1_EN == 'Yala' | ADM1_EN == 'Narathiwat') %>% 
  st_make_grid(cellsize = .01) %>% st_sf %>% 
  mutate(lon = as.numeric(purrr::map_chr(st_centroid(geometry), 1), 
         lat =  as.numeric(purrr::map_chr(st_centroid(geometry), 2)) 

tha_0 = read_sf(dsn = 'tha_adm_rtsd_itos_20210121_shp/tha_admbnda_adm3_rtsd_20220121.shp') %>% 
  filter(ADM1_EN == 'Pattani' | ADM1_EN == 'Yala' | ADM1_EN == 'Narathiwat') %>% 
  summarise(doUnion = T)
  
tha_grid = tha_grid |> 
    mutate(grid_in_land = as.numeric(st_distance(., tha_0), 
           grid_in_land = as.numeric(grid_in_land == 0, 1,0)) |> 
    filter(grid_in_land == 1)       

#### join rasters with grid #### 
r = getData("worldclim",var="bio",res=.5, lon=tha_grid$lon, lat=tha_grid$lat)
r <- r[[c(1,12)]]

tha_sp = as_Spatial(tha_grid)
values <- extract(r,tha_sp,fun=mean)
values_NA <- extract(r,tha_sp,fun=mean, na.rm = T, method = 'bilineal')

srtm = raster('/Users/donaldgrasse/Dropbox/cambodia proj/250m/SRTM_NE_250m_TIF/SRTM_NE_250m.tif')
mean_elev <- extract(srtm,tha_sp,fun=mean, na.rm = T, method = 'bilineal')

ph = raster('soilPH/out.tif')
mean_ph5<- extract(ph,tha_sp,fun=mean, na.rm = T, method = 'bilineal')

tha_grid = cbind.data.frame(tha_grid, values_NA, mean_elev, mean_ph5)

tha_grid$temp_mean = tha_grid$bio1_29/10
tha_grid$rain_mean = tha_grid$bio12_29

tha_grid = tha_grid %>%  
  mutate(
    prec_suit = assign_suit(., 'rain_mean', pop_max, pop_min, p_max, p_min), 
    temp_suit = assign_suit(., 'tem_mean', pop_max, pop_min, p_max, p_min)
    ph_suit = assign_suit(., 'mean_ph5', sop_max, sop_min, s_max, s_min)
    elev_suit = if_else(mean_elev < 500, 1,0)
    rubber_suit = prec_suit*temp_suit*ph_suit*elev_suit
  )

#### Convert to a Raster ####  
tha_grid = tha_grid |> 
  dplyr::select(rubber_suit, lat, lon) 

coordinates(tha_grid) <- ~ lat + lon
gridded(tha_grid) <- TRUE
rasterDF <- raster(tha_grid)
rasterDF


