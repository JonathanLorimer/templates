use anyhow::Context;
use fuzzy_matcher::skim::SkimMatcherV2;
use fuzzy_matcher::FuzzyMatcher;
use inquire::Select;
use inquire::Text;
use spinners::Spinner;
use spinners::Spinners;

use crate::language::template::BasicData;
use crate::nixpkgs_version::get_nixpkgs_versions;

pub async fn collect_basic_data() -> Result<BasicData, anyhow::Error> {
    let package_name: String = Text::new("What should this package be called?")
        .prompt()
        .context("Couldn't collect package name")?;

    let mut sp =
        Spinner::new(Spinners::Dots, "Fetching nixpkgs versions...".into());

    match get_nixpkgs_versions().await {
        Ok(nixpkgs_versions) => {
            sp.stop_and_persist(
                "\x1b[32m✔\x1b[0m",
                "Succesfully retrieved nixpkgs versions".into(),
            );

            let matcher = SkimMatcherV2::default();

            let nixpkgs_version: String = Select::new(
                "Which nixpkgs version would you like to use?",
                nixpkgs_versions,
            )
            .with_filter(&|input, _, value, _| {
                matcher.fuzzy_match(value, input).is_some()
            })
            .prompt()
            .context("Couldn't collect nixpkgs version")?;

            Ok(BasicData {
                package_name,
                nixpkgs_version,
            })
        },
        Err(e) => {
            sp.stop_and_persist(
                "\x1b[31m✘\x1b[0m",
                "Failed to retrieve nixpkgs versions, perhaps try again".into(),
            );
            Err(e)
        },
    }
}
