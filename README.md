# Etch-a-sketch
Etch-a-sketch in MIPS Assembly

Using MIPS and Mars compiler, I created an Etch-A-Sketch game using the native Mars bitmap display and MMIO interface. 

When running the program set your bitmap display to the heap, set the unit width and height to 8, and your display width and height to 512. This produces a bitmap display of 64 pixels by 64 pixels.

The following keys are used when running the program:

W will write to the screen one pixel above your current location
S will write to the screen one pixel below your current location
A will write to the screen one pixel to the left of your current location
D will write to the screen one pixel to the right of your current location
Z will write to the screen one pixel to the left downward location (diagonally)
X will write to the screen one pixel to the right downward location (diagonally)
K will write to the screen one pixel to the left upward location (diagonally)
L will write to the screen one pixel to the right upward location (diagonally)
R changes the current pixel color by a factor of 0x0d000000
G changes the current pixel color to green
O changes the current pixel color back to the original blue
Q is to exit the game cleanly (or quit)

