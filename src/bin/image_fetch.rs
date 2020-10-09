use std::fs::{DirEntry, File};
use std::io::{BufRead, BufReader};
use std::process::Command;

fn main() -> Result<(), std::io::Error> {
    let link = File::open("link.txt")?;
    let reader = BufReader::new(link);

    for line in reader.lines() {
        let line = line?;
        println!("Downloading {}...", line);
        let (r, i) = iauname_to_link(&line);
        let mut cmd_r = wget(&r);
        let mut cmd_i = wget(&i);
        cmd_r.output().expect(&format!("Can't download r_band of {}", line));
        cmd_i.output().expect(&format!("Can't download i_band of {}", line));
    }

    let mut cmd = Command::new("mv");
    cmd.arg("*.gz");
    cmd.arg("images/");
    cmd.output().expect("Can't move *.gz files");

    println!("Complete!");

    Ok(())
}

fn iauname_to_link(name: &str) -> (String, String) {
    let mut s = "https://dr12.sdss.org/sas/dr16/sdss/atlas/v1/detect/sdss";
    let name_vec = name.chars().collect::<Vec<char>>();
    let hour = format!("{}{}h", name_vec[1], name_vec[2]);
    let sign = match name_vec[10] {
        '+' => 'p',
        '-' => 'm',
        _ => panic!("Unvalid sign!"),
    };
    let other: u32 = format!("{}{}", name_vec[11], name_vec[12]).parse().unwrap();
    let second_temp = (other / 2) * 2;
    let second = if second_temp < 10 {
        format!("{}0{}", sign, second_temp)
    } else {
        format!("{}{}", sign, second_temp)
    };

    let full_r = format!("{}/{}/{}/{}/{}-r.fits.gz", s, hour, second, name, name);
    let full_i = format!("{}/{}/{}/{}/{}-i.fits.gz", s, hour, second, name, name);

    (full_r, full_i)
}

fn wget(link: &str) -> Command {
    let mut cmd = Command::new("wget");
    cmd.arg(link);
    cmd
}

//https://dr12.sdss.org/sas/dr16/sdss/atlas/v1/detect/sdss/09h/m00/J090011.07-001806.5/J090011.07-001806.5-g.fits.gz
