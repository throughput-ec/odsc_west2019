#########################
# Makefile
# Simon Goring
#########################

localmake: 
	reveal-md sgoring_osdc_annotation.md --css src/sjg_custom.css

localweb: 
	reveal-md sgoring_osdc_annotation.md --css src/sjg_custom.css --static _site

localpdf: 
	reveal-md sgoring_osdc_annotation.md --css src/sjg_custom.css --print sgoring_odsc2019.pdf

