use anyhow::anyhow;
use anyhow::Context;
use fuzzy_matcher::skim::SkimMatcherV2;
use fuzzy_matcher::FuzzyMatcher;
use inquire::MultiSelect;
use inquire::Select;
use rnix::ast::HasEntry;
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
    // Get GHC Version
    let mut sp = Spinner::new(
        Spinners::Dots,
        "Fetching GHC versions in nixpkgs...".into(),
    );
    let ghc_versions = get_ghc_versions(nixpkgs_version).await?;
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved ghc versions".into(),
    );

    let matcher = SkimMatcherV2::default();

    let ghc_version_number =
        Select::new("Which ghc version would you like to use?", ghc_versions)
            .with_filter(&|input, _, value, _| {
                matcher
                    .fuzzy_match(&value.to_lowercase(), &input.to_lowercase())
                    .is_some()
            })
            .prompt()
            .context("Couldn't collect ghc version")?;

    let ghc_version = format!("ghc{}", ghc_version_number.replace('.', ""));

    // Get Language Extensions
    let mut sp = Spinner::new(
        Spinners::Dots,
        "Fetching language extensions from Hackage...".into(),
    );
    let all_haskell_extensions = get_haskell_extensions().await?;
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved haskell extensions".into(),
    );

    let language_extensions = MultiSelect::new(
        "Which language extensions would you like to use?",
        all_haskell_extensions,
    )
    .with_filter(&|input, _, value, _| {
        matcher.fuzzy_match(&value.to_lowercase(), &input.to_lowercase()).is_some()
    })
    .prompt()
    .context("Couldn't collect ghc version")?;

    // Get Hackage Packages
    let mut sp = Spinner::new(
        Spinners::Dots,
        "Fetching hackage packages from nixpkgs...".into(),
    );
    let all_hackage_packages = get_hackage_packages(nixpkgs_version).await?;
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved haskell extensions".into(),
    );

    let hackage_packages = MultiSelect::new(
        "Which default packages would you like to use?",
        all_hackage_packages,
    )
    .prompt()
    .context("Couldn't collect default packages")?;

    Ok(TemplateData::Haskell {
        ghc_version,
        language_extensions,
        hackage_packages,
    })
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

const HASKELL_EXTENSION_URL: &str = r"https://hackage.haskell.org/package/template-haskell/docs/Language-Haskell-TH-LanguageExtensions.html";

pub(crate) async fn get_haskell_extensions()
-> Result<Vec<String>, anyhow::Error> {
    let res = reqwest::get(HASKELL_EXTENSION_URL).await?.text().await?;
    let document = Html::parse_document(&res);
    let selector = Selector::parse("td.src a").map_err(|_| {
        anyhow!("Unable to scrape ghc version from nixpkgs github page")
    })?;
    let mut language_extensions: Vec<String> = document
        .select(&selector)
        .map(|node| node.inner_html())
        .collect();

    language_extensions.sort();

    Ok(language_extensions)
}

pub(crate) async fn get_hackage_packages(
    nixpkgs_version: &str,
) -> Result<Vec<String>, anyhow::Error> {
    let haskell_packages_address = format!(
        "https://raw.githubusercontent.com/NixOS/nixpkgs/{nixpkgs_version}/pkgs/development/haskell-modules/hackage-packages.nix"
    );
    let res = reqwest::get(haskell_packages_address).await?.text().await?;

    let ast = rnix::Root::parse(&res).ok()?;
    let hackage_packages = match ast.expr() {
        Some(rnix::ast::Expr::Lambda(expr)) => {
            match expr.body() {
                Some(rnix::ast::Expr::Lambda(expr)) => {
                    if let Some(rnix::ast::Expr::AttrSet(set)) = expr.body() {
                        Ok(set
                            .entries()
                            .filter_map(|node| {
                                if let rnix::ast::Entry::AttrpathValue(
                                    attrpath_value,
                                ) = node
                                {
                                    attrpath_value.attrpath().map(|path| {
                                        path.to_string().replace("\"", "")
                                    })
                                } else {
                                    None
                                }
                            })
                            .collect::<Vec<String>>())
                    } else {
                        Err(anyhow!("Expected a attrset"))
                    }
                },
                _ => Err(anyhow!("Expected a lambda")),
            }
        },
        _ => Err(anyhow!("Expected a lambda")),
    }?;

    Ok(hackage_packages)
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::get_hackage_packages;

    #[tokio::test]
    pub async fn test_get_hackage_packages() {
        get_hackage_packages("nixpkgs-unstable").await.unwrap();
    }
}

const GHC_REPLACEMENT_TEXT: &str = "__ghcVersion";
const DEFAULT_EXTENSIONS_TEXT: &str = "__default_extensions\n";
const DEFAULT_PACKAGES_TEXT: &str = "__default_build_depends\n";


pub(crate) async fn create_haskell_template(
    basic_data: BasicData,
    ghc_version: &str,
    language_extensions: Vec<String>,
    hackage_packages: Vec<String>,
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

    let formatted_language_extensions = if language_extensions.len() == 0 {
        "".to_owned()
    } else {
        language_extensions
            .into_iter()
            .fold("\tdefault-extensions:\n ".to_owned(), |a, v| {
                format!("{}\t\t{}\n", a.to_owned(), v)
            })
    };

    let formatted_hackage_packages = if hackage_packages.len() == 0 {
        "".to_owned()
    } else {
        hackage_packages
            .into_iter()
            .fold("".to_owned(), |a, v| {
                format!("{}\t\t, {}\n", a.to_owned(), v)
            })
    };

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
        replacer::replace_many(
            "./template.cabal",
            vec![
                (PACKAGE_NAME_REPLACEMENT_TEXT, &package_name),
                (DEFAULT_EXTENSIONS_TEXT, &formatted_language_extensions),
                (DEFAULT_PACKAGES_TEXT, &formatted_hackage_packages),
            ],
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
