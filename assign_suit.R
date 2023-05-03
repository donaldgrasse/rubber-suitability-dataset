#a function to assign a suitability score based on a pre-defined covariate 

#the function takes as arguments 
#data - a data frame (if it is saved as an sf object the code will coerce the object to a data.frame)
#var - the variable that suitability analysis is being conducted for 

#the next four parameters are the optimum and absolute tolerance for the crop in question 
#these values can be obtained from https://gaez.fao.org/pages/ecocrop-find-plant

#the output of the function is a suitability score scaled from 0-1, where 1 
#is ideal conditions and 0 is unsuitable. 

assign_suit = function(data, var, op_max, op_min, t_max, t_min){ 
  
  data = as.data.frame(data) %>% 
    dplyr::select(var) 
  
  colnames(data2)[1] = 'var'
  
  data2$suit = ifelse(data$var > op_max | 
                        data$var < t_min, 0, NA)
  data2$suit = ifelse(pop_min <= data$var & data$var <= op_max, 1,0)
  data2$suit = ifelse(op_max < data$var & data$var < p_max, 
                      (t_max - data$var)/(t_max-op_max),
                      data2$suit
  )
  data2$suit = ifelse(p_min < data$var & data$var < pop_min, 
                      (data$var - p_min)/(pop_min-p_min),
                      data$suit
  )
  
  return(data$suit)
  
}
