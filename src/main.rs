use std::{borrow::Cow, collections::HashMap};

use tide::{http::mime, Request, Response};
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

	app.at("/riot/privacy").get(|_| async { Ok(Response::builder(200).content_type(mime::HTML).body(r#"

	<h3> Privacy Policy </h3>

	This application collects data from custom games and accounts that are made available by the RIOT API. To get said data we also store RIOT API tokens which give access to them.

	This data is used to provide information about custom games or accounts through the discord bot commands.

	All data is stored in a database where sensitive information (like API tokens) is encrypted.

	"#)) });

	app.at("/riot/tos").get(|_| async { Ok(Response::builder(200).content_type(mime::HTML).body(r#"
	
	<h3> Terms of Use </h3>

	Please don't spam commands.

	Checkout privacy policy <a href="/riot/tos">here</a>.

	"#)) });

    app.at("/riot/oauth").get(oauth);

	app.at("/riot/logout").get(|_| async { Ok(Response::builder(200).content_type(mime::HTML).body("You have logged out.")) });

    app.listen(
        TlsListener::build()
            .addrs(format!("0.0.0.0:{}", config.tls.port))
            .cert(config.tls.cert)
            .key(config.tls.key),
        ).await?;
    Ok(())
}

async fn oauth(req: Request<()>) -> tide::Result {
	let params = url_params(&req);
	if params.contains_key("code") {
		Ok(Response::builder(200).content_type(mime::HTML).body(format!("Your code is '{}'", params["code"])).build())
	} else {
		Ok(Response::builder(400).body(format!("No code specified")).build())
	}
}

fn url_params(req: &Request<()>) -> HashMap<Cow<'_, str>, Cow<'_, str>> {
	let mut map = HashMap::new();
	for (name, value) in req.url().query_pairs() {
		map.insert(name, value);
	}
	map
}
