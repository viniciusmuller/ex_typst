use std::{fs, path::Path};

#[rustler::nif]
fn compile<'a>(markup: String) -> Result<String, String> {
    // TODO: add a function into typst that just receives an string and returns an `Vec<u8>` or
    // `Document` instead of doing this
    let tmp_dir = std::env::temp_dir();
    let tmp_file_path = Path::new(&tmp_dir).join("tmp-typst-markup.typst");

    if let Err(e) = fs::write(&tmp_file_path, &markup) {
        return Err(e.to_string());
    }

    // let result = Command::new("typst"
    //               .arg("compile")
    //               .arg(&tmp_file_path);
    //               // .status()
    //               // .unwrap();

    // if !result.status().unwrap().success() {
    //     // TODO: return error message

    //     return Err("failed to run the typst command".into());
    // }

    // let pdf = fs::read(tmp_file_path).unwrap();
    // Ok(String::from_utf8(pdf).unwrap())
  
    Ok("typst cannot be called programatically yet".into())
}

rustler::init!("Elixir.ExTypst.NIF", [compile]);
