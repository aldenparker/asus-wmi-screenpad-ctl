use clap::{Parser, ValueEnum};
use confy;
use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum Mode {
    /// Set the brightness value
    Set,
    /// Add to the brightness value (negative value for decrease)
    Add,
    /// Set the max brightness to allow (defaults to 100, just because you can set it higher does not mean your screen can handle it)
    Max,
}

/// Small application to control the asus-wmi-screenpad brightness.
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Cli {
    /// The mode to run the command in
    #[arg(value_enum)]
    mode: Mode,
    /// The value used to modify the brightness value
    data: i64,
}

// The config structure to hold current max
#[derive(Serialize, Deserialize)]
struct Config {
    current_max: u64,
}

impl ::std::default::Default for Config {
    fn default() -> Self {
        Self { current_max: 100 }
    }
}

// Helper func
fn trim_newline(mut s: String) -> String {
    if s.ends_with('\n') {
        s.pop();
        if s.ends_with('\r') {
            s.pop();
        }
    }

    s
}

fn main() {
    // Constant value
    let device_path = "/sys/class/leds/asus::screenpad/brightness";
    let app_name = env!("CARGO_PKG_NAME");

    // Parse args
    let args = Cli::parse();

    // Grab cached max or use default (check)
    let cfg: Config = confy::load(app_name, None).expect("Error: Could not load config file");

    // Run main part of program
    match args.mode {
        Mode::Set => {
            // Check for bounds
            if args.data < 0 {
                panic!("Error: Inputed set value is less than zero.");
            }

            // Generate value to write
            let mut value = args.data as u64;
            if value > cfg.current_max {
                value = cfg.current_max;
            }

            // Write value
            fs::write(device_path, format!("{}", value))
                .expect("Error: Could not write to brightness file. Check permisions for the file");
        }
        Mode::Add => {
            // Get current brightness
            let mut value = trim_newline(
                fs::read_to_string(device_path)
                    .expect("Error: Could not read brightness file. Check permisions for the file"),
            )
            .parse::<u64>()
            .expect("Error: Could not parse brightness file into integer");

            // Generate value to write
            if args.data > 0 && (value + args.data as u64) > cfg.current_max {
                value = cfg.current_max;
            } else if args.data < 0 && (value as i64 + args.data) < 0 {
                value = 0;
            } else {
                value = (value as i64 + args.data) as u64;
            }

            // Write value
            fs::write(device_path, format!("{}", value))
                .expect("Error: Could not write to brightness file. Check permisions for the file");
        }
        Mode::Max => {
            // Check for bounds
            if args.data < 0 {
                panic!("Error: Inputed max value is less than zero");
            }

            // Write value
            let new_cfg = Config {
                current_max: args.data as u64,
            };
            confy::store(app_name, None, new_cfg).expect("Error: Unable to write config file");
        }
    }
}
