extern crate peroxide;
extern crate fitsio;
use peroxide::fuga::*;
use fitsio::*;

fn main() -> Result<(), Box<dyn Error>> {
    let mut fptr = FitsFile::open("data/nsa_v1_0_1.fits")?;

    fptr.pretty_print()?;

    let hdu = fptr.hdu(0)?;

    if let hdu::HduInfo::ImageInfo { shape, .. } = hdu.info {
        println!("Image is {}-dimensional", shape.len());
        println!("Found image with shape {:?}", shape);
    }

    Ok(())
}
