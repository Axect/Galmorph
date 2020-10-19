#[macro_use]
extern crate puruda;
extern crate peroxide;
use puruda::*;
use peroxide::fuga::*;

use std::error::Error;
use std::fs::{rename, read_dir};
//use std::io::{BufRead, BufReader};
use std::process::Command;

fn main() -> Result<(), Box<dyn Error>> {
    //let link = File::open("link.txt")?;
    //let reader = BufReader::new(link);
    let catalog: Col3<
        Vec<String>, 
        Vec<usize>, 
        Vec<usize>
    >;
    catalog = Col3::read_csv("catalog2.csv", ',')?;

    for i in 0 .. catalog.c1().len() {
        let name = &catalog.c1()[i];
        let pid = catalog.c2()[i];
        let aid = catalog.c3()[i];

        let (link, sersic) = get_link(name, pid, aid);

        println!("Downloading {}...", name);
        let mut cmd = wget(&link);
        cmd.output().expect(&format!("Can't download {}", name));
        println!("Downloading sersic profile of {}...", name);
        let mut cmd2 = wget(&sersic);
        cmd2.output().expect(&format!("Can't download sersic profile of {}", name));
    }

    let mut gz_list: Vec<String> = Vec::new();
    for file in read_dir("./")? {
        let entry = file?;
        let path = entry.path();
        if !path.is_dir() {
            match entry.file_name().into_string() {
                Ok(path) if path.contains(".gz") => {
                    gz_list.push(path);
                }
                _ => (),
            }
        }
    }

    for gz in gz_list {
        let old_path = format!("./{}", gz);
        let new_path = format!("images/{}", gz);
        rename(old_path, new_path)?;
    }

    println!("Complete!");

    Ok(())
}

fn get_link(name: &str, pid: usize, aid: usize) -> (String, String) {
    let s = "https://dr12.sdss.org/sas/dr16/sdss/atlas/v1/detect/v1_0";
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

    let full = format!("{}/{}/{}/{}/atlases/{}/{}-{}-atlas-{}.fits.gz", s, hour, second, name, pid, name, pid, aid);
    let sersic = format!("{}/{}/{}/{}/atlases/{}/{}-{}-sersic.fits.gz", s, hour, second, name, pid, name, pid);
    (full, sersic)
}

//fn iauname_to_link(name: &str) -> (String, String) {
//    let s = "https://dr12.sdss.org/sas/dr16/sdss/atlas/v1/detect/sdss";
//    let name_vec = name.chars().collect::<Vec<char>>();
//    let hour = format!("{}{}h", name_vec[1], name_vec[2]);
//    let sign = match name_vec[10] {
//        '+' => 'p',
//        '-' => 'm',
//        _ => panic!("Unvalid sign!"),
//    };
//    let other: u32 = format!("{}{}", name_vec[11], name_vec[12]).parse().unwrap();
//    let second_temp = (other / 2) * 2;
//    let second = if second_temp < 10 {
//        format!("{}0{}", sign, second_temp)
//    } else {
//        format!("{}{}", sign, second_temp)
//    };
//
//    let full_r = format!("{}/{}/{}/{}/{}-r.fits.gz", s, hour, second, name, name);
//    let full_i = format!("{}/{}/{}/{}/{}-i.fits.gz", s, hour, second, name, name);
//
//    (full_r, full_i)
//}

fn wget(link: &str) -> Command {
    let mut cmd = Command::new("wget");
    cmd.arg(link);
    cmd
}

//https://dr12.sdss.org/sas/dr16/sdss/atlas/v1/detect/sdss/09h/m00/J090011.07-001806.5/J090011.07-001806.5-g.fits.gz
