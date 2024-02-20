use tide_rustls::TlsListener;
use serde::{Deserialize, Serialize};

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct TLSConfig {
	port: usize,
	cert: String,
	key: String,
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct Config {
	tls: TLSConfig,
}


#[async_std::main]
async fn main() -> tide::Result<()> {
	let default_config = Config {
		tls: TLSConfig { port: 443, cert: "./tls/public.key.pem".to_string(), key: "./tls/private.key.pem".to_string() }
	};

	let config: Config = match std::fs::read_to_string("config.yaml") {
		Ok(s) => serde_yaml::from_str(&s)?,
		Err(_) => default_config,
	};

    let mut app = tide::new();
    app.at("/").get(|_| async { Ok("Hello TLS") });
    app.listen(
        TlsListener::build()
            .addrs(format!("0.0.0.0:{}", config.tls.port))
            .cert(config.tls.cert)
            .key(config.tls.key),
        ).await?;
    Ok(())
}
