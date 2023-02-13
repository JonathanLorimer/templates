pub mod lib {
    use std::io;
    use std::io::Write;

    pub fn print_hello_world() {
        let _ = io::stdout().write_all(b"Hello, world!\n");
    }
}
