use std::env;
use std::process::{Command, exit};
use std::os::unix::process::CommandExt;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    
    let err = Command::new("ls")
        .args(&args)
        .exec();
    
    eprintln!("Failed to execute ls: {}", err);
    exit(127);
}