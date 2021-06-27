//ESS.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

# define OOT_MAX 80
# define BOUNDARY 39

extern const PROGMEM char one_dimensional_map[];

extern const PROGMEM char triangular_map[];

void gc_to_n64(uint8_t coords[2]);

uint16_t triangular_to_linear_index(uint8_t row, uint8_t col, uint8_t size);

void invert_vc(uint8_t coords[2]);

void invert_vc_gc(uint8_t coords[2]);

void invert_vc_n64(int8_t coords[2], uint8_t ucoords[2]);

void normalize_origin(uint8_t coords[2], uint8_t origin[2]);

void N64toGC_buttonMap_Simple(const N64_Report_t& N64report, Gamecube_Report_t& GCreport);

void N64toGC_buttonMap_OOT(const N64_Report_t& N64report, Gamecube_Report_t& GC_report);

void N64toGC_buttonMap_Yoshi(const N64_Report_t& N64report, Gamecube_Report_t& GC_report);
