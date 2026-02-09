use console::{Emoji, Term, style};
use dialoguer::{Confirm, MultiSelect, Select};
use std::fs;
use std::path::Path;

mod banner;
mod helpers;

use banner::*;
use helpers::*;

pub static LOOKING_GLASS: Emoji<'_, '_> = Emoji("🔍 ", "");
pub static LINK: Emoji<'_, '_> = Emoji("🔗 ", "");
pub static COPY: Emoji<'_, '_> = Emoji("📄 ", "");
pub static WARNING: Emoji<'_, '_> = Emoji("⚠️  ", "");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let term = Term::stdout();
    term.clear_screen()?;

    show_banner();

    let options = &["🚀 Install Dotfiles", "🗑️  Remove Dotfiles", "❌ Exit"];
    let selection = Select::with_theme(&dialoguer::theme::ColorfulTheme::default())
        .with_prompt("What would you like to do?")
        .items(options)
        .default(0)
        .interact()?;

    match selection {
        0 => run_install()?,
        1 => run_remove()?,
        _ => println!("{}", style("Goodbye!").cyan()),
    }

    Ok(())
}

fn run_install() -> Result<(), Box<dyn std::error::Error>> {
    let home = std::env::var("HOME")?;
    let current_dir = std::env::current_dir()?;
    let config_dir = Path::new(&home).join(".config");
    let bin_dst = Path::new(&home).join(".local/bin");

    let entries = get_config_entries(&current_dir)?;
    let selections = MultiSelect::with_theme(&dialoguer::theme::ColorfulTheme::default())
        .with_prompt("Select components to install")
        .items(&entries)
        .defaults(&vec![true; entries.len()])
        .interact()?;

    let modes = &["Symlink (Sync with repo)", "Copy (Standalone)"];
    let mode_idx = Select::with_theme(&dialoguer::theme::ColorfulTheme::default())
        .with_prompt("Installation Mode")
        .items(modes)
        .default(0)
        .interact()?;

    if !Confirm::new().with_prompt("Ready to proceed?").interact()? {
        return Ok(());
    }

    for &idx in &selections {
        let src = current_dir.join(&entries[idx]);
        let dst = config_dir.join(&entries[idx]);
        process_item(&src, &dst, mode_idx == 0)?;
    }

    install_binaries(&current_dir, &bin_dst, mode_idx == 0)?;

    println!("\n{}", style("✔ Installation Complete!").green().bold());
    check_environment(&bin_dst);
    Ok(())
}

fn run_remove() -> Result<(), Box<dyn std::error::Error>> {
    let home = std::env::var("HOME")?;
    let current_dir = std::env::current_dir()?;
    let config_dir = Path::new(&home).join(".config");
    let bin_dst = Path::new(&home).join(".local/bin");

    println!(
        "\n{} Scanning for installed components...",
        style("●").blue()
    );

    let mut to_remove = Vec::new();
    let entries = get_config_entries(&current_dir)?;

    for name in entries {
        let target = config_dir.join(&name);
        if target.exists() {
            to_remove.push(target);
        }
    }

    if let Ok(bin_entries) = fs::read_dir(current_dir.join("bin")) {
        for entry in bin_entries.filter_map(|e| e.ok()) {
            let target = bin_dst.join(entry.file_name());
            if target.exists() {
                to_remove.push(target);
            }
        }
    }

    if to_remove.is_empty() {
        println!("{}", style("No installed components found.").yellow());
        return Ok(());
    }

    println!("Found {} items to remove.", style(to_remove.len()).yellow());
    if Confirm::new()
        .with_prompt("Delete these items?")
        .interact()?
    {
        for path in to_remove {
            println!("  {} Removing {}...", style("×").red(), path.display());
            if path.is_dir() && !path.is_symlink() {
                fs::remove_dir_all(path)?;
            } else {
                fs::remove_file(path)?;
            }
        }
        println!("\n{}", style("✔ Cleanup complete.").green());
    }
    Ok(())
}
