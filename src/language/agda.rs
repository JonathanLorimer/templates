use crate::language::replacer;
use crate::language::template::BasicData;
use crate::language::template::PACKAGE_NAME_REPLACEMENT_TEXT;
use crate::language::template::TEMPLATE_REPO;

pub(crate) async fn create_agda_template(
    basic_data: BasicData,
) -> Result<(), anyhow::Error> {
    let BasicData {
        package_name,
        nixpkgs_version,
    } = basic_data;

    tokio::process::Command::new("nix")
        .arg("flake")
        .arg("init")
        .arg("-t")
        .arg(format!("{}#{}", TEMPLATE_REPO, "agda"))
        .spawn()?
        .wait()
        .await?;

    let (res1, res2) = tokio::join!(
        replacer::replace(
            "./flake.nix",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        ),
        replacer::replace(
            "./template.agda-lib",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        )
    );

    res1?;
    res2?;

    tokio::fs::rename(
        "./template.agda-lib",
        format!("./{package_name}.agda-lib"),
    )
    .await?;

    println!(
        r"
        Template: Haskell
        Package Name: {package_name}
        Nixpkgs Version: {nixpkgs_version}
        "
    );

    Ok(())
}
