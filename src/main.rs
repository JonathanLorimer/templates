// use inquire::ui::RenderConfig;
// use inquire::CustomUserError;
use inquire::Select;
use strum::IntoEnumIterator;
use template_picker::basic_data::collect_basic_data;
use template_picker::git::init_git;
use template_picker::language::collect_template_data;
use template_picker::language::discharge_template_data;
use template_picker::language::template::BasicData;
use template_picker::language::template::Template;
use template_picker::language::template::TemplateData;

#[tokio::main]
async fn main() {
    let template: Template = Select::new(
        "Which template would you like to use?",
        Template::iter()
            .map(|template| template.to_string())
            .collect(),
    )
    .prompt()
    .unwrap()
    .parse()
    .unwrap();

    let basic_data: BasicData = collect_basic_data().await.unwrap();

    let template_data: TemplateData =
        collect_template_data(template, &basic_data).await.unwrap();

    discharge_template_data(basic_data, template_data)
        .await
        .unwrap();

    init_git().await.unwrap();
}
