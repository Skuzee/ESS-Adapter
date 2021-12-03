//ESS.cpp

#include "ESS.hpp"
#include "extra.hpp"

const PROGMEM char one_dimensional_map[] = "\x00\x00\x10\x10\x11\x11\x12\x12\x13\x13\x14\x14\x15\x15\x16\x16\x16\x17\x17\x17\x18\x18\x19\x19\x1a\x1a\x1a\x1b\x1b\x1b\x1c\x1c\x1d\x1d\x1d\x1e\x1e\x1e\x1f\x1f  !!!\"\"\"###$$$%%%&&&'''((()))***+++,,,,---...///00001111222333344445555666677778888899999::::;;;;;<<<<<=====>>>>>??????@@@";
const PROGMEM char triangular_map[] = ",,-,.,.,/,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,9,:,:,;,;,<,<,<,=,=,>,>,>,?,?,?,@,--.-.-/-0-0-1-1-2-2-3-3-4-4-5-5-6-6-7-7-8-8-9-9-9-:-:-;-;-<-<-<-=-=->->->-?-?-?-@,..../.0.0.1.1.2.2.3.3.4.4.5.5.6.6.7.7.8.8.9.9.9.:.:.;.;.<.<.<.=.=.>.>.>.?-?-?-?-../.0.0.1.1.2.2.3.3.4.4.5.5.6.6.7.7.8.8.9.9.9.:.:.;.;.<.<.<.=.=.>.>.>.?-?-?-?-//0/0/1/1/2/2/3/3/4/4/5/5/6/6/7/7/8/8/9/9/9/:/:/;/;/</</</=/=/>/>/>/>/>/?-?-000010102020303040405050606070708080909090:0:0;0;0<0<0<0=0=0>/>/>/>/>/>/>/0010102020303040405050606070708080909090:0:0;0;0<0<0<0=0=0=0>/>/>/>/>/>/11112121313141415151616171718181919191:1:1;1;1<1<1<1=0=0=0>/>/>/>/>/>/112121313141415151616171718181919191:1:1;1;1<1<1<1<1<1=0=0>/>/>/>/>/2222323242425252626272728282929292:2:2;2;2<1<1<1<1<1<1=0=0>/>/>/>/22323242425252626272728282929292:2:2;2;2;2<1<1<1<1<1<1<1=0=0>/>/333343435353636373738383939393:3:3;3;3;3;3<1<1<1<1<1<1<1=0=0>/3343435353636373738383939393:3:3;3;3;3;3;3<1<1<1<1<1<1<1<1=044445454646474748484949494:4:4:4;3;3;3;3;3<1<1<1<1<1<1<1<1445454646474748484949494:4:4:4:4;3;3;3;3;3;3<1<1<1<1<1<1555565657575858595959595:4:4:4:4;3;3;3;3;3;3<1<1<1<1<1556565757585859595959595:4:4:4:4;3;3;3;3;3;3<1<1<1<1666676768686869595959595:4:4:4:4;3;3;3;3;3;3;3<1<1667676868686959595959595:4:4:4:4:4;3;3;3;3;3;3<1777777868686959595959595:4:4:4:4:4;3;3;3;3;3;3777777868686869595959595:4:4:4:4:4;3;3;3;3;377777786868686959595959595:4:4:4:4:4;3;3;377777786868686959595959595:4:4:4:4:4;3;377777786868686959595959595:4:4:4:4:4;377777786868686959595959595:4:4:4:4:477777786868686959595959595:4:4:4:47777778686868695959595959595:4:47777778686868695959595959595:4777777868686869595959595959577777786868686959595959595777777868686869595959595777777868686869595959577777786868686869595777777868686868695777777868686868677777786868686777777868686777777868677777786777777777777";

//smaller sized map that only goes to 67, but takes less PROGMEM
// const PROGMEM char triangular_map[] = "3343435353636373738383939393:3:3;344445454646474748484949494:4:4:4445454646474748484949494:4:4:4555565657575858595959595:4:4556565757585859595959595:4666676768686869595959595667676868686959595959577777786868695959595777777868686869595777777868686869577777786868686777777868686777777868677777786777777777777";

void gc_to_n64(uint8_t coords[2]) {
  /* Assume 0 <= y <= x <= 127

     Converts Gamecube analog stick coordinates to N64 analog stick coordinates

     Achievable range on a gamecube controller is 75 in corners and 105 straight
     N64 ranges from 70 in the corners to 80 straight. The shape is different.
     To maximize precision while allowing full range, we need to scale:
       - Straight directions to 80/105
       - Corner directions to 70/75
     Because this stretching effect warps the shape of the controller,
     we'd like to minimize our warping in the center and scale it up near edge.

     First we try to find the intersection point with the edge of the range.
       distance = (5x+2y) / 525
       closeness_to_corner = 7y / 5x+2y
     These range from 0 to 1 and derive from the formula for line intersection:
       https://gamedev.stackexchange.com/questions/44720/

     Our conversion formula becomes:
       extra_corner_scaling = 70/75-80/105
       scale = distance^3 * closeness_to_corner * extra_corner_scaling + 80/105
       return x * scale, y * scale
     The cubing of distance means we warp very little in the center.

     We implement the below formula in uint32 integer math:
       ((5x + 2y) / 525)^2 * (7y / 525) * (70/75-80/105) + 80/105
     Notice that the multiplication cancels out one factor of 5x+2y

     Writes back converted N64 coordinates to x and y on a scale of 0-255
     The doubled resolution is to help rounding when inverting the VC mapping
  */
  uint32_t scale = 5L * coords[0] + 2L * coords[1];
  if (scale > 525) {
    // Multiply by 16 here to reduce precision loss from dividing by scale
    scale = 16UL * 525 * 525 * 525 / scale; // clamp distance to 1.0
  } else {
    scale = 16 * scale * scale; // (5x + 2y)^2, leaving 525^2 to divide later.
  }

  scale *= coords[1]; // * y, leaving another 525 to divide later.

  // Now we need to divide by 525^3 and multiply by: 7 * (70/75-80/105) = 1.2
  // Double resolution so multiply by 2. And we divide by 2**24 at the end.
  // So our final multiplication factor is 525^3 / 1.2 / 2 / 2^24 ~= 32 / 115
  scale = scale * 2 / 115; // we already multiplied by an extra *16 above

  // Constants chosen so rounding errors don't affect the end result.
  scale += 25565300; // ~= 2 * 80/105 * 2^24

  // Add a bit less than 2^24 so we round up by truncating.
  // n-0.5 < box[2n]   <= n
  // n     < box[2n+1] <= n+0.5
  coords[0] = (coords[0] * scale + 16774000) >> 24;
  coords[1] = (coords[1] * scale + 16774000) >> 24;
}

void n64_to_gc_generic(const N64_Report_t& N64report, Gamecube_Report_t& GCreport) { // Converts N64 analog stick coordinates to Gamecube analog stick coordinates
  GCreport.xAxis = N64report.xAxis + 128;
  GCreport.yAxis = N64report.yAxis + 128;
}

void n64_to_gc_yoshi(const N64_Report_t& N64report, Gamecube_Report_t& GCreport) {
  // Scale and convert N64 analog stick to work with Yoshi Story menu and gameplay. Does not contain an VC ESS map at this point. Just simple scaling.

  if (N64report.xAxis * 1.2 > 127)
    GCreport.xAxis = 255;
  else if (N64report.xAxis * 1.2 < -128)
    GCreport.xAxis = 0;
  else
    GCreport.xAxis = N64report.xAxis * 1.2 + 128;

  if (N64report.yAxis * 1.2 > 127)
    GCreport.yAxis = 255;
  else if (N64report.yAxis * 1.2 < -128)
    GCreport.yAxis = 0;
  else
    GCreport.yAxis = N64report.yAxis * 1.2 + 128;
}

uint16_t triangular_to_linear_index(uint8_t row, uint8_t col, uint8_t size) {
  /* Adapted from https://math.stackexchange.com/questions/2134011

     Given index i,j of a triangular array stored as a linear 1d array
     Returns the index of the linear 1d array. Assumes col >= row (!)

     Since X and Y are symmetrical (reflected),
     we only want to store half the values.
  */
  return (size * (size - 1) / 2) - (size - row) * ((size - row) - 1) / 2 + col;
}

void invert_vc(uint8_t coords[2]) {
  /* Assume 0 <= y <= x <= 2*127 - double resolution */
  /* Approach is documented in the python implementation */
  if (coords[0] > 2 * OOT_MAX) coords[0] = 2 * OOT_MAX;
  if (coords[1] > 2 * OOT_MAX) coords[1] = 2 * OOT_MAX;

  if (coords[0] >= 2 * BOUNDARY && coords[1] >= 2 * BOUNDARY) {
    uint8_t remainder = OOT_MAX + 1 - BOUNDARY;
    coords[0] = (coords[0] / 2) - BOUNDARY;
    coords[1] = (coords[1] / 2) - BOUNDARY;
    uint16_t index = triangular_to_linear_index(coords[1], coords[0], remainder);
    coords[0] = pgm_read_byte(triangular_map + 2 * index);
    coords[1] = pgm_read_byte(triangular_map + 2 * index + 1);
  } else {
    coords[0] = pgm_read_byte(one_dimensional_map + coords[0]);
    coords[1] = pgm_read_byte(one_dimensional_map + coords[1]);
  }
}

void invert_vc_gc(uint8_t coords[2]) {
  /* Our other functions exploit symmetry to calculate only 0 <= y <= x <= 127
     So convert to the proper range and then fix the signs back up.

     Expects unsigned GC controller input x, y coordinates from 0 - 255

     Returns unsigned GC controller input x, y coordinates from 0 - 255,
     that, when mangled by VC, will give the in-game input that best matches.
  */
  int x_positive = 0;
  int y_positive = 0;
  int swap = 0;

  if (coords[0] >= 128) {
    x_positive = 1;
    coords[0] -= 128;
  } else {
    if (coords[0] == 0) coords[0] = 127;
    else coords[0] = 128 - coords[0];
  }

  if (coords[1] >= 128) {
    y_positive = 1;
    coords[1] -= 128;
  } else {
    if (coords[1] == 0) coords[1] = 127;
    else coords[1] = 128 - coords[1];
  }

  if (coords[1] > coords[0]) {
    swap = 1;
    uint8_t temp = coords[0];
    coords[0] = coords[1];
    coords[1] = temp;
  }

  gc_to_n64(coords);
  invert_vc(coords);

  if (swap) {
    uint8_t temp = coords[0];
    coords[0] = coords[1];
    coords[1] = temp;
  }

  if (x_positive) coords[0] += 128;
  else coords[0] = 128 - coords[0];
  if (y_positive) coords[1] += 128;
  else coords[1] = 128 - coords[1];
}

void invert_vc_n64(int8_t coords[2], uint8_t ucoords[2]) {
  /* Our other functions exploit symmetry to calculate only 0 <= y <= x <= 127
     So convert to the proper range and then fix the signs back up.

     Expects signed N64 controller input x, y coordinates from -128 to 127

     Returns unsigned GC controller input x, y coordinates from 0 - 255,
     that, when mangled by VC, will give the in-game input that best matches.
  */
  int x_positive = 0;
  int y_positive = 0;
  int swap = 0;

  if (coords[0] >= 0) {
    x_positive = 1;
    ucoords[0] = 2 * coords[0];
  } else {
    if (coords[0] == -128) ucoords[0] = 2 * 127;
    else ucoords[0] = -2 * coords[0];
  }

  if (coords[1] >= 0) {
    y_positive = 1;
    ucoords[1] = 2 * coords[1];
  } else {
    if (coords[1] == -128) ucoords[1] = 2 * 127;
    else ucoords[1] = -2 * coords[1];
  }

  if (ucoords[1] > ucoords[0]) {
    swap = 1;
    uint8_t temp = ucoords[0];
    ucoords[0] = ucoords[1];
    ucoords[1] = temp;
  }

  invert_vc(ucoords);

  if (swap) {
    uint8_t temp = ucoords[0];
    ucoords[0] = ucoords[1];
    ucoords[1] = temp;
  }

  if (x_positive) ucoords[0] += 128;
  else ucoords[0] = 128 - ucoords[0];
  if (y_positive) ucoords[1] += 128;
  else ucoords[1] = 128 - ucoords[1];
}

void normalize_origin(uint8_t coords[2], uint8_t origin[2]) {
  /* Gamecube controllers store the position of the analog stick when it is powered on.
     Coordinates range from 0 to 255 and are centered at 128.
     This function interprets coordinates relative to the origin, then centers the origin.
  */
  for (int i = 0; i < 2; ++i) {
    int16_t normalized = (coords[i] - 128) - (origin[i] - 128);
    if (normalized > 127) normalized = 127;
    if (normalized < -128) normalized = -128;
    coords[i] = normalized + 128;
    origin[i] = 128;
  }
}

void N64toGC_buttonMap_Generic(const N64_Report_t& N64report, Gamecube_Report_t& GCreport) { // Converts N64 controller data to Gamecube data. Button Mapping is for VC OOT / GZ Practice ROM. N64 Cbuttons mapped to Gamecube X Y Z because Practice rom uses Gamecube cdown / N64 L to fly.

  GCreport.a = N64report.a;
  GCreport.b = N64report.b;
  GCreport.start = N64report.start;
  GCreport.z = N64report.z;
  GCreport.r = N64report.r;
  GCreport.right = N64report.r * 255;
  GCreport.l = N64report.l;
  GCreport.left = N64report.l * 255;

  GCreport.cxAxis = 128 + (N64report.cright * 127) - (N64report.cleft * 127);
  GCreport.cyAxis = 128 + (N64report.cup * 127) - (N64report.cdown * 127);

  GCreport.dleft = N64report.dleft;
  GCreport.dright = N64report.dright;
  GCreport.dup = N64report.dup;
  GCreport.ddown = N64report.ddown;

  n64_to_gc_generic(N64report, GCreport);
}

void N64toGC_buttonMap_OOT(const N64_Report_t& N64report, Gamecube_Report_t& GCreport) { // Converts N64 controller data to Gamecube data. Button Mapping is for VC OOT / GZ Practice ROM. N64 Cbuttons mapped to Gamecube X Y Z because Practice rom uses Gamecube cdown / N64 L to fly.

  GCreport.a = N64report.a;
  GCreport.b = N64report.b;
  GCreport.start = N64report.start;
  GCreport.z = N64report.cdown; // Gamecube Z same as cdown.
  GCreport.r = N64report.r;
  GCreport.right = N64report.r * 255;
  GCreport.l = N64report.z;
  GCreport.left = N64report.z * 255;

  GCreport.x = N64report.cright; // Gamecube X same as cleft
  GCreport.y = N64report.cleft; // Camecube Y same as cright
  GCreport.cyAxis = 128 + (N64report.cup * 127) - (N64report.l * 127); // set cyAxis(up) to N64 cup, set cyAxis(down) to N64 l for flying in GZ.

  GCreport.dleft = N64report.dleft;
  GCreport.dright = N64report.dright;
  GCreport.dup = N64report.dup;
  GCreport.ddown = N64report.ddown;

  if (settings.ess_map == ESS_ON)
    invert_vc_n64(&N64report.xAxis, &GCreport.xAxis);
  else
    n64_to_gc_generic(N64report, GCreport);
}

void N64toGC_buttonMap_Yoshi(const N64_Report_t& N64report, Gamecube_Report_t& GCreport) {

  GCreport.a = N64report.a;
  GCreport.b = N64report.b;
  GCreport.start = N64report.start;
  GCreport.z = N64report.l;
  GCreport.r = N64report.r;
  GCreport.right = N64report.r * 255;
  GCreport.l = N64report.z  || N64report.cpad; // 'z' and all of cpad are throw egg.
  GCreport.left = (N64report.z || N64report.cpad) * 255;

  GCreport.dleft = N64report.dleft;
  GCreport.dright = N64report.dright;
  GCreport.dup = N64report.dup;
  GCreport.ddown = N64report.ddown;

  if (settings.ess_map == ESS_ON)
    n64_to_gc_yoshi(N64report, GCreport);
  else
    n64_to_gc_generic(N64report, GCreport);

}
