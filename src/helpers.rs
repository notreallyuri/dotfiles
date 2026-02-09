use crate::{COPY, LINK, LOOKING_GLASS};
use console::style;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Command;

pub fn get_config_entries(path: &Path) -> Result<Vec<String>, std::io::Error> {
    Ok(fs::read_dir(path)?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().is_dir())
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .filter(|s| !["bin", "scripts", ".git", "fonts", "src", "target"].contains(&s.as_str()))
        .collect())
}

pub fn install_binaries(
    root: &Path,
    dst: &Path,
    is_symlink: bool,
) -> Result<(), Box<dyn std::error::Error>> {
    let bin_src = root.join("bin");
    if bin_src.exists() {
        println!("\n{} Installing executables...", style("●").blue());
        fs::create_dir_all(dst)?;
        for entry in fs::read_dir(bin_src)? {
            let entry = entry?;
            let src = entry.path();
            let target = dst.join(entry.file_name());

            let mut perms = fs::metadata(&src)?.permissions();
            perms.set_mode(0o755);
            fs::set_permissions(&src, perms)?;

            process_item(&src, &target, is_symlink)?;
        }
    }
    Ok(())
}

pub fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> std::io::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}

pub fn process_item(src: &Path, dst: &Path, is_symlink: bool) -> std::io::Result<()> {
    let name = src.file_name().unwrap().to_string_lossy();
    println!("{} Processing {}...", LOOKING_GLASS, style(&name).cyan());

    if dst.exists() {
        if dst.is_dir() && !dst.is_symlink() {
            fs::remove_dir_all(dst)?;
        } else {
            fs::remove_file(dst)?;
        }
    }

    if is_symlink {
        #[cfg(unix)]
        std::os::unix::fs::symlink(src, dst)?;
        println!("  {} Linked to {}", LINK, dst.display());
    } else if src.is_dir() {
        copy_dir_all(src, dst)?;
        println!("  {} Copied to {}", COPY, dst.display());
    } else {
        fs::copy(src, dst)?;
        println!("  {} Copied to {}", COPY, dst.display());
    }
    Ok(())
}

pub fn check_environment(bin_path: &Path) {
    println!("\n{}", style("Checking Environment...").yellow());
    let mut issues = Vec::new();

    let path_var = std::env::var("PATH").unwrap_or_default();
    if !path_var.contains(&bin_path.to_string_lossy().to_string()) {
        issues.push(format!("{} is not in your PATH", bin_path.display()));
    }

    let deps = ["lua", "fastfetch"];
    for dep in deps {
        if Command::new("which")
            .arg(dep)
            .output()
            .map(|o| !o.status.success())
            .unwrap_or(true)
        {
            issues.push(format!("'{}' is not installed", dep));
        }
    }

    if issues.is_empty() {
        println!(
            "  {} All dependencies and paths are correct.",
            style("✔").green()
        );
    } else {
        println!(
            "  {} Found {} environment issue(s):",
            style("✘").red(),
            issues.len()
        );
        for issue in issues {
            println!("    {} {}", style("•").red(), issue);
        }
    }
}
