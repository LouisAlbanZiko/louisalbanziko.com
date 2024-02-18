use tide_rustls::TlsListener;

#[async_std::main]
async fn main() -> tide::Result<()> {
    let mut app = tide::new();
    app.at("/").get(|_| async { Ok("Hello TLS") });
    app.listen(
        TlsListener::build()
            .addrs("0.0.0.0:443")
            .cert("./tls/certificate.crt")
            .key("./tls/privatekey.key"),
        ).await?;
    Ok(())
}
