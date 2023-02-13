pub mod haskell;
pub mod replacer;
pub mod rust;
pub mod template;

use self::haskell::get_haskell_data;
use self::rust::create_rust_template;
use self::template::BasicData;
use self::template::Template;
use self::template::TemplateData;
use crate::language::haskell::create_haskell_template;

pub async fn collect_template_data(
    template: Template,
    basic_data: &BasicData,
) -> Result<TemplateData, anyhow::Error> {
    match template {
        Template::Haskell => {
            get_haskell_data(&basic_data.nixpkgs_version).await
        },
        Template::Rust => Ok(TemplateData::Rust),
        Template::Idris => Ok(TemplateData::Idris),
        Template::Agda => Ok(TemplateData::Agda),
    }
}

pub async fn discharge_template_data(
    basic_data: BasicData,
    template_data: TemplateData,
) -> Result<(), anyhow::Error> {
    match template_data {
        TemplateData::Haskell { ghc_version } => {
            create_haskell_template(basic_data, &ghc_version).await
        },
        TemplateData::Rust => create_rust_template(basic_data).await,
        TemplateData::Idris | TemplateData::Agda => Ok(()),
    }
}
