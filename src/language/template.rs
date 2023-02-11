use strum::Display;
use strum::EnumIter;
use strum::EnumString;

#[derive(EnumIter, Display, EnumString)]
pub enum Template {
    Haskell,
    Rust,
    Idris,
    Agda,
}

pub struct BasicData {
    pub package_name: String,
    pub nixpkgs_version: String,
}

pub enum TemplateData {
    Haskell { ghc_version: String },
    Rust,
    Idris,
    Agda,
}
