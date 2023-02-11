use anyhow::Context;
use inquire::Select;
use scraper::Html;
use scraper::Selector;
use spinners::Spinner;
use spinners::Spinners;

use super::template::TemplateData;

pub(crate) async fn get_haskell_data(
    nixpkgs_version: &str,
) -> Result<TemplateData, anyhow::Error> {
    let mut sp = Spinner::new(
        Spinners::Dots,
        "Fetching GHC versions in nixpkgs...".into(),
    );
    let ghc_versions = get_ghc_versions(nixpkgs_version).await.unwrap();
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved ghc versions".into(),
    );
    let ghc_version_number =
        Select::new("Which ghc version would you like to use?", ghc_versions)
            .prompt()
            .context("Couldn't collect ghc version")?;

    let ghc_version = format!("ghc{}", ghc_version_number.replace(".", ""));

    Ok(TemplateData::Haskell { ghc_version })
}

pub(crate) async fn get_ghc_versions(
    nixpkgs_version: &str,
) -> Result<Vec<String>, anyhow::Error> {
    let ghc_version_address = format!(
        "https://github.com/NixOS/nixpkgs/tree/{}/pkgs/development/compilers/ghc",
        nixpkgs_version
    );
    let res = reqwest::get(ghc_version_address).await?.text().await?;
    let document = Html::parse_document(&res);
    let selector =
        Selector::parse(".js-navigation-open.Link--primary").unwrap();
    let mut ghc_versions: Vec<String> = document
        .select(&selector)
        .filter_map(|node| {
            node.inner_html().strip_suffix(".nix").and_then(|str| {
                if str.ends_with("binary")
                    || !str.chars().all(|c| c.is_numeric() || c == '.')
                {
                    None
                } else {
                    Some(str.to_string())
                }
            })
        })
        .collect();

    ghc_versions.sort_by(|a, b| b.cmp(a));

    Ok(ghc_versions)
}
