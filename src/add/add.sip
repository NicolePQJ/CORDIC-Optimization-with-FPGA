set_global_assignment -entity "add" -library "lib_add" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "add" -library "lib_add" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "add" -library "lib_add" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_add" -name SPD_FILE [file join $::quartus(sip_path) "add.spd"]

set_global_assignment -library "lib_add" -name MISC_FILE [file join $::quartus(sip_path) "add_sim/add.vo"]
