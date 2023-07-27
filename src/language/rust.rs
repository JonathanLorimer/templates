use crate::language::replacer;
use crate::language::template::BasicData;
use crate::language::template::NIXPKGS_REPLACEMENT_TEXT;
use crate::language::template::PACKAGE_NAME_REPLACEMENT_TEXT;
use crate::language::template::TEMPLATE_REPO;

pub(crate) async fn create_rust_template(
    basic_data: BasicData,
) -> Result<(), anyhow::Error> {
    let BasicData {
        package_name,
        nixpkgs_version,
    } = basic_data;

    tokio::process::Command::new("nix")
        .arg("flake")
        .arg("init")
        .arg("-t")
        .arg(format!("{}#{}", TEMPLATE_REPO, "rust"))
        .spawn()?
        .wait()
        .await?;

    let (res1, res2, res3) = tokio::join!(
        replacer::replace_many(
            "./flake.nix",
            vec![
                (PACKAGE_NAME_REPLACEMENT_TEXT, &package_name),
                (NIXPKGS_REPLACEMENT_TEXT, &nixpkgs_version),
            ],
        ),
        replacer::replace(
            "./Cargo.toml",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        ),
        replacer::replace(
            "./src/main.rs",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        )
    );

    res1?;
    res2?;
    res3?;

    tokio::process::Command::new("nix")
        .arg("run")
        .arg("nixpkgs#cargo")
        .arg("generate-lockfile")
        .spawn()?
        .wait()
        .await?;

    println!(
        r"
        Template: Rust
        Package Name: {package_name}
        Nixpkgs Version: {nixpkgs_version}
        "
    );

    Ok(())
}
