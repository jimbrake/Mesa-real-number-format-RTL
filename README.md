## The Mesa format is a variation on IEEE 754 that supports gradual overflow.  
### Its taper diagram has linear tapers on both ends.  
### It can be configured to support the Gustafson criteria.  
### Or by giving up binary monotonicity, eliminate the need for fraction shifters in its load/store CODECs.  

## The pedestal directories have RTL and vivado project files for 16-bit pedestal memory format  
### NS_ld_pedestal16  no shifter, standard load  
### NSHld_pedestal16  no shifter, HUB format load  
### NS_st_pedestal16  no shifter, standard store: round ties-to-even  
### NSHst_pedestal16  no shifter, HUB format store: chop with implicit trailing one bit  
## The Wide Mesa directories have RTL and vivado project files for 16-bit wide memory format  



