# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BURST_SIZE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_M00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FILTER_OUT_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FILTER_SHIFT_BITS" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "HBP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HFP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HPIXELS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HSW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HSYNC_POLARITY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PITCH_PERIOD_BITS" -parent ${Page_0}
  set VBP [ipgui::add_param $IPINST -name "VBP" -parent ${Page_0}]
  set_property tooltip {LCD Vertical Back Porch} ${VBP}
  set VFP [ipgui::add_param $IPINST -name "VFP" -parent ${Page_0}]
  set_property tooltip {LCD Vertical Front Porch} ${VFP}
  ipgui::add_param $IPINST -name "VOLUME_PERIOD_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VPIXELS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VSW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VSYNC_POLARITY" -parent ${Page_0}


}

proc update_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to update BURST_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to validate BURST_SIZE
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH { PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH } {
	# Procedure called to update C_M00_AXI_ARUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH { PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH } {
	# Procedure called to validate C_M00_AXI_ARUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH { PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH } {
	# Procedure called to update C_M00_AXI_AWUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH { PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH } {
	# Procedure called to validate C_M00_AXI_AWUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_BURST_LEN { PARAM_VALUE.C_M00_AXI_BURST_LEN } {
	# Procedure called to update C_M00_AXI_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_BURST_LEN { PARAM_VALUE.C_M00_AXI_BURST_LEN } {
	# Procedure called to validate C_M00_AXI_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_BUSER_WIDTH { PARAM_VALUE.C_M00_AXI_BUSER_WIDTH } {
	# Procedure called to update C_M00_AXI_BUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_BUSER_WIDTH { PARAM_VALUE.C_M00_AXI_BUSER_WIDTH } {
	# Procedure called to validate C_M00_AXI_BUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to update C_M00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_ID_WIDTH { PARAM_VALUE.C_M00_AXI_ID_WIDTH } {
	# Procedure called to update C_M00_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_ID_WIDTH { PARAM_VALUE.C_M00_AXI_ID_WIDTH } {
	# Procedure called to validate C_M00_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_RUSER_WIDTH { PARAM_VALUE.C_M00_AXI_RUSER_WIDTH } {
	# Procedure called to update C_M00_AXI_RUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_RUSER_WIDTH { PARAM_VALUE.C_M00_AXI_RUSER_WIDTH } {
	# Procedure called to validate C_M00_AXI_RUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to update C_M00_AXI_TARGET_SLAVE_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to validate C_M00_AXI_TARGET_SLAVE_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_WUSER_WIDTH { PARAM_VALUE.C_M00_AXI_WUSER_WIDTH } {
	# Procedure called to update C_M00_AXI_WUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_WUSER_WIDTH { PARAM_VALUE.C_M00_AXI_WUSER_WIDTH } {
	# Procedure called to validate C_M00_AXI_WUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FILTER_OUT_BITS { PARAM_VALUE.FILTER_OUT_BITS } {
	# Procedure called to update FILTER_OUT_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FILTER_OUT_BITS { PARAM_VALUE.FILTER_OUT_BITS } {
	# Procedure called to validate FILTER_OUT_BITS
	return true
}

proc update_PARAM_VALUE.FILTER_SHIFT_BITS { PARAM_VALUE.FILTER_SHIFT_BITS } {
	# Procedure called to update FILTER_SHIFT_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FILTER_SHIFT_BITS { PARAM_VALUE.FILTER_SHIFT_BITS } {
	# Procedure called to validate FILTER_SHIFT_BITS
	return true
}

proc update_PARAM_VALUE.HBP { PARAM_VALUE.HBP } {
	# Procedure called to update HBP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HBP { PARAM_VALUE.HBP } {
	# Procedure called to validate HBP
	return true
}

proc update_PARAM_VALUE.HFP { PARAM_VALUE.HFP } {
	# Procedure called to update HFP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HFP { PARAM_VALUE.HFP } {
	# Procedure called to validate HFP
	return true
}

proc update_PARAM_VALUE.HPIXELS { PARAM_VALUE.HPIXELS } {
	# Procedure called to update HPIXELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HPIXELS { PARAM_VALUE.HPIXELS } {
	# Procedure called to validate HPIXELS
	return true
}

proc update_PARAM_VALUE.HSW { PARAM_VALUE.HSW } {
	# Procedure called to update HSW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HSW { PARAM_VALUE.HSW } {
	# Procedure called to validate HSW
	return true
}

proc update_PARAM_VALUE.HSYNC_POLARITY { PARAM_VALUE.HSYNC_POLARITY } {
	# Procedure called to update HSYNC_POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HSYNC_POLARITY { PARAM_VALUE.HSYNC_POLARITY } {
	# Procedure called to validate HSYNC_POLARITY
	return true
}

proc update_PARAM_VALUE.PITCH_PERIOD_BITS { PARAM_VALUE.PITCH_PERIOD_BITS } {
	# Procedure called to update PITCH_PERIOD_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PITCH_PERIOD_BITS { PARAM_VALUE.PITCH_PERIOD_BITS } {
	# Procedure called to validate PITCH_PERIOD_BITS
	return true
}

proc update_PARAM_VALUE.VBP { PARAM_VALUE.VBP } {
	# Procedure called to update VBP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VBP { PARAM_VALUE.VBP } {
	# Procedure called to validate VBP
	return true
}

proc update_PARAM_VALUE.VFP { PARAM_VALUE.VFP } {
	# Procedure called to update VFP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VFP { PARAM_VALUE.VFP } {
	# Procedure called to validate VFP
	return true
}

proc update_PARAM_VALUE.VOLUME_PERIOD_BITS { PARAM_VALUE.VOLUME_PERIOD_BITS } {
	# Procedure called to update VOLUME_PERIOD_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VOLUME_PERIOD_BITS { PARAM_VALUE.VOLUME_PERIOD_BITS } {
	# Procedure called to validate VOLUME_PERIOD_BITS
	return true
}

proc update_PARAM_VALUE.VPIXELS { PARAM_VALUE.VPIXELS } {
	# Procedure called to update VPIXELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VPIXELS { PARAM_VALUE.VPIXELS } {
	# Procedure called to validate VPIXELS
	return true
}

proc update_PARAM_VALUE.VSW { PARAM_VALUE.VSW } {
	# Procedure called to update VSW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VSW { PARAM_VALUE.VSW } {
	# Procedure called to validate VSW
	return true
}

proc update_PARAM_VALUE.VSYNC_POLARITY { PARAM_VALUE.VSYNC_POLARITY } {
	# Procedure called to update VSYNC_POLARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VSYNC_POLARITY { PARAM_VALUE.VSYNC_POLARITY } {
	# Procedure called to validate VSYNC_POLARITY
	return true
}


proc update_MODELPARAM_VALUE.BURST_SIZE { MODELPARAM_VALUE.BURST_SIZE PARAM_VALUE.BURST_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BURST_SIZE}] ${MODELPARAM_VALUE.BURST_SIZE}
}

proc update_MODELPARAM_VALUE.HPIXELS { MODELPARAM_VALUE.HPIXELS PARAM_VALUE.HPIXELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HPIXELS}] ${MODELPARAM_VALUE.HPIXELS}
}

proc update_MODELPARAM_VALUE.VPIXELS { MODELPARAM_VALUE.VPIXELS PARAM_VALUE.VPIXELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VPIXELS}] ${MODELPARAM_VALUE.VPIXELS}
}

proc update_MODELPARAM_VALUE.HBP { MODELPARAM_VALUE.HBP PARAM_VALUE.HBP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HBP}] ${MODELPARAM_VALUE.HBP}
}

proc update_MODELPARAM_VALUE.VBP { MODELPARAM_VALUE.VBP PARAM_VALUE.VBP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VBP}] ${MODELPARAM_VALUE.VBP}
}

proc update_MODELPARAM_VALUE.HSW { MODELPARAM_VALUE.HSW PARAM_VALUE.HSW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HSW}] ${MODELPARAM_VALUE.HSW}
}

proc update_MODELPARAM_VALUE.VSW { MODELPARAM_VALUE.VSW PARAM_VALUE.VSW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VSW}] ${MODELPARAM_VALUE.VSW}
}

proc update_MODELPARAM_VALUE.HFP { MODELPARAM_VALUE.HFP PARAM_VALUE.HFP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HFP}] ${MODELPARAM_VALUE.HFP}
}

proc update_MODELPARAM_VALUE.VFP { MODELPARAM_VALUE.VFP PARAM_VALUE.VFP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VFP}] ${MODELPARAM_VALUE.VFP}
}

proc update_MODELPARAM_VALUE.HSYNC_POLARITY { MODELPARAM_VALUE.HSYNC_POLARITY PARAM_VALUE.HSYNC_POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HSYNC_POLARITY}] ${MODELPARAM_VALUE.HSYNC_POLARITY}
}

proc update_MODELPARAM_VALUE.VSYNC_POLARITY { MODELPARAM_VALUE.VSYNC_POLARITY PARAM_VALUE.VSYNC_POLARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VSYNC_POLARITY}] ${MODELPARAM_VALUE.VSYNC_POLARITY}
}

proc update_MODELPARAM_VALUE.PITCH_PERIOD_BITS { MODELPARAM_VALUE.PITCH_PERIOD_BITS PARAM_VALUE.PITCH_PERIOD_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PITCH_PERIOD_BITS}] ${MODELPARAM_VALUE.PITCH_PERIOD_BITS}
}

proc update_MODELPARAM_VALUE.VOLUME_PERIOD_BITS { MODELPARAM_VALUE.VOLUME_PERIOD_BITS PARAM_VALUE.VOLUME_PERIOD_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VOLUME_PERIOD_BITS}] ${MODELPARAM_VALUE.VOLUME_PERIOD_BITS}
}

proc update_MODELPARAM_VALUE.FILTER_OUT_BITS { MODELPARAM_VALUE.FILTER_OUT_BITS PARAM_VALUE.FILTER_OUT_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FILTER_OUT_BITS}] ${MODELPARAM_VALUE.FILTER_OUT_BITS}
}

proc update_MODELPARAM_VALUE.FILTER_SHIFT_BITS { MODELPARAM_VALUE.FILTER_SHIFT_BITS PARAM_VALUE.FILTER_SHIFT_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FILTER_SHIFT_BITS}] ${MODELPARAM_VALUE.FILTER_SHIFT_BITS}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR}] ${MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_BURST_LEN { MODELPARAM_VALUE.C_M00_AXI_BURST_LEN PARAM_VALUE.C_M00_AXI_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_BURST_LEN}] ${MODELPARAM_VALUE.C_M00_AXI_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_ID_WIDTH { MODELPARAM_VALUE.C_M00_AXI_ID_WIDTH PARAM_VALUE.C_M00_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_AWUSER_WIDTH { MODELPARAM_VALUE.C_M00_AXI_AWUSER_WIDTH PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_AWUSER_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_AWUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_ARUSER_WIDTH { MODELPARAM_VALUE.C_M00_AXI_ARUSER_WIDTH PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_ARUSER_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_ARUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_WUSER_WIDTH { MODELPARAM_VALUE.C_M00_AXI_WUSER_WIDTH PARAM_VALUE.C_M00_AXI_WUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_WUSER_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_WUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_RUSER_WIDTH { MODELPARAM_VALUE.C_M00_AXI_RUSER_WIDTH PARAM_VALUE.C_M00_AXI_RUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_RUSER_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_RUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_BUSER_WIDTH { MODELPARAM_VALUE.C_M00_AXI_BUSER_WIDTH PARAM_VALUE.C_M00_AXI_BUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_BUSER_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_BUSER_WIDTH}
}

