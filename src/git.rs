pub async fn init_git() -> Result<(), anyhow::Error> {
    let is_in_git_tree = tokio::process::Command::new("git")
        .arg("rev-parse")
        .arg("--is-inside-work-tree")
        .output()
        .await;

    if is_in_git_tree.is_err() {
        tokio::process::Command::new("git")
            .arg("init")
            .spawn()?
            .wait()
            .await?;
        tokio::process::Command::new("git")
            .arg("add")
            .arg(".")
            .spawn()?
            .wait()
            .await?;
        tokio::process::Command::new("git")
            .arg("branch")
            .arg("-m")
            .arg("main")
            .spawn()?
            .wait()
            .await?;
    }

    Ok(())
}
