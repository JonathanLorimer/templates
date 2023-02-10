use anyhow::anyhow;
use serde_json::Value;

pub(crate) const NIXPKGS_VERSION_ADDRESS: &str =
    r"https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision";

pub async fn get_nixpkgs_versions() -> Result<Vec<String>, anyhow::Error> {
    let res: Value = reqwest::get(NIXPKGS_VERSION_ADDRESS)
        .await?
        .json::<Value>()
        .await?
        .clone();
    let versions: Vec<String> = res["data"]["result"]
        .as_array()
        .ok_or_else(|| anyhow!("Expected result to be an array"))?
        .into_iter()
        .filter_map(|val| val["metric"]["channel"].as_str())
        .map(|str| str.trim().to_string())
        .collect();
    Ok(versions)
}
