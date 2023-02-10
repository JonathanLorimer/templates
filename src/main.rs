// use inquire::ui::RenderConfig;
// use inquire::CustomUserError;
use inquire::Select;
use inquire::Text;
use spinners::Spinner;
use spinners::Spinners;
use strum::Display;
use strum::EnumIter;
use strum::EnumString;
use strum::IntoEnumIterator;

#[derive(EnumIter, Display, EnumString)]
enum Templates {
    Haskell,
    Rust,
    Idris,
    Agda,
}

#[tokio::main]
async fn main() {
    let template: Templates = Select::new(
        "Which template would you like to use?",
        Templates::iter()
            .map(|template| template.to_string())
            .collect(),
    )
    .prompt()
    .unwrap()
    .parse()
    .unwrap();

    let package_name: String = Text::new("What should this package be called?")
        .prompt()
        .unwrap();

    let mut sp = Spinner::new(Spinners::Dots, "Fetching nixpkgs versions...".into());
    let nixpkgs_versions = template_picker::nixpkgs_version::get_nixpkgs_versions()
        .await
        .unwrap();
    sp.stop_and_persist(
        "\x1b[32m✔\x1b[0m",
        "Succesfully retrieved nixpkgs versions".into(),
    );

    let nixpkgs_version: String = Select::new(
        "Which nixpkgs version would you like to use?",
        nixpkgs_versions,
    )
    .prompt()
    .unwrap();

    println!(
        r"
        Template: {}
        Package Name: {}
        Nixpkgs Version: {}
        ",
        template, package_name, nixpkgs_version
    );

    // let _input = Text {
    //     message: "How are you feeling?",
    //     initial_value: None,
    //     default: None,
    //     placeholder: Some("Good"),
    //     help_message: None,
    //     formatter: Text::DEFAULT_FORMATTER,
    //     validators: Vec::new(),
    //     page_size: Text::DEFAULT_PAGE_SIZE,
    //     autocompleter: None,
    //     render_config: RenderConfig::default(),
    // }
    // .prompt()
    // .unwrap();
}
