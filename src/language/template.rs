use strum::Display;
use strum::EnumIter;
use strum::EnumString;

pub const PACKAGE_NAME_REPLACEMENT_TEXT: &str = "__package_name";
pub const NIXPKGS_REPLACEMENT_TEXT: &str = "__nixpkgs";

pub struct BasicData {
    pub package_name: String,
    pub nixpkgs_version: String,
}

#[derive(EnumIter, Display, EnumString)]
pub enum Template {
    Haskell,
    Rust,
    Agda,
}

pub enum TemplateData {
    Haskell {
        ghc_version: String,
        language_extensions: Vec<String>,
    },
    Rust,
    Agda,
}

pub const TEMPLATE_REPO: &str = match option_env!("TEMPLATES_DEVELOPMENT_PATH") {
    Some(v) => v,
    None => r"github:JonathanLorimer/templates"
};
