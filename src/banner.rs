use console::style;

use crate::WARNING;

pub fn show_banner() {
    let title = style("      \"notreallyuri\" Dotfiles Installer            ")
        .bold()
        .cyan();
    let warning_text = style("REMEMBER TO BACKUP YOUR CURRENT SETTINGS")
        .red()
        .bold();

    println!(
        "{}",
        style("┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓").blue()
    );
    // Manual alignment for the title
    println!("{} {} {}", style("┃").blue(), title, style("┃").blue());
    println!(
        "{}",
        style("┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫").blue()
    );
    println!(
        "{}                                                     {}",
        style("┃").blue(),
        style("┃").blue()
    );
    println!(
        "{}  {}                                  {}",
        style("┃").blue(),
        style("This script will:").underlined(),
        style("┃").blue()
    );
    println!(
        "{}  {} Symlink or Copy config into ~/.config            {}",
        style("┃").blue(),
        style("•").green(),
        style("┃").blue()
    );
    println!(
        "{}  {} Setup executable scripts in ~/.local/bin         {}",
        style("┃").blue(),
        style("•").green(),
        style("┃").blue()
    );
    println!(
        "{}  {} Overwrite existing versions found                {}",
        style("┃").blue(),
        style("•").yellow(),
        style("┃").blue()
    );
    println!(
        "{}                                                     {}",
        style("┃").blue(),
        style("┃").blue()
    );
    println!(
        "{}  {}  {}      {}",
        style("┃").blue(),
        WARNING,
        warning_text,
        style("┃").blue()
    );
    println!(
        "{}                                                     {}",
        style("┃").blue(),
        style("┃").blue()
    );
    println!(
        "{}",
        style("┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛").blue()
    );
    println!();
}
