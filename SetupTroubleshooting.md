## 🤔 Troubleshooting Container errors

Starting from version v0.16.0, our entrypoint script is now POSIX-complaint and while I was at it, I added more sanity checks. If you're here, you probably ran into an issue with it so uh... hopefully this provides some guidance

## 🧤 Environmental Variables - CADDY_ENVIRONMENT


- **Your CADDY_ENVIRONMENT environmental variable is invalid!**

In order to run the image, you need to choose between two environments. Each one of them does something a bit different than the other one, mainly:

`TEST` will run Caddy in background and listen actively to any config changes

`PROD` will run Caddy but won't listen to any config changes

To choose your environment, pass CADDY_ENVIRONMENT with the environment type you want to use ex. `CADDY_ENVIRONMENT=PROD`. 

> [!WARNING]
> According to Caddy docs, it is NOT recommended to have config watching in production. You should either use `caddy reload` or restart your container. To use `caddy reload`, admin endpoint needs to be **on**.

## 🏗️ Environmental Variables - ADAPTER_TYPE

- **Potentially invalid ADAPTER_TYPE value**

If you're using a config adapter that's not one of the following: caddyfile, json, yaml in your custom-built image, then you can discard this error.

However if you're using our Caddy image, it means that your `ADAPTER_TYPE` environmental variable is set **wrong**. Please make sure it's one of the supported values which is `caddyfile`, `json` or `yaml`! 

> [!WARNING]
> Please keep in mind while yaml is an option, it **isn't** supported and we probably are missing a module for it either way so it might just not work.

## ✈️ Environmental Variables - CONFIG_PATH

- **Your CONFIG_PATH is empty! It is required to launch the container successfully!**

You **must** specify a path where Caddyfile/caddy.json/caddy.yaml will residue inside the container. This can be _anything_ as long as the file exists in this path.
> [!WARNING]
> Remember to mount a volume pointing to your local Caddyfile/caddy.json, otherwise you will get file not found error! By default it is recommended to mount your own config to `/app/configs/Caddyfile`
