//ESS.cpp

#include "ESS.hpp"


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
