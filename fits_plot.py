import matplotlib.pyplot as plt
from astropy.visualization import astropy_mpl_style
from astropy.io import fits
plt.style.use(astropy_mpl_style)

image_file = fits.open('images/J094454.67+000236.8-r.fits')
image_data = image_file[1].data

plt.figure()
plt.plot(image_data)
plt.savefig("test.png")

