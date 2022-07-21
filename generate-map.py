#!/usr/bin/env python
""" Helper functions for creating ESS adapters """

import sys
import numpy as np

from scipy.spatial.distance import euclidean as euclidean_distance
from scipy.spatial import cKDTree as KDTree
sys.setrecursionlimit(10000)


class GCN64Map:
    """ Mapping of GC controller inputs to N64
    """
    gc_straight_max = 105
    n64_straight_max = 80
    gc_corner_max = 75
    n64_corner_max = 70

    def __init__(self):
        self.gamecube_segments = self.make_gamecube_octagon()

    def make_gamecube_octagon(self):
        """ Initialize line segments for the max range of a gamecube controller
            We always make the line go from a cardinal direction to the corner
            Store the arctan so we can tell which segment a point is in by angle
        """
        gsm = self.gc_straight_max
        gcm = self.gc_corner_max
        dtype = [("x1", "int"),
                 ("y1", "int"),
                 ("x2", "int"),
                 ("y2", "int"),
                 ("atan2", "float")]

        return np.array([
            (0, gsm, gcm, gcm, np.arctan2(gsm, 0)),        # N to NE, N
            (gsm, 0, gcm, gcm, np.arctan2(gcm, gcm)),      # E to NE, NE
            (gsm, 0, gcm, -gcm, np.arctan2(0, gsm)),       # E to SE, E
            (0, -gsm, gcm, -gcm, np.arctan2(-gcm, gcm)),   # S to SE, SE
            (0, -gsm, -gcm, -gcm, np.arctan2(-gsm, 0)),    # S to SW, S
            (-gsm, 0, -gcm, -gcm, np.arctan2(-gcm, -gcm)), # W to SW, SW
            (-gsm, 0, -gcm, gcm, np.arctan2(0, -gsm)),     # W to NW, W
            (0, gsm, -gcm, gcm, np.arctan2(gcm, -gcm)),    # N to NW, NW
        ], dtype=dtype)

    @staticmethod
    def find_nearest_below(my_array, target):
        """ Adapted from https://stackoverflow.com/questions/17118350/

            Find the closest match below target in a 1d array.
        """
        diff = my_array - target
        mask = np.ma.less(diff, 0)
        if np.all(mask):
            return my_array.argmax()
        masked_diff = np.ma.masked_array(diff, mask)
        return masked_diff.argmin()

    def find_segment_intersect(self, x_coord, y_coord):
        """ Adapted from https://gamedev.stackexchange.com/questions/44720/

            Draw a line from the origin through the point x, y
            Find the intersection with the edge of the gamecube range.

            Selects the correct edge to intersect with by angle.

            Returns how close to a corner we intersected, where
            0 is a cardinal direction and 1 is in the corner,
            and the distance from the point to the edge of the range, where
            0 is at the origin and 1 is at the edge of the range.

            Assumes segments start in cardinal direction and end in corner.
        """
        segs = self.gamecube_segments
        seg = segs[self.find_nearest_below(
            segs["atan2"],
            np.arctan2(y_coord, x_coord)
        )]

        cornerity = ((x_coord * seg["y1"] - y_coord * seg["x1"])
                     / (y_coord * (seg["x2"] - seg["x1"]) - x_coord * (seg["y2"] - seg["y1"])))
        distance = ((x_coord * (seg["y2"] - seg["y1"]) - y_coord * (seg["x2"] - seg["x1"]))
                    / ((seg["y2"] - seg["y1"]) * (seg["x1"]) - (seg["x2"] - seg["x1"]) * seg["y1"]))

        return cornerity, distance

    def map(self, x_coord, y_coord):
        """ The N64 controller not only has a smaller range, but it has a different shape.
            So we want to squash straight directions by more than the corners.
            That way we can get the full range of the N64 controller, but we don't lose
            sensitivity in the straight directions.

            We also want to take care to warp less in the center to preserve precision.
            Expects signed input from -128 to 127
        """
        if (x_coord == 0 and y_coord == 0):
            return (0.0, 0.0)

        scale = self.n64_straight_max / self.gc_straight_max
        corner_difference = self.n64_corner_max / self.gc_corner_max - scale

        closeness_to_corner, distance = self.find_segment_intersect(x_coord, y_coord)
        corner_scale = closeness_to_corner * corner_difference
        scale += min(1, distance)**3 * corner_scale # Warp less in center

        return x_coord * scale, y_coord * scale

    def umap(self, x_coord, y_coord):
        """ Map unsigned coords from 0 to 255 centered at 128 """
        return self.map(x_coord - 128, y_coord - 128)

    def simple_map(self, x_coord, y_coord):
        """ Approximation that does not involve calculating intersections and suchlike
        """
        scale = self.n64_straight_max / self.gc_straight_max
        corner_difference = self.n64_corner_max / self.gc_corner_max - scale

        # 1 when we're in a corner, 0 when far
        closeness_to_corner = abs(x_coord * y_coord) / self.gc_corner_max**2

        scale += closeness_to_corner * corner_difference
        return x_coord * scale, y_coord * scale

    def naive_map(self, x_coord, y_coord):
        """ Simply scales down to fit gamecube range onto n64 range
            Means you don't reach maximum values in the corners,
            because the N64 controller shape is different.
        """
        scale = self.n64_straight_max / self.gc_straight_max
        return x_coord * scale, y_coord * scale

    def plot_map(self, mapping_func=None):
        """ Make a plot of a gc -> n64 mapping function
        """
        from matplotlib.patches import Circle
        import matplotlib.pyplot as plt

        gsm = self.gc_straight_max
        gcm = self.gc_corner_max
        if mapping_func is None:
            mapping_func = self.map

        _, axes = plt.subplots(figsize=(900/96, 900/96), dpi=96)
        axes.add_patch(Circle([0, 0], fill=False, color="green", radius=self.n64_straight_max))

        # The lines that make up the GC octagon
        x_coords = np.concatenate([np.linspace(-gsm, -gcm), np.linspace(-gcm, 0),
                                   np.linspace(0, gcm), np.linspace(gcm, gsm),
                                   np.linspace(gsm, gcm), np.linspace(gcm, 0),
                                   np.linspace(0, -gcm), np.linspace(-gcm, -gsm)])
        y_coords = np.concatenate([np.linspace(0, gcm), np.linspace(gcm, gsm),
                                   np.linspace(gsm, gcm), np.linspace(gcm, 0),
                                   np.linspace(0, -gcm), np.linspace(-gcm, -gsm),
                                   np.linspace(-gsm, -gcm), np.linspace(-gcm, 0)])

        # Create 11 evenly spaced octagons to show how each gets mapped
        for scale in np.arange(0.0909, 1, 0.0909):
            scaled_x, scaled_y = zip(*[
                mapping_func(*e) for e in zip(x_coords*scale, y_coords*scale)
            ])
            axes.plot(scaled_x, scaled_y, c="blue")

        plt.xticks(np.arange(-90, 90+1, 10))
        plt.yticks(np.arange(-90, 90+1, 10))
        plt.grid()
        plt.show()

class OOTVCMap:
    """ Implementation of VC's mapping algorithm """
    deadzone = 15
    max_length = 56
    n64_max = 80 # Full N64 range so the adapter works in menus as well

    def __init__(self, verbose=False):
        self.vc_map, self.vc_reachable = self.create_lookup_tables()
        self.neighbor_finder = KDTree(np.vstack(self.vc_map))
        self.verbose = verbose
        self.one_dimensional_boundary = self.find_1d_boundary()
        self.one_dimensional_map, self.triangular_map = self.factorize_lookup_table()

    def subtract_deadzone(self, coord, deadzone=0):
        """ Extra deadzone. Any movement within this zone is ignored.
            The game itself will also apply its own 7x7 deadzone
        """
        if deadzone == 0:
            deadzone = self.deadzone
        if coord > deadzone:
            return coord - deadzone
        if coord < -deadzone:
            return coord + deadzone
        return 0

    def clamp_absolute_length(self, coord, length):
        """ Coordinates past a certain radius are scaled down, so
            that their distance from the origin is no more than max.
        """
        if length > self.max_length:
            coord = coord * self.max_length / np.trunc(length)
        return np.trunc(coord)

    def map_coord(self, coord):
        """ Each coordinate is mapped individually,
            but they're not scaled the same.

            This means that angles are not maintained by VC.
        """
        coord = np.trunc(coord / self.max_length * 127)

        # The intention was perhaps to have more precision in the center area.
        if coord >= 0:
            sign = 1
        else:
            sign = -1
        coord /= 127
        coord = 1 - np.sqrt(1 - abs(coord))
        coord *= sign
        coord *= 127

        return int(np.trunc(coord))

    def map(self, x_coord, y_coord):
        """ VC actually maps each coordinate separately

            Although GC controllers range from 0-255 unsigned,
            this function expects signed input from -128 to 127
            Use umap for unsigned input.
        """
        x_coord = self.subtract_deadzone(int(x_coord))
        y_coord = self.subtract_deadzone(int(y_coord))

        length = np.sqrt(x_coord**2 + y_coord**2)
        x_coord = self.clamp_absolute_length(x_coord, length)
        y_coord = self.clamp_absolute_length(y_coord, length)

        return self.map_coord(x_coord), self.map_coord(y_coord)

    def umap(self, x_coord, y_coord):
        """ Map unsigned coords from 0 to 255 centered at 128 """
        return self.map(x_coord - 128, y_coord - 128)

    def create_lookup_tables(self):
        """ Map all possible inputs and store the result in a 2D lookup table.

            Exploits symmetry to store only the positive quarter of the table.
        """
        vc_map = np.zeros((128, 128, 2), dtype=("uint8", "uint8"))
        vc_reachable = np.zeros((128, 128), dtype=("bool"))

        for y_coord in range(128):
            for x_coord in range(128):
                mapped_x, mapped_y = self.map(x_coord, y_coord)

                # Check that we really are symmetrical
                assert self.map(-x_coord, y_coord) == (-mapped_x, mapped_y)
                assert self.map(x_coord, -y_coord) == (mapped_x, -mapped_y)
                assert self.map(-x_coord, -y_coord) == (-mapped_x, -mapped_y)

                vc_map[y_coord, x_coord] = (mapped_x, mapped_y)
                vc_reachable[mapped_y, mapped_x] = True

        return vc_map, vc_reachable

    def plot_reachable(self):
        """ Make a plot of all input coordinates you can reach in-game

            Only plots the positive quarter, since the vc mapping is symmetric.
        """
        import matplotlib.pyplot as plt
        from matplotlib.patches import Circle

        # Technically we're plotting unreachables (True/1 = white) making the
        # reachables (False/0) black because that's how the color scheme works
        # It looks better than the other way around.
        vc_unreachable = np.invert(self.vc_reachable)

        _, axes = plt.subplots(figsize=(900/96, 900/96), dpi=96)
        image_data = vc_unreachable[0:self.n64_max+2, 0:self.n64_max+2]
        axes.imshow(image_data, origin="lower", cmap="gray")
        axes.add_patch(Circle([0, 0], fill=False, color="green", radius=self.n64_max))

        plt.xticks(np.arange(0, self.n64_max+2, 5))
        plt.yticks(np.arange(0, self.n64_max+2, 5))
        plt.show()

    def invert(self, x_coord, y_coord):
        """ Return the input that comes closest to getting x, y in game

            Expects signed in-game x, y coordinates. Can be fractional.
            Returns unsigned GC controller x, y coordinates.

            The neighbor_finder requires a flat array of coordinates,
            so we have to calculate the x and y by dividing by 128
        """
        if x_coord >= 0:
            x_sign = 1
        else:
            x_sign = -1
        if y_coord >= 0:
            y_sign = 1
        else:
            y_sign = -1

        point = self.clamp_to_max(abs(x_coord), abs(y_coord))
        distance, _ = self.neighbor_finder.query(point)

        # If the nearest neighbor is too far away, move closer to origin
        # This prevents flickering between two neighbors that are nearly
        # equidistant to P, but very far apart from each other.
        if distance > 2.5:
            length = np.sqrt(point[0] * point[0] + point[1] * point[1])
            scale = (length - distance + 2.5) / length
            point = (point[0] * scale, point[1] * scale)
            distance, _ = self.neighbor_finder.query(point)

        inverted_x, inverted_y = self.best_inversion(abs(x_coord), abs(y_coord), point, distance)

        return inverted_x * x_sign + 128, inverted_y * y_sign + 128

    def best_inversion(self, original_x, original_y, point, distance):
        """ Multiple inputs map to the same output.
            Return the input that is closest to the original.
            If equally close, bias towards bottom left (origin).
        """
        options = self.neighbor_finder.query_ball_point(point, distance+0.001)

        def distance_length_tuple(option):
            """ Return distance, length tuple for easy of sorting """
            inverted_x = option % 128 # column of vc_map
            inverted_y = option // 128 # row of vc_map
            return (
                euclidean_distance(
                    self.map(inverted_x, inverted_y),
                    (original_x, original_y)
                ),
                np.sqrt(inverted_x ** 2 + inverted_y ** 2),
                (inverted_x, inverted_y)
            )

        return sorted([distance_length_tuple(x) for x in options])[0][2]

    @staticmethod
    def triangular_to_linear_index(row, col, size):
        """ Adapted from https://math.stackexchange.com/questions/2134011

            Given index i,j of a triangular array stored as a linear 1d array
            Returns the index of the linear 1d array. Assumes col >= row (!)

            Since X and Y are symmetrical (reflected),
            we only want to store half the values.
        """
        return (size*(size-1)//2) - (size-row)*((size-row)-1)//2 + col

    def find_1d_boundary(self):
        """ See docstring of factorize_lookup_table
            Find the boundary where 1d lookups still work
        """
        if self.verbose:
            print("Finding one dimensional boundary")
        for i in range(self.n64_max+1):
            if self.verbose:
                print("Row {}".format(i))
            for j in range(self.n64_max+1):
                inverted_i = self.invert(i, 0)[0]
                inverted_j = self.invert(j, 0)[0]
                if self.invert(i, j) != (inverted_i, inverted_j):
                    if self.verbose:
                        print(inverted_i, inverted_j, self.invert(i, j))
                    return i - 1 # Start one lower for rounding
        return self.n64_max

    def clamp_to_max(self, x_coord, y_coord):
        """ Treat inputs beyond n64_max as the max.
        """
        if x_coord > self.n64_max:
            x_coord = self.n64_max
        if x_coord < -self.n64_max:
            x_coord = -self.n64_max
        if y_coord > self.n64_max:
            y_coord = self.n64_max
        if y_coord < -self.n64_max:
            y_coord = -self.n64_max
        return x_coord, y_coord


    def factorize_lookup_table(self):
        """ VC's mapping is not only symmetrical in the negatives and positives.
            It applies its mapping to each coordinate separately,
            so it's also symmetrical in the reflection x and y.

            Furthermore, coordinates below absolute max_length in
            length after deadzone, don't even interact with the other
            coordinate at all! That makes inverting a simple 1D lookup.

            It's only coordinates in the upper right part of the space
            that require a 2D lookup. And that lookup is triangular.

            We find the smallest coordinate where 1D lookup breaks down.
            Then we build a triangular 2D lookup for the remainder.

            We make the 1d map double resolution so we can round e.g.
            8 to both 7 and 9 depending on which we are closer to.
        """
        if self.verbose:
            print("Factorizing lookup table")
        one_dimensional_map = np.zeros(2*(self.n64_max+1), dtype="uint8")
        for i in range(self.n64_max+1):
            # Make sure we round both up and down
            one_dimensional_map[2*i] = self.invert(i, 0)[0] - 128
            one_dimensional_map[2*i+1] = self.invert(i + 0.5, 0)[0] - 128

        boundary = self.one_dimensional_boundary
        remainder = self.n64_max + 1 - boundary

        if remainder <= 1:
            return one_dimensional_map, None

        index = self.triangular_to_linear_index(remainder-1, remainder-1, remainder) # biggest index
        triangular_map = np.zeros((index + 1, 2), dtype=("uint8", "uint8"))
        for row in range(remainder):
            for col in range(row, remainder):
                index = self.triangular_to_linear_index(row, col, remainder)
                triangular_map[index] = np.array(self.invert(boundary + col, boundary + row)) - 128

        return one_dimensional_map, triangular_map

    def factorized_invert(self, x_coord, y_coord):
        """ Same as invert(), but much faster and needs less memory.
            Exploits several symmetries to invert with small lookup tables.

            - Negative and positive are symmetrical, calculate with abolute values
            - Y and X are reflected, so we can store half the values
            - The game treats large input values all the same, so the region we
              need to map is actually reasonably small.
            - Within a large part of this region, X and Y can be calculated separately.
              Call plot_reachable() for a visual clue to how this works.

            After the calculation we check that our answer matches with invert()
        """
        clamped_x, clamped_y = self.clamp_to_max(x_coord, y_coord)

        if clamped_x >= 0:
            x_sign = 1
        else:
            x_sign = -1
            clamped_x = abs(clamped_x)
        if clamped_y >= 0:
            y_sign = 1
        else:
            y_sign = -1
            clamped_y = abs(clamped_y)

        boundary = self.one_dimensional_boundary
        remainder = None
        if clamped_x > boundary-0.5 and clamped_y > boundary-0.5:
            # Outside the one dimensional range
            remainder = self.n64_max + 1 - boundary

            # Now x and y must become zero indexed in our 2D lookup
            clamped_x -= boundary
            clamped_y -= boundary
            clamped_x = int(np.round(clamped_x))
            clamped_y = int(np.round(clamped_y))

            if clamped_y >= clamped_x:
                index = self.triangular_to_linear_index(clamped_x, clamped_y, remainder)
                inverted_y, inverted_x = self.triangular_map[index]
            else:
                index = self.triangular_to_linear_index(clamped_y, clamped_x, remainder)
                inverted_x, inverted_y = self.triangular_map[index]
        else:
            inverted_x = self.one_dimensional_map[int(np.ceil(clamped_x*2))]
            inverted_y = self.one_dimensional_map[int(np.ceil(clamped_y*2))]

        inverted_x = x_sign * inverted_x + 128
        inverted_y = y_sign * inverted_y + 128

        # Check how accurate factorized_invert is vs the canonical self.invert
        factorized = self.clamp_to_max(*self.umap(inverted_x, inverted_y))
        canonical = self.clamp_to_max(*self.umap(*self.invert(x_coord, y_coord)))
        distance = euclidean_distance(factorized, canonical)

        if remainder:
            # Used triangular map (upper right corner of the range)
            # We care less about accuracy in the far ranges
            # There might be a small rounding error in the 2D lookup
            if distance > 5:
                print("d>5: {}, x, y: {} {}, ix, iy: {} {}, r: {}, six, siy: {} {}, r: {}".format(
                    distance, x_coord, y_coord, inverted_x, inverted_y, factorized,
                    *self.invert(x_coord, y_coord), canonical), file=sys.stderr, flush=True)
            assert distance <= 5
        else:
            # Used one dimensional map
            if distance != 0:
                print("d>0: {}, x, y: {} {}, ix, iy: {} {}, r: {}, six, siy: {} {}, r: {}".format(
                    distance, x_coord, y_coord, inverted_x, inverted_y, factorized,
                    *self.invert(x_coord, y_coord), canonical), file=sys.stderr, flush=True)
            assert distance == 0

        return inverted_x, inverted_y

    @staticmethod
    def c_style(byte_array):
        """ Python likes to print b'bytes' instead of "bytes"
            Which isn't legal C. Convert it to double quoted string
        """
        return str(byte_array)[:-1].replace("\\'", "'").replace('b\'', '', 1).replace('"', '\\"')

    @staticmethod
    def java_style(map: np.ndarray):
        return str(map.flatten().tolist()).replace('[', '{').replace(']', '}')

    def print_factorized_tables(self):
        """ Print out the generated tables for inclusion in C code """
        print("\nBoundary:")
        print(self.one_dimensional_boundary)
        print("One dimensional map:")
        print('"{}"'.format(self.c_style(self.one_dimensional_map.tobytes())))
        print("Triangular map:")
        print('"{}"'.format(self.c_style(self.triangular_map.tobytes())))
        # print("For Java:")
        # print('byte[] one_dimensional_map = {};'.format(self.java_style(self.one_dimensional_map)))
        # print('byte[] triangular_map = {};'.format(self.java_style(self.triangular_map)))

def main():
    """ Invert 10 random coordinates """
    print("Building inversion tables...")
    gcmapper = GCN64Map()
    vcmapper = OOTVCMap(verbose=True)
    vcmapper.print_factorized_tables()
    print("\nEnter two coordinates to invert.")
    while True:
        x_coord = int(input("Enter x: "))
        y_coord = int(input("Enter y: "))
        n64_x, n64_y = gcmapper.umap(x_coord, y_coord)
        inverted_x, inverted_y = vcmapper.factorized_invert(n64_x, n64_y)
        mapped_x, mapped_y = vcmapper.umap(inverted_x, inverted_y)
        print("\nGamecube {:3d},{:3d} converted to n64 {: 6.1f},{: 6.1f}\n"
              "inverted {:3d},{:3d}   which maps to    {: 4d},{: 4d}"
              .format(x_coord, y_coord, n64_x, n64_y,
                      inverted_x, inverted_y, mapped_x, mapped_y))

def plot_inversion():
    """ Make a plot of the gamecube range after inverting VC's mapping """
    gcmapper = GCN64Map()
    vcmapper = OOTVCMap(verbose=True)
    print("Plotting reachable coordinates")
    vcmapper.plot_reachable()
    print("Plotting post-inversion gamecube range")
    def remap(x_coord, y_coord):
        n64_x, n64_y = gcmapper.map(x_coord, y_coord)
        inverted_x, inverted_y = vcmapper.factorized_invert(n64_x, n64_y)
        mapped_x, mapped_y = vcmapper.umap(inverted_x, inverted_y)
        return mapped_x, mapped_y
    gcmapper.plot_map(remap)

def print_full_map():
    """ Useful to compare with another implementation """
    gcmapper = GCN64Map()
    vcmapper = OOTVCMap()
    for y_coord in range(256):
        for x_coord in range(256):
            mapped_x, mapped_y = vcmapper.factorized_invert(*gcmapper.umap(x_coord, y_coord))
            print("{} {} {} {}".format(x_coord, y_coord, mapped_x, mapped_y))

if __name__ == "__main__":
    main()
    #print_full_map()
    #plot_inversion()
