use tokio::fs::OpenOptions;
use tokio::io::AsyncWriteExt;

pub async fn replace(
    path: &str,
    from: &str,
    to: &str,
) -> Result<(), anyhow::Error> {
    let contents = tokio::fs::read_to_string(path).await?;
    let new = contents.replace(from, to);
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(path)
        .await?;

    file.write_all(new.as_bytes()).await?;
    Ok(())
}

pub async fn replace_many(
    path: &str,
    replacements: Vec<(&str, &str)>,
) -> Result<(), anyhow::Error> {
    let contents = tokio::fs::read_to_string(path).await?;
    let new = replacements
        .into_iter()
        .fold(contents, |c, (from, to)| c.replace(from, to));
    // contents.replace(from, to);
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(path)
        .await?;

    file.write_all(new.as_bytes()).await?;
    Ok(())
}
