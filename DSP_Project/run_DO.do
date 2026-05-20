vlib work
vlog FFmux_DSP.v DSP_Project.v DSP_Project_tb.v
vsim -voptargs=+acc work.DSP_Project_tb
add wave *
run -all
#quit -sim