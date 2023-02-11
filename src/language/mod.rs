pub mod haskell;
pub mod template;

use self::haskell::get_haskell_data;
use self::template::BasicData;
use self::template::Template;
use self::template::TemplateData;

pub async fn collect_template_data(
  template: Template,
  basic_data: &BasicData,
) -> Result<TemplateData, anyhow::Error> {
  match template {
    Template::Haskell => get_haskell_data(&basic_data.nixpkgs_version).await,
    Template::Rust => Ok(TemplateData::Rust),
    Template::Idris => Ok(TemplateData::Idris),
    Template::Agda => Ok(TemplateData::Agda),
  }
}

pub async fn discharge_template_data(
  basic_data: BasicData,
  template_data: TemplateData,
) {
  match template_data {
    TemplateData::Haskell { ghc_version } => {
      println!(
        r"
                Template: Haskell
                Package Name: {}
                Nixpkgs Version: {}
                GHC Version: {}
                ",
        basic_data.package_name, basic_data.nixpkgs_version, ghc_version
      );
    },
    TemplateData::Rust => todo!(),
    TemplateData::Idris => todo!(),
    TemplateData::Agda => todo!(),
  }
}
