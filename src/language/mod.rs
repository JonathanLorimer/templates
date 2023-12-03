pub mod agda;
pub mod haskell;
pub mod terraform;
pub mod replacer;
pub mod rust;
pub mod template;

use self::terraform::create_terraform_template;
use self::agda::create_agda_template;
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
        Template::Agda => Ok(TemplateData::Agda),
        Template::Terraform => Ok(TemplateData::Terraform),
    }
}

pub async fn discharge_template_data(
    basic_data: BasicData,
    template_data: TemplateData,
) -> Result<(), anyhow::Error> {
    match template_data {
        TemplateData::Haskell {
            ghc_version,
            language_extensions,
        } => {
            create_haskell_template(
                basic_data,
                &ghc_version,
                language_extensions,
            )
            .await
        },
        TemplateData::Rust => create_rust_template(basic_data).await,
        TemplateData::Agda => create_agda_template(basic_data).await,
        TemplateData::Terraform => create_terraform_template(basic_data).await,
    }
}
