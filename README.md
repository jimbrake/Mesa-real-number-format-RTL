### The Mesa format is a variation on IEEE 754 that supports gradual overflow.  
#### Its taper diagram has linear tapers on both ends.  
#### It can be configured to support the Gustafson criteria.  
#### Or by giving up binary monotonicity, eliminate the need for fraction shifters in its load/store CODECs.  

### The pedestal directories have RTL and vivado project files for 16-bit pedestal memory format  
#### NS_ld_pedestal16  no shifter, standard load  
#### NSHld_pedestal16  no shifter, HUB format load  
#### NS_st_pedestal16  no shifter, standard store: round ties-to-even  
#### NSHst_pedestal16  no shifter, HUB format store: chop with implicit trailing one bit  

### Wide Mesa directories have RTL and vivado project files for 16-bit wide memory format  
#### NS_ld_wMesa6-16  no shifter, standard load  
#### NSHld_wMesa6-16  no shifter, HUB format load: implicit trailing HUB bit made explicit  

### Narrow Mesa directories have RTL and vivado project files for 16-bit narrow memory format  
#### NS_ld_nMesa6-16  no shifter, standard load  
#### NSHld_nMesa6-16  no shifter, HUB format load: implicit trailing HUB bit made explicit  
#### NS_st_nMesa-16  no shifter, standard store: round ties-to-even void at this time  
#### NSHst_nMesal16  no shifter, HUB format store: chop with implicit trailing one bit  

### Multiplier runs with timing constraints of 3.0 and 4.0ns  
#### mult9_13_3ns_run and mult9_13_4ns_run  


