use anyhow::anyhow;
use anyhow::Context;
use inquire::Select;
use scraper::Html;
use scraper::Selector;
use spinners::Spinner;
use spinners::Spinners;

use super::template::BasicData;
use super::template::TemplateData;
use crate::language::replacer;
use crate::language::template::NIXPKGS_REPLACEMENT_TEXT;
use crate::language::template::PACKAGE_NAME_REPLACEMENT_TEXT;
use crate::language::template::TEMPLATE_REPO;

pub(crate) async fn get_haskell_data(
    nixpkgs_version: &str,
) -> Result<TemplateData, anyhow::Error> {
    let mut sp = Spinner::new(
        Spinners::Dots,
        "Fetching GHC versions in nixpkgs...".into(),
    );
    let ghc_versions = get_ghc_versions(nixpkgs_version).await?;
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved ghc versions".into(),
    );
    let ghc_version_number =
        Select::new("Which ghc version would you like to use?", ghc_versions)
            .prompt()
            .context("Couldn't collect ghc version")?;

    let ghc_version = format!("ghc{}", ghc_version_number.replace('.', ""));

    Ok(TemplateData::Haskell { ghc_version })
}

pub(crate) async fn get_ghc_versions(
    nixpkgs_version: &str,
) -> Result<Vec<String>, anyhow::Error> {
    let ghc_version_address = format!(
        "https://github.com/NixOS/nixpkgs/tree/{nixpkgs_version}/pkgs/development/compilers/ghc"
    );
    let res = reqwest::get(ghc_version_address).await?.text().await?;
    let document = Html::parse_document(&res);
    let selector = Selector::parse(".js-navigation-open.Link--primary")
        .map_err(|_| {
            anyhow!("Unable to scrape ghc version from nixpkgs github page")
        })?;
    let mut ghc_versions: Vec<String> = document
        .select(&selector)
        .filter_map(|node| {
            node.inner_html().strip_suffix(".nix").and_then(|str| {
                if str.ends_with("binary")
                    || !str.chars().all(|c| c.is_numeric() || c == '.')
                {
                    None
                } else {
                    Some(str.to_owned())
                }
            })
        })
        .collect();

    ghc_versions.sort_by(|a, b| b.cmp(a));

    Ok(ghc_versions)
}

const GHC_REPLACEMENT_TEXT: &str = "__ghcVersion";

pub(crate) async fn create_haskell_template(
    basic_data: BasicData,
    ghc_version: &str,
) -> Result<(), anyhow::Error> {
    let BasicData {
        package_name,
        nixpkgs_version,
    } = basic_data;

    tokio::process::Command::new("nix")
        .arg("flake")
        .arg("init")
        .arg("-t")
        .arg(format!("{}#{}", TEMPLATE_REPO, "haskell"))
        .spawn()?
        .wait()
        .await?;

    let (res1, res2, res3) = tokio::join!(
        replacer::replace_many(
            "./flake.nix",
            vec![
                (GHC_REPLACEMENT_TEXT, ghc_version),
                (PACKAGE_NAME_REPLACEMENT_TEXT, &package_name),
                (NIXPKGS_REPLACEMENT_TEXT, &nixpkgs_version),
            ],
        ),
        replacer::replace(
            "./scripts.nix",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        ),
        replacer::replace(
            "./template.cabal",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        )
    );

    res1?;
    res2?;
    res3?;

    tokio::fs::rename("./template.cabal", format!("./{package_name}.cabal"))
        .await?;

    println!(
        r"
        Template: Haskell
        Package Name: {package_name}
        Nixpkgs Version: {nixpkgs_version}
        GHC Version: {ghc_version}
        "
    );

    Ok(())
}
