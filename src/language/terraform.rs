use crate::language::replacer;
use crate::language::template::BasicData;
use crate::language::template::NIXPKGS_REPLACEMENT_TEXT;
use crate::language::template::PACKAGE_NAME_REPLACEMENT_TEXT;
use crate::language::template::TEMPLATE_REPO;

pub(crate) async fn create_terraform_template(
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
        .arg(format!("{}#{}", TEMPLATE_REPO, "terraform"))
        .spawn()?
        .wait()
        .await?;

    let (res1, res2) = tokio::join!(
        replacer::replace_many(
            "./flake.nix",
            vec![
                (PACKAGE_NAME_REPLACEMENT_TEXT, &package_name),
                (NIXPKGS_REPLACEMENT_TEXT, &nixpkgs_version),
            ],
        ),
        replacer::replace(
            "./nix/flake/devshells.nix",
            PACKAGE_NAME_REPLACEMENT_TEXT,
            &package_name,
        ),
    );

    res1?;
    res2?;

    println!(
        r"
        Template: Terraform
        Package Name: {package_name}
        Nixpkgs Version: {nixpkgs_version}
        "
    );

    Ok(())
}
