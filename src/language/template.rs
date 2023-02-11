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
    Idris,
    Agda,
}

pub enum TemplateData {
    Haskell { ghc_version: String },
    Rust,
    Idris,
    Agda,
}

pub const TEMPLATE_REPO: &str = r"github:JonathanLorimer/templates";
