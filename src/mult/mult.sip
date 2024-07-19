set_global_assignment -entity "mult" -library "lib_mult" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "mult" -library "lib_mult" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "mult" -library "lib_mult" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_mult" -name SPD_FILE [file join $::quartus(sip_path) "mult.spd"]

set_global_assignment -library "lib_mult" -name MISC_FILE [file join $::quartus(sip_path) "mult_sim/mult.vo"]
