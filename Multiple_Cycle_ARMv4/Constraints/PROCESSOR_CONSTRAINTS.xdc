########################################################
# ZedBoard Pin Assignments
########################################################
# CLK - Zedboard 121.9MHz oscillator
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports CLK]

########################################################
##ZedBoard Timing Constraints
########################################################
# define clock and period
create_clock -period 8.200 -name CLK -waveform {0.000 4.100} [get_ports CLK]

#Set Output registers to IOB
#set_property IOB TRUE [all_outputs]